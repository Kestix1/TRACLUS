#' Plot TRACLUS objects
#'
#' Convenience wrapper around the S3 `plot()` methods for TRACLUS objects.
#' Equivalent to calling `plot(x, ...)` directly, but discoverable via
#' `?tc_plot` and RStudio's F1 help.
#'
#' All plot methods use the viridis colour palette (via
#' [viridisLite::viridis()]) for colourblind-safe display and accept `...`
#' for standard plot parameters (`main`, `xlim`, `ylim`, `cex`, etc.).
#'
#' @param x A TRACLUS workflow object (`tc_trajectories`, `tc_partitions`,
#'   `tc_clusters`, `tc_representatives`, or `tc_traclus`).
#' @param show_clusters Logical; passed to [plot.tc_representatives()] when
#'   `x` is a `tc_representatives` or `tc_traclus` object. If `FALSE`
#'   (default), cluster member segments are drawn in grey and only the
#'   representative lines appear in colour. If `TRUE`, cluster segments are
#'   drawn in full colour with representatives overlaid.
#' @param show_points Logical; passed to [plot.tc_partitions()] when `x` is a
#'   `tc_partitions` object. If `TRUE` (default), characteristic points are
#'   drawn as black X markers.
#' @param ... Additional arguments passed to [plot()] / [segments()].
#'   Use to override default parameters like `main`, `xlim`, `ylim`.
#'
#' @return `x`, invisibly.
#'
#' @details
#' This function calls `plot(x, ...)` with S3 dispatch based on the class of
#' `x`. Use `tc_plot()` when you want RStudio help lookup (F1) to work, or
#' `plot()` for standard R syntax — both produce identical results.
#'
#' @seealso [tc_leaflet()] for interactive Leaflet maps (geographic data
#'   only).
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
#'                        x = "x", y = "y", coord_type = "euclidean")
#' tc_plot(trj)  # same as plot(trj)
#'
#' @family workflow functions
#' @export
tc_plot <- function(x, show_clusters = FALSE, show_points = TRUE, ...) {
  if (inherits(x, c("tc_representatives", "tc_traclus"))) {
    plot(x, show_clusters = show_clusters, ...)
  } else if (inherits(x, "tc_partitions")) {
    plot(x, show_points = show_points, ...)
  } else {
    plot(x, ...)
  }
}


#' Plot methods for TRACLUS objects
#'
#' Base R visualizations for each stage of the TRACLUS workflow.
#' All methods use the viridis colour palette (via [viridisLite::viridis()])
#' for colourblind-safe display and accept `...` for standard plot
#' parameters (`main`, `xlim`, `ylim`, `cex`, etc.).
#'
#' @param x A TRACLUS workflow object.
#' @param ... Additional arguments passed to [plot()] or [segments()].
#'   Use to override default parameters like `main`, `xlim`, `ylim`.
#'
#' @return `x`, invisibly.
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
#'                        x = "x", y = "y", coord_type = "euclidean")
#' plot(trj)
#'
#' @name plot.TRACLUS
#' @family workflow functions
NULL


# ============================================================================
# Internal helpers
# ============================================================================

# Compute aspect ratio: 1 for euclidean, cos-corrected for geographic
.compute_asp <- function(coord_type, y_values) {
  if (coord_type == "geographic") {
    mean_lat <- mean(y_values, na.rm = TRUE)
    1 / cos(mean_lat * pi / 180)
  } else {
    1
  }
}

# Default axis labels: "Longitude"/"Latitude" for geographic, "x"/"y" otherwise
.default_axis_labels <- function(coord_type) {
  if (coord_type == "geographic") {
    list(x = "Longitude", y = "Latitude")
  } else {
    list(x = "x", y = "y")
  }
}

# Merge user ... with defaults, giving user precedence
.merge_plot_args <- function(defaults, user_args) {
  for (nm in names(user_args)) {
    defaults[[nm]] <- user_args[[nm]]
  }
  defaults
}


# ============================================================================
# plot.tc_trajectories
# ============================================================================

