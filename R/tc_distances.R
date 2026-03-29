#' Perpendicular distance between two line segments
#'
#' Computes the perpendicular distance between two line segments as defined in
#' the TRACLUS paper (Definition 1). The longer segment is treated as the
#' reference line (Li), and the endpoints of the shorter segment (Lj) are
#' projected onto the **line** (not the segment) through Li. The two
#' perpendicular distances are combined using the Lehmer mean of order 2:
#' \eqn{d_\perp = (l_1^2 + l_2^2) / (l_1 + l_2)}.
#'
#' @param si Numeric vector of length 2: start point of segment i \code{(x, y)}
#'   or \code{(longitude, latitude)}.
#' @param ei Numeric vector of length 2: end point of segment i.
#' @param sj Numeric vector of length 2: start point of segment j.
#' @param ej Numeric vector of length 2: end point of segment j.
#' @param method Character string specifying the distance method. One of
#'   \code{"euclidean"} (default) or \code{"haversine"}. When
#'   \code{"haversine"}, coordinates are interpreted as (longitude, latitude)
#'   in decimal degrees and distances are returned in meters.
#'
#' @return A single non-negative numeric value representing the perpendicular
#'   distance. Units are coordinate units for \code{"euclidean"} or meters for
#'   \code{"haversine"}.
#'
#' @details
#' The swap convention from the original paper is applied internally: the
#' longer segment becomes Li regardless of argument order. At exact length
#' equality (floating-point \code{==}), the first segment (i) is kept as Li.
#'
#' For \code{method = "haversine"}, perpendicular distances are computed as
#' absolute cross-track distances to the great circle through Li, then
#' combined with the same Lehmer formula.
#'
#' @family distance functions
#' @export
#'
#' @examples
#' # Two parallel horizontal segments offset vertically
#' tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
#'
#' # Geographic example (London to Paris great circle, point near Brussels)
#' tc_dist_perpendicular(
#'   c(-0.1278, 51.5074), c(2.3522, 48.8566),
#'   c(0.5, 50.5), c(3.0, 49.5),
#'   method = "haversine"
#' )
tc_dist_perpendicular <- function(si, ei, sj, ej, method = "euclidean") {
  .validate_dist_inputs(si, ei, sj, ej, method)

  if (method == "euclidean") {
    .r_d_perp_euc(si, ei, sj, ej)
  } else {
    .r_d_perp_sph(si, ei, sj, ej)
  }
}

#' Parallel distance between two line segments
#'
#' Computes the parallel distance between two line segments as defined in the
#' TRACLUS paper (Definition 2). The endpoints of the shorter segment (Lj) are
#' projected onto the **line** through the longer segment (Li). The parallel
#' distance of each projected point is its distance to the nearer endpoint of
#' Li. The overall parallel distance is \eqn{d_\parallel = \min(l_1, l_2)}.
#'
#' @inheritParams tc_dist_perpendicular
#'
#' @return A single non-negative numeric value representing the parallel
#'   distance.
#'
#' @details
#' The swap convention from the original paper is applied internally: the
#' longer segment becomes Li. For \code{method = "haversine"}, signed
#' along-track distances are used to compute parallel offsets on the sphere.
#'
#' @family distance functions
#' @export
#'
#' @examples
#' # Overlapping segments: parallel distance is 0
#' tc_dist_parallel(c(0, 0), c(10, 0), c(2, 1), c(8, 1))
#'
#' # Non-overlapping segments
#' tc_dist_parallel(c(0, 0), c(10, 0), c(12, 1), c(15, 1))
tc_dist_parallel <- function(si, ei, sj, ej, method = "euclidean") {
  .validate_dist_inputs(si, ei, sj, ej, method)

  if (method == "euclidean") {
    .r_d_par_euc(si, ei, sj, ej)
  } else {
    .r_d_par_sph(si, ei, sj, ej)
  }
}

