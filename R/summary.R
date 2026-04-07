#' Summary methods for TRACLUS objects
#'
#' Detailed summaries of TRACLUS workflow objects, printed via [cat()].
#' All methods return the object invisibly.
#'
#' @param object A TRACLUS object.
#' @param ... Further arguments (ignored).
#'
#' @return `object`, invisibly.
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy,
#'   traj_id = "traj_id",
#'   x = "x", y = "y", coord_type = "euclidean"
#' )
#' summary(trj)
#'
#' @name summary.TRACLUS
#' @family workflow functions
NULL

#' @rdname summary.TRACLUS
#' @export
summary.tc_trajectories <- function(object, ...) {
  pts_per_traj <- table(object$data$traj_id)

  cat("TRACLUS Trajectories - Summary\n")
  cat(sprintf("  Trajectories:       %d\n", object$n_trajectories))
  cat(sprintf("  Total points:       %d\n", object$n_points))
  cat(sprintf(
    "  Points per traj:    min = %d, median = %.0f, max = %d\n",
    min(pts_per_traj), stats::median(as.integer(pts_per_traj)),
    max(pts_per_traj)
  ))
  cat(sprintf("  Coord type:         %s\n", object$coord_type))
  cat(sprintf("  Method:             %s\n", object$method))
  invisible(object)
}

#' @rdname summary.TRACLUS
#' @export
summary.tc_partitions <- function(object, ...) {
  segs_per_traj <- table(object$segments$traj_id)

  # Compute segment lengths
  if (object$method == "euclidean") {
    seg_lens <- sqrt(
      (object$segments$ex - object$segments$sx)^2 +
        (object$segments$ey - object$segments$sy)^2
    )
  } else if (object$method == "projected") {
    # Project to meters, then euclidean length
    proj_params <- object$trajectories$proj_params
    proj_s <- .equirectangular_proj(
      object$segments$sx, object$segments$sy,
      proj_params$lat_mean
    )
    proj_e <- .equirectangular_proj(
      object$segments$ex, object$segments$ey,
      proj_params$lat_mean
    )
    seg_lens <- sqrt((proj_e$x - proj_s$x)^2 + (proj_e$y - proj_s$y)^2)
  } else {
    # Haversine lengths — use the R reference implementation
    seg_lens <- mapply(
      function(sx, sy, ex, ey) {
        .r_haversine(c(sx, sy), c(ex, ey))
      },
      object$segments$sx, object$segments$sy,
      object$segments$ex, object$segments$ey
    )
  }

  unit_label <- if (object$method %in% c("haversine", "projected")) " (meters)" else ""

  cat("TRACLUS Partitions - Summary\n")
  cat(sprintf("  Trajectories:       %d\n", length(segs_per_traj)))
  cat(sprintf("  Total segments:     %d\n", object$n_segments))
  cat(sprintf(
    "  Segs per traj:      min = %d, median = %.0f, max = %d\n",
    min(segs_per_traj),
    stats::median(as.integer(segs_per_traj)),
    max(segs_per_traj)
  ))
  cat(sprintf(
    "  Segment lengths%s:  min = %.2f, median = %.2f, max = %.2f\n",
    unit_label,
    min(seg_lens), stats::median(seg_lens), max(seg_lens)
  ))
  cat(sprintf("  Coord type:         %s\n", object$coord_type))
  cat(sprintf("  Method:             %s\n", object$method))
  invisible(object)
}

#' @rdname summary.TRACLUS
#' @export
summary.tc_clusters <- function(object, ...) {
  eps_unit <- if (object$method %in% c("haversine", "projected")) " (meters)" else " (coordinate units)"
  total_segs <- nrow(object$segments)
  noise_frac <- if (total_segs > 0) object$n_noise / total_segs * 100 else 0

  cat("TRACLUS Clusters - Summary\n")
  cat(sprintf("  Clusters:           %d\n", object$n_clusters))
  cat(sprintf("  Total segments:     %d\n", total_segs))
  cat(sprintf("  Noise segments:     %d (%.1f%%)\n", object$n_noise, noise_frac))

  if (object$n_clusters > 0L) {
    cs <- object$cluster_summary
    cat(sprintf(
      "  Segs per cluster:   min = %d, median = %.0f, max = %d\n",
      min(cs$n_segments),
      stats::median(cs$n_segments),
      max(cs$n_segments)
    ))
    cat(sprintf(
      "  Trajs per cluster:  min = %d, median = %.0f, max = %d\n",
      min(cs$n_trajectories),
      stats::median(cs$n_trajectories),
      max(cs$n_trajectories)
    ))
  }

  cat(sprintf("  eps:                %.4g%s\n", object$params$eps, eps_unit))
  cat(sprintf("  min_lns:            %d\n", object$params$min_lns))
  cat(sprintf("  Coord type:         %s\n", object$coord_type))
  cat(sprintf("  Method:             %s\n", object$method))
  invisible(object)
}

