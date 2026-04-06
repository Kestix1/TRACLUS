# --- Tests for tc_represent (sweep-line representative generation) ---

# --- Helper: create a clustered toy dataset ---
make_test_clusters <- function(eps = 25, min_lns = 3) {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  parts <- suppressMessages(tc_partition(trj))
  suppressMessages(suppressWarnings(tc_cluster(parts, eps = eps, min_lns = min_lns)))
}

# --- Basic functionality ----------------------------------------------------

test_that("tc_represent works on toy data", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  expect_s3_class(repr, "tc_representatives")
  expect_true(repr$n_clusters >= 1)
  expect_true(nrow(repr$representatives) >= 2)
})

test_that("tc_representatives object has correct structure", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  # Required elements
  expect_true(all(c("segments", "representatives", "clusters",
                     "n_clusters", "n_noise", "params",
                     "coord_type", "method") %in% names(repr)))

  # Representatives data.frame columns
  expect_true(all(c("cluster_id", "point_id", "rx", "ry")
                  %in% names(repr$representatives)))

  # Segments data.frame has cluster_id column
 expect_true("cluster_id" %in% names(repr$segments))

  # Params
  expect_equal(repr$params$gamma, 1)
  expect_equal(repr$params$min_lns, 3L)

  # Reference chain intact
  expect_s3_class(repr$clusters, "tc_clusters")
  expect_s3_class(repr$clusters$partitions, "tc_partitions")
  expect_s3_class(repr$clusters$partitions$trajectories, "tc_trajectories")

  # Metadata propagation
  expect_equal(repr$coord_type, "euclidean")
  expect_equal(repr$method, "euclidean")
})

test_that("representatives have sequential point_ids starting from 1", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  if (repr$n_clusters > 0) {
    for (cid in unique(repr$representatives$cluster_id)) {
      pts <- repr$representatives[repr$representatives$cluster_id == cid, ]
      expect_equal(pts$point_id, seq_len(nrow(pts)))
    }
  }
})

test_that("cluster IDs in representatives are sequential", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  if (repr$n_clusters > 0) {
    ids <- sort(unique(repr$representatives$cluster_id))
    expect_equal(ids, seq_len(repr$n_clusters))
  }
})

test_that("segments cluster_ids match representatives cluster_ids", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  if (repr$n_clusters > 0) {
    seg_cids <- sort(unique(repr$segments$cluster_id[
      !is.na(repr$segments$cluster_id)
    ]))
    repr_cids <- sort(unique(repr$representatives$cluster_id))
    expect_equal(seg_cids, repr_cids)
  }
})

test_that("n_noise and n_clusters are consistent with segments", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  expect_equal(repr$n_noise, sum(is.na(repr$segments$cluster_id)))
  expect_equal(repr$n_clusters,
               length(unique(repr$segments$cluster_id[
                 !is.na(repr$segments$cluster_id)
               ])))
  expect_equal(repr$n_noise + sum(!is.na(repr$segments$cluster_id)),
               nrow(repr$segments))
})

# --- Parameter handling -----------------------------------------------------

test_that("gamma parameter is validated", {
  clust <- make_test_clusters()

  expect_error(tc_represent(clust, gamma = -1), "'gamma'")
  expect_error(tc_represent(clust, gamma = 0), "'gamma'")
  expect_error(tc_represent(clust, gamma = "a"), "'gamma'")
})

test_that("custom min_lns is applied and message shown", {
  clust <- make_test_clusters()

  expect_message(
    repr <- tc_represent(clust, min_lns = 2),
    "Using custom min_lns = 2"
  )
  expect_equal(repr$params$min_lns, 2L)
})

test_that("default min_lns inherits from clustering", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  expect_equal(repr$params$min_lns, clust$params$min_lns)
})

test_that("wrong input class gives informative error", {
  expect_error(
    tc_represent(data.frame(x = 1)),
    "Expected a 'tc_clusters' object"
  )
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  parts <- suppressMessages(tc_partition(trj))
  expect_error(
    tc_represent(parts),
    "Expected a 'tc_clusters' object"
  )
})

# --- Edge cases -------------------------------------------------------------

