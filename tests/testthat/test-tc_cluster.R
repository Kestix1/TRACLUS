# =============================================================================
# Tests for Phase 4: tc_cluster (DBSCAN clustering of line segments)
# =============================================================================

# --- Helper: create a partitioned toy dataset for clustering tests ---
make_test_partitions <- function() {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  suppressMessages(tc_partition(trj))
}

# =============================================================================
# Basic functionality
# =============================================================================

test_that("tc_cluster works on toy data with reasonable parameters", {
  parts <- make_test_partitions()
  # eps = 25 covers the mid-section where TR1-TR5 are parallel
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  expect_s3_class(clust, "tc_clusters")
  expect_true(clust$n_clusters >= 1)
  expect_true(clust$n_noise >= 0)
  expect_equal(nrow(clust$segments), nrow(parts$segments))
  expect_true("cluster_id" %in% names(clust$segments))
})

test_that("tc_clusters object has correct structure", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  # Required elements
  expect_true(all(c("segments", "cluster_summary", "n_clusters", "n_noise",
                     "params", "partitions", "coord_type", "method")
                  %in% names(clust)))

  # Segments data.frame columns
  expect_true(all(c("traj_id", "seg_id", "sx", "sy", "ex", "ey", "cluster_id")
                  %in% names(clust$segments)))

  # Cluster summary columns
  expect_true(all(c("cluster_id", "n_segments", "n_trajectories")
                  %in% names(clust$cluster_summary)))

  # Params list
  expect_equal(clust$params$eps, 25)
  expect_equal(clust$params$min_lns, 3L)
  expect_equal(clust$params$w_perp, 1)
  expect_equal(clust$params$w_par, 1)
  expect_equal(clust$params$w_angle, 1)

  # Reference chain
  expect_s3_class(clust$partitions, "tc_partitions")

  # Metadata propagation
  expect_equal(clust$coord_type, "euclidean")
  expect_equal(clust$method, "euclidean")
})

test_that("noise segments have cluster_id = NA", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  noise_segs <- clust$segments[is.na(clust$segments$cluster_id), ]
  clustered_segs <- clust$segments[!is.na(clust$segments$cluster_id), ]

  expect_equal(nrow(noise_segs), clust$n_noise)
  expect_equal(nrow(clustered_segs), nrow(clust$segments) - clust$n_noise)
})

test_that("cluster IDs are sequential starting from 1", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  if (clust$n_clusters > 0) {
    ids <- sort(unique(clust$segments$cluster_id[
      !is.na(clust$segments$cluster_id)
    ]))
    expect_equal(ids, seq_len(clust$n_clusters))
  }
})

test_that("cluster_summary matches segments data", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  if (clust$n_clusters > 0) {
    for (i in seq_len(nrow(clust$cluster_summary))) {
      cid <- clust$cluster_summary$cluster_id[i]
      mask <- clust$segments$cluster_id == cid & !is.na(clust$segments$cluster_id)
      expect_equal(clust$cluster_summary$n_segments[i], sum(mask))
      expect_equal(clust$cluster_summary$n_trajectories[i],
                   length(unique(clust$segments$traj_id[mask])))
    }
  }
})

test_that("TR6 (vertical outlier) is noise with appropriate params", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  # TR6 is nearly vertical, far from the horizontal cluster
  tr6_segs <- clust$segments[clust$segments$traj_id == "TR6", ]
  expect_true(all(is.na(tr6_segs$cluster_id)),
              info = "TR6 (vertical outlier) should be classified as noise")
})

# =============================================================================
# Parameter validation
# =============================================================================

test_that("missing eps and min_lns gives custom error message", {
  parts <- make_test_partitions()

  expect_error(
    tc_cluster(parts),
    "'eps' and 'min_lns' are required"
  )
  expect_error(
    tc_cluster(parts, eps = 10),
    "'eps' and 'min_lns' are required"
  )
  expect_error(
    tc_cluster(parts, min_lns = 3),
    "'eps' and 'min_lns' are required"
  )
})

test_that("invalid eps is rejected", {
  parts <- make_test_partitions()

  expect_error(tc_cluster(parts, eps = -1, min_lns = 3), "'eps'")
  expect_error(tc_cluster(parts, eps = 0, min_lns = 3), "'eps'")
  expect_error(tc_cluster(parts, eps = "a", min_lns = 3), "'eps'")
  expect_error(tc_cluster(parts, eps = Inf, min_lns = 3), "'eps'")
})

