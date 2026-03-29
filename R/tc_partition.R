#' Partition trajectories using MDL-based approximation
#'
#' Applies the approximate trajectory partitioning algorithm (Paper Figure 8)
#' to identify characteristic points in each trajectory, then connects them
#' into line segments. The MDL (Minimum Description Length) principle balances
#' compression (fewer segments) against fidelity (preserving trajectory shape).
#'
#' @param x A `tc_trajectories` object created by [tc_trajectories()].
#' @param verbose Logical; if `TRUE` (default), prints an informative summary
#'   after partitioning.
#'
#' @return A `tc_partitions` S3 object (list) with elements:
#' \describe{
#'   \item{segments}{`data.frame` with columns `traj_id` (character),
#'     `seg_id` (integer), `sx`, `sy`, `ex`, `ey` (numeric).}
#'   \item{trajectories}{Reference to the input `tc_trajectories` object.}
#'   \item{n_segments}{Integer total number of segments.}
#'   \item{coord_type}{Coordinate type inherited from input.}
#'   \item{method}{Distance method inherited from input.}
#' }
#'
#' @details
#' The partitioning uses only perpendicular and angle distance in the MDL
#' cost function, as described in the original paper (Formulas 6 and 7).
#' The weighting parameters `w_perp`, `w_par`, `w_angle` have no influence
#' on partitioning — they only affect the clustering step.
#'
#' Consistent with Paper Section 4.1.3, a small additive bias is applied to
#' the no-partition cost to suppress over-partitioning. This produces longer
#' segments that generally improve clustering quality.
#'
#' Zero-length segments (from numerical rounding or very dense GPS points)
#' are removed with a warning. If no segments remain after partitioning, an
#' error is thrown.
#'
#' @family workflow functions
#' @export
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
#'                        x = "x", y = "y", coord_type = "euclidean")
#' parts <- tc_partition(trj)
#' print(parts)
tc_partition <- function(x, verbose = TRUE) {
  # --- Class check ---
  .check_class(x, "tc_trajectories", "tc_trajectories")

  # --- Resolve method code for C++ ---
  # "projected" uses euclidean C++ on projected coordinates
  is_projected <- (x$method == "projected")
  method_code <- if (x$method == "haversine") 1L else 0L

  # --- Project coordinates if needed ---
  if (is_projected) {
    proj <- .equirectangular_proj(x$data$x, x$data$y,
                                  x$proj_params$lat_mean)
    x_in <- proj$x
    y_in <- proj$y
  } else {
    x_in <- x$data$x
    y_in <- x$data$y
  }

  # --- Call C++ partitioning ---
  result <- .cpp_partition_all(
    traj_ids = x$data$traj_id,
    x_coords = x_in,
    y_coords = y_in,
    method = method_code
  )

  # --- Inverse-project segment endpoints back to lon/lat ---
  if (is_projected) {
    inv_s <- .equirectangular_inverse(result$sx, result$sy,
                                       x$proj_params$lat_mean)
    inv_e <- .equirectangular_inverse(result$ex, result$ey,
                                       x$proj_params$lat_mean)
    result$sx <- inv_s$lon
    result$sy <- inv_s$lat
    result$ex <- inv_e$lon
    result$ey <- inv_e$lat
  }

  # --- Build segments data.frame ---
  segments <- data.frame(
    traj_id = result$traj_id,
    seg_id = result$seg_id,
    sx = result$sx,
    sy = result$sy,
    ex = result$ex,
    ey = result$ey,
    stringsAsFactors = FALSE
  )

  # --- Warn about null segments removed in C++ ---
  n_null_removed <- result$n_null_removed
  if (n_null_removed > 0L) {
    warning(sprintf("Removed %d zero-length segment(s) after partitioning.",
                    n_null_removed), call. = FALSE)
  }

  n_input_trajs <- x$n_trajectories
  n_output_trajs <- length(unique(segments$traj_id))

  if (nrow(segments) == 0) {
    # All segments were null — catastrophic
    stop("No segments remain after partitioning. ",
         "All trajectory segments have zero or near-zero length.",
         call. = FALSE)
  }

  if (n_output_trajs < n_input_trajs) {
    lost_ids <- setdiff(unique(x$data$traj_id), unique(segments$traj_id))
    id_msg <- .truncate_ids(lost_ids, max_show = 5)
    warning(sprintf(
      "Removed all segments from %d trajectory(ies) (zero-length): %s",
      length(lost_ids), id_msg
    ), call. = FALSE)
  }

  # --- Construct S3 object ---
  obj <- .new_tc_partitions(
    segments = segments,
    trajectories = x,
    coord_type = x$coord_type,
    method = x$method
  )

  if (verbose) {
    message(sprintf("Partitioned %d trajectories into %d line segments.",
                    n_input_trajs, obj$n_segments))
  }

  obj
}


# ============================================================================
# S3 constructor
# ============================================================================

#' Construct a tc_partitions object
#'
#' Low-level constructor that assembles the S3 list. No validation is
#' performed — use [tc_partition()] for the validated public API.
#'
#' @param segments data.frame with columns traj_id, seg_id, sx, sy, ex, ey.
#' @param trajectories The source tc_trajectories object.
#' @param coord_type Character: "euclidean" or "geographic".
#' @param method Character: "euclidean" or "haversine".
#' @return A tc_partitions S3 object.
#' @keywords internal
.new_tc_partitions <- function(segments, trajectories, coord_type, method) {
  structure(
    list(
      segments = segments,
      trajectories = trajectories,
      n_segments = nrow(segments),
      coord_type = coord_type,
      method = method
    ),
    class = "tc_partitions"
  )
}