test_that("0 clusters input produces warning and empty representatives", {
  clust <- make_test_clusters()
  # Force 0 clusters
  clust$n_clusters <- 0L
  clust$segments$cluster_id <- NA_integer_
  clust$n_noise <- nrow(clust$segments)

  expect_warning(
    repr <- suppressMessages(tc_represent(clust)),
    "No clusters to represent"
  )
  expect_equal(repr$n_clusters, 0L)
  expect_equal(nrow(repr$representatives), 0)
})

test_that("extremely large min_lns produces 0 clusters and empty representatives", {
  # min_lns = 1000000L means the sweep-line can never reach the threshold,
  # so all clusters fail and are degraded to noise. No warning is issued
  # by this path (warning only fires when n_clusters == 0 at input).
  clust <- make_test_clusters()
  skip_if(clust$n_clusters == 0L, "Toy data produced no clusters")

  repr <- suppressMessages(suppressWarnings(
    tc_represent(clust, min_lns = 1000000L)
  ))
  expect_equal(repr$n_clusters, 0L)
  expect_true(all(is.na(repr$segments$cluster_id)))
  expect_equal(nrow(repr$representatives), 0L)
})

test_that("large gamma suppresses waypoints, may fail clusters", {
  clust <- make_test_clusters()

  # Very large gamma: require huge spacing between waypoints
  repr <- suppressMessages(
    suppressWarnings(tc_represent(clust, gamma = 10000))
  )

  # Either 0 clusters (all failed) or fewer waypoints per cluster
  expect_s3_class(repr, "tc_representatives")
})

test_that("gamma = 0.001 produces more waypoints than gamma = 10", {
  clust <- make_test_clusters()

  repr_fine <- suppressMessages(tc_represent(clust, gamma = 0.001))
  repr_coarse <- suppressMessages(
    suppressWarnings(tc_represent(clust, gamma = 10))
  )

  # Fine gamma should produce at least as many waypoints
  if (repr_fine$n_clusters > 0 && repr_coarse$n_clusters > 0) {
    expect_gte(nrow(repr_fine$representatives),
               nrow(repr_coarse$representatives))
  }
})

test_that("failed clusters are degraded to noise and renumbered", {
  # Create a scenario where at least one cluster produces < 2 waypoints
  # Use very high min_lns for representation to force failure
  clust <- make_test_clusters(eps = 25, min_lns = 3)

  if (clust$n_clusters > 0) {
    # Use a min_lns higher than any cluster's segment count for representation
    max_segs <- max(clust$cluster_summary$n_segments)
    repr <- suppressMessages(
      suppressWarnings(
        tc_represent(clust, min_lns = max_segs + 1)
      )
    )

    # All clusters should fail (min_lns too high for any waypoint)
    expect_equal(repr$n_clusters, 0L)
    expect_true(all(is.na(repr$segments$cluster_id)))
  }
})

test_that("pre-cleanup reference is preserved in clusters element", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  # The clusters reference should be the original, unmodified object
  expect_identical(repr$clusters, clust)
  # Original cluster IDs are preserved in the reference
  expect_equal(repr$clusters$n_clusters, clust$n_clusters)
})

# --- Sweep-line internals ---------------------------------------------------

test_that(".compute_average_direction returns unit vector", {
  dir <- TRACLUS:::.compute_average_direction(
    sx = c(0, 0), sy = c(0, 0),
    ex = c(10, 5), ey = c(0, 0)
  )
  magnitude <- sqrt(dir[1]^2 + dir[2]^2)
  expect_equal(magnitude, 1.0, tolerance = 1e-10)
})

test_that(".compute_average_direction with horizontal segments", {
  dir <- TRACLUS:::.compute_average_direction(
    sx = c(0, 0, 0), sy = c(0, 1, 2),
    ex = c(10, 10, 10), ey = c(0, 1, 2)
  )
  # All horizontal: direction should be (1, 0)
  expect_equal(dir, c(1, 0), tolerance = 1e-10)
})