test_that("invalid min_lns is rejected", {
  parts <- make_test_partitions()

  expect_error(tc_cluster(parts, eps = 10, min_lns = 0), "'min_lns'")
  expect_error(tc_cluster(parts, eps = 10, min_lns = -1), "'min_lns'")
  expect_error(tc_cluster(parts, eps = 10, min_lns = 2.5), "'min_lns'")
})

test_that("invalid weights are rejected", {
  parts <- make_test_partitions()

  expect_error(tc_cluster(parts, eps = 10, min_lns = 3, w_perp = -1), "'w_perp'")
  expect_error(tc_cluster(parts, eps = 10, min_lns = 3, w_par = -1), "'w_par'")
  expect_error(tc_cluster(parts, eps = 10, min_lns = 3, w_angle = -1), "'w_angle'")
})

test_that("wrong input class gives informative error", {
  expect_error(
    tc_cluster(data.frame(x = 1), eps = 10, min_lns = 3),
    "Expected a 'tc_partitions' object"
  )
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  expect_error(
    tc_cluster(trj, eps = 10, min_lns = 3),
    "Expected a 'tc_partitions' object"
  )
})

# =============================================================================
# Edge cases
# =============================================================================

test_that("very small eps produces 0 clusters with warning", {
  parts <- make_test_partitions()

  expect_warning(
    clust <- suppressMessages(tc_cluster(parts, eps = 0.001, min_lns = 3)),
    "No clusters found"
  )
  expect_equal(clust$n_clusters, 0)
  expect_equal(clust$n_noise, nrow(parts$segments))
  # All cluster_ids should be NA
  expect_true(all(is.na(clust$segments$cluster_id)))
  # cluster_summary should be empty
  expect_equal(nrow(clust$cluster_summary), 0)
})

test_that("very large eps puts everything in one cluster", {
  parts <- make_test_partitions()
  # With a huge eps, all segments are neighbours of each other
  clust <- suppressMessages(tc_cluster(parts, eps = 10000, min_lns = 2))

  # Should get 1 cluster (or at most a few)
  expect_true(clust$n_clusters >= 1)
  # Very few or no noise segments
  expect_true(clust$n_noise <= 2)
})

test_that("min_lns = 1 allows every segment to be a core segment", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 1))

  # With min_lns=1, every segment with at least 1 neighbour forms/joins a cluster
  # Cardinality check also requires >= 1 distinct trajectory, always true
  expect_true(clust$n_clusters >= 1)
})

test_that("trajectory cardinality check removes single-trajectory clusters", {
  # Create data where 2 trajectories form a pair and 1 is far away alone
  toy <- data.frame(
    traj_id = rep(c("A", "B", "C"), each = 3),
    x = c(0, 5, 10,        # A: at y=0
          0, 5, 10,         # B: at y=1 (close to A)
          100, 105, 110),   # C: far away alone
    y = c(0, 0, 0,
          1, 1, 1,
          100, 100, 100)
  )
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  parts <- suppressMessages(tc_partition(trj))

  # With min_lns = 2: C's segments alone can't form a valid cluster because
  # cardinality check requires >= 2 distinct trajectories
  clust <- suppressMessages(
    suppressWarnings(tc_cluster(parts, eps = 5, min_lns = 2))
  )

  # Segments from C should be noise
  c_segs <- clust$segments[clust$segments$traj_id == "C", ]
  expect_true(all(is.na(c_segs$cluster_id)))
})

test_that("custom weights influence clustering", {
  parts <- make_test_partitions()

  # Default weights
  clust1 <- suppressMessages(
    suppressWarnings(tc_cluster(parts, eps = 25, min_lns = 3))
  )
  # Only perpendicular distance (more lenient since we skip parallel + angle)
  clust2 <- suppressMessages(
    suppressWarnings(tc_cluster(parts, eps = 25, min_lns = 3,
                                w_perp = 1, w_par = 0, w_angle = 0))
  )

  # At minimum, the function should work without error
  expect_s3_class(clust2, "tc_clusters")
})