#' @rdname plot.TRACLUS
#' @export
plot.tc_trajectories <- function(x, ...) {
  data <- x$data
  user_args <- list(...)

  # Assign colours per trajectory
  traj_ids <- unique(data$traj_id)
  n_trajs <- length(traj_ids)
  cols <- viridisLite::viridis(n_trajs)
  col_map <- stats::setNames(cols, traj_ids)

  # Compute asp unless user overrides
  asp <- if (!is.null(user_args$asp)) user_args$asp else
    .compute_asp(x$coord_type, data$y)

  # Set up plot
  labs <- .default_axis_labels(x$coord_type)
  plot_args <- .merge_plot_args(
    list(
      x = range(data$x), y = range(data$y),
      type = "n", asp = asp,
      xlab = labs$x, ylab = labs$y,
      main = "TRACLUS Trajectories"
    ),
    user_args
  )
  do.call(graphics::plot, plot_args)

  # Draw trajectories with endpoint dots
  for (tid in traj_ids) {
    idx <- data$traj_id == tid
    graphics::lines(data$x[idx], data$y[idx], col = col_map[tid], lwd = 1.5)
    graphics::points(data$x[idx], data$y[idx],
                     col = col_map[tid], pch = 16, cex = 0.6)
  }

  # Legend (suppress for >10 trajectories)
  if (n_trajs <= 10) {
    graphics::legend("bottomright",
                     legend = traj_ids, col = cols,
                     lwd = 1.5, cex = 0.7, bg = "white")
  }

  invisible(x)
}


# ============================================================================
# plot.tc_partitions
# ============================================================================

#' @rdname plot.TRACLUS
#' @param show_points Logical; if `TRUE` (default for `tc_partitions`),
#'   characteristic points are drawn as black X markers.
#' @export
plot.tc_partitions <- function(x, show_points = TRUE, ...) {
  segs <- x$segments
  user_args <- list(...)

  # Colours per trajectory
  traj_ids <- unique(segs$traj_id)
  n_trajs <- length(traj_ids)
  cols <- viridisLite::viridis(n_trajs)
  col_map <- stats::setNames(cols, traj_ids)

  all_x <- c(segs$sx, segs$ex)
  all_y <- c(segs$sy, segs$ey)
  asp <- if (!is.null(user_args$asp)) user_args$asp else
    .compute_asp(x$coord_type, all_y)

  labs <- .default_axis_labels(x$coord_type)
  plot_args <- .merge_plot_args(
    list(
      x = range(all_x), y = range(all_y),
      type = "n", asp = asp,
      xlab = labs$x, ylab = labs$y,
      main = "TRACLUS Partitions"
    ),
    user_args
  )
  do.call(graphics::plot, plot_args)

  # Draw segments coloured by trajectory
  for (tid in traj_ids) {
    idx <- segs$traj_id == tid
    graphics::segments(segs$sx[idx], segs$sy[idx],
                       segs$ex[idx], segs$ey[idx],
                       col = col_map[tid], lwd = 1.5)
  }

  # Characteristic points (start and end of each segment)
  if (show_points) {
    graphics::points(c(segs$sx, segs$ex), c(segs$sy, segs$ey),
                     pch = 4, cex = 0.8, col = "black")
  }

  if (n_trajs <= 10) {
    graphics::legend("bottomright",
                     legend = traj_ids, col = cols,
                     lwd = 1.5, cex = 0.7, bg = "white")
  }

  invisible(x)
}


# ============================================================================
# plot.tc_clusters
# ============================================================================

