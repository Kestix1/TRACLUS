#' DBSCAN expansion for TRACLUS line segment clustering
#'
#' Implements the modified DBSCAN algorithm from Paper Figure 12.
#' Core logic: segments with >= min_lns neighbours are "core segments"
#' that seed cluster expansion. The key modification from standard DBSCAN
#' is that noise segments CAN be reassigned to a cluster, but they do NOT
#' trigger further expansion (Paper Figure 12, Lines 23-26).
#'
#' @param neighbours List of integer vectors (1-indexed adjacency lists
#'   from C++ neighbourhood computation).
#' @param min_lns Minimum neighbourhood size for core segments (integer >= 1).
#' @return Integer vector of cluster assignments. 0 = unclassified (will
#'   become NA noise). Cluster IDs are 1-indexed and sequential.
#' @keywords internal
.dbscan_expand <- function(neighbours, min_lns) {
  n <- length(neighbours)

  # Cluster assignment: 0 = unclassified, -1 = noise, >0 = cluster ID

  cluster_id <- integer(n) # all zeros = unclassified
  current_cluster <- 0L

  # Pre-allocate a queue (vector used as FIFO via index tracking)
  # Maximum queue size is n; we reuse the buffer across clusters
  queue <- integer(n)

  for (i in seq_len(n)) {
    # Skip already classified segments
    if (cluster_id[i] != 0L) next

    # Check if segment i is a core segment
    # Paper Figure 12, Line 06: |Nε(L)| >= MinLns
    # Nε(L) includes L itself (dist(L,L) = 0 <= eps), but our adjacency
    # lists store only *other* segments. So |Nε(L)| = length(nb_i) + 1.
    nb_i <- neighbours[[i]]
    if (length(nb_i) + 1L < min_lns) {
      # Mark as noise (may be reclassified later during expansion)
      cluster_id[i] <- -1L
      next
    }

    # Start a new cluster from this core segment
    current_cluster <- current_cluster + 1L
    cluster_id[i] <- current_cluster

    # Initialize queue with all neighbours of the core segment
    # Paper Figure 12, Line 14: insert all segments in N_eps(L) into queue
    queue_start <- 1L
    queue_end <- 0L

    for (nb_idx in nb_i) {
      if (cluster_id[nb_idx] == 0L) {
        # Unclassified: assign to cluster and add to expansion queue
        cluster_id[nb_idx] <- current_cluster
        queue_end <- queue_end + 1L
        queue[queue_end] <- nb_idx
      } else if (cluster_id[nb_idx] == -1L) {
        # Paper Figure 12, Lines 23-26: noise can be absorbed into cluster
        # but does NOT get added to the expansion queue
        cluster_id[nb_idx] <- current_cluster
      }
      # Already in another cluster: skip (shouldn't happen for core's
      # direct neighbours in first pass, but defensive)
    }

    # BFS expansion: process queue
    while (queue_start <= queue_end) {
      m <- queue[queue_start]
      queue_start <- queue_start + 1L

      # Check if segment m is also a core segment
      # |Nε(M)| = length(nb_m) + 1 (self-inclusive, see above)
      nb_m <- neighbours[[m]]
      if (length(nb_m) + 1L < min_lns) next

      # Expand through m's neighbours
      for (nb_idx in nb_m) {
        if (cluster_id[nb_idx] == 0L) {
          # Unclassified: assign and enqueue for further expansion
          cluster_id[nb_idx] <- current_cluster
          queue_end <- queue_end + 1L
          queue[queue_end] <- nb_idx
        } else if (cluster_id[nb_idx] == -1L) {
          # Noise reclassification: absorb but don't expand
          # Paper Figure 12, Lines 23-26
          cluster_id[nb_idx] <- current_cluster
        }
      }
    }
  }

  # Convert: -1 (noise) and 0 (unclassified, shouldn't exist) -> 0
  cluster_id[cluster_id < 0L] <- 0L

  cluster_id
}


#' Renumber cluster IDs to be sequential starting from 1
#'
#' After trajectory cardinality filtering, cluster IDs may have gaps
#' (e.g., 1, 3, 5). This function renumbers them to 1, 2, 3 for
#' consistent colour assignment in plots.
#'
#' @param cluster_ids Integer vector of cluster assignments (0 or NA = noise).
#' @return Integer vector with renumbered cluster IDs. Noise remains 0.
#' @keywords internal
.renumber_clusters <- function(cluster_ids) {
  unique_ids <- sort(unique(cluster_ids[cluster_ids > 0L]))
  if (length(unique_ids) == 0L) {
    return(cluster_ids)
  }

  # Create mapping: old_id -> new_id
  mapping <- integer(max(unique_ids))
  for (k in seq_along(unique_ids)) {
    mapping[unique_ids[k]] <- k
  }

  result <- cluster_ids
  pos <- which(cluster_ids > 0L)
  result[pos] <- mapping[cluster_ids[pos]]

  result
}