#' Angle distance between two line segments
#'
#' Computes the angle distance between two line segments as defined in the
#' TRACLUS paper (Definition 3). The angle \eqn{\theta} between the direction
#' vectors of Li and Lj determines the result:
#' \eqn{d_\theta = \|Lj\| \sin(\theta)} if \eqn{\theta < 90°}, otherwise
#' \eqn{d_\theta = \|Lj\|}.
#'
#' @inheritParams tc_dist_perpendicular
#'
#' @return A single non-negative numeric value representing the angle distance.
#'
#' @details
#' The swap convention is applied internally: the longer segment becomes Li.
#' For \code{method = "haversine"}, the forward azimuth bearing difference
#' is used instead of the euclidean direction vector angle.
#'
#' @family distance functions
#' @export
#'
#' @examples
#' # Parallel segments: angle distance is 0
#' tc_dist_angle(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
#'
#' # Perpendicular segments
#' tc_dist_angle(c(0, 0), c(10, 0), c(5, 0), c(5, 5))
tc_dist_angle <- function(si, ei, sj, ej, method = "euclidean") {
  .validate_dist_inputs(si, ei, sj, ej, method)

  if (method == "euclidean") {
    .r_d_angle_euc(si, ei, sj, ej)
  } else {
    .r_d_angle_sph(si, ei, sj, ej)
  }
}

#' Weighted total distance between two line segments
#'
#' Computes the weighted combination of perpendicular, parallel, and angle
#' distances between two line segments (Paper Section 2.3):
#' \deqn{dist(L_i, L_j) = w_\perp \cdot d_\perp + w_\parallel \cdot d_\parallel + w_\theta \cdot d_\theta}
#'
#' @inheritParams tc_dist_perpendicular
#' @param w_perp Non-negative numeric weight for perpendicular distance.
#'   Default is 1.
#' @param w_par Non-negative numeric weight for parallel distance. Default is 1.
#' @param w_angle Non-negative numeric weight for angle distance. Default is 1.
#'
#' @return A single non-negative numeric value representing the weighted total
#'   distance.
#'
#' @details
#' Each distance component is computed only if its weight is positive. The
#' swap convention (longer segment = Li) is applied independently by each
#' sub-function.
#'
#' @family distance functions
#' @export
#'
#' @examples
#' # Default equal weights
#' tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(8, 6))
#'
#' # Custom weights emphasising perpendicular distance
#' tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(8, 6),
#'                  w_perp = 2, w_par = 0.5, w_angle = 1)
tc_dist_segments <- function(si, ei, sj, ej, w_perp = 1, w_par = 1,
                             w_angle = 1, method = "euclidean") {
  .validate_dist_inputs(si, ei, sj, ej, method)
  .validate_weights(w_perp, w_par, w_angle)

  d_p <- if (w_perp > 0) {
    if (method == "euclidean") .r_d_perp_euc(si, ei, sj, ej)
    else .r_d_perp_sph(si, ei, sj, ej)
  } else {
    0.0
  }

  d_l <- if (w_par > 0) {
    if (method == "euclidean") .r_d_par_euc(si, ei, sj, ej)
    else .r_d_par_sph(si, ei, sj, ej)
  } else {
    0.0
  }

  d_a <- if (w_angle > 0) {
    if (method == "euclidean") .r_d_angle_euc(si, ei, sj, ej)
    else .r_d_angle_sph(si, ei, sj, ej)
  } else {
    0.0
  }

  w_perp * d_p + w_par * d_l + w_angle * d_a
}


# ============================================================================
# Internal R reference implementations — euclidean
# ============================================================================

#' R reference: euclidean segment length
#' @param s Start point (length-2 numeric).
#' @param e End point (length-2 numeric).
#' @return Euclidean distance (double).
#' @keywords internal
.r_seg_len_euc <- function(s, e) {
  sqrt((e[1] - s[1])^2 + (e[2] - s[2])^2)
}

#' R reference: project point onto LINE through ls-le
#' @param p Point (length-2 numeric).
#' @param ls Line start (length-2 numeric).
#' @param le Line end (length-2 numeric).
#' @return Scalar projection parameter t.
#' @keywords internal
.r_project_onto_line <- function(p, ls, le) {
  dx <- le[1] - ls[1]
  dy <- le[2] - ls[2]
  len_sq <- dx * dx + dy * dy
  if (len_sq < 1e-15) return(0.0)
  ((p[1] - ls[1]) * dx + (p[2] - ls[2]) * dy) / len_sq
}

