#' Generate representative trajectories for clusters
#'
#' Computes a representative trajectory for each cluster using the
#' sweep-line algorithm (Paper Figure 15). The representative captures
#' the "average path" of all line segments in the cluster.
#'
#' @param x A `tc_clusters` object created by [tc_cluster()].
#' @param gamma Positive numeric smoothing parameter: minimum distance
#'   between consecutive waypoints (default 1). Unit: meters for
#'   `method = "haversine"` or `"projected"`, coordinate units for
#'   `method = "euclidean"`.
#' @param min_lns Positive integer or `NULL` (default). Minimum number
#'   of crossing segments required to generate a waypoint. If `NULL`,
#'   inherits from `x$params$min_lns` (clustering value). Override for
#'   advanced use.
#' @param verbose Logical; if `TRUE` (default), prints an informative
#'   summary.
#'
#' @return A `tc_representatives` S3 object (list) with elements:
#' \describe{
#'   \item{segments}{`data.frame` — own copy of segment data with updated
#'     `cluster_id` (renumbered, failed clusters degraded to noise).}
#'   \item{representatives}{`data.frame` with columns `cluster_id`
#'     (integer), `point_id` (integer, 1-based), `rx`, `ry` (numeric
#'     waypoint coordinates in original format).}
#'   \item{clusters}{Reference to the input `tc_clusters` object
#'     (unmodified, pre-cleanup IDs for traceability).}
#'   \item{n_clusters}{Integer number of clusters with valid representatives.}
#'   \item{n_noise}{Integer number of noise segments (updated after cleanup).}
#'   \item{params}{List with `min_lns` and `gamma` used for representation.}
#'   \item{coord_type}{Coordinate type inherited from input.}
#'   \item{method}{Distance method inherited from input.}
#' }
#'
#' @details
#' For geographic data (`coord_type = "geographic"`), segment coordinates
#' are locally projected to meters using equirectangular approximation
#' before the sweep-line runs, then transformed back. This ensures
#' gamma operates in meters, consistent with eps.
#'
#' Clusters that produce fewer than 2 waypoints are degraded to noise.
#' The remaining cluster IDs are renumbered (1..K) and the segments
#' data.frame is updated accordingly.
#'
#' **Trajectory diversity check (deviation from paper):** The sweep-line
#' checks segment density (`count >= min_lns`, per Paper Figure 15) AND
#' additionally requires at least 2 distinct trajectories among the
#' active segments at each waypoint position. This prevents degenerate
#' representatives from consecutive segments of a single trajectory
#' whose shared characteristic points create artificial count peaks
#' via entry-before-exit tie-breaking. The check only affects results
#' when `min_lns < 3`; at higher values, the segment density threshold
#' is already sufficient. See `vignette("algorithm-details")` for a
#' detailed explanation.
#'
#' @family workflow functions
#' @export
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
#'                         x = "x", y = "y", coord_type = "euclidean")
#' parts <- tc_partition(trj)
#' \donttest{
#' clust <- tc_cluster(parts, eps = 25, min_lns = 3)
#' repr <- tc_represent(clust)
#' print(repr)
#' }
tc_represent <- function(x, gamma = 1, min_lns = NULL, verbose = TRUE) {
  # --- Class check ---
  .check_class(x, "tc_clusters", "tc_cluster")

  # --- Parameter validation ---
  .validate_gamma(gamma)

  # Resolve min_lns: default from clustering, or user override
  if (is.null(min_lns)) {
    min_lns <- x$params$min_lns
  } else {
    .validate_min_lns(min_lns)
    min_lns <- as.integer(min_lns)
    message(sprintf("Using custom min_lns = %d for representation (clustering used %d).",
                    min_lns, x$params$min_lns))
  }

  # --- Handle 0 clusters ---
  if (x$n_clusters == 0L) {
    warning("No clusters to represent (all segments are noise).",
            call. = FALSE)
    return(.new_tc_representatives(
      segments = x$segments,
      representatives = data.frame(
        cluster_id = integer(0),
        point_id = integer(0),
        rx = numeric(0),
        ry = numeric(0),
        stringsAsFactors = FALSE
      ),
      clusters = x,
      n_clusters = 0L,
      n_noise = x$n_noise,
      params = list(min_lns = min_lns, gamma = gamma),
      coord_type = x$coord_type,
      method = x$method
    ))
  }

  # --- Own copy of segments (will be modified for failed clusters) ---
  out_segments <- x$segments

  # --- Determine if geographic projection is needed ---
  is_geographic <- (x$coord_type == "geographic")
  is_projected <- (x$method == "projected")

  # --- Process each cluster ---
  cluster_ids <- sort(unique(
    out_segments$cluster_id[!is.na(out_segments$cluster_id)]
  ))

  all_representatives <- list()
  failed_clusters <- integer(0)

  for (cid in cluster_ids) {
    mask <- out_segments$cluster_id == cid & !is.na(out_segments$cluster_id)
    cl_segs <- out_segments[mask, ]

    # Working coordinates: project geographic to meters if needed
    if (is_geographic) {
      # Use stored projection params if available, else per-cluster centroid
      if (is_projected) {
        lat_mean <- x$partitions$trajectories$proj_params$lat_mean
      } else {
        lat_mean <- mean(c(cl_segs$sy, cl_segs$ey))
      }
      proj_s <- .equirectangular_proj(cl_segs$sx, cl_segs$sy, lat_mean)
      proj_e <- .equirectangular_proj(cl_segs$ex, cl_segs$ey, lat_mean)
      w_sx <- proj_s$x
      w_sy <- proj_s$y
      w_ex <- proj_e$x
      w_ey <- proj_e$y
    } else {
      w_sx <- cl_segs$sx
      w_sy <- cl_segs$sy
      w_ex <- cl_segs$ex
      w_ey <- cl_segs$ey
    }

    # Run sweep-line algorithm
    result <- .sweep_line_representative(w_sx, w_sy, w_ex, w_ey,
                                          traj_id = cl_segs$traj_id,
                                          min_lns = min_lns, gamma = gamma)

    if (is.null(result)) {
      # Cluster failed: < 2 waypoints
      failed_clusters <- c(failed_clusters, cid)
      next
    }

    # Transform waypoints back to geographic if needed
    if (is_geographic) {
      orig <- .equirectangular_inverse(result$rx, result$ry, lat_mean)
      result$rx <- orig$lon
      result$ry <- orig$lat
    }

    all_representatives[[length(all_representatives) + 1]] <- data.frame(
      cluster_id = cid,
      point_id = seq_len(nrow(result)),
      rx = result$rx,
      ry = result$ry,
      stringsAsFactors = FALSE
    )
  }

  # --- Handle failed clusters: degrade to noise ---
  if (length(failed_clusters) > 0L) {
    for (fc in failed_clusters) {
      out_segments$cluster_id[out_segments$cluster_id == fc &
                                !is.na(out_segments$cluster_id)] <- NA_integer_
    }
  }

  # --- Renumber remaining cluster IDs ---
  if (length(failed_clusters) > 0L || length(all_representatives) == 0L) {
    # Renumber in segments
    remaining_ids <- sort(unique(
      out_segments$cluster_id[!is.na(out_segments$cluster_id)]
    ))
    if (length(remaining_ids) > 0L) {
      id_map <- stats::setNames(seq_along(remaining_ids), remaining_ids)
      non_na <- !is.na(out_segments$cluster_id)
      out_segments$cluster_id[non_na] <-
        as.integer(id_map[as.character(out_segments$cluster_id[non_na])])

      # Renumber in representatives
      for (i in seq_along(all_representatives)) {
        old_cid <- all_representatives[[i]]$cluster_id[1]
        all_representatives[[i]]$cluster_id <-
          as.integer(id_map[as.character(old_cid)])
      }
    }
  }

  # --- Combine representatives ---
  if (length(all_representatives) > 0L) {
    representatives <- do.call(rbind, all_representatives)
    rownames(representatives) <- NULL
  } else {
    representatives <- data.frame(
      cluster_id = integer(0),
      point_id = integer(0),
      rx = numeric(0),
      ry = numeric(0),
      stringsAsFactors = FALSE
    )
  }

  # --- Updated counts ---
  final_n_clusters <- length(unique(
    out_segments$cluster_id[!is.na(out_segments$cluster_id)]
  ))
  final_n_noise <- sum(is.na(out_segments$cluster_id))

  # --- Construct S3 object ---
  obj <- .new_tc_representatives(
    segments = out_segments,
    representatives = representatives,
    clusters = x,
    n_clusters = final_n_clusters,
    n_noise = final_n_noise,
    params = list(min_lns = min_lns, gamma = gamma),
    coord_type = x$coord_type,
    method = x$method
  )

  # --- Verbose output ---
  n_lost <- length(failed_clusters)
  if (verbose) {
    if (n_lost > 0L) {
      message(sprintf(
        "Representatives: %d trajectory(ies) (%d cluster(s) lost to cleanup).",
        final_n_clusters, n_lost))
    } else {
      message(sprintf("Representatives: %d trajectory(ies).",
                      final_n_clusters))
    }
  }

  obj
}


# ============================================================================
# S3 constructor
# ============================================================================

#' Construct a tc_representatives object
#'
#' Low-level constructor that assembles the S3 list. No validation is
#' performed — use [tc_represent()] for the validated public API.
#'
#' @param segments data.frame with updated cluster_ids.
#' @param representatives data.frame with columns cluster_id, point_id, rx, ry.
#' @param clusters The source tc_clusters object (unmodified).
#' @param n_clusters Integer number of valid clusters.
#' @param n_noise Integer number of noise segments.
#' @param params List with min_lns and gamma.
#' @param coord_type Character: "euclidean" or "geographic".
#' @param method Character: "euclidean" or "haversine".
#' @return A tc_representatives S3 object.
#' @keywords internal
.new_tc_representatives <- function(segments, representatives, clusters,
                                     n_clusters, n_noise, params,
                                     coord_type, method) {
  structure(
    list(
      segments = segments,
      representatives = representatives,
      clusters = clusters,
      n_clusters = n_clusters,
      n_noise = n_noise,
      params = params,
      coord_type = coord_type,
      method = method
    ),
    class = "tc_representatives"
  )
}
