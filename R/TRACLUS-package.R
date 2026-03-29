#' @title TRACLUS: Trajectory Clustering Using Line Segments
#'
#' @description
#' Implements the TRACLUS (TRAjectory CLUStering) algorithm for partitioning,
#' clustering, and summarizing trajectory data. The algorithm works in three
#' phases: (1) partition trajectories into line segments using minimum
#' description length (MDL), (2) cluster segments using density-based spatial
#' clustering (DBSCAN), and (3) generate representative trajectories using a
#' sweep-line algorithm. Supports both euclidean and spherical (haversine)
#' distance calculations.
#'
#' @references
#' Lee, J.-G., Han, J., & Whang, K.-Y. (2007). Trajectory clustering:
#' A partition-and-group framework. In \emph{Proceedings of the 2007 ACM
#' SIGMOD International Conference on Management of Data} (pp. 593--604).
#' \doi{10.1145/1247480.1247546}
#'
#' @keywords internal
#' @useDynLib TRACLUS, .registration = TRUE
#' @importFrom Rcpp sourceCpp
"_PACKAGE"