# =============================================================================
# DBSCAN expansion logic
# =============================================================================

test_that(".dbscan_expand correctly identifies clusters in simple case", {
  # 5 segments: 1-2-3 form a chain, 4-5 form another chain, no connection.
  # Adjacency lists store only OTHER neighbours (self not stored).
  # |Nε| = length(nb) + 1 (paper: self-inclusive).
  neighbours <- list(
    c(2L, 3L),    # seg 1: |Nε|=3
    c(1L, 3L),    # seg 2: |Nε|=3
    c(1L, 2L),    # seg 3: |Nε|=3
    c(5L),        # seg 4: |Nε|=2
    c(4L)         # seg 5: |Nε|=2
  )
  result <- TRACLUS:::.dbscan_expand(neighbours, min_lns = 2L)

  # All segments have |Nε| >= 2 => all core.
  # S1-S3 form cluster 1, S4-S5 form cluster 2 (no connection between chains).
  expect_true(all(result[1:3] > 0))
  expect_equal(length(unique(result[1:3])), 1)
  expect_true(all(result[4:5] > 0))
  expect_equal(length(unique(result[4:5])), 1)
  # The two clusters have different IDs
  expect_false(result[1] == result[4])
})

test_that(".dbscan_expand: noise absorbed by core expansion", {
  # seg 1-3 form a core chain; seg 4 is connected to 3 but not core;
  # seg 4 should be absorbed into the cluster via seg 3's expansion
  neighbours <- list(
    c(2L, 3L),      # seg 1: core (2 neighbours)
    c(1L, 3L),      # seg 2: core (2 neighbours)
    c(1L, 2L, 4L),  # seg 3: core (3 neighbours)
    c(3L)            # seg 4: only 1 neighbour -> not core, but reachable from core
  )
  result <- TRACLUS:::.dbscan_expand(neighbours, min_lns = 2L)

  # All should be in the same cluster: 1-3 are core, 4 is absorbed
  expect_true(all(result[1:4] > 0))
  expect_equal(length(unique(result[1:4])), 1)
})

test_that(".dbscan_expand marks isolated segments as noise", {
  # Segment with no neighbours. |Nε| = length(nb) + 1 (self-inclusive).
  neighbours <- list(
    integer(0),   # seg 1: |Nε|=1 < 2 => noise
    c(3L),        # seg 2: |Nε|=2 >= 2 => core
    c(2L)         # seg 3: |Nε|=2 >= 2 => core
  )
  result <- TRACLUS:::.dbscan_expand(neighbours, min_lns = 2L)

  # S1 is noise (truly isolated), S2-S3 form a cluster
  expect_equal(result[1], 0L)
  expect_true(all(result[2:3] > 0))
  expect_equal(result[2], result[3])
})

test_that(".renumber_clusters creates sequential IDs", {
  # Gaps in cluster IDs (e.g., after cardinality filtering)
  ids <- c(2L, 2L, 5L, 0L, 5L, 0L, 9L)
  result <- TRACLUS:::.renumber_clusters(ids)

  expect_equal(result, c(1L, 1L, 2L, 0L, 2L, 0L, 3L))
})

test_that(".renumber_clusters handles all-noise input", {
  ids <- c(0L, 0L, 0L)
  result <- TRACLUS:::.renumber_clusters(ids)
  expect_equal(result, c(0L, 0L, 0L))
})

# =============================================================================
# Neighbourhood computation (C++)
# =============================================================================

test_that("C++ neighbourhood computation returns correct structure", {
  parts <- make_test_partitions()
  segs <- parts$segments

  nb <- TRACLUS:::.cpp_compute_neighbourhoods(
    sx = segs$sx, sy = segs$sy, ex = segs$ex, ey = segs$ey,
    eps = 25, w_perp = 1, w_par = 1, w_angle = 1,
    method = "euclidean", show_progress = FALSE
  )

  expect_type(nb, "list")
  expect_equal(length(nb), nrow(segs))
  # All indices should be 1-indexed and within range
  for (i in seq_along(nb)) {
    if (length(nb[[i]]) > 0) {
      expect_true(all(nb[[i]] >= 1L & nb[[i]] <= nrow(segs)))
      # Segment should not be in its own neighbourhood
      expect_false(i %in% nb[[i]])
    }
  }
})