test_that(".compute_average_direction warns on cancellation", {
  # Two segments pointing in opposite directions
  expect_warning(
    dir <- TRACLUS:::.compute_average_direction(
      sx = c(0, 10), sy = c(0, 0),
      ex = c(10, 0), ey = c(0, 0)
    ),
    "cancel out"
  )
  # Fallback to X-axis
  expect_equal(dir, c(1, 0))
})

test_that(".rotate_to_axis and .rotate_from_axis are inverses", {
  dir_vec <- c(cos(pi / 6), sin(pi / 6))  # 30 degrees
  x_orig <- c(3, 7, -2)
  y_orig <- c(4, -1, 5)

  rotated <- TRACLUS:::.rotate_to_axis(x_orig, y_orig, dir_vec)
  restored <- TRACLUS:::.rotate_from_axis(rotated$x, rotated$y, dir_vec)

  expect_equal(restored$x, x_orig, tolerance = 1e-10)
  expect_equal(restored$y, y_orig, tolerance = 1e-10)
})

test_that(".sweep_line_representative produces correct output for parallel segments", {
  # 3 parallel segments at y = 0, 1, 2 with staggered starts
  # so that entry events occur at different x-positions, producing >= 2 waypoints
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 1, 2), sy = c(0, 1, 2),
    ex = c(10, 11, 12), ey = c(0, 1, 2),
    traj_id = c("A", "B", "C"),
    min_lns = 2, gamma = 0.001
  )

  expect_true(!is.null(result))
  expect_true(nrow(result) >= 2)
  # Representative should be near y = 1 (mean of 0, 1, 2)
  expect_equal(mean(result$ry), 1.0, tolerance = 0.5)
})

test_that(".sweep_line_representative returns NULL for sparse segments", {
  # Only 1 segment — can't reach min_lns = 3
  result <- TRACLUS:::.sweep_line_representative(
    sx = 0, sy = 0, ex = 10, ey = 0,
    traj_id = "A",
    min_lns = 3, gamma = 1
  )
  expect_null(result)
})

test_that(".sweep_line_representative handles segments in opposite directions", {
  # 4 segments: two LTR and two RTL, with staggered entry positions
  # After normalization (left_x < right_x), entries occur at different x-positions
  # ensuring >= 2 waypoints are generated
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 12, 2, 14), sy = c(0, 1, 0.5, 1.5),
    ex = c(10, 2, 12, 4), ey = c(0, 1, 0.5, 1.5),
    traj_id = c("A", "B", "C", "D"),
    min_lns = 2, gamma = 0.001
  )

  expect_true(!is.null(result))
  expect_true(nrow(result) >= 2)
})

# --- Equirectangular projection ---------------------------------------------

test_that(".equirectangular_proj and _inverse are inverses", {
  lon <- c(-74.006, -73.935, -73.870)
  lat <- c(40.712, 40.730, 40.745)
  lat_mean <- mean(lat)

  proj <- TRACLUS:::.equirectangular_proj(lon, lat, lat_mean)
  inv <- TRACLUS:::.equirectangular_inverse(proj$x, proj$y, lat_mean)

  expect_equal(inv$lon, lon, tolerance = 1e-10)
  expect_equal(inv$lat, lat, tolerance = 1e-10)
})

test_that(".equirectangular_proj produces meter-scale values", {
  # 1 degree of latitude is approx 111320 meters
  proj <- TRACLUS:::.equirectangular_proj(0, 1, 0)
  expect_equal(proj$y, 111320, tolerance = 1)
  expect_equal(proj$x, 0, tolerance = 1e-10)
})

# --- Print and summary ------------------------------------------------------

test_that("print.tc_representatives works", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  out <- capture.output(print(repr))
  expect_true(any(grepl("TRACLUS Representatives", out)))
  expect_true(any(grepl("complete", out)))
})

test_that("summary.tc_representatives works", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  out <- capture.output(summary(repr))
  expect_true(any(grepl("TRACLUS Representatives - Summary", out)))
  expect_true(any(grepl("gamma", out)))
})

test_that("summary.tc_representatives works with 0 clusters", {
  clust <- make_test_clusters()
  clust$n_clusters <- 0L
  clust$segments$cluster_id <- NA_integer_
  clust$n_noise <- nrow(clust$segments)

  repr <- suppressMessages(suppressWarnings(tc_represent(clust)))
  out <- capture.output(summary(repr))
  expect_true(any(grepl("Clusters:.*0", out)))
})

