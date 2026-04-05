# =============================================================================
# Tests for tc_partition() — MDL-based trajectory partitioning (Phase 3)
# =============================================================================

test_that("tc_partition works on toy data", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  expect_s3_class(parts, "tc_partitions")
  expect_true(parts$n_segments > 0)
  expect_equal(parts$coord_type, "euclidean")
  expect_equal(parts$method, "euclidean")

  # Segments data.frame has correct columns
  expect_named(parts$segments,
               c("traj_id", "seg_id", "sx", "sy", "ex", "ey"))

  # All trajectory IDs from input are represented
  expect_true(all(unique(trj$data$traj_id) %in% unique(parts$segments$traj_id)))

  # Reference to trajectories object is preserved

  expect_identical(parts$trajectories, trj)
})

test_that("tc_partition works on geographic data (haversine)", {
  geo <- generate_geo_trajectories()
  trj <- tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                         coord_type = "geographic", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  expect_s3_class(parts, "tc_partitions")
  expect_true(parts$n_segments > 0)
  expect_equal(parts$method, "haversine")
})

test_that("tc_partition works in paper replication mode", {
  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic", method = "euclidean",
                    verbose = TRUE)
  )
  parts <- tc_partition(trj, verbose = FALSE)

  expect_s3_class(parts, "tc_partitions")
  expect_equal(parts$method, "euclidean")
})

test_that("two-point trajectories produce exactly 1 segment each", {
  trj <- tc_trajectories(generate_two_point_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  # Each 2-point trajectory should produce exactly 1 segment (no split possible)
  segs_per_traj <- table(parts$segments$traj_id)
  expect_true(all(segs_per_traj == 1))
})

test_that("straight-line trajectory is not partitioned", {
  # A perfectly straight trajectory: MDL should never favor splitting
  straight <- data.frame(
    traj_id = rep(c("S1", "S2"), each = 10),
    x = rep(seq(0, 90, by = 10), 2),
    y = c(rep(0, 10), rep(10, 10))
  )
  trj <- tc_trajectories(straight, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  # Straight trajectory should yield exactly 1 segment
  segs_per_traj <- table(parts$segments$traj_id)
  expect_true(all(segs_per_traj == 1))
})

test_that("sharply bent trajectory gets partitioned", {
  # L-shaped trajectory: strong direction change should trigger a split
  bent <- data.frame(
    traj_id = rep(c("B1", "B2"), each = 6),
    x = c(0, 20, 40, 60, 60, 60,
          0, 0, 0, 20, 40, 60),
    y = c(0, 0, 0, 0, 20, 40,
          0, 20, 40, 40, 40, 40)
  )
  trj <- tc_trajectories(bent, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  # Should have more than 1 segment due to direction change
  segs_per_traj <- table(parts$segments$traj_id)
  expect_true(all(segs_per_traj >= 2))
})

test_that("partition segments cover the trajectory range", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  # For each trajectory, the first segment starts at the first point
  # and the last segment ends at the last point
  for (tid in unique(parts$segments$traj_id)) {
    traj_pts <- trj$data[trj$data$traj_id == tid, ]
    traj_segs <- parts$segments[parts$segments$traj_id == tid, ]

    # First segment starts at first trajectory point
    expect_equal(traj_segs$sx[1], traj_pts$x[1])
    expect_equal(traj_segs$sy[1], traj_pts$y[1])

    # Last segment ends at last trajectory point
    n_segs <- nrow(traj_segs)
    expect_equal(traj_segs$ex[n_segs], traj_pts$x[nrow(traj_pts)])
    expect_equal(traj_segs$ey[n_segs], traj_pts$y[nrow(traj_pts)])
  }
})

test_that("consecutive segments are connected", {
  # Use sharply bent data that produces multiple segments per trajectory
  bent <- data.frame(
    traj_id = rep(c("B1", "B2"), each = 6),
    x = c(0, 20, 40, 60, 60, 60,
          0, 0, 0, 20, 40, 60),
    y = c(0, 0, 0, 0, 20, 40,
          0, 20, 40, 40, 40, 40)
  )
  trj <- suppressWarnings(
    tc_trajectories(bent, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", verbose = FALSE)
  )
  parts <- tc_partition(trj, verbose = FALSE)

  # For trajectories with multiple segments, end of segment k = start of k+1
  found_multi <- FALSE
  for (tid in unique(parts$segments$traj_id)) {
    traj_segs <- parts$segments[parts$segments$traj_id == tid, ]
    if (nrow(traj_segs) > 1) {
      found_multi <- TRUE
      for (i in 1:(nrow(traj_segs) - 1)) {
        expect_equal(traj_segs$ex[i], traj_segs$sx[i + 1])
        expect_equal(traj_segs$ey[i], traj_segs$sy[i + 1])
      }
    }
  }
  expect_true(found_multi, info = "Expected at least one multi-segment trajectory")
})

test_that("seg_id is 1-based and sequential within each trajectory", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  for (tid in unique(parts$segments$traj_id)) {
    traj_segs <- parts$segments[parts$segments$traj_id == tid, ]
    expect_equal(traj_segs$seg_id, seq_len(nrow(traj_segs)))
  }
})

test_that("tc_partition rejects wrong input class", {
  expect_error(
    tc_partition(data.frame(x = 1)),
    "Expected a 'tc_trajectories' object"
  )
  expect_error(
    tc_partition("not an object"),
    "Expected a 'tc_trajectories' object"
  )
})

test_that("verbose message is printed when verbose = TRUE", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_message(tc_partition(trj, verbose = TRUE), "Partitioned")
})

test_that("no message when verbose = FALSE", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_silent(tc_partition(trj, verbose = FALSE))
})