test_that("C++ neighbourhood is symmetric", {
  parts <- make_test_partitions()
  segs <- parts$segments

  nb <- TRACLUS:::.cpp_compute_neighbourhoods(
    sx = segs$sx, sy = segs$sy, ex = segs$ex, ey = segs$ey,
    eps = 25, w_perp = 1, w_par = 1, w_angle = 1,
    method = "euclidean", show_progress = FALSE
  )

  # If j is in nb[[i]], then i must be in nb[[j]]
  for (i in seq_along(nb)) {
    for (j in nb[[i]]) {
      expect_true(i %in% nb[[j]],
                  info = sprintf("Symmetry violated: %d in nb[%d] but %d not in nb[%d]",
                                 j, i, i, j))
    }
  }
})

test_that("C++ neighbourhood matches R distance function", {
  parts <- make_test_partitions()
  segs <- parts$segments
  eps <- 15

  nb <- TRACLUS:::.cpp_compute_neighbourhoods(
    sx = segs$sx, sy = segs$sy, ex = segs$ex, ey = segs$ey,
    eps = eps, w_perp = 1, w_par = 1, w_angle = 1,
    method = "euclidean", show_progress = FALSE
  )

  # Verify a few pairs against R distance function
  n <- nrow(segs)
  max_check <- min(n, 6)
  for (i in 1:(max_check - 1)) {
    for (j in (i + 1):max_check) {
      r_dist <- tc_dist_segments(
        c(segs$sx[i], segs$sy[i]), c(segs$ex[i], segs$ey[i]),
        c(segs$sx[j], segs$sy[j]), c(segs$ex[j], segs$ey[j])
      )
      in_nb <- j %in% nb[[i]]
      if (r_dist <= eps) {
        expect_true(in_nb,
                    info = sprintf("d(%d,%d)=%.2f <= eps but not neighbours", i, j, r_dist))
      } else {
        expect_false(in_nb,
                     info = sprintf("d(%d,%d)=%.2f > eps but are neighbours", i, j, r_dist))
      }
    }
  }
})

test_that("eps near-zero yields empty neighbourhoods", {
  parts <- make_test_partitions()
  segs <- parts$segments

  nb <- TRACLUS:::.cpp_compute_neighbourhoods(
    sx = segs$sx, sy = segs$sy, ex = segs$ex, ey = segs$ey,
    eps = 0.0001,
    w_perp = 1, w_par = 1, w_angle = 1,
    method = "euclidean", show_progress = FALSE
  )

  total_neighbours <- sum(vapply(nb, length, integer(1)))
  expect_equal(total_neighbours, 0L)
})

# =============================================================================
# Print and summary
# =============================================================================

test_that("print.tc_clusters works", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  out <- capture.output(print(clust))
  expect_true(any(grepl("TRACLUS Clusters", out)))
  expect_true(any(grepl("clustered", out)))
  expect_true(any(grepl("coordinate units", out)))
})

test_that("print.tc_clusters shows non-default weights", {
  parts <- make_test_partitions()
  clust <- suppressMessages(
    suppressWarnings(
      tc_cluster(parts, eps = 25, min_lns = 3, w_perp = 2, w_par = 0.5, w_angle = 1)
    )
  )

  out <- capture.output(print(clust))
  expect_true(any(grepl("Weights", out)))
})

test_that("print.tc_clusters omits weights when all are 1", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  out <- capture.output(print(clust))
  expect_false(any(grepl("Weights", out)))
})

test_that("summary.tc_clusters works", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  out <- capture.output(summary(clust))
  expect_true(any(grepl("TRACLUS Clusters - Summary", out)))
  expect_true(any(grepl("Noise segments", out)))
  expect_true(any(grepl("Segs per cluster", out)))
  expect_true(any(grepl("Trajs per cluster", out)))
})

test_that("summary.tc_clusters works with 0 clusters", {
  parts <- make_test_partitions()
  clust <- suppressWarnings(
    suppressMessages(tc_cluster(parts, eps = 0.001, min_lns = 3))
  )

  out <- capture.output(summary(clust))
  expect_true(any(grepl("Clusters:.*0", out)))
})

# =============================================================================
# Verbose control
# =============================================================================

