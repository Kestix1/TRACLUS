#' Toy trajectory dataset
#'
#' A small euclidean trajectory dataset for testing and demonstration
#' purposes. Contains 6 trajectories in local km coordinates: five
#' roughly horizontal trajectories (TR1--TR5) with 7 points each and one
#' nearly vertical outlier trajectory (TR6) with 5 points.
#'
#' @format A data.frame with 40 rows and 3 columns:
#' \describe{
#'   \item{traj_id}{Character trajectory identifier (`"TR1"` through `"TR6"`).}
#'   \item{x}{Numeric x-coordinate.}
#'   \item{y}{Numeric y-coordinate.}
#' }
#'
#' @examples
#' head(traclus_toy)
#' trj <- tc_trajectories(traclus_toy,
#'   traj_id = "traj_id",
#'   x = "x", y = "y", coord_type = "euclidean"
#' )
#'
#' @source Synthetic data created for the TRACLUS package.
"traclus_toy"