test_that("print.tc_partitions works", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  output <- capture.output(print(parts))
  expect_true(any(grepl("TRACLUS Partitions", output)))
  expect_true(any(grepl("Segments", output)))
  expect_true(any(grepl("partitioned", output)))

  # Returns invisible
  expect_invisible(print(parts))
})

test_that("summary.tc_partitions works", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  output <- capture.output(summary(parts))
  expect_true(any(grepl("Summary", output)))
  expect_true(any(grepl("Segs per traj", output)))
  expect_true(any(grepl("Segment lengths", output)))

  # Returns invisible
  expect_invisible(summary(parts))
})

# =============================================================================
# MDL cost function tests (C++ internals)
# =============================================================================

test_that("safe_log2 clamps values below 1", {
  # For values >= 1, log2 is returned normally
  costpar_10 <- TRACLUS:::.cpp_mdl_costpar(0, 0, 10, 0,
                                            c(0, 10), c(0, 0), 0L)
  # L(H) = log2(10) = 3.32..., L(D|H) for identical segment = log2(0)+log2(0) = 0+0
  # But with safe_log2, log2(max(0,1)) = 0
  expect_true(is.finite(costpar_10))
  expect_true(costpar_10 > 0)
})

test_that("costnopar includes partition bias", {
  # costnopar for a single segment of length 10:
  # bias + log2(max(10, 1)) = 1.0 + log2(10) = 1 + 3.32 = 4.32
  costnopar <- TRACLUS:::.cpp_mdl_costnopar(c(0, 10), c(0, 0), 0L)
  expected <- 1.0 + log2(10)
  expect_equal(costnopar, expected, tolerance = 1e-10)
})

test_that("costpar for identical sub-segment equals log2(length)", {
  # When the partition segment IS the sub-segment, d_perp = 0, d_angle = 0
  # so L(D|H) = safe_log2(0) + safe_log2(0) = 0 + 0 = 0
  # costpar = L(H) = log2(10) = 3.32...
  costpar <- TRACLUS:::.cpp_mdl_costpar(0, 0, 10, 0,
                                         c(0, 10), c(0, 0), 0L)
  expect_equal(costpar, log2(10), tolerance = 1e-10)
})

