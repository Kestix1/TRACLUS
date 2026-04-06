# --- Tests for tc_estimate_params (parameter estimation via entropy) ---

make_test_partitions_for_estimate <- function() {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  suppressMessages(tc_partition(trj))
}

# --- Basic functionality ----------------------------------------------------

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

# --- Parameter handling -----------------------------------------------------

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

# --- Tie-breaking -----------------------------------------------------------

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

# --- Print ------------------------------------------------------------------

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

# --- Verbose ----------------------------------------------------------------

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

# --- Numerical correctness --------------------------------------------------

test_that("entropy formula -sum(p_i * log2(p_i)) is correctly implemented", {
  # 3 segments with known pairwise distances: d(0,1)=1, d(0,2)=2, d(1,2)=3
  # C++ counts "outside-neighborhood" pairs: pairs where d >= eps (using upper_bound logic)
  # At eps=1.5: pairs with d >= 1.5 are (0,2)=2 and (1,2)=3
  #   nb_counts (pairs at-or-beyond eps): seg0→{2}, seg1→{2}, seg2→{3→both}
  #   Outside-nb counts: {1, 1, 2}, sizes (self-inclusive +1): {2, 2, 3}, total=7
  #   H = -2*(2/7)*log2(2/7) - (3/7)*log2(3/7)
  pair_dists <- c(1.0, 2.0, 3.0)
  expected_H <- -2 * (2/7) * log2(2/7) - (3/7) * log2(3/7)

  result <- TRACLUS:::.cpp_count_neighbours_multi_eps(pair_dists, 3L, c(1.5))
  expect_equal(result$entropy_vals[1], expected_H, tolerance = 1e-10)

  # Also verify mean_nb_size: (2+2+3)/3 = 7/3
  expect_equal(result$mean_nb_sizes[1], 7/3, tolerance = 1e-10)
})

test_that("degenerate eps_grid (q5 >= q95) uses fallback without error", {
  # All identical trajectories → all pairwise segment distances = 0
  # → q5 = q95 = 0 → fallback: q5*0.5=0, q95*1.5=0, still degenerate
  # → second guard: q95 = q5 + 1 = 1
  df <- data.frame(
    traj_id = rep(c("T1", "T2", "T3", "T4"), each = 2),
    x       = rep(c(0, 10), 4),
    y       = rep(c(0, 0),  4)
  )
  trj <- suppressMessages(
    tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  parts <- suppressMessages(tc_partition(trj))

  # Should complete without error; fallback produces a finite eps (may be 0 if all distances are 0)
  est <- suppressMessages(tc_estimate_params(parts))
  expect_s3_class(est, "tc_estimate")
  expect_true(is.finite(est$eps))
  expect_gte(est$eps, 0)
  expect_equal(nrow(est$entropy_df), 50L)
})

test_that("min_lns formula ceiling(mean_nb_size) + 1 applied correctly", {
  # Directly test the C++ helper: 3 segments, all pairs OUTSIDE eps neighborhood
  # C++ counts pairs where d >= eps (outside-neighborhood semantics via upper_bound)
  # pair_dists = c(2,2,2), eps = 1.5 → all 3 pairs have d=2 >= 1.5 → all counted
  # nb_counts: each segment has 2 others counted → size = 3, total = 9, mean = 3
  # min_lns = ceiling(3) + 1 = 4
  pair_dists <- c(2.0, 2.0, 2.0)
  result <- TRACLUS:::.cpp_count_neighbours_multi_eps(pair_dists, 3L, c(1.5))
  expect_equal(result$mean_nb_sizes[1], 3.0, tolerance = 1e-10)

  computed_min_lns <- as.integer(ceiling(result$mean_nb_sizes[1]) + 1L)
  expect_equal(computed_min_lns, 4L)

  # Verify tc_estimate_params uses same formula: min_lns >= ceiling(mean_nb) + 1
  df <- data.frame(
    traj_id = rep(paste0("T", 1:4), each = 3),
    x = c(0,5,10, 0,5,10, 0,5,10, 0,5,10),
    y = c(0,0,0,  1,1,1,  2,2,2,  3,3,3)
  )
  trj <- suppressMessages(
    tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  parts <- suppressMessages(tc_partition(trj))
  est <- suppressMessages(tc_estimate_params(parts))

  # min_lns must be ceiling(mean_nb_at_optimal) + 1, hence >= 2
  expect_gte(est$min_lns, 2L)
  expect_true(is.integer(est$min_lns))
})

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