#' R reference: perpendicular distance from point to LINE
#' @param p Point (length-2 numeric).
#' @param ls Line start (length-2 numeric).
#' @param le Line end (length-2 numeric).
#' @return Perpendicular distance (double).
#' @keywords internal
.r_point_to_line_dist <- function(p, ls, le) {
  t <- .r_project_onto_line(p, ls, le)
  proj <- ls + t * (le - ls)
  sqrt(sum((p - proj)^2))
}

#' R reference: apply swap convention — returns list(si, ei, sj, ej) with
#' segment i being the longer one.
#' @param si,ei,sj,ej Segment endpoints (each length-2 numeric).
#' @return List with elements si, ei, sj, ej (possibly swapped).
#' @keywords internal
.r_swap_segments <- function(si, ei, sj, ej) {
  len_i <- .r_seg_len_euc(si, ei)
  len_j <- .r_seg_len_euc(sj, ej)
  # Swap if j is strictly longer; at tie, keep original order

  if (len_j > len_i) {
    list(si = sj, ei = ej, sj = si, ej = ei)
  } else {
    list(si = si, ei = ei, sj = sj, ej = ej)
  }
}

#' R reference: euclidean perpendicular distance (Paper Def. 1)
#' @param si,ei,sj,ej Segment endpoints (each length-2 numeric).
#' @return Perpendicular distance (double).
#' @keywords internal
.r_d_perp_euc <- function(si, ei, sj, ej) {
  s <- .r_swap_segments(si, ei, sj, ej)
  l1 <- .r_point_to_line_dist(s$sj, s$si, s$ei)
  l2 <- .r_point_to_line_dist(s$ej, s$si, s$ei)
  total <- l1 + l2
  if (total < 1e-15) return(0.0)
  (l1^2 + l2^2) / total
}

#' R reference: euclidean parallel distance (Paper Def. 2)
#' @param si,ei,sj,ej Segment endpoints (each length-2 numeric).
#' @return Parallel distance (double).
#' @keywords internal
.r_d_par_euc <- function(si, ei, sj, ej) {
  s <- .r_swap_segments(si, ei, sj, ej)

  # Project Lj endpoints onto LINE through Li
  t_sj <- .r_project_onto_line(s$sj, s$si, s$ei)
  t_ej <- .r_project_onto_line(s$ej, s$si, s$ei)

  proj_sj <- s$si + t_sj * (s$ei - s$si)
  proj_ej <- s$si + t_ej * (s$ei - s$si)

  # Distance from each projection to nearer endpoint of Li
  l_par1 <- min(.r_seg_len_euc(proj_sj, s$si), .r_seg_len_euc(proj_sj, s$ei))
  l_par2 <- min(.r_seg_len_euc(proj_ej, s$si), .r_seg_len_euc(proj_ej, s$ei))

  min(l_par1, l_par2)
}

#' R reference: euclidean angle distance (Paper Def. 3)
#' @param si,ei,sj,ej Segment endpoints (each length-2 numeric).
#' @return Angle distance (double).
#' @keywords internal
.r_d_angle_euc <- function(si, ei, sj, ej) {
  s <- .r_swap_segments(si, ei, sj, ej)

  len_i <- .r_seg_len_euc(s$si, s$ei)
  len_j <- .r_seg_len_euc(s$sj, s$ej)

  if (len_j < 1e-15) return(0.0)
  if (len_i < 1e-15) return(len_j)

  # Direction vectors
  di <- s$ei - s$si
  dj <- s$ej - s$sj

  cos_theta <- sum(di * dj) / (len_i * len_j)
  # Clamp before acos
  cos_theta <- max(-1, min(1, cos_theta))
  theta <- acos(cos_theta)

  if (theta >= pi / 2) {
    len_j
  } else {
    len_j * sin(theta)
  }
}


# ============================================================================
# Internal R reference implementations — spherical (haversine)
# ============================================================================

