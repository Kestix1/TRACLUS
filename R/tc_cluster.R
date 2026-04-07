#' Cluster line segments using density-based clustering
#'
#' `r lifecycle::badge("stable")`
#'
#' Applies a modified DBSCAN algorithm to group similar line segments
#' into clusters. Segments that are not dense enough are classified as
#' noise (cluster_id = NA). After clustering, a trajectory cardinality
#' check removes clusters whose segments originate from fewer than
#' `min_lns` distinct trajectories (Paper Section 4.3).
#'
#' @param x A `tc_partitions` object created by [tc_partition()].
#' @param eps Positive numeric distance threshold. Segments within `eps`
#'   distance are considered neighbours. Unit: meters for
#'   `method = "haversine"` or `"projected"`, coordinate units for
#'   `method = "euclidean"`.
#'   **Required** — no default. Use trial and error or
#'   [tc_estimate_params()] for guidance.
#' @param min_lns Positive integer (>= 1). Minimum neighbourhood size
#'   for a segment to be a core segment in DBSCAN, AND minimum number
#'   of distinct source trajectories for a cluster to be retained.
#'   **Required** — no default.
#' @param w_perp Non-negative weight for perpendicular distance (default 1).
#' @param w_par Non-negative weight for parallel distance (default 1).
#' @param w_angle Non-negative weight for angle distance (default 1).
#' @param verbose Logical; if `TRUE` (default), prints an informative
#'   summary after clustering.
#'
#' @return A `tc_clusters` S3 object (list) with elements:
#' \describe{
#'   \item{segments}{`data.frame` with columns `traj_id`, `seg_id`, `sx`,
#'     `sy`, `ex`, `ey`, `cluster_id` (integer, `NA` for noise).}
#'   \item{cluster_summary}{`data.frame` with per-cluster statistics:
#'     `cluster_id`, `n_segments`, `n_trajectories`.}
#'   \item{n_clusters}{Integer number of clusters (excluding noise).}
#'   \item{n_noise}{Integer number of noise segments.}
#'   \item{params}{List with `eps`, `min_lns`, `w_perp`, `w_par`, `w_angle`.}
#'   \item{partitions}{Reference to the input `tc_partitions` object.}
#'   \item{coord_type}{Coordinate type inherited from input.}
#'   \item{method}{Distance method inherited from input.}
#' }
#'
#' @details
#' The weighted distance between two segments is:
#' `dist = w_perp * d_perp + w_par * d_par + w_angle * d_angle`
#' (Paper Section 2.3). Early termination skips remaining components
#' when the accumulated distance already exceeds `eps`.
#'
#' The DBSCAN modification from the paper: noise segments CAN be absorbed
#' into a cluster during expansion, but they do NOT trigger further
#' expansion (Paper Figure 12, Lines 23-26).
#'
#' **Choosing `min_lns`:** The paper recommends `min_lns` =
#' avg|N_eps(L)| + 1 to 3, typically yielding values of 5–9 (Section
#' 4.4). Use [tc_estimate_params()] for a data-driven starting point.
#' Values below 3 can lead to clusters dominated by a single trajectory
#' and degenerate representative trajectories — see [tc_represent()]
#' details for the trajectory diversity check that mitigates this.
#'
#' @family workflow functions
#' @export
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy,
#'   traj_id = "traj_id",
#'   x = "x", y = "y", coord_type = "euclidean"
#' )
#' parts <- tc_partition(trj)
#' \donttest{
#' clust <- tc_cluster(parts, eps = 10, min_lns = 3)
#' print(clust)
#' }
tc_cluster <- function(x, eps, min_lns,
                       w_perp = 1, w_par = 1, w_angle = 1,
                       verbose = TRUE) {
  # --- Class check ---
  .check_class(x, "tc_partitions", "tc_partition")

  # --- Custom error for missing required parameters ---
  # Paper: eps and min_lns are user-chosen, no sensible defaults
  if (missing(eps) || missing(min_lns)) {
    stop("'eps' and 'min_lns' are required. Choose values by trial and ",
      "error or use tc_estimate_params() after tc_partition() for a ",
      "data-driven starting point.",
      call. = FALSE
    )
  }

  # --- Parameter validation ---
  .validate_eps(eps)
  .validate_min_lns(min_lns)
  .validate_weights(w_perp, w_par, w_angle)
  min_lns <- as.integer(min_lns)

  # --- Extract segment data ---
  segs <- x$segments

  # --- Project coordinates if method = "projected" ---
  is_projected <- (x$method == "projected")
  if (is_projected) {
    proj_params <- x$trajectories$proj_params
    proj_s <- .equirectangular_proj(segs$sx, segs$sy, proj_params$lat_mean)
    proj_e <- .equirectangular_proj(segs$ex, segs$ey, proj_params$lat_mean)
    c_sx <- proj_s$x
    c_sy <- proj_s$y
    c_ex <- proj_e$x
    c_ey <- proj_e$y
    c_method <- "euclidean"
  } else {
    c_sx <- segs$sx
    c_sy <- segs$sy
    c_ex <- segs$ex
    c_ey <- segs$ey
    c_method <- x$method
  }

  # --- Compute epsilon-neighbourhoods in C++ ---
  neighbours <- .cpp_compute_neighbourhoods(
    sx = c_sx,
    sy = c_sy,
    ex = c_ex,
    ey = c_ey,
    eps = eps,
    w_perp = w_perp,
    w_par = w_par,
    w_angle = w_angle,
    method = c_method,
    show_progress = verbose
  )

  # --- Run DBSCAN expansion in R ---
  cluster_ids <- .dbscan_expand(neighbours, min_lns)

  # --- Trajectory cardinality check (Paper Section 4.3) ---
  # Clusters whose segments originate from fewer than min_lns distinct
  # trajectories are removed — their segments become noise
  if (any(cluster_ids > 0L)) {
    unique_clusters <- sort(unique(cluster_ids[cluster_ids > 0L]))
    degraded <- integer(0)

    for (cid in unique_clusters) {
      mask <- cluster_ids == cid
      n_distinct_trajs <- length(unique(segs$traj_id[mask]))
      if (n_distinct_trajs < min_lns) {
        degraded <- c(degraded, cid)
        cluster_ids[mask] <- 0L
      }
    }

    if (length(degraded) > 0L) {
      # Renumber remaining clusters to be sequential
      cluster_ids <- .renumber_clusters(cluster_ids)
    }
  }

  # --- Convert 0 -> NA for noise (R convention) ---
  cluster_ids[cluster_ids == 0L] <- NA_integer_

  # --- Build output segments data.frame ---
  out_segments <- data.frame(
    traj_id = segs$traj_id,
    seg_id = segs$seg_id,
    sx = segs$sx,
    sy = segs$sy,
    ex = segs$ex,
    ey = segs$ey,
    cluster_id = cluster_ids
  )

  # --- Cluster summary ---
  n_clusters <- length(unique(cluster_ids[!is.na(cluster_ids)]))
  n_noise <- sum(is.na(cluster_ids))

  cluster_summary <- NULL
  if (n_clusters > 0L) {
    clustered <- out_segments[!is.na(out_segments$cluster_id), ]
    cluster_summary <- do.call(rbind, lapply(
      sort(unique(clustered$cluster_id)),
      function(cid) {
        mask <- clustered$cluster_id == cid
        data.frame(
          cluster_id = cid,
          n_segments = sum(mask),
          n_trajectories = length(unique(clustered$traj_id[mask]))
        )
      }
    ))
  } else {
    cluster_summary <- data.frame(
      cluster_id = integer(0),
      n_segments = integer(0),
      n_trajectories = integer(0)
    )
  }

  # --- 0 clusters warning ---
  if (n_clusters == 0L) {
    warning(
      "No clusters found (all segments are noise). ",
      "Consider increasing 'eps' or decreasing 'min_lns'.",
      call. = FALSE
    )
  }

  # --- Construct S3 object ---
  obj <- .new_tc_clusters(
    segments = out_segments,
    cluster_summary = cluster_summary,
    n_clusters = n_clusters,
    n_noise = n_noise,
    params = list(
      eps = eps,
      min_lns = min_lns,
      w_perp = w_perp,
      w_par = w_par,
      w_angle = w_angle
    ),
    partitions = x,
    coord_type = x$coord_type,
    method = x$method
  )

  if (verbose) {
    message(sprintf(
      "Clustering: %d cluster(s), %d noise segment(s).",
      n_clusters, n_noise
    ))
  }

  obj
}


# ============================================================================
# S3 constructor
# ============================================================================

#' Construct a tc_clusters object
#'
#' Low-level constructor that assembles the S3 list. No validation is
#' performed — use [tc_cluster()] for the validated public API.
#'
#' @param segments data.frame with columns traj_id, seg_id, sx, sy, ex, ey,
#'   cluster_id.
#' @param cluster_summary data.frame with per-cluster statistics.
#' @param n_clusters Integer number of clusters.
#' @param n_noise Integer number of noise segments.
#' @param params List of clustering parameters.
#' @param partitions The source tc_partitions object.
#' @param coord_type Character: "euclidean" or "geographic".
#' @param method Character: "euclidean" or "haversine".
#' @return A tc_clusters S3 object.
#' @keywords internal
.new_tc_clusters <- function(segments, cluster_summary, n_clusters, n_noise,
                             params, partitions, coord_type, method) {
  structure(
    list(
      segments = segments,
      cluster_summary = cluster_summary,
      n_clusters = n_clusters,
      n_noise = n_noise,
      params = params,
      partitions = partitions,
      coord_type = coord_type,
      method = method
    ),
    class = "tc_clusters"
  )
}
