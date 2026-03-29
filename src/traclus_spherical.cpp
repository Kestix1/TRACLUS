#include "traclus_spherical.h"
#include "traclus_distances.h"
#include <cmath>
#include <algorithm>

// Convert degrees to radians
double deg2rad(double deg) {
  return deg * M_PI / 180.0;
}

// Convert radians to degrees
double rad2deg(double rad) {
  return rad * 180.0 / M_PI;
}

// Haversine distance between two points given in (lon, lat) degrees.
// Returns distance in meters using EARTH_RADIUS_M.
double haversine_dist(double lon1, double lat1, double lon2, double lat2) {
  double rlat1 = deg2rad(lat1);
  double rlat2 = deg2rad(lat2);
  double dlat = deg2rad(lat2 - lat1);
  double dlon = deg2rad(lon2 - lon1);

  double a = std::sin(dlat / 2.0) * std::sin(dlat / 2.0) +
             std::cos(rlat1) * std::cos(rlat2) *
             std::sin(dlon / 2.0) * std::sin(dlon / 2.0);

  // Clamp a to [0, 1] for numerical safety
  a = std::max(0.0, std::min(1.0, a));

  double c = 2.0 * std::asin(std::sqrt(a));
  return EARTH_RADIUS_M * c;
}

// Initial bearing (forward azimuth) from point 1 to point 2.
// Inputs in degrees, output in degrees [0, 360).
double initial_bearing(double lon1, double lat1, double lon2, double lat2) {
  double rlat1 = deg2rad(lat1);
  double rlat2 = deg2rad(lat2);
  double dlon = deg2rad(lon2 - lon1);

  double x = std::sin(dlon) * std::cos(rlat2);
  double y = std::cos(rlat1) * std::sin(rlat2) -
             std::sin(rlat1) * std::cos(rlat2) * std::cos(dlon);

  double bearing = rad2deg(std::atan2(x, y));
  // Normalise to [0, 360)
  bearing = std::fmod(bearing + 360.0, 360.0);
  return bearing;
}

// Cross-track distance: shortest distance from point P to great circle through A-B.
// Returns ABSOLUTE value in meters (sign indicating side is discarded).
// Formula: d_xt = |asin(sin(d_AP/R) * sin(bearing_AP - bearing_AB))| * R
double cross_track_dist(double plon, double plat,
                        double lon1, double lat1, double lon2, double lat2) {
  double d_ap = haversine_dist(lon1, lat1, plon, plat);
  double bearing_ap = deg2rad(initial_bearing(lon1, lat1, plon, plat));
  double bearing_ab = deg2rad(initial_bearing(lon1, lat1, lon2, lat2));

  // Angular distance from A to P
  double angular_ap = d_ap / EARTH_RADIUS_M;

  double sin_xt = std::sin(angular_ap) * std::sin(bearing_ap - bearing_ab);
  // Clamp for numerical safety before asin
  sin_xt = std::max(-1.0, std::min(1.0, sin_xt));

  return std::abs(std::asin(sin_xt)) * EARTH_RADIUS_M;
}

// Signed along-track distance from A along the great circle A-B to the
// projection of P onto that great circle.
// Positive = in direction A->B, negative = behind A.
// Formula: d_at = acos(cos(d_AP/R) / cos(d_xt/R)) * R, with sign from bearing comparison
double along_track_signed(double plon, double plat,
                          double lon1, double lat1, double lon2, double lat2) {
  double d_ap = haversine_dist(lon1, lat1, plon, plat);
  double d_xt = cross_track_dist(plon, plat, lon1, lat1, lon2, lat2);

  double angular_ap = d_ap / EARTH_RADIUS_M;
  double angular_xt = d_xt / EARTH_RADIUS_M;

  double cos_xt = std::cos(angular_xt);
  // Guard against division by zero (point is exactly on the perpendicular through A)
  if (std::abs(cos_xt) < SPHERE_ZERO_THRESHOLD) return 0.0;

  double cos_at = std::cos(angular_ap) / cos_xt;
  // Clamp before acos
  cos_at = std::max(-1.0, std::min(1.0, cos_at));

  double d_at = std::acos(cos_at) * EARTH_RADIUS_M;

  // Determine sign: compare bearing from A to P vs bearing from A to B
  double bearing_ap = initial_bearing(lon1, lat1, plon, plat);
  double bearing_ab = initial_bearing(lon1, lat1, lon2, lat2);

  // The projection is in front of A if the along-track component points
  // in roughly the same direction as A->B
  double bearing_diff = std::abs(bearing_ap - bearing_ab);
  if (bearing_diff > 180.0) bearing_diff = 360.0 - bearing_diff;

  // If bearing difference > 90 degrees, projection is behind A
  if (bearing_diff > 90.0) {
    d_at = -d_at;
  }

  return d_at;
}