#' R reference: haversine distance in meters
#' @param p1 Point 1 as c(lon, lat) in degrees.
#' @param p2 Point 2 as c(lon, lat) in degrees.
#' @return Distance in meters (double).
#' @keywords internal
.r_haversine <- function(p1, p2) {
  R <- 6371000.0
  lat1 <- p1[2] * pi / 180
  lat2 <- p2[2] * pi / 180
  dlat <- (p2[2] - p1[2]) * pi / 180
  dlon <- (p2[1] - p1[1]) * pi / 180

  a <- sin(dlat / 2)^2 + cos(lat1) * cos(lat2) * sin(dlon / 2)^2
  a <- max(0, min(1, a))
  2 * R * asin(sqrt(a))
}

#' R reference: initial bearing (forward azimuth) in degrees [0, 360)
#' @param p1 Point 1 as c(lon, lat) in degrees.
#' @param p2 Point 2 as c(lon, lat) in degrees.
#' @return Bearing in degrees (double).
#' @keywords internal
.r_bearing <- function(p1, p2) {
  lat1 <- p1[2] * pi / 180
  lat2 <- p2[2] * pi / 180
  dlon <- (p2[1] - p1[1]) * pi / 180

  x <- sin(dlon) * cos(lat2)
  y <- cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon)

  bearing <- atan2(x, y) * 180 / pi
  (bearing + 360) %% 360
}

#' R reference: cross-track distance (absolute, meters)
#' @param p Point as c(lon, lat) in degrees.
#' @param a Start of great circle as c(lon, lat).
#' @param b End of great circle as c(lon, lat).
#' @return Absolute cross-track distance in meters (double).
#' @keywords internal
.r_cross_track <- function(p, a, b) {
  R <- 6371000.0
  d_ap <- .r_haversine(a, p)
  bearing_ap <- .r_bearing(a, p) * pi / 180
  bearing_ab <- .r_bearing(a, b) * pi / 180
  angular_ap <- d_ap / R

  sin_xt <- sin(angular_ap) * sin(bearing_ap - bearing_ab)
  sin_xt <- max(-1, min(1, sin_xt))
  abs(asin(sin_xt)) * R
}

#' R reference: signed along-track distance (meters)
#' @param p Point as c(lon, lat) in degrees.
#' @param a Start of great circle as c(lon, lat).
#' @param b End of great circle as c(lon, lat).
#' @return Signed along-track distance in meters (double).
#' @keywords internal
.r_along_track_signed <- function(p, a, b) {
  R <- 6371000.0
  d_ap <- .r_haversine(a, p)
  d_xt <- .r_cross_track(p, a, b)

  angular_ap <- d_ap / R
  angular_xt <- d_xt / R

  cos_xt <- cos(angular_xt)
  if (abs(cos_xt) < 1e-15) return(0.0)

  cos_at <- cos(angular_ap) / cos_xt
  cos_at <- max(-1, min(1, cos_at))
  d_at <- acos(cos_at) * R

  # Sign from bearing comparison
  bearing_ap <- .r_bearing(a, p)
  bearing_ab <- .r_bearing(a, b)

  bearing_diff <- abs(bearing_ap - bearing_ab)
  if (bearing_diff > 180) bearing_diff <- 360 - bearing_diff

  if (bearing_diff > 90) d_at <- -d_at

  d_at
}

#' R reference: apply swap convention for spherical segments
#' @param si,ei,sj,ej Segment endpoints (each c(lon, lat)).
#' @return List with swapped endpoints if needed.
#' @keywords internal
.r_swap_segments_sph <- function(si, ei, sj, ej) {
  len_i <- .r_haversine(si, ei)
  len_j <- .r_haversine(sj, ej)
  if (len_j > len_i) {
    list(si = sj, ei = ej, sj = si, ej = ei)
  } else {
    list(si = si, ei = ei, sj = sj, ej = ej)
  }
}