test_that("costpar increases with perpendicular deviation", {
  # Sub-segment that deviates from the partition line
  cost_aligned <- TRACLUS:::.cpp_mdl_costpar(0, 0, 20, 0,
                                              c(0, 10, 20), c(0, 0, 0), 0L)
  cost_deviated <- TRACLUS:::.cpp_mdl_costpar(0, 0, 20, 0,
                                               c(0, 10, 20), c(0, 5, 0), 0L)
  expect_true(cost_deviated > cost_aligned)
})

test_that("cpp_partition_single returns correct indices for 2-point trajectory", {
  # 2 points: always returns indices 1 and 2 (1-based)
  cp <- TRACLUS:::.cpp_partition_single(c(0, 10), c(0, 0), 0L)
  expect_equal(cp, c(1L, 2L))
})

test_that("cpp_partition_single returns start and end for straight line", {
  # Straight line: should not be split
  cp <- TRACLUS:::.cpp_partition_single(
    c(0, 10, 20, 30, 40, 50),
    c(0, 0, 0, 0, 0, 0),
    0L
  )
  expect_equal(cp, c(1L, 6L))
})

test_that("cpp_partition_single splits sharp turns", {
  # L-shaped: 90-degree turn
  cp <- TRACLUS:::.cpp_partition_single(
    c(0, 20, 40, 60, 60, 60),
    c(0, 0, 0, 0, 20, 40),
    0L
  )
  # Should have at least 3 characteristic points (start, corner, end)
  expect_true(length(cp) >= 3)
  # First and last are always included
  expect_equal(cp[1], 1L)
  expect_equal(cp[length(cp)], 6L)
})

test_that("partition works with haversine method (single trajectory)", {
  # Geographic straight path along equator
  cp <- TRACLUS:::.cpp_partition_single(
    c(0, 1, 2, 3, 4, 5),  # longitudes
    c(0, 0, 0, 0, 0, 0),  # equator
    1L  # haversine
  )
  # Straight path: should not split
  expect_equal(cp, c(1L, 6L))
})

# =============================================================================
# Edge cases
# =============================================================================

test_that("partition handles many trajectories", {
  # Create 20 trajectories
  df <- data.frame(
    traj_id = rep(paste0("T", 1:20), each = 6),
    x = rep(seq(0, 50, by = 10), 20),
    y = rep(seq(0, 19) * 5, each = 6) +
        rep(c(0, 0.5, -0.3, 0.8, -0.2, 0), 20)
  )
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  expect_s3_class(parts, "tc_partitions")
  expect_equal(length(unique(parts$segments$traj_id)), 20)
})

test_that("segments have positive length (no zero-length segments)", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  seg_lens <- sqrt(
    (parts$segments$ex - parts$segments$sx)^2 +
    (parts$segments$ey - parts$segments$sy)^2
  )
  expect_true(all(seg_lens > 0))
})

test_that("n_segments matches actual segment count", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  expect_equal(parts$n_segments, nrow(parts$segments))
})