// Spherical perpendicular distance (Paper Def. 1 adapted for sphere)
// Uses cross-track distances to the great circle through Li, combined via Lehmer mean
double d_perp_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                  double lon_sj, double lat_sj, double lon_ej, double lat_ej) {
  // Swap convention: Li = longer segment
  double len_i = haversine_dist(lon_si, lat_si, lon_ei, lat_ei);
  double len_j = haversine_dist(lon_sj, lat_sj, lon_ej, lat_ej);

  if (len_j > len_i) {
    std::swap(lon_si, lon_sj); std::swap(lat_si, lat_sj);
    std::swap(lon_ei, lon_ej); std::swap(lat_ei, lat_ej);
  }

  // Cross-track distances (absolute) from Lj endpoints to great circle through Li
  double l_perp1 = cross_track_dist(lon_sj, lat_sj,
                                    lon_si, lat_si, lon_ei, lat_ei);
  double l_perp2 = cross_track_dist(lon_ej, lat_ej,
                                    lon_si, lat_si, lon_ei, lat_ei);

  double sum = l_perp1 + l_perp2;
  // Guard: avoid 0/0 for nearly collinear segments
  if (sum < SPHERE_ZERO_THRESHOLD) return 0.0;

  // Lehmer mean of order 2
  return (l_perp1 * l_perp1 + l_perp2 * l_perp2) / sum;
}

// Spherical parallel distance (Paper Def. 2 adapted for sphere)
// Uses signed along-track distances for projection onto the great circle through Li
double d_par_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                 double lon_sj, double lat_sj, double lon_ej, double lat_ej) {
  // Swap convention: Li = longer segment
  double len_i = haversine_dist(lon_si, lat_si, lon_ei, lat_ei);
  double len_j = haversine_dist(lon_sj, lat_sj, lon_ej, lat_ej);

  if (len_j > len_i) {
    std::swap(lon_si, lon_sj); std::swap(lat_si, lat_sj);
    std::swap(lon_ei, lon_ej); std::swap(lat_ei, lat_ej);
    std::swap(len_i, len_j);
  }

  // Along-track distances (signed) from Li's start to projections of Lj endpoints
  double at_sj = along_track_signed(lon_sj, lat_sj,
                                    lon_si, lat_si, lon_ei, lat_ei);
  double at_ej = along_track_signed(lon_ej, lat_ej,
                                    lon_si, lat_si, lon_ei, lat_ei);

  // l_par1: distance from projected sj to nearest endpoint of Li
  // If at_sj < 0, projection is before si, distance = |at_sj|
  // If at_sj > len_i, projection is past ei, distance = at_sj - len_i
  // Otherwise projection is within the segment, distance = min(at_sj, len_i - at_sj)
  double l_par1 = std::min(std::abs(at_sj), std::abs(at_sj - len_i));
  double l_par2 = std::min(std::abs(at_ej), std::abs(at_ej - len_i));

  return std::min(l_par1, l_par2);
}

// Spherical angle distance (Paper Def. 3 adapted for sphere)
// Uses forward azimuth bearing difference
double d_angle_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                   double lon_sj, double lat_sj, double lon_ej, double lat_ej) {
  // Swap convention: Li = longer segment
  double len_i = haversine_dist(lon_si, lat_si, lon_ei, lat_ei);
  double len_j = haversine_dist(lon_sj, lat_sj, lon_ej, lat_ej);

  if (len_j > len_i) {
    std::swap(lon_si, lon_sj); std::swap(lat_si, lat_sj);
    std::swap(lon_ei, lon_ej); std::swap(lat_ei, lat_ej);
    std::swap(len_i, len_j);
  }

  // Degenerate cases
  if (len_j < SPHERE_ZERO_THRESHOLD) return 0.0;
  if (len_i < SPHERE_ZERO_THRESHOLD) return len_j;

  // Forward azimuths (bearings) of both segments
  double bearing_i = initial_bearing(lon_si, lat_si, lon_ei, lat_ei);
  double bearing_j = initial_bearing(lon_sj, lat_sj, lon_ej, lat_ej);

  // Bearing difference normalised to [0, 180]
  double diff = std::abs(bearing_i - bearing_j);
  if (diff > 180.0) diff = 360.0 - diff;

  // Convert to radians for sin computation
  double theta_rad = deg2rad(diff);

  // Paper: if theta >= 90 degrees, d_angle = len(Lj)
  if (diff >= 90.0) {
    return len_j;
  }

  return len_j * std::sin(theta_rad);
}