#' R reference: spherical perpendicular distance
#' @param si,ei,sj,ej Segment endpoints (each c(lon, lat)).
#' @return Perpendicular distance in meters (double).
#' @keywords internal
.r_d_perp_sph <- function(si, ei, sj, ej) {
  s <- .r_swap_segments_sph(si, ei, sj, ej)

  l1 <- .r_cross_track(s$sj, s$si, s$ei)
  l2 <- .r_cross_track(s$ej, s$si, s$ei)

  total <- l1 + l2
  if (total < 1e-15) return(0.0)
  (l1^2 + l2^2) / total
}

#' R reference: spherical parallel distance
#' @param si,ei,sj,ej Segment endpoints (each c(lon, lat)).
#' @return Parallel distance in meters (double).
#' @keywords internal
.r_d_par_sph <- function(si, ei, sj, ej) {
  s <- .r_swap_segments_sph(si, ei, sj, ej)

  len_i <- .r_haversine(s$si, s$ei)

  at_sj <- .r_along_track_signed(s$sj, s$si, s$ei)
  at_ej <- .r_along_track_signed(s$ej, s$si, s$ei)

  l_par1 <- min(abs(at_sj), abs(at_sj - len_i))
  l_par2 <- min(abs(at_ej), abs(at_ej - len_i))

  min(l_par1, l_par2)
}

#' R reference: spherical angle distance
#' @param si,ei,sj,ej Segment endpoints (each c(lon, lat)).
#' @return Angle distance in meters (double).
#' @keywords internal
.r_d_angle_sph <- function(si, ei, sj, ej) {
  s <- .r_swap_segments_sph(si, ei, sj, ej)

  len_i <- .r_haversine(s$si, s$ei)
  len_j <- .r_haversine(s$sj, s$ej)

  if (len_j < 1e-15) return(0.0)
  if (len_i < 1e-15) return(len_j)

  bearing_i <- .r_bearing(s$si, s$ei)
  bearing_j <- .r_bearing(s$sj, s$ej)

  # Bearing difference normalised to [0, 180]
  diff_deg <- abs(bearing_i - bearing_j)
  if (diff_deg > 180) diff_deg <- 360 - diff_deg

  if (diff_deg >= 90) return(len_j)

  len_j * sin(diff_deg * pi / 180)
}


# ============================================================================
# Input validation for distance functions
# ============================================================================

#' Validate inputs for distance functions
#' @param si,ei,sj,ej Point vectors to validate.
#' @param method Distance method string.
#' @return NULL (invisible). Throws errors on invalid input.
#' @keywords internal
.validate_dist_inputs <- function(si, ei, sj, ej, method) {
  if (!is.numeric(si) || length(si) != 2) {
    stop("'si' must be a numeric vector of length 2.", call. = FALSE)
  }
  if (!is.numeric(ei) || length(ei) != 2) {
    stop("'ei' must be a numeric vector of length 2.", call. = FALSE)
  }
  if (!is.numeric(sj) || length(sj) != 2) {
    stop("'sj' must be a numeric vector of length 2.", call. = FALSE)
  }
  if (!is.numeric(ej) || length(ej) != 2) {
    stop("'ej' must be a numeric vector of length 2.", call. = FALSE)
  }
  if (!is.character(method) || length(method) != 1 ||
      !method %in% c("euclidean", "haversine")) {
    stop("'method' must be one of 'euclidean' or 'haversine'.", call. = FALSE)
  }
  # Check for non-finite values
  if (any(!is.finite(c(si, ei, sj, ej)))) {
    stop("All coordinate values must be finite (no NA, NaN, or Inf).",
         call. = FALSE)
  }
  # Plausibility check for haversine coordinates
  if (method == "haversine") {
    lats <- c(si[2], ei[2], sj[2], ej[2])
    lons <- c(si[1], ei[1], sj[1], ej[1])
    if (any(lats < -90 | lats > 90)) {
      warning("Latitude values outside [-90, 90]. ",
              "For haversine, coordinates are (longitude, latitude).",
              call. = FALSE)
    }
    if (any(lons < -180 | lons > 180)) {
      warning("Longitude values outside [-180, 180]. ",
              "For haversine, coordinates are (longitude, latitude).",
              call. = FALSE)
    }
  }
  invisible(NULL)
}