# --- Verbose control --------------------------------------------------------

test_that("verbose = TRUE produces message", {
  clust <- make_test_clusters()
  expect_message(
    tc_represent(clust, verbose = TRUE),
    "Representatives:"
  )
})

test_that("verbose = FALSE suppresses message", {
  clust <- make_test_clusters()
  expect_no_message(
    suppressWarnings(tc_represent(clust, verbose = FALSE))
  )
})

# --- Golden-Value Tests ---
# 5 parallel horizontal segments with staggered start positions.
# Hand-computed: average direction, rotation, event order, interpolated y-values.
#
# Segments:
#   S1: (0,0)  -> (10,0)    len 10
#   S2: (2,1)  -> (10,1)    len 8
#   S3: (1,2)  -> (10,2)    len 9
#   S4: (3,3)  -> (10,3)    len 7
#   S5: (4,1.5) -> (8,1.5)  len 4

test_that("golden: average direction for horizontal segments is (1, 0)", {
  # Sum of direction vectors:
  #   S1: (10,0), S2: (8,0), S3: (9,0), S4: (7,0), S5: (4,0)
  #   Sum = (38, 0). Normalized = (1, 0).
  dir <- TRACLUS:::.compute_average_direction(
    sx = c(0, 2, 1, 3, 4), sy = c(0, 1, 2, 3, 1.5),
    ex = c(10, 10, 10, 10, 8), ey = c(0, 1, 2, 3, 1.5)
  )
  expect_equal(dir, c(1, 0), tolerance = 1e-10)
})

test_that("golden: rotation is identity for direction (1, 0)", {
  # Rotation matrix for dir=(1,0): cos=1, sin=0
  # x' = x*1 + y*0 = x
  # y' = -x*0 + y*1 = y
  dir_vec <- c(1, 0)
  x_orig <- c(0, 2, 1, 3, 4)
  y_orig <- c(0, 1, 2, 3, 1.5)
  rotated <- TRACLUS:::.rotate_to_axis(x_orig, y_orig, dir_vec)

  expect_equal(rotated$x, x_orig, tolerance = 1e-10)
  expect_equal(rotated$y, y_orig, tolerance = 1e-10)
})