test_that("partition result is pipeable", {
  trj <- tc_trajectories(generate_toy_trajectories(),
                         traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  # tc_partition should accept the output of tc_trajectories
  parts <- trj |> tc_partition(verbose = FALSE)
  expect_s3_class(parts, "tc_partitions")
})

test_that("traclus_toy dataset partitions correctly", {
  trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
                         x = "x", y = "y", coord_type = "euclidean",
                         verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  expect_s3_class(parts, "tc_partitions")
  expect_true(parts$n_segments >= 6)  # At least 1 segment per trajectory
  expect_true(parts$n_segments <= 36) # At most 6 segments per trajectory
})

# --- Golden-Value Tests ---
# L-shaped trajectory with 90-degree turn: hand-computed MDL costs and partition.
# Trajectory T: p1=(0,0), p2=(10,0), p3=(20,0), p4=(20,10), p5=(20,20)
# Segments: 4 sub-segments of length 10 each.
# Sharp 90-degree turn at p3=(20,0).

test_that("golden: costnopar for collinear sub-range p1-p3", {
  # p1=(0,0), p2=(10,0), p3=(20,0) — 2 collinear sub-segments of length 10.
  # costnopar = bias + sum(safe_log2(sub_len_k))
  #           = 1.0 + log2(10) + log2(10)
  #           = 1.0 + 2 * log2(10)
  #           = 1.0 + 2 * 3.321928 = 7.643856
  expect_equal(
    TRACLUS:::.cpp_mdl_costnopar(c(0, 10, 20), c(0, 0, 0), 0L),
    1.0 + 2 * log2(10),
    tolerance = 1e-10
  )
})

test_that("golden: costpar for collinear sub-range p1-p3", {
  # Partition segment (0,0)->(20,0), length 20, with 2 collinear sub-segs.
  # All points lie on the partition line => d_perp = 0, d_angle = 0 for all.
  # safe_log2(0) = log2(max(0, 1)) = 0.
  # costpar = L(H) + L(D|H) = log2(20) + 0 + 0 + 0 + 0 = log2(20)
  expect_equal(
    TRACLUS:::.cpp_mdl_costpar(0, 0, 20, 0, c(0, 10, 20), c(0, 0, 0), 0L),
    log2(20),
    tolerance = 1e-10
  )
})

test_that("golden: costpar for partition spanning bend p1-p4", {
  # Partition (0,0)->(20,10), length sqrt(500), with 3 sub-segments.
  # Direction of partition: (20, 10). Perpendicular distance from P to line =
  # |cross product| / |direction| = |Px*10 - Py*20| / sqrt(500).
  #
  # Sub-seg 1: (0,0)->(10,0)
  #   l1 = |0*10 - 0*20| / sqrt(500) = 0
  #   l2 = |10*10 - 0*20| / sqrt(500) = 100/sqrt(500) = 2*sqrt(5)
  #   d_perp = (0 + 20) / (0 + 2*sqrt(5)) = 20/(2*sqrt(5)) = 2*sqrt(5) = 4.47214
  #   cos(theta) = (20*10 + 10*0)/(sqrt(500)*10) = 200/sqrt(50000) = 2/sqrt(5)
  #   sin(theta) = 1/sqrt(5)
  #   d_angle = 10/sqrt(5) = 2*sqrt(5) = 4.47214
  #   L(D|H)_1 = log2(2*sqrt(5)) + log2(2*sqrt(5)) = 2*log2(2*sqrt(5))
  #
  # Sub-seg 2: (10,0)->(20,0)
  #   l1 = 100/sqrt(500) = 2*sqrt(5)
  #   l2 = 200/sqrt(500) = 4*sqrt(5)
  #   d_perp = (20 + 80)/(6*sqrt(5)) = 100/(6*sqrt(5)) = 10*sqrt(5)/3 = 7.45356
  #   d_angle = 2*sqrt(5) (same angle)
  #   L(D|H)_2 = log2(10*sqrt(5)/3) + log2(2*sqrt(5))
  #
  # Sub-seg 3: (20,0)->(20,10)
  #   l1 = 200/sqrt(500) = 4*sqrt(5)
  #   l2 = |20*10 - 10*20| / sqrt(500) = 0
  #   d_perp = (80 + 0)/(4*sqrt(5)) = 4*sqrt(5) = 8.94427
  #   cos(theta) = (20*0 + 10*10)/(sqrt(500)*10) = 1/sqrt(5)
  #   sin(theta) = 2/sqrt(5)
  #   d_angle = 10 * 2/sqrt(5) = 4*sqrt(5) = 8.94427
  #   L(D|H)_3 = 2*log2(4*sqrt(5))
  #
  # costpar = log2(sqrt(500)) + 2*log2(2*sqrt(5))
  #         + log2(10*sqrt(5)/3) + log2(2*sqrt(5))
  #         + 2*log2(4*sqrt(5))
  expected <- log2(sqrt(500)) +
    2 * log2(2 * sqrt(5)) +
    log2(10 * sqrt(5) / 3) + log2(2 * sqrt(5)) +
    2 * log2(4 * sqrt(5))

  expect_equal(
    TRACLUS:::.cpp_mdl_costpar(0, 0, 20, 10, c(0, 10, 20, 20), c(0, 0, 0, 10), 0L),
    expected,
    tolerance = 1e-10
  )
})

test_that("golden: MDL split decision — costpar > costnopar at bend", {
  # At the iteration where the algorithm considers partition p1->(p4=(20,10)):
  # costpar = 20.186 (see test above)
  # costnopar = 1 + 3*log2(10) = 10.966
  # costpar > costnopar => the algorithm splits.
  costpar <- TRACLUS:::.cpp_mdl_costpar(0, 0, 20, 10,
                                         c(0, 10, 20, 20), c(0, 0, 0, 10), 0L)
  costnopar <- TRACLUS:::.cpp_mdl_costnopar(c(0, 10, 20, 20), c(0, 0, 0, 10), 0L)

  expect_true(costpar > costnopar)

  # The collinear portion p1->p3 should NOT trigger a split:
  costpar_lin <- TRACLUS:::.cpp_mdl_costpar(0, 0, 20, 0,
                                             c(0, 10, 20), c(0, 0, 0), 0L)
  costnopar_lin <- TRACLUS:::.cpp_mdl_costnopar(c(0, 10, 20), c(0, 0, 0), 0L)
  expect_true(costpar_lin < costnopar_lin)
})

test_that("golden: expected characteristic points for L-shaped trajectory", {
  # T: (0,0), (10,0), (20,0), (20,10), (20,20)
  # Expected CPs: {p1, p3, p5} = indices {1, 3, 5} (1-based)
  # Split at the corner p3=(20,0), yielding 2 segments:
  #   Seg 1: (0,0)->(20,0)  horizontal
  #   Seg 2: (20,0)->(20,20) vertical
  cp <- TRACLUS:::.cpp_partition_single(
    c(0, 10, 20, 20, 20),
    c(0,  0,  0, 10, 20),
    0L
  )
  expect_equal(cp, c(1L, 3L, 5L))
})

test_that("golden: full pipeline partitions L-shape at the corner", {
  # tc_trajectories requires >= 2 trajectories, so add a second straight one.
  df <- data.frame(
    traj_id = c(rep("L1", 5), rep("L2", 3)),
    x = c(0, 10, 20, 20, 20,  0, 10, 20),
    y = c(0,  0,  0, 10, 20,  5,  5,  5)
  )
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  parts <- tc_partition(trj, verbose = FALSE)

  # L1 should be partitioned into 2 segments (split at corner)
  l1_segs <- parts$segments[parts$segments$traj_id == "L1", ]
  expect_equal(nrow(l1_segs), 2)
  # Segment 1: (0,0) -> (20,0)
  expect_equal(l1_segs$sx[1], 0)
  expect_equal(l1_segs$sy[1], 0)
  expect_equal(l1_segs$ex[1], 20)
  expect_equal(l1_segs$ey[1], 0)
  # Segment 2: (20,0) -> (20,20)
  expect_equal(l1_segs$sx[2], 20)
  expect_equal(l1_segs$sy[2], 0)
  expect_equal(l1_segs$ex[2], 20)
  expect_equal(l1_segs$ey[2], 20)

  # L2 (straight line) should remain 1 segment
  l2_segs <- parts$segments[parts$segments$traj_id == "L2", ]
  expect_equal(nrow(l2_segs), 1)
})

# =============================================================================
# New tests: HIGH gaps (Session 1)
# =============================================================================

test_that("E09 / H-9: all segments zero-length after partitioning gives error", {
  # Each trajectory has 2 distinct-but-nearly-identical points.
  # 1e-16 is representable as non-zero double: df$x[-1] != df$x[-nrow(df)]
  # → not filtered as consecutive duplicates by tc_trajectories.
  # Segment length = 1e-16 < ZERO_THRESHOLD (1e-15) → C++ marks as null.
  # All segments removed → tc_partition must throw an error.
  df <- data.frame(
    traj_id = rep(c("A", "B", "C"), each = 2),
    x       = c(0, 1e-16, 0, 1e-16, 0, 1e-16),
    y       = c(0, 0,     1, 1,     2, 2)
  )
  trj <- suppressMessages(
    tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", verbose = FALSE)
  )
  expect_error(
    suppressWarnings(tc_partition(trj)),
    "No segments remain"
  )
})