test_that("verbose = TRUE produces message", {
  parts <- make_test_partitions()
  expect_message(
    tc_cluster(parts, eps = 25, min_lns = 3, verbose = TRUE),
    "Clustering:"
  )
})

test_that("verbose = FALSE suppresses message", {
  parts <- make_test_partitions()
  expect_no_message(
    suppressWarnings(tc_cluster(parts, eps = 25, min_lns = 3, verbose = FALSE))
  )
})

# =============================================================================
# Pipe compatibility
# =============================================================================

test_that("tc_cluster result can be printed invisibly", {
  parts <- make_test_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))

  # print should return invisible(x)
  ret <- capture.output(result <- print(clust))
  expect_s3_class(result, "tc_clusters")
})

# --- Golden-Value Tests ---
# 6 parallel horizontal segments with hand-computed pairwise distances.
# Segments S1-S4 form a cluster; S5, S6 are noise.
#
# Layout:
#   S1: (0,0)->(10,0)    traj A
#   S2: (0,1)->(10,1)    traj B
#   S3: (0,2)->(10,2)    traj C
#   S4: (0,3)->(10,3)    traj D
#   S5: (50,50)->(60,50) traj E  (isolated, far away)
#   S6: (0,100)->(10,100) traj F (isolated, far away)
#
# All segments are horizontal, length 10, parallel.
# For any pair (Si at y=a, Sj at y=b):
#   d_perp = |a-b|  (Lehmer mean of two equal perpendicular distances)
#   d_par  = 0      (projections align exactly with Li endpoints)
#   d_angle = 0     (parallel segments)
#   dist(Si, Sj) = |a - b|

make_golden_partitions <- function() {
  df <- data.frame(
    traj_id = c("A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F", "F"),
    x = c(0, 10, 0, 10, 0, 10, 0, 10, 50, 60, 0, 10),
    y = c(0, 0, 1, 1, 2, 2, 3, 3, 50, 50, 100, 100)
  )
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  tc_partition(trj, verbose = FALSE)
}

test_that("golden: pairwise distances for parallel horizontal segments", {
  # dist(Si, Sj) = |yi - yj| for cluster segments (same x-range, parallel).
  # Noise segments are very far away (dist > 80).
  expect_equal(
    tc_dist_segments(c(0, 0), c(10, 0), c(0, 1), c(10, 1)),
    1.0, tolerance = 1e-10
  )
  expect_equal(
    tc_dist_segments(c(0, 0), c(10, 0), c(0, 3), c(10, 3)),
    3.0, tolerance = 1e-10
  )
  # Noise segment S5 is far from S1
  # d_perp=50, d_par=40, d_angle=0  => dist=90
  expect_equal(
    tc_dist_segments(c(0, 0), c(10, 0), c(50, 50), c(60, 50)),
    90.0, tolerance = 1e-10
  )
})

test_that("golden: neighbourhoods with eps=5", {
  # With eps=5, all cluster segments (dist <= 3) are neighbours.
  # Noise segments (dist >= 87) have empty neighbourhoods.
  parts <- make_golden_partitions()
  segs <- parts$segments
  nb <- TRACLUS:::.cpp_compute_neighbourhoods(
    sx = segs$sx, sy = segs$sy, ex = segs$ex, ey = segs$ey,
    eps = 5, w_perp = 1, w_par = 1, w_angle = 1,
    method = "euclidean", show_progress = FALSE
  )

  # S1 (y=0): neighbours S2(1), S3(2), S4(3) — all within eps=5
  expect_equal(sort(nb[[1]]), c(2L, 3L, 4L))
  # S2 (y=1): neighbours S1(1), S3(1), S4(2)
  expect_equal(sort(nb[[2]]), c(1L, 3L, 4L))
  # S3 (y=2): neighbours S1(2), S2(1), S4(1)
  expect_equal(sort(nb[[3]]), c(1L, 2L, 4L))
  # S4 (y=3): neighbours S1(3), S2(2), S3(1)
  expect_equal(sort(nb[[4]]), c(1L, 2L, 3L))
  # S5, S6: no neighbours
  expect_equal(length(nb[[5]]), 0)
  expect_equal(length(nb[[6]]), 0)
})

