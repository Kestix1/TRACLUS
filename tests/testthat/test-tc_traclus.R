# =============================================================================
# Tests for tc_traclus (all-in-one wrapper)
# =============================================================================

test_that("tc_traclus runs complete pipeline on toy data", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  result <- suppressMessages(tc_traclus(trj, eps = 25, min_lns = 3))

  expect_s3_class(result, "tc_traclus")
  expect_s3_class(result, "tc_representatives")
  expect_true(result$n_clusters >= 1)
})

test_that("tc_traclus has correct dual class", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  result <- suppressMessages(tc_traclus(trj, eps = 25, min_lns = 3))

  expect_equal(class(result), c("tc_traclus", "tc_representatives"))
})

test_that("tc_traclus preserves full reference chain", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  result <- suppressMessages(tc_traclus(trj, eps = 25, min_lns = 3))

  # Full chain: tc_traclus -> tc_clusters -> tc_partitions -> tc_trajectories
  expect_s3_class(result$clusters, "tc_clusters")
  expect_s3_class(result$clusters$partitions, "tc_partitions")
  expect_s3_class(result$clusters$partitions$trajectories, "tc_trajectories")
})

test_that("tc_traclus missing eps/min_lns gives custom error", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  expect_error(tc_traclus(trj), "'eps' and 'min_lns' are required")
  expect_error(tc_traclus(trj, eps = 25), "'eps' and 'min_lns' are required")
})

test_that("tc_traclus validates parameters before computation", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  expect_error(tc_traclus(trj, eps = -1, min_lns = 3), "'eps'")
  expect_error(tc_traclus(trj, eps = 25, min_lns = 0), "'min_lns'")
  expect_error(tc_traclus(trj, eps = 25, min_lns = 3, gamma = -1), "'gamma'")
  expect_error(tc_traclus(trj, eps = 25, min_lns = 3, w_perp = -1), "'w_perp'")
})

test_that("tc_traclus rejects wrong input class", {
  parts <- suppressMessages(tc_partition(
    suppressMessages(tc_trajectories(
      generate_toy_trajectories(), traj_id = "traj_id",
      x = "x", y = "y", coord_type = "euclidean"
    ))
  ))
  expect_error(tc_traclus(parts, eps = 25, min_lns = 3),
               "Expected a 'tc_trajectories' object")
})

test_that("tc_traclus passes verbose to all sub-functions", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  # verbose = TRUE: should produce messages from partition, cluster, represent
  msgs <- capture.output(
    result <- tc_traclus(trj, eps = 25, min_lns = 3, verbose = TRUE),
    type = "message"
  )
  expect_true(any(grepl("Partitioned", msgs)))
  expect_true(any(grepl("Clustering", msgs)))
  expect_true(any(grepl("Representatives", msgs)))
})

test_that("tc_traclus verbose = FALSE suppresses all messages", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  expect_no_message(
    suppressWarnings(tc_traclus(trj, eps = 25, min_lns = 3, verbose = FALSE))
  )
})

test_that("tc_traclus repr_min_lns overrides min_lns for representation", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  # Use repr_min_lns = 2 (different from clustering min_lns = 3)
  result <- suppressMessages(
    tc_traclus(trj, eps = 25, min_lns = 3, repr_min_lns = 2)
  )

  expect_equal(result$params$min_lns, 2L)
  expect_equal(result$clusters$params$min_lns, 3L)
})

test_that("tc_traclus custom weights are passed through", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )

  result <- suppressMessages(suppressWarnings(
    tc_traclus(trj, eps = 25, min_lns = 3, w_perp = 2, w_par = 0.5, w_angle = 1)
  ))

  expect_equal(result$clusters$params$w_perp, 2)
  expect_equal(result$clusters$params$w_par, 0.5)
})

test_that("print.tc_traclus works", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  result <- suppressMessages(tc_traclus(trj, eps = 25, min_lns = 3))

  out <- capture.output(print(result))
  expect_true(any(grepl("TRACLUS Result", out)))
  expect_true(any(grepl("complete", out)))
})

test_that("summary.tc_traclus shows full pipeline stats", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  result <- suppressMessages(tc_traclus(trj, eps = 25, min_lns = 3))

  out <- capture.output(summary(result))
  expect_true(any(grepl("TRACLUS Result - Summary", out)))
  expect_true(any(grepl("Input trajs", out)))
  expect_true(any(grepl("Partitioned into", out)))
})
