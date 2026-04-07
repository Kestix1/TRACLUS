#' Estimate clustering parameters from data
#'
#' `r lifecycle::badge("stable")`
#'
#' Provides a data-driven starting point for `eps` and `min_lns` by
#' minimizing the entropy of epsilon-neighbourhood sizes across a grid
#' of candidate eps values (Paper Section 4.4). This is an optional
#' helper — the optimal values are typically found by trial and error.
#'
#' @param x A `tc_partitions` object created by [tc_partition()].
#' @param eps_grid Optional numeric vector of candidate eps values to
#'   evaluate. If `NULL` (default), an intelligent grid of 50 values
#'   is generated from a random sample of pairwise distances (5th to
#'   95th percentile).
#' @param sample_size Integer number of segments to sample for pairwise
#'   distance computation (default 200). Ignored when `eps_grid` is
#'   provided explicitly.
#' @param w_perp,w_par,w_angle Non-negative distance weights (each
#'   default 1). Used for both grid generation and entropy computation.
#' @param verbose Logical; if `TRUE` (default), prints the estimated
#'   parameters.
#'
#' @return A `tc_estimate` S3 object (list) with elements:
#' \describe{
#'   \item{eps}{Numeric: estimated optimal eps value.}
#'   \item{min_lns}{Integer: estimated min_lns value
#'     (ceiling of mean neighbourhood size at optimal eps, + 1).}
#'   \item{w_perp,w_par,w_angle}{Numeric: weight values used
#'     (input values, not estimated).}
#'   \item{entropy_df}{`data.frame` with columns `eps` and `entropy`
#'     for the full grid.}
#' }
#'
#' @details
#' The algorithm works in two stages:
#' 1. **Grid generation** (when `eps_grid = NULL`): A random sample of
#'    `sample_size` segments is drawn. All pairwise distances within the
#'    sample are computed. The grid spans 50 equally spaced values from
#'    the 5th to 95th percentile of these distances.
#' 2. **Entropy computation**: For each candidate eps, the neighbourhood
#'    size of each sampled segment is counted. The entropy of these sizes
#'    (normalized to a probability distribution) is computed. The eps with
#'    minimum entropy is selected. Ties are broken by choosing the smallest
#'    eps.
#'
#' The estimated `min_lns` is `ceiling(mean neighbourhood size at optimal eps) + 1`.
#' This typically yields values of 5 or higher, consistent with the paper's
#' recommendation (Section 4.4). Values below 3 are rarely appropriate and
#' can produce degenerate representatives — see [tc_represent()] for details.
#'
#' @note This function does not break the pipe chain — it accepts a
#'   `tc_partitions` object and returns a `tc_estimate` object (not a
#'   workflow object). Use `result$eps` and `result$min_lns` to extract
#'   the values for [tc_cluster()].
#'
#' @family helper functions
#' @export
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy,
#'   traj_id = "traj_id",
#'   x = "x", y = "y", coord_type = "euclidean"
#' )
#' parts <- tc_partition(trj)
#' \donttest{
#' est <- tc_estimate_params(parts)
#' print(est)
#' }
tc_estimate_params <- function(x, eps_grid = NULL, sample_size = 200L,
                               w_perp = 1, w_par = 1, w_angle = 1,
                               verbose = TRUE) {
  # --- Class check ---
  .check_class(x, "tc_partitions", "tc_partition")

  # --- Validate weights ---
  .validate_weights(w_perp, w_par, w_angle)

  # --- Validate sample_size ---
  if (!is.numeric(sample_size) || length(sample_size) != 1 ||
    !is.finite(sample_size) || sample_size < 2) {
    stop("'sample_size' must be a positive integer >= 2.", call. = FALSE)
  }
  sample_size <- as.integer(sample_size)

  # --- Extract segments ---
  segs <- x$segments
  n_segs <- nrow(segs)
  method <- x$method

  # --- Project coordinates if method = "projected" ---
  is_projected <- (method == "projected")
  if (is_projected) {
    proj_params <- x$trajectories$proj_params
    proj_s <- .equirectangular_proj(segs$sx, segs$sy, proj_params$lat_mean)
    proj_e <- .equirectangular_proj(segs$ex, segs$ey, proj_params$lat_mean)
    segs$sx <- proj_s$x
    segs$sy <- proj_s$y
    segs$ex <- proj_e$x
    segs$ey <- proj_e$y
    dist_method <- "euclidean"
  } else {
    dist_method <- method
  }

  # --- Sample segments ---
  if (n_segs <= sample_size) {
    sample_idx <- seq_len(n_segs)
  } else {
    sample_idx <- sort(sample(n_segs, sample_size))
  }
  n_sample <- length(sample_idx)

  s_sx <- segs$sx[sample_idx]
  s_sy <- segs$sy[sample_idx]
  s_ex <- segs$ex[sample_idx]
  s_ey <- segs$ey[sample_idx]

  # --- Compute pairwise distances for sample (triangular) ---
  pair_dists <- .cpp_compute_pairwise_dists( # nolint: object_usage_linter.
    s_sx, s_sy, s_ex, s_ey,
    w_perp, w_par, w_angle,
    dist_method
  )

  # --- Generate eps grid if not provided ---
  if (is.null(eps_grid)) {
    q5 <- stats::quantile(pair_dists, 0.05)
    q95 <- stats::quantile(pair_dists, 0.95)
    if (q5 >= q95) {
      # Degenerate: all distances nearly equal
      q5 <- min(pair_dists) * 0.5
      q95 <- max(pair_dists) * 1.5
      if (q5 >= q95) q95 <- q5 + 1 # Arbitrary offset to ensure non-empty grid
    }
    eps_grid <- seq(q5, q95, length.out = 50)
  } else {
    # Validate user-provided grid
    if (!is.numeric(eps_grid) || length(eps_grid) < 2 ||
      any(!is.finite(eps_grid)) || any(eps_grid <= 0)) {
      stop("'eps_grid' must be a numeric vector of positive values ",
        "with at least 2 elements.",
        call. = FALSE
      )
    }
    eps_grid <- sort(eps_grid)
  }

  # --- Compute entropy for each candidate eps ---
  # C++: single pass through pair_dists, binary search per pair → O(n_pairs * log(n_eps))
  cpp_result <- .cpp_count_neighbours_multi_eps( # nolint: object_usage_linter.
    pair_dists, n_sample, eps_grid
  )
  mean_nb_sizes <- cpp_result$mean_nb_sizes
  entropy_vals <- cpp_result$entropy_vals

  # --- Find optimal eps (minimum entropy, smallest eps on tie) ---
  min_entropy <- min(entropy_vals)
  min_idx <- which(entropy_vals == min_entropy)
  # Tie-break: smallest eps
  optimal_idx <- min_idx[1]
  optimal_eps <- eps_grid[optimal_idx]

  # --- Estimate min_lns ---
  optimal_min_lns <- as.integer(ceiling(mean_nb_sizes[optimal_idx]) + 1L)
  # Ensure min_lns >= 1
  optimal_min_lns <- max(optimal_min_lns, 1L)

  # --- Build result ---
  entropy_df <- data.frame(
    eps = eps_grid,
    entropy = entropy_vals
  )

  result <- structure(
    list(
      eps = optimal_eps,
      min_lns = optimal_min_lns,
      w_perp = w_perp,
      w_par = w_par,
      w_angle = w_angle,
      entropy_df = entropy_df,
      method = x$method
    ),
    class = "tc_estimate"
  )

  if (verbose) {
    message(sprintf(
      "Estimated parameters: eps = %.4g, min_lns = %d (grid: %.4g to %.4g, %d points).",
      optimal_eps, optimal_min_lns,
      min(eps_grid), max(eps_grid), length(eps_grid)
    ))
  }

  result
}