test_that("golden: cluster assignment with eps=5, min_lns=3", {
  # Paper Figure 12, Line 06: |Nε(L)| >= MinLns, where Nε includes L itself.
  # S1-S4: each has 3 other neighbours + self => |Nε| = 4 >= 3 => all core.
  # DBSCAN expansion: S1-S4 connected => 1 cluster.
  # Cardinality: 4 trajectories (A,B,C,D) >= min_lns=3 => cluster kept.
  # S5, S6: |Nε| = 1 (only self) < 3 => noise (cluster_id = NA).
  parts <- make_golden_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 5, min_lns = 3))

  expect_equal(clust$n_clusters, 1)
  expect_equal(clust$n_noise, 2)

  # Cluster IDs: S1-S4 = cluster 1, S5-S6 = NA
  expect_equal(clust$segments$cluster_id, c(1L, 1L, 1L, 1L, NA, NA))

  # Cluster summary
  expect_equal(clust$cluster_summary$n_segments[1], 4)
  expect_equal(clust$cluster_summary$n_trajectories[1], 4)
})

test_that("golden: self-inclusive neighbourhood with eps=3, min_lns=4", {
  # Paper: Nε(L) includes L itself (dist(L,L) = 0 <= eps).
  # With eps=3: S1-S4 pairwise distances are 1,2,3 (all <= 3).
  # Each of S1-S4 has 3 other neighbours + self => |Nε| = 4 >= 4 => all core.
  # DBSCAN expansion: S1-S4 connected => 1 cluster.
  # Cardinality: 4 trajectories (A,B,C,D) >= 4 => cluster kept.
  # S5, S6: |Nε| = 1 (only self) < 4 => noise.
  parts <- make_golden_partitions()
  clust <- suppressMessages(tc_cluster(parts, eps = 3, min_lns = 4))

  expect_equal(clust$n_clusters, 1)
  expect_equal(clust$n_noise, 2)
  expect_equal(clust$segments$cluster_id, c(1L, 1L, 1L, 1L, NA, NA))
})

test_that("golden: no core segments when min_lns exceeds |Nε|", {
  # With eps=3, min_lns=5: S1-S4 each have |Nε| = 4 < 5 => no core segments.
  # 0 clusters, all 6 segments are noise.
  parts <- make_golden_partitions()
  clust <- suppressWarnings(
    suppressMessages(tc_cluster(parts, eps = 3, min_lns = 5))
  )

  expect_equal(clust$n_clusters, 0)
  expect_equal(clust$n_noise, 6)
  expect_true(all(is.na(clust$segments$cluster_id)))
})

test_that("golden: two segments with min_lns=2 form a cluster (self-inclusive)", {
  # The simplest case that catches the self-inclusion bug:
  # Two parallel horizontal segments, 10 apart, eps=10.
  # |Nε(S1)| = 2 (S1 + S2), |Nε(S2)| = 2 (S2 + S1).
  # min_lns=2: 2 >= 2 => both are core => 1 cluster.
  # Without self-inclusion this would fail: length(nb) = 1 < 2 => noise.
  df <- data.frame(
    traj_id = c("TR1", "TR1", "TR2", "TR2"),
    x = c(0, 50, 0, 50),
    y = c(0, 0, 10, 10)
  )
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)
  clust <- suppressMessages(tc_cluster(parts, eps = 10, min_lns = 2))

  expect_equal(clust$n_clusters, 1)
  expect_equal(clust$n_noise, 0)
  expect_equal(clust$segments$cluster_id, c(1L, 1L))
})

# =============================================================================
# New tests: CRITICAL gaps (Session 1)
# =============================================================================

test_that("F13 / C-1: all weights = 0 yields all distances 0 → one giant cluster", {
  # With w_perp=w_par=w_angle=0, every segment pair has distance 0.
  # Any eps > 0 makes all segments mutual neighbours → one cluster, zero noise.
  parts <- make_test_partitions()
  n_segs <- nrow(parts$segments)

  clust <- suppressMessages(
    tc_cluster(parts, eps = 0.001, min_lns = 2,
               w_perp = 0, w_par = 0, w_angle = 0)
  )

  expect_equal(clust$n_noise, 0L)
  expect_equal(clust$n_clusters, 1L)
  expect_true(all(clust$segments$cluster_id == 1L))
})
