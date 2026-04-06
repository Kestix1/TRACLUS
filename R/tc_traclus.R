#' Run the complete TRACLUS algorithm
#'
#' Convenience wrapper that executes all three TRACLUS steps in sequence:
#' partitioning ([tc_partition()]), clustering ([tc_cluster()]), and
#' representative trajectory generation ([tc_represent()]).
#'
#' @param x A `tc_trajectories` object created by [tc_trajectories()].
#' @param eps Positive numeric distance threshold for clustering.
#'   Unit: meters for `method = "haversine"` or `"projected"`, coordinate
#'   units for `method = "euclidean"`. **Required** — no default.
#' @param min_lns Positive integer (>= 1). Used for both clustering
#'   (minimum neighbourhood size / trajectory cardinality) and
#'   representation (minimum segment density for waypoints).
#'   **Required** — no default.
#' @param gamma Positive numeric smoothing parameter for representative
#'   generation (default 1). Minimum distance between consecutive
#'   waypoints.
#' @param repr_min_lns Optional positive integer. If provided, overrides
#'   `min_lns` for the representation step only (power-user option).
#'   Corresponds to the `min_lns` parameter of [tc_represent()].
#'   If `NULL` (default), the clustering `min_lns` is used for both phases.
#' @param w_perp,w_par,w_angle Non-negative weights for perpendicular,
#'   parallel, and angle distance components (each default 1).
#' @param verbose Logical; if `TRUE` (default), prints informative
#'   messages after each step. Passed through to all three sub-functions.
#'
#' @return A `tc_traclus` object (inherits from `tc_representatives`).
#'   The full reference chain is preserved:
#'   `result$clusters$partitions$trajectories`.
#'
#' @details
#' This wrapper is equivalent to:
#' ```
#' x |> tc_partition() |>
#'   tc_cluster(eps, min_lns, w_perp, w_par, w_angle) |>
#'   tc_represent(gamma, min_lns)
#' ```
#'
#' For iterative parameter tuning, use the step-by-step approach instead:
#' partition once with [tc_partition()], then re-cluster the same
#' partitions object with different `eps`/`min_lns` values.
#'
#' @family workflow functions
#' @export
#'
#' @examples
#' trj <- tc_trajectories(traclus_toy,
#'   traj_id = "traj_id",
#'   x = "x", y = "y", coord_type = "euclidean"
#' )
#' \donttest{
#' result <- tc_traclus(trj, eps = 25, min_lns = 3)
#' print(result)
#' }
tc_traclus <- function(x, eps, min_lns, gamma = 1, repr_min_lns = NULL,
                       w_perp = 1, w_par = 1, w_angle = 1,
                       verbose = TRUE) {
  # --- Class check ---
  .check_class(x, "tc_trajectories", "tc_trajectories")

  # --- Custom error for missing required parameters ---
  if (missing(eps) || missing(min_lns)) {
    stop("'eps' and 'min_lns' are required. Choose values by trial and ",
      "error or use tc_estimate_params() after tc_partition() for a ",
      "data-driven starting point.",
      call. = FALSE
    )
  }

  # --- Parameter validation (fail early before any computation) ---
  .validate_eps(eps)
  .validate_min_lns(min_lns)
  .validate_gamma(gamma)
  .validate_weights(w_perp, w_par, w_angle)
  if (!is.null(repr_min_lns)) {
    .validate_min_lns(repr_min_lns)
  }

  # --- Step 1: Partition ---
  parts <- tc_partition(x, verbose = verbose)

  # --- Step 2: Cluster ---
  clust <- tc_cluster(parts,
    eps = eps, min_lns = min_lns,
    w_perp = w_perp, w_par = w_par, w_angle = w_angle,
    verbose = verbose
  )

  # --- Step 3: Represent ---
  # repr_min_lns overrides min_lns for representation only
  result <- tc_represent(clust,
    gamma = gamma, min_lns = repr_min_lns,
    verbose = verbose
  )

  # --- Add tc_traclus class for potential custom dispatch ---
  class(result) <- c("tc_traclus", "tc_representatives")

  result
}
