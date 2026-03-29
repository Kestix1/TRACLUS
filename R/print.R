#' Print methods for TRACLUS objects
#'
#' Compact summaries of TRACLUS workflow objects, printed via [cat()].
#' All methods return the object invisibly for pipe compatibility.
#'
#' @param x A TRACLUS object.
#' @param ... Further arguments (ignored).
#'
#' @return `x`, invisibly.
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
#'                        x = "x", y = "y", coord_type = "euclidean")
#' print(trj)
#'
#' @name print.TRACLUS
#' @family workflow functions
NULL

#' @rdname print.TRACLUS
#' @export
print.tc_trajectories <- function(x, ...) {
  cat("TRACLUS Trajectories\n")
  cat(sprintf("  Trajectories: %d\n", x$n_trajectories))
  cat(sprintf("  Points:       %d\n", x$n_points))
  cat(sprintf("  Coord type:   %s\n", x$coord_type))
  cat(sprintf("  Method:       %s\n", x$method))
  cat("  Status:       loaded (run tc_partition next)\n")
  invisible(x)
}

#' @rdname print.TRACLUS
#' @export
print.tc_partitions <- function(x, ...) {
  segs_per_traj <- table(x$segments$traj_id)
  cat("TRACLUS Partitions\n")
  cat(sprintf("  Trajectories: %d\n", length(segs_per_traj)))
  cat(sprintf("  Segments:     %d\n", x$n_segments))
  cat(sprintf("  Coord type:   %s\n", x$coord_type))
  cat(sprintf("  Method:       %s\n", x$method))
  cat("  Status:       partitioned (run tc_cluster next)\n")
  invisible(x)
}

#' @rdname print.TRACLUS
#' @export
print.tc_clusters <- function(x, ...) {
  eps_unit <- if (x$method %in% c("haversine", "projected")) " (meters)" else " (coordinate units)"
  cat("TRACLUS Clusters\n")
  cat(sprintf("  Clusters:     %d\n", x$n_clusters))
  cat(sprintf("  Noise segs:   %d\n", x$n_noise))
  cat(sprintf("  Total segs:   %d\n", nrow(x$segments)))
  cat(sprintf("  eps:          %.4g%s\n", x$params$eps, eps_unit))
  cat(sprintf("  min_lns:      %d\n", x$params$min_lns))
  if (x$params$w_perp != 1 || x$params$w_par != 1 || x$params$w_angle != 1) {
    cat(sprintf("  Weights:      perp=%.2g, par=%.2g, angle=%.2g\n",
                x$params$w_perp, x$params$w_par, x$params$w_angle))
  }
  cat(sprintf("  Coord type:   %s\n", x$coord_type))
  cat(sprintf("  Method:       %s\n", x$method))
  cat("  Status:       clustered (run tc_represent next)\n")
  if (x$params$min_lns < 3L) {
    cat(sprintf(
      "  Note:         min_lns = %d may produce representatives dominated by\n",
      x$params$min_lns))
    cat("                a single trajectory. Consider min_lns >= 3.\n")
    cat("                See ?tc_represent or vignette('TRACLUS-parameter-guide').\n")
  }
  invisible(x)
}

#' @rdname print.TRACLUS
#' @export
print.tc_representatives <- function(x, ...) {
  cat("TRACLUS Representatives\n")
  cat(sprintf("  Clusters:     %d\n", x$n_clusters))
  cat(sprintf("  Noise segs:   %d\n", x$n_noise))
  if (x$n_clusters > 0) {
    wps <- table(x$representatives$cluster_id)
    cat(sprintf("  Waypoints:    %d total (%.0f per representative)\n",
                nrow(x$representatives),
                stats::median(as.integer(wps))))
  }
  cat(sprintf("  gamma:        %.4g\n", x$params$gamma))
  cat(sprintf("  min_lns:      %d\n", x$params$min_lns))
  cat(sprintf("  Coord type:   %s\n", x$coord_type))
  cat(sprintf("  Method:       %s\n", x$method))
  cat("  Status:       complete\n")
  invisible(x)
}

#' @rdname print.TRACLUS
#' @export
print.tc_traclus <- function(x, ...) {
  cat("TRACLUS Result (all-in-one)\n")
  cat(sprintf("  Clusters:     %d\n", x$n_clusters))
  cat(sprintf("  Noise segs:   %d\n", x$n_noise))
  if (x$n_clusters > 0) {
    wps <- table(x$representatives$cluster_id)
    cat(sprintf("  Waypoints:    %d total (%.0f per representative)\n",
                nrow(x$representatives),
                stats::median(as.integer(wps))))
  }
  # Show clustering params from the reference chain
  cl_params <- x$clusters$params
  eps_unit <- if (x$method %in% c("haversine", "projected")) " (meters)" else " (coordinate units)"
  cat(sprintf("  eps:          %.4g%s\n", cl_params$eps, eps_unit))
  cat(sprintf("  min_lns:      %d\n", cl_params$min_lns))
  cat(sprintf("  gamma:        %.4g\n", x$params$gamma))
  if (cl_params$w_perp != 1 || cl_params$w_par != 1 || cl_params$w_angle != 1) {
    cat(sprintf("  Weights:      perp=%.2g, par=%.2g, angle=%.2g\n",
                cl_params$w_perp, cl_params$w_par, cl_params$w_angle))
  }
  cat(sprintf("  Coord type:   %s\n", x$coord_type))
  cat(sprintf("  Method:       %s\n", x$method))
  cat("  Status:       complete\n")
  invisible(x)
}

#' Print method for tc_estimate objects
#'
#' @param x A `tc_estimate` object from [tc_estimate_params()].
#' @param ... Further arguments (ignored).
#' @return `x`, invisibly.
#'
#' @examples
#' \donttest{
#' trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
#'                        x = "x", y = "y", coord_type = "euclidean")
#' parts <- tc_partition(trj)
#' est <- tc_estimate_params(parts)
#' print(est)
#' }
#' @export
print.tc_estimate <- function(x, ...) {
  eps_unit <- if (!is.null(x$method) && x$method %in% c("haversine", "projected")) {
    " (meters)"
  } else {
    " (coordinate units)"
  }
  cat("TRACLUS Parameter Estimate\n")
  cat(sprintf("  Optimal eps:  %.4g%s\n", x$eps, eps_unit))
  cat(sprintf("  Est. min_lns: %d\n", x$min_lns))
  cat(sprintf("  Grid range:   %.4g to %.4g (%d points)\n",
              min(x$entropy_df$eps), max(x$entropy_df$eps),
              nrow(x$entropy_df)))
  if (x$w_perp != 1 || x$w_par != 1 || x$w_angle != 1) {
    cat(sprintf("  Weights:      perp=%.2g, par=%.2g, angle=%.2g\n",
                x$w_perp, x$w_par, x$w_angle))
  }
  invisible(x)
}