// Weighted total spherical distance with early termination
double traclus_dist_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                        double lon_sj, double lat_sj, double lon_ej, double lat_ej,
                        double w_perp, double w_par, double w_angle,
                        double eps) {
  // Swap convention is applied inside each sub-function (d_perp_sph, etc.)
  // so we do NOT swap here to avoid double-swap cancellation.

  double total = 0.0;

  if (w_perp > 0.0) {
    total += w_perp * d_perp_sph(lon_si, lat_si, lon_ei, lat_ei,
                                  lon_sj, lat_sj, lon_ej, lat_ej);
    if (total > eps) return total;
  }

  if (w_par > 0.0) {
    total += w_par * d_par_sph(lon_si, lat_si, lon_ei, lat_ei,
                                lon_sj, lat_sj, lon_ej, lat_ej);
    if (total > eps) return total;
  }

  if (w_angle > 0.0) {
    total += w_angle * d_angle_sph(lon_si, lat_si, lon_ei, lat_ei,
                                    lon_sj, lat_sj, lon_ej, lat_ej);
  }

  return total;
}

// --- Rcpp exports for R-level testing ---

//' Compute haversine distance between two points (C++)
//' @param lon1,lat1 Coordinates of point 1 in degrees
//' @param lon2,lat2 Coordinates of point 2 in degrees
//' @return Distance in meters (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_haversine_dist")]]
double cpp_haversine_dist(double lon1, double lat1, double lon2, double lat2) {
  return haversine_dist(lon1, lat1, lon2, lat2);
}

//' Compute initial bearing between two points (C++)
//' @param lon1,lat1 Coordinates of point 1 in degrees
//' @param lon2,lat2 Coordinates of point 2 in degrees
//' @return Bearing in degrees [0, 360) (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_initial_bearing")]]
double cpp_initial_bearing(double lon1, double lat1, double lon2, double lat2) {
  return initial_bearing(lon1, lat1, lon2, lat2);
}

//' Compute cross-track distance from point to great circle (C++)
//' @param plon,plat Point coordinates in degrees
//' @param lon1,lat1,lon2,lat2 Great circle endpoints in degrees
//' @return Absolute cross-track distance in meters (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_cross_track_dist")]]
double cpp_cross_track_dist(double plon, double plat,
                            double lon1, double lat1, double lon2, double lat2) {
  return cross_track_dist(plon, plat, lon1, lat1, lon2, lat2);
}

//' Compute signed along-track distance (C++)
//' @param plon,plat Point coordinates in degrees
//' @param lon1,lat1,lon2,lat2 Great circle endpoints in degrees
//' @return Signed along-track distance in meters (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_along_track_signed")]]
double cpp_along_track_signed(double plon, double plat,
                              double lon1, double lat1, double lon2, double lat2) {
  return along_track_signed(plon, plat, lon1, lat1, lon2, lat2);
}

//' Compute spherical perpendicular distance between two segments (C++)
//' @param lon_si,lat_si,lon_ei,lat_ei Segment i endpoints in degrees
//' @param lon_sj,lat_sj,lon_ej,lat_ej Segment j endpoints in degrees
//' @return Perpendicular distance in meters (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_d_perp_sph")]]
double cpp_d_perp_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                      double lon_sj, double lat_sj, double lon_ej, double lat_ej) {
  return d_perp_sph(lon_si, lat_si, lon_ei, lat_ei,
                    lon_sj, lat_sj, lon_ej, lat_ej);
}

//' Compute spherical parallel distance between two segments (C++)
//' @param lon_si,lat_si,lon_ei,lat_ei Segment i endpoints in degrees
//' @param lon_sj,lat_sj,lon_ej,lat_ej Segment j endpoints in degrees
//' @return Parallel distance in meters (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_d_par_sph")]]
double cpp_d_par_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                     double lon_sj, double lat_sj, double lon_ej, double lat_ej) {
  return d_par_sph(lon_si, lat_si, lon_ei, lat_ei,
                   lon_sj, lat_sj, lon_ej, lat_ej);
}

//' Compute spherical angle distance between two segments (C++)
//' @param lon_si,lat_si,lon_ei,lat_ei Segment i endpoints in degrees
//' @param lon_sj,lat_sj,lon_ej,lat_ej Segment j endpoints in degrees
//' @return Angle distance in meters (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_d_angle_sph")]]
double cpp_d_angle_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                       double lon_sj, double lat_sj, double lon_ej, double lat_ej) {
  return d_angle_sph(lon_si, lat_si, lon_ei, lat_ei,
                     lon_sj, lat_sj, lon_ej, lat_ej);
}

//' Compute weighted total spherical distance between two segments (C++)
//' @param lon_si,lat_si,lon_ei,lat_ei Segment i endpoints in degrees
//' @param lon_sj,lat_sj,lon_ej,lat_ej Segment j endpoints in degrees
//' @param w_perp,w_par,w_angle Distance component weights
//' @param eps Epsilon threshold for early termination
//' @return Weighted total distance in meters (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_traclus_dist_sph")]]
double cpp_traclus_dist_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                            double lon_sj, double lat_sj, double lon_ej, double lat_ej,
                            double w_perp, double w_par, double w_angle,
                            double eps) {
  return traclus_dist_sph(lon_si, lat_si, lon_ei, lat_ei,
                          lon_sj, lat_sj, lon_ej, lat_ej,
                          w_perp, w_par, w_angle, eps);
}
