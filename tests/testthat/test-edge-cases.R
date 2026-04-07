# --- Edge case tests for numerical stability and minimal inputs ---

# --- P9: Numerical instability tests ---

test_that("haversine distances near poles are finite", {
  # Points near the North Pole
  si <- c(0, 89.0)
  ei <- c(90, 89.0)
  sj <- c(45, 89.5)
  ej <- c(135, 89.5)

  d_perp <- tc_dist_perpendicular(si, ei, sj, ej, method = "haversine")
  d_par <- tc_dist_parallel(si, ei, sj, ej, method = "haversine")
  d_ang <- tc_dist_angle(si, ei, sj, ej, method = "haversine")
  d_tot <- tc_dist_segments(si, ei, sj, ej, method = "haversine")

  expect_true(is.finite(d_perp))
  expect_true(is.finite(d_par))
  expect_true(is.finite(d_ang))
  expect_true(is.finite(d_tot))
  expect_gte(d_perp, 0)
  expect_gte(d_par, 0)
  expect_gte(d_ang, 0)
  expect_gte(d_tot, 0)
})

test_that("euclidean distances with large coordinate values are finite", {
  si <- c(1e6, 1e6)
  ei <- c(1e6 + 100, 1e6 + 100)
  sj <- c(1e6 + 50, 1e6 + 200)
  ej <- c(1e6 + 150, 1e6 + 250)

  d_tot <- tc_dist_segments(si, ei, sj, ej, method = "euclidean")
  expect_true(is.finite(d_tot))
  expect_gte(d_tot, 0)
})

test_that("haversine distance with nearly antipodal points is finite", {
  si <- c(0, 0)
  ei <- c(1, 0)
  sj <- c(179, 0)
  ej <- c(180, 0)

  d <- tc_dist_segments(si, ei, sj, ej, method = "haversine")
  expect_true(is.finite(d))
  expect_gte(d, 0)
})

# --- P10: Minimal pipeline test (2 trajectories) ---

test_that("pipeline works with exactly 2 trajectories", {
  df <- data.frame(
    id = rep(c("A", "B"), each = 4),
    x = c(0, 5, 10, 15, 0, 5, 10, 15),
    y = c(0, 1, 0, 1, 2, 3, 2, 3)
  )

  trj <- tc_trajectories(df,
    traj_id = "id", x = "x", y = "y",
    coord_type = "euclidean", verbose = FALSE
  )
  expect_equal(trj$n_trajectories, 2L)

  parts <- tc_partition(trj, verbose = FALSE)
  expect_gte(parts$n_segments, 2L)

  clust <- tc_cluster(parts, eps = 5, min_lns = 2, verbose = FALSE)
  # With 2 trajectories, should get at least some segments
  expect_true(inherits(clust, "tc_clusters"))

  repr <- tc_represent(clust, verbose = FALSE)
  expect_true(inherits(repr, "tc_representatives"))
})

# --- P11: Trajectory reduced to <2 points after dedup ---

test_that("trajectory of identical points is removed after dedup", {
  df <- data.frame(
    id = rep(c("A", "B", "C"), each = 5),
    x = c(
      0, 1, 2, 3, 4, # A: valid
      5, 5, 5, 5, 5, # B: all identical → removed
      10, 11, 12, 13, 14
    ), # C: valid
    y = c(
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0
    )
  )

  expect_warning(
    trj <- tc_trajectories(df,
      traj_id = "id", x = "x", y = "y",
      coord_type = "euclidean", verbose = FALSE
    ),
    "duplicate"
  )
  # B should be removed (only 1 unique point after dedup)
  expect_equal(trj$n_trajectories, 2L)
  expect_false("B" %in% unique(trj$data$traj_id))
})

# --- P13: Antimeridian End-to-End Pipeline ---

test_that("antimeridian crossing: warning issued and tc_partitions object returned", {
  # Two trajectories that cross the antimeridian (lon jump > 180 deg)
  df <- data.frame(
    traj_id = c(rep("CROSS_A", 4), rep("CROSS_B", 4)),
    x = c(
      178, 179, -179, -178, # A crosses antimeridian
      170, 175, 179, -179
    ), # B crosses antimeridian
    y = c(
      40, 41, 41, 40,
      35, 36, 37, 38
    )
  )

  expect_warning(
    trj <- tc_trajectories(df,
      traj_id = "traj_id", x = "x", y = "y",
      coord_type = "geographic", method = "haversine",
      verbose = FALSE
    ),
    "antimeridian"
  )

  expect_s3_class(trj, "tc_trajectories")
  expect_equal(trj$n_trajectories, 2L)

  parts <- tc_partition(trj, verbose = FALSE)
  expect_s3_class(parts, "tc_partitions")
  expect_gte(parts$n_segments, 2L)
})

# --- S12: tc_trajectories class check on data ---

test_that("tc_trajectories rejects non-data.frame input", {
  expect_error(
    tc_trajectories(list(a = 1),
      traj_id = "a", x = "b", y = "c",
      coord_type = "euclidean"
    ),
    "data.frame"
  )
  expect_error(
    tc_trajectories(matrix(1:6, ncol = 3),
      traj_id = "a", x = "b", y = "c",
      coord_type = "euclidean"
    ),
    "data.frame"
  )
})