#' @rdname summary.TRACLUS
#' @export
summary.tc_representatives <- function(object, ...) {
  total_segs <- nrow(object$segments)
  noise_frac <- if (total_segs > 0) object$n_noise / total_segs * 100 else 0

  cat("TRACLUS Representatives - Summary\n")
  cat(sprintf("  Clusters:           %d\n", object$n_clusters))
  cat(sprintf("  Total segments:     %d\n", total_segs))
  cat(sprintf("  Noise segments:     %d (%.1f%%)\n", object$n_noise, noise_frac))

  if (object$n_clusters > 0L) {
    wps <- table(object$representatives$cluster_id)
    cat(sprintf(
      "  WPs per repr:       min = %d, median = %.0f, max = %d\n",
      min(wps), stats::median(as.integer(wps)), max(wps)
    ))

    # Cluster detail statistics from cluster_summary
    cs <- object$clusters$cluster_summary
    if (!is.null(cs) && nrow(cs) > 0L) {
      cat(sprintf(
        "  Segs per cluster:   min = %d, median = %.0f, max = %d\n",
        min(cs$n_segments),
        stats::median(cs$n_segments),
        max(cs$n_segments)
      ))
      cat(sprintf(
        "  Trajs per cluster:  min = %d, median = %.0f, max = %d\n",
        min(cs$n_trajectories),
        stats::median(cs$n_trajectories),
        max(cs$n_trajectories)
      ))
    }

    # Report clusters lost from clustering to representation
    pre_clusters <- object$clusters$n_clusters
    lost <- pre_clusters - object$n_clusters
    if (lost > 0L) {
      cat(sprintf("  Clusters lost:      %d (degraded to noise)\n", lost))
    }
  }

  cat(sprintf("  gamma:              %.4g\n", object$params$gamma))
  cat(sprintf("  min_lns:            %d\n", object$params$min_lns))
  cat(sprintf("  Coord type:         %s\n", object$coord_type))
  cat(sprintf("  Method:             %s\n", object$method))
  invisible(object)
}

#' @rdname summary.TRACLUS
#' @export
summary.tc_traclus <- function(object, ...) {
  total_segs <- nrow(object$segments)
  noise_frac <- if (total_segs > 0) object$n_noise / total_segs * 100 else 0

  cat("TRACLUS Result - Summary\n")
  n_trajs <- object$clusters$partitions$trajectories$n_trajectories
  n_parts <- object$clusters$partitions$n_segments
  cat(sprintf("  Input trajs:        %d\n", n_trajs))
  cat(sprintf("  Partitioned into:   %d segments\n", n_parts))
  cat(sprintf("  Clusters:           %d\n", object$n_clusters))
  cat(sprintf("  Total segments:     %d\n", total_segs))
  cat(sprintf("  Noise segments:     %d (%.1f%%)\n", object$n_noise, noise_frac))

  if (object$n_clusters > 0L) {
    wps <- table(object$representatives$cluster_id)
    cat(sprintf(
      "  WPs per repr:       min = %d, median = %.0f, max = %d\n",
      min(wps), stats::median(as.integer(wps)), max(wps)
    ))

    # Report clusters lost from clustering to representation
    pre_clusters <- object$clusters$n_clusters
    lost <- pre_clusters - object$n_clusters
    if (lost > 0L) {
      cat(sprintf("  Clusters lost:      %d (degraded to noise)\n", lost))
    }
  }

  cl_params <- object$clusters$params
  eps_unit <- if (object$method %in% c("haversine", "projected")) " (meters)" else " (coordinate units)"
  cat(sprintf("  eps:                %.4g%s\n", cl_params$eps, eps_unit))
  cat(sprintf("  min_lns:            %d\n", cl_params$min_lns))
  cat(sprintf("  gamma:              %.4g\n", object$params$gamma))
  cat(sprintf("  Coord type:         %s\n", object$coord_type))
  cat(sprintf("  Method:             %s\n", object$method))
  invisible(object)
}

#' @rdname summary.TRACLUS
#' @export
summary.tc_estimate <- function(object, ...) {
  eps_unit <- if (!is.null(object$method) && object$method %in% c("haversine", "projected")) {
    " (meters)"
  } else {
    " (coordinate units)"
  }
  cat("TRACLUS Parameter Estimate - Summary\n")
  cat(sprintf("  Optimal eps:        %.4g%s\n", object$eps, eps_unit))
  cat(sprintf("  Est. min_lns:       %d\n", object$min_lns))
  cat(sprintf(
    "  Grid range:         %.4g to %.4g (%d points)\n",
    min(object$entropy_df$eps), max(object$entropy_df$eps),
    nrow(object$entropy_df)
  ))
  cat(sprintf("  Min entropy:        %.4f\n", min(object$entropy_df$entropy)))
  if (object$w_perp != 1 || object$w_par != 1 || object$w_angle != 1) {
    cat(sprintf(
      "  Weights:            perp=%.2g, par=%.2g, angle=%.2g\n",
      object$w_perp, object$w_par, object$w_angle
    ))
  }
  invisible(object)
}