test_that("golden: sweep-line waypoints for 5 horizontal segments", {
  # With min_lns=3, gamma=0.001:
  #
  # Events sorted by x (entries before exits at same x):
  #   x=0:  Entry S1 (count=1)        — count < 3, skip
  #   x=1:  Entry S3 (count=2)        — count < 3, skip
  #   x=2:  Entry S2 (count=3) ★      — count >= 3, WP candidate
  #   x=3:  Entry S4 (count=4) ★      — count >= 3, WP candidate
  #   x=4:  Entry S5 (count=5) ★      — count >= 3, WP candidate
  #   x=8:  Exit  S5 (count 5→4) ★    — count >= 3, WP candidate (exit)
  #   x=10: Exit  S1,S2,S3,S4 (count 4→0) ★ — count >= 3 before exits, WP
  #
  # Waypoint 1 at x=2: active = {S1, S2, S3}
  #   S1: (0,0)→(10,0), t=(2-0)/10=0.2, y=0
  #   S2: (2,1)→(10,1), t=(2-2)/8=0,   y=1
  #   S3: (1,2)→(10,2), t=(2-1)/9=1/9, y=2
  #   mean_y = (0 + 1 + 2) / 3 = 1.0
  #   WP1 = (2, 1.0)
  #
  # Waypoint 2 at x=3: active = {S1, S2, S3, S4}
  #   S1: t=3/10, y=0 | S2: t=1/8, y=1 | S3: t=2/9, y=2 | S4: t=0/7, y=3
  #   mean_y = (0 + 1 + 2 + 3) / 4 = 1.5
  #   WP2 = (3, 1.5)
  #
  # Waypoint 3 at x=4: active = {S1, S2, S3, S4, S5}
  #   S1: t=4/10, y=0 | S2: t=2/8, y=1 | S3: t=3/9, y=2
  #   S4: t=1/7, y=3  | S5: t=0/4, y=1.5
  #   mean_y = (0 + 1 + 2 + 3 + 1.5) / 5 = 1.5
  #   WP3 = (4, 1.5)
  #
  # Waypoint 4 at x=8: active = {S1, S2, S3, S4, S5} (exit S5 not yet removed)
  #   S1: t=8/10, y=0 | S2: t=6/8, y=1 | S3: t=7/9, y=2
  #   S4: t=5/7, y=3  | S5: t=4/4=1, y=1.5
  #   mean_y = (0 + 1 + 2 + 3 + 1.5) / 5 = 1.5
  #   WP4 = (8, 1.5)
  #
  # Waypoint 5 at x=10: active = {S1, S2, S3, S4} (S5 already exited)
  #   S1: t=1, y=0 | S2: t=1, y=1 | S3: t=1, y=2 | S4: t=1, y=3
  #   mean_y = (0 + 1 + 2 + 3) / 4 = 1.5
  #   WP5 = (10, 1.5)
  #
  # Back-rotation with dir=(1,0) is identity => waypoints unchanged.
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 2, 1, 3, 4), sy = c(0, 1, 2, 3, 1.5),
    ex = c(10, 10, 10, 10, 8), ey = c(0, 1, 2, 3, 1.5),
    traj_id = c("A", "B", "C", "D", "E"),
    min_lns = 3, gamma = 0.001
  )

  expect_false(is.null(result))
  expect_equal(nrow(result), 5)

  # Waypoint coordinates
  expect_equal(result$rx, c(2, 3, 4, 8, 10), tolerance = 1e-10)
  expect_equal(result$ry, c(1.0, 1.5, 1.5, 1.5, 1.5), tolerance = 1e-10)
})

test_that("golden: gamma spacing and exit-event waypoints", {
  # With only 4 segments (drop S5) and min_lns=3, gamma=2:
  #
  # Events:
  #   x=0:  Entry S1 (count=1)  — count < 3, skip
  #   x=1:  Entry S3 (count=2)  — count < 3, skip
  #   x=2:  Entry S2 (count=3)  — count >= 3, diff=∞ >= 2 → WP(2, 1.0)
  #   x=3:  Entry S4 (count=4)  — count >= 3, diff=3-2=1 < 2 → skip
  #   x=10: Exit S1,S2,S3,S4    — count=4 >= 3, diff=10-2=8 >= 2 → WP
  #     Active: {S1,S2,S3,S4}. All at endpoint: y=0,1,2,3.
  #     mean_y = (0+1+2+3)/4 = 1.5  →  WP(10, 1.5)
  #
  # 2 waypoints: (2, 1.0) and (10, 1.5).
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 2, 1, 3), sy = c(0, 1, 2, 3),
    ex = c(10, 10, 10, 10), ey = c(0, 1, 2, 3),
    traj_id = c("A", "B", "C", "D"),
    min_lns = 3, gamma = 2
  )
  expect_false(is.null(result))
  expect_equal(nrow(result), 2)
  expect_equal(result$rx, c(2, 10), tolerance = 1e-10)
  expect_equal(result$ry, c(1.0, 1.5), tolerance = 1e-10)
})

# --- Trajectory diversity fix (sweep-line trajectory-diversity check) -------

test_that("diversity fix: consecutive same-trajectory segments produce no representative", {
  # 3 consecutive segments from the SAME trajectory, sharing endpoints.
  # Without the diversity fix, entry-before-exit creates count=2 at
  # shared points P1=(10,0) and P2=(20,0), producing 2 waypoints.
  # With the fix: all active segments are from traj "A", so
  # n_distinct_traj=1 < 2 → no waypoints → NULL.
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 10, 20), sy = c(0, 0, 0),
    ex = c(10, 20, 30), ey = c(0, 0, 0),
    traj_id = c("A", "A", "A"),
    min_lns = 2, gamma = 0.001
  )
  expect_null(result)
})