#' @rdname plot.TRACLUS
#' @export
plot.tc_clusters <- function(x, ...) {
  segs <- x$segments
  user_args <- list(...)

  all_x <- c(segs$sx, segs$ex)
  all_y <- c(segs$sy, segs$ey)
  asp <- if (!is.null(user_args$asp)) user_args$asp else
    .compute_asp(x$coord_type, all_y)

  eps_unit <- if (x$method %in% c("haversine", "projected")) "m" else ""
  default_main <- sprintf("TRACLUS Clustering (eps = %g%s, min_lns = %d)",
                           x$params$eps, eps_unit, x$params$min_lns)

  labs <- .default_axis_labels(x$coord_type)
  plot_args <- .merge_plot_args(
    list(
      x = range(all_x), y = range(all_y),
      type = "n", asp = asp,
      xlab = labs$x, ylab = labs$y,
      main = default_main
    ),
    user_args
  )
  do.call(graphics::plot, plot_args)

  # Draw noise segments first (background)
  noise <- is.na(segs$cluster_id)
  if (any(noise)) {
    graphics::segments(segs$sx[noise], segs$sy[noise],
                       segs$ex[noise], segs$ey[noise],
                       col = "grey80", lty = 2, lwd = 0.8)
  }

  # Draw clustered segments coloured by cluster
  if (x$n_clusters > 0) {
    cluster_ids <- sort(unique(segs$cluster_id[!noise]))
    cols <- viridisLite::viridis(length(cluster_ids))
    col_map <- stats::setNames(cols, as.character(cluster_ids))

    for (cid in cluster_ids) {
      idx <- segs$cluster_id == cid & !is.na(segs$cluster_id)
      graphics::segments(segs$sx[idx], segs$sy[idx],
                         segs$ex[idx], segs$ey[idx],
                         col = col_map[as.character(cid)], lwd = 1.5)
    }

    # Legend
    if (length(cluster_ids) <= 10) {
      leg_labels <- paste("Cluster", cluster_ids)
      leg_cols <- cols
      leg_lty <- rep(1, length(cluster_ids))
      if (any(noise)) {
        leg_labels <- c(leg_labels, "Noise")
        leg_cols <- c(leg_cols, "grey80")
        leg_lty <- c(leg_lty, 2)
      }
      graphics::legend("bottomright",
                       legend = leg_labels,
                       col = leg_cols, lty = leg_lty, lwd = 1.5,
                       cex = 0.7, bg = "white")
    } else {
      message("Legend suppressed (>10 clusters). ",
              "Use summary() to see cluster details.")
    }
  }

  invisible(x)
}


# ============================================================================
# plot.tc_representatives
# ============================================================================

#' @rdname plot.TRACLUS
#' @param show_clusters Logical; if `FALSE` (default), cluster member segments
#'   are drawn in grey and only the representative lines appear in colour.
#'   If `TRUE`, cluster segments are drawn in full colour with representatives
#'   overlaid.
#' @param legend_pos Character; legend position (default `"bottomright"`).
#'   Set to `NA` to suppress the legend.
#' @export
plot.tc_representatives <- function(x, show_clusters = FALSE,
                                     legend_pos = "bottomright", ...) {
  segs <- x$segments
  repr <- x$representatives
  user_args <- list(...)

  all_x <- c(segs$sx, segs$ex)
  all_y <- c(segs$sy, segs$ey)
  if (nrow(repr) > 0) {
    all_x <- c(all_x, repr$rx)
    all_y <- c(all_y, repr$ry)
  }
  asp <- if (!is.null(user_args$asp)) user_args$asp else
    .compute_asp(x$coord_type, all_y)

  labs <- .default_axis_labels(x$coord_type)
  plot_args <- .merge_plot_args(
    list(
      x = range(all_x), y = range(all_y),
      type = "n", asp = asp,
      xlab = labs$x, ylab = labs$y,
      main = "TRACLUS Representatives"
    ),
    user_args
  )
  do.call(graphics::plot, plot_args)

  # --- Noise segments (includes cleanup-degraded segments) ---
  curr_ids <- segs$cluster_id
  noise <- is.na(curr_ids)

  if (any(noise)) {
    graphics::segments(segs$sx[noise], segs$sy[noise],
                       segs$ex[noise], segs$ey[noise],
                       col = "grey80", lty = 2, lwd = 0.8)
  }

  if (x$n_clusters == 0) {
    invisible(x)
    return(invisible(x))
  }

  cluster_ids <- sort(unique(repr$cluster_id))
  n_cl <- length(cluster_ids)

  # Colour consistency: use the same palette as tc_cluster() by generating
  # colours based on the original (pre-cleanup) cluster count, then subsetting.
  orig_ids <- x$clusters$segments$cluster_id
  orig_n_clusters <- x$clusters$n_clusters
  orig_cols <- viridisLite::viridis(orig_n_clusters)
  # Map renumbered representative IDs back to original cluster IDs
  orig_cluster_ids <- sort(unique(
    x$clusters$segments$cluster_id[!is.na(x$clusters$segments$cluster_id)]
  ))
  # Build mapping: for each representative cluster_id, find the original ID
  # by matching renumbered segments back to original
  orig_col_map <- stats::setNames(orig_cols, as.character(orig_cluster_ids))
  # Surviving clusters: find which original IDs survived cleanup
  surviving_orig_ids <- integer(0)
  for (cid in cluster_ids) {
    # Find a segment in this renumbered cluster and look up its original cluster
    seg_idx <- which(segs$cluster_id == cid & !is.na(segs$cluster_id))[1]
    if (!is.na(seg_idx)) {
      orig_cid <- orig_ids[seg_idx]  # orig_ids is x$clusters$segments$cluster_id
      surviving_orig_ids <- c(surviving_orig_ids, orig_cid)
    }
  }
  cols <- unname(orig_col_map[as.character(surviving_orig_ids)])
  col_map <- stats::setNames(cols, as.character(cluster_ids))

  if (!show_clusters) {
    # Active cluster segments: grey background
    clustered <- !is.na(curr_ids)
    if (any(clustered)) {
      graphics::segments(segs$sx[clustered], segs$sy[clustered],
                         segs$ex[clustered], segs$ey[clustered],
                         col = "grey70", lwd = 0.8)
    }
    # Representatives: black outline + colour
    for (cid in cluster_ids) {
      pts <- repr[repr$cluster_id == cid, ]
      # Black outline for visibility
      graphics::lines(pts$rx, pts$ry, col = "black", lwd = 4)
      graphics::lines(pts$rx, pts$ry,
                      col = col_map[as.character(cid)], lwd = 2.5)
    }
  } else {
    # "clusters" mode: segments coloured, representatives in matching colour
    for (cid in cluster_ids) {
      col <- col_map[as.character(cid)]
      idx <- segs$cluster_id == cid & !is.na(segs$cluster_id)
      graphics::segments(segs$sx[idx], segs$sy[idx],
                         segs$ex[idx], segs$ey[idx],
                         col = col, lwd = 1.2)
      pts <- repr[repr$cluster_id == cid, ]
      graphics::lines(pts$rx, pts$ry, col = "black", lwd = 4)
      graphics::lines(pts$rx, pts$ry, col = col, lwd = 2.5)
    }
  }

  # Legend
  show_legend <- !is.na(legend_pos) && n_cl <= 10
  if (show_legend) {
    leg_labels <- paste("Representative", cluster_ids)
    leg_cols <- cols
    leg_lty <- rep(1, n_cl)
    leg_lwd <- rep(2.5, n_cl)
    if (any(noise)) {
      leg_labels <- c(leg_labels, "Noise")
      leg_cols <- c(leg_cols, "grey80")
      leg_lty <- c(leg_lty, 2)
      leg_lwd <- c(leg_lwd, 0.8)
    }
    graphics::legend(legend_pos,
                     legend = leg_labels, col = leg_cols,
                     lty = leg_lty, lwd = leg_lwd,
                     cex = 0.7, bg = "white")
  } else if (n_cl > 10 && !is.na(legend_pos)) {
    message("Legend suppressed (>10 clusters). ",
            "Use summary() to see cluster details.")
  }

  invisible(x)
}


