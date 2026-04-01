# =============================================================================
# Tests for tc_estimate_params (parameter estimation via entropy)
# =============================================================================

make_test_partitions_for_estimate <- function() {
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

test_that("tc_estimate_params returns tc_estimate object", {
  parts <- make_test_partitions_for_estimate()
  est <- suppressMessages(tc_estimate_params(parts))

  expect_s3_class(est, "tc_estimate")
  expect_true(is.numeric(est$eps) && est$eps > 0)
  expect_true(is.integer(est$min_lns) && est$min_lns >= 1)
})

test_that("tc_estimate object has correct structure", {
  parts <- make_test_partitions_for_estimate()
  est <- suppressMessages(tc_estimate_params(parts))

  expect_true(all(c("eps", "min_lns", "w_perp", "w_par", "w_angle",
                     "entropy_df") %in% names(est)))
  expect_s3_class(est$entropy_df, "data.frame")
  expect_true(all(c("eps", "entropy") %in% names(est$entropy_df)))
  expect_equal(nrow(est$entropy_df), 50)  # default grid size
})

test_that("entropy values are non-negative", {
  parts <- make_test_partitions_for_estimate()
  est <- suppressMessages(tc_estimate_params(parts))

  expect_true(all(est$entropy_df$entropy >= 0))
})

test_that("optimal eps is within grid range", {
  parts <- make_test_partitions_for_estimate()
  est <- suppressMessages(tc_estimate_params(parts))

  expect_gte(est$eps, min(est$entropy_df$eps))
  expect_lte(est$eps, max(est$entropy_df$eps))
})

# =============================================================================
# Parameter handling
# =============================================================================

test_that("custom eps_grid is used", {
  parts <- make_test_partitions_for_estimate()
  grid <- c(5, 10, 15, 20, 25, 30)
  est <- suppressMessages(tc_estimate_params(parts, eps_grid = grid))

  expect_equal(nrow(est$entropy_df), 6)
  expect_equal(est$entropy_df$eps, grid)
  expect_true(est$eps %in% grid)
})

test_that("sample_size parameter is respected", {
  parts <- make_test_partitions_for_estimate()
  # Sample size larger than n_segments uses all segments
  est1 <- suppressMessages(tc_estimate_params(parts, sample_size = 5))
  est2 <- suppressMessages(tc_estimate_params(parts, sample_size = 200))

  # Both should produce valid results
  expect_s3_class(est1, "tc_estimate")
  expect_s3_class(est2, "tc_estimate")
})

test_that("custom weights are stored in result", {
  parts <- make_test_partitions_for_estimate()
  est <- suppressMessages(
    tc_estimate_params(parts, w_perp = 2, w_par = 0.5, w_angle = 1.5)
  )

  expect_equal(est$w_perp, 2)
  expect_equal(est$w_par, 0.5)
  expect_equal(est$w_angle, 1.5)
})

test_that("wrong input class gives informative error", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  expect_error(tc_estimate_params(trj),
               "Expected a 'tc_partitions' object")
})

test_that("invalid eps_grid is rejected", {
  parts <- make_test_partitions_for_estimate()

  expect_error(tc_estimate_params(parts, eps_grid = c(-1, 5)),
               "'eps_grid'")
  expect_error(tc_estimate_params(parts, eps_grid = 5),
               "'eps_grid'")  # less than 2 elements
})

test_that("invalid sample_size is rejected", {
  parts <- make_test_partitions_for_estimate()
  expect_error(tc_estimate_params(parts, sample_size = 0), "'sample_size'")
  expect_error(tc_estimate_params(parts, sample_size = -5), "'sample_size'")
})

# =============================================================================
# Tie-breaking
# =============================================================================

test_that("tie in entropy chooses smallest eps", {
  parts <- make_test_partitions_for_estimate()
  # With a very coarse grid where multiple eps may tie
  est <- suppressMessages(tc_estimate_params(parts, eps_grid = c(1, 2, 3)))

  # The minimum entropy should correspond to the smallest eps
  # among those with equal entropy
  min_ent <- min(est$entropy_df$entropy)
  min_eps_candidates <- est$entropy_df$eps[est$entropy_df$entropy == min_ent]
  expect_equal(est$eps, min(min_eps_candidates))
})

# =============================================================================
# Print
# =============================================================================

test_that("print.tc_estimate works", {
  parts <- make_test_partitions_for_estimate()
  est <- suppressMessages(tc_estimate_params(parts))

  out <- capture.output(print(est))
  expect_true(any(grepl("TRACLUS Parameter Estimate", out)))
  expect_true(any(grepl("Optimal eps", out)))
  expect_true(any(grepl("Grid range", out)))
})

test_that("print.tc_estimate shows non-default weights", {
  parts <- make_test_partitions_for_estimate()
  est <- suppressMessages(
    tc_estimate_params(parts, w_perp = 2, w_par = 0.5, w_angle = 1)
  )

  out <- capture.output(print(est))
  expect_true(any(grepl("Weights", out)))
})

# =============================================================================
# Verbose
# =============================================================================

test_that("verbose = TRUE produces message", {
  parts <- make_test_partitions_for_estimate()
  expect_message(
    tc_estimate_params(parts, verbose = TRUE),
    "Estimated parameters"
  )
})

test_that("verbose = FALSE suppresses message", {
  parts <- make_test_partitions_for_estimate()
  expect_no_message(
    tc_estimate_params(parts, verbose = FALSE)
  )
})

# =============================================================================
# method = "projected"
# =============================================================================

test_that("tc_estimate_params with method='projected' returns meter-scale eps", {
  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic", method = "projected")
  )
  parts <- suppressMessages(tc_partition(trj))
  est <- suppressMessages(tc_estimate_params(parts))

  # eps must be in meters: clearly > 1 (not in degree scale < 1)
  expect_gt(est$eps, 100)
  # method propagated into the tc_estimate object
  expect_equal(est$method, "projected")
})
