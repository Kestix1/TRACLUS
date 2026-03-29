#' Sweep-line representative trajectory generation
#'
#' Internal functions implementing the sweep-line algorithm from
#' Paper Figure 15. The algorithm computes a representative trajectory
#' for a single cluster by:
#' 1. Computing the average direction vector (Paper Definition 11)
#' 2. Rotating coordinates so X'-axis aligns with average direction
#' 3. Normalizing segments (left_x < right_x)
#' 4. Sweeping through entry/exit events, generating waypoints
#'    where segment density >= min_lns and spacing >= gamma
#' 5. Rotating waypoints back to original coordinate system
#'
#' @name sweep_line
#' @keywords internal
NULL


#' Compute average direction vector for a cluster
#'
#' Sums raw (unnormalized) direction vectors of all segments, then
#' normalizes. Longer segments contribute proportionally more to the
#' cluster direction (Paper Definition 11).
#'
#' @param sx,sy,ex,ey Numeric vectors of segment coordinates.
#' @return Numeric vector of length 2: unit direction vector (dx, dy).
#'   Falls back to c(1, 0) if segments cancel out.
#' @keywords internal
.compute_average_direction <- function(sx, sy, ex, ey) {
  # Sum raw direction vectors — longer segments contribute more
  sum_dx <- sum(ex - sx)
  sum_dy <- sum(ey - sy)
  magnitude <- sqrt(sum_dx^2 + sum_dy^2)

  if (magnitude < 1e-15) {
    # Segments cancel out — fall back to X-axis direction
    warning("Cluster segments cancel out in direction. ",
            "Using X-axis as fallback direction.",
            call. = FALSE)
    return(c(1, 0))
  }

  c(sum_dx / magnitude, sum_dy / magnitude)
}


#' Rotate coordinates so X'-axis aligns with direction vector
#'
#' Applies a 2D rotation matrix to align the given direction vector
#' with the positive X-axis (Paper Formula 9).
#'
#' @param x,y Numeric vectors of coordinates.
#' @param dir_vec Numeric vector of length 2: unit direction vector.
#' @return A list with elements `x` and `y` (rotated coordinates).
#' @keywords internal
.rotate_to_axis <- function(x, y, dir_vec) {
  # Rotation angle: angle between dir_vec and X-axis
  cos_a <- dir_vec[1]
  sin_a <- dir_vec[2]

  # Rotate by -angle to align dir_vec with X-axis
  list(
    x = x * cos_a + y * sin_a,
    y = -x * sin_a + y * cos_a
  )
}


#' Rotate coordinates back from aligned system
#'
#' Inverse of [.rotate_to_axis()]: rotates from the aligned coordinate
#' system back to the original.
#'
#' @param x,y Numeric vectors of rotated coordinates.
#' @param dir_vec Numeric vector of length 2: unit direction vector.
#' @return A list with elements `x` and `y` (original coordinates).
#' @keywords internal
.rotate_from_axis <- function(x, y, dir_vec) {
  cos_a <- dir_vec[1]
  sin_a <- dir_vec[2]

  # Rotate by +angle (transpose of rotation matrix)
  list(
    x = x * cos_a - y * sin_a,
    y = x * sin_a + y * cos_a
  )
}