# ============================================================================
# plot.tc_traclus
# ============================================================================

#' @rdname plot.TRACLUS
#' @export
plot.tc_traclus <- function(x, ...) {
  NextMethod()
}


# ============================================================================
# plot.tc_estimate — entropy plot
# ============================================================================

#' Plot method for tc_estimate objects
#'
#' Displays the entropy curve across the eps grid with the optimal
#' value marked by a red circle.
#'
#' @param x A `tc_estimate` object from [tc_estimate_params()].
#' @param ... Additional arguments passed to [plot()].
#' @return `x`, invisibly.
#'
#' @examples
#' \donttest{
#' trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
#'                        x = "x", y = "y", coord_type = "euclidean")
#' parts <- tc_partition(trj)
#' est <- tc_estimate_params(parts)
#' plot(est)
#' }
#' @export
plot.tc_estimate <- function(x, ...) {
  df <- x$entropy_df
  user_args <- list(...)

  plot_args <- .merge_plot_args(
    list(
      x = df$eps, y = df$entropy,
      type = "l", lwd = 1.5,
      xlab = "eps", ylab = "Entropy",
      main = "Parameter Estimation: Entropy vs. eps"
    ),
    user_args
  )
  do.call(graphics::plot, plot_args)

  # Mark optimal point with red circle
  graphics::points(x$eps, min(df$entropy), col = "red", pch = 1,
                   cex = 2, lwd = 2)
  graphics::text(x$eps, min(df$entropy),
                 labels = sprintf("eps = %.4g", x$eps),
                 pos = 4, col = "red", cex = 0.8)

  invisible(x)
}