test_that("diversity fix: two overlapping segments from different trajectories work", {
  # 2 parallel segments from DIFFERENT trajectories, overlapping in X'.
  # count=2 at entry positions, n_distinct_traj=2 >= 2 → waypoints generated.
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 1), sy = c(0, 1),
    ex = c(10, 11), ey = c(0, 1),
    traj_id = c("A", "B"),
    min_lns = 2, gamma = 0.001
  )
  expect_false(is.null(result))
  expect_true(nrow(result) >= 2)
})

test_that("diversity fix: mixed cluster produces representative only in overlap region", {
  # 3 consecutive segments from traj A + 1 segment from traj B
  # that overlaps with the middle segment.
  # Traj A: (0,0)->(10,0), (10,0)->(20,0), (20,0)->(30,0)
  # Traj B: (8,1)->(22,1) — overlaps with A's segments in X' range [8,22]
  #
  # At x=8: Entry B → count=2 (A_seg1 + B), distinct={A,B}=2 → waypoint
  # At x=10: Entry A_seg2, count=3, distinct={A,B}=2 → waypoint
  # At x=10: Exit A_seg1, count=2
  # At x=20: Entry A_seg3, count=3, distinct={A,B}=2 → waypoint
  # At x=20: Exit A_seg2, count=2
  # At x=22: Exit B, count=1 (only A_seg3) → distinct={A}=1 → NO waypoint
  # At x=30: Exit A_seg3, count=0
  #
  # Representative should exist (>= 2 waypoints) but NOT extend to x=30.
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 10, 20, 8), sy = c(0, 0, 0, 1),
    ex = c(10, 20, 30, 22), ey = c(0, 0, 0, 1),
    traj_id = c("A", "A", "A", "B"),
    min_lns = 2, gamma = 0.001
  )
  expect_false(is.null(result))
  expect_true(nrow(result) >= 2)
  # Representative should not extend beyond x=22 (B's exit)
  expect_true(max(result$rx) <= 22 + 1e-10)
  # Representative should not start before x=8 (B's entry)
  expect_true(min(result$rx) >= 8 - 1e-10)
})

test_that("diversity fix: high min_lns with many trajectories is unchanged", {
  # 5 parallel segments from 5 different trajectories, min_lns=3.
  # This is the normal case — diversity check (n_distinct >= 2) is always
  # satisfied when multiple trajectories are present. Behavior unchanged.
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 2, 1, 3, 4), sy = c(0, 1, 2, 3, 1.5),
    ex = c(10, 10, 10, 10, 8), ey = c(0, 1, 2, 3, 1.5),
    traj_id = c("A", "B", "C", "D", "E"),
    min_lns = 3, gamma = 0.001
  )
  expect_false(is.null(result))
  expect_equal(nrow(result), 5)
  # Same golden values as before the fix
  expect_equal(result$rx, c(2, 3, 4, 8, 10), tolerance = 1e-10)
  expect_equal(result$ry, c(1.0, 1.5, 1.5, 1.5, 1.5), tolerance = 1e-10)
})

# --- Pipe compatibility -----------------------------------------------------

test_that("tc_represent result can be printed invisibly", {
  clust <- make_test_clusters()
  repr <- suppressMessages(tc_represent(clust))

  ret <- capture.output(result <- print(repr))
  expect_s3_class(result, "tc_representatives")
})


test_that("geographic haversine representation: representatives in valid lon/lat range", {
  geo  <- generate_geo_trajectories()
  trj  <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic", verbose = FALSE)
  )
  parts <- suppressMessages(tc_partition(trj))
  clust <- suppressMessages(suppressWarnings(
    tc_cluster(parts, eps = 500000, min_lns = 2)
  ))
  repr <- suppressMessages(suppressWarnings(tc_represent(clust)))

  expect_equal(repr$method, "haversine")

  if (repr$n_clusters > 0) {
    expect_true(
      all(repr$representatives$rx >= -180 & repr$representatives$rx <= 180),
      label = "representative longitudes in [-180, 180]"
    )
    expect_true(
      all(repr$representatives$ry >= -90 & repr$representatives$ry <= 90),
      label = "representative latitudes in [-90, 90]"
    )
  }
})