#' Sweep-line representative trajectory for one cluster
#'
#' Implements the full sweep-line algorithm (Paper Figure 15) for a
#' single cluster of line segments. Returns waypoint coordinates in the
#' original coordinate system.
#'
#' **Deviation from paper:** In addition to the segment density check
#' (`count >= min_lns`), a trajectory diversity check requires at least
#' 2 distinct trajectories among the active segments at each waypoint
#' position. This prevents degenerate representatives from consecutive
#' segments of a single trajectory whose entry-before-exit overlap at
#' shared characteristic points artificially inflates the segment count.
#' See package documentation for details.
#'
#' @param sx,sy,ex,ey Numeric vectors of segment coordinates (already
#'   in the working coordinate system — meters for geographic, raw for
#'   euclidean).
#' @param traj_id Character or integer vector identifying which
#'   trajectory each segment belongs to. Must have the same length as
#'   `sx`. Used for the trajectory diversity check.
#' @param min_lns Minimum number of crossing segments to generate a
#'   waypoint (Paper Figure 15, Line 7).
#' @param gamma Minimum distance between consecutive waypoints.
#' @return A data.frame with columns `rx`, `ry` (waypoint coordinates
#'   in the working coordinate system), or NULL if < 2 waypoints.
#' @keywords internal
.sweep_line_representative <- function(sx, sy, ex, ey, traj_id, min_lns, gamma) {
  n_segs <- length(sx)
  if (n_segs == 0) return(NULL)

  # --- Step 1: Average direction vector ---
  dir_vec <- .compute_average_direction(sx, sy, ex, ey)

  # --- Step 2: Rotate so X'-axis aligns with average direction ---
  rot_s <- .rotate_to_axis(sx, sy, dir_vec)
  rot_e <- .rotate_to_axis(ex, ey, dir_vec)
  rsx <- rot_s$x
  rsy <- rot_s$y
  rex <- rot_e$x
  rey <- rot_e$y

  # --- Step 3: Normalize segments so left_x < right_x ---
  # Segments pointing against the main direction get flipped
  left_x <- pmin(rsx, rex)
  right_x <- pmax(rsx, rex)

  # Corresponding y-values: ensure (left_x, left_y)-(right_x, right_y)
  # preserves the segment's linear equation
  left_y <- ifelse(rsx <= rex, rsy, rey)
  right_y <- ifelse(rsx <= rex, rey, rsy)

  # Filter out zero-length segments in the rotated system
  seg_len <- right_x - left_x
  valid <- seg_len > 1e-15
  if (sum(valid) == 0) return(NULL)

  left_x <- left_x[valid]
  right_x <- right_x[valid]
  left_y <- left_y[valid]
  right_y <- right_y[valid]
  seg_len <- seg_len[valid]
  seg_traj_id <- traj_id[valid]  # trajectory ID per valid segment
  n_valid <- sum(valid)

  # --- Step 4: Create entry/exit events ---
  # Event types: 1 = entry (segment starts), -1 = exit (segment ends)
  event_x <- c(left_x, right_x)
  event_type <- c(rep(1L, n_valid), rep(-1L, n_valid))
  # Track which segment each event belongs to

  event_seg_idx <- c(seq_len(n_valid), seq_len(n_valid))

  # --- Step 5: Sort events ---
  # Primary: by x-position. Tie-break: entry (1) before exit (-1)
  # Using -event_type so that 1 (entry) sorts before -1 (exit) in ascending order
  ord <- order(event_x, -event_type)
  event_x <- event_x[ord]
  event_type <- event_type[ord]
  event_seg_idx <- event_seg_idx[ord]

  # --- Step 6: Sweep through events, generate waypoints ---
  # Paper Figure 15, Lines 5-12: for each point p, count the number of
  # segments that *contain* the X'-value of p (nump). A segment contains
  # its own endpoints, so at an exit point the exiting segment is still
  # counted. We implement this by batching events at the same x-position:
  #   1. Process all entries  (activate segments, increment count)
  #   2. Check for waypoint   (count reflects all containing segments)
  #   3. Process all exits    (deactivate segments, decrement count)
  active <- logical(n_valid)
  count <- 0L
  last_wp_x <- -Inf  # x-position of last generated waypoint

  k <- 1L
  n_events <- length(event_x)

  # Pre-allocate waypoint storage (upper bound: one waypoint per unique x)
  wp_x <- numeric(n_events)
  wp_y <- numeric(n_events)
  wp_count <- 0L

  while (k <= n_events) {
    cur_x <- event_x[k]

    # 1. Process all entry events at this x-position
    j <- k
    while (j <= n_events && event_x[j] == cur_x && event_type[j] == 1L) {
      active[event_seg_idx[j]] <- TRUE
      count <- count + 1L
      j <- j + 1L
    }

    # 2. Paper Figure 15, Lines 7-12: generate waypoint when
    #    density >= min_lns and distance to last waypoint >= gamma.
    #    Deviation from paper: additionally require >= 2 distinct
    #    trajectories among active segments to prevent degenerate
    #    representatives from consecutive same-trajectory segments.
    if (count >= min_lns && (cur_x - last_wp_x) >= gamma) {
      active_idx <- which(active)
      n_distinct_traj <- length(unique(seg_traj_id[active_idx]))
      if (n_distinct_traj < 2L) {
        # Skip waypoint: insufficient trajectory diversity
        # (all active segments from the same trajectory)
      } else {
      t_vals <- (cur_x - left_x[active_idx]) / seg_len[active_idx]
      y_interp <- left_y[active_idx] +
        t_vals * (right_y[active_idx] - left_y[active_idx])
      mean_y <- mean(y_interp)

      wp_count <- wp_count + 1L
      wp_x[wp_count] <- cur_x
      wp_y[wp_count] <- mean_y
      last_wp_x <- cur_x
      } # end else (diversity check passed)
    }

    # 3. Process all exit events at this x-position
    while (j <= n_events && event_x[j] == cur_x) {
      active[event_seg_idx[j]] <- FALSE
      count <- count - 1L
      j <- j + 1L
    }

    k <- j
  }

  if (wp_count < 2L) return(NULL)
  wp_x <- wp_x[seq_len(wp_count)]
  wp_y <- wp_y[seq_len(wp_count)]

  # --- Step 7: Rotate waypoints back to original coordinate system ---
  orig <- .rotate_from_axis(wp_x, wp_y, dir_vec)

  data.frame(rx = orig$x, ry = orig$y)
}
