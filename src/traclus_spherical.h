#ifndef TRACLUS_SPHERICAL_H
#define TRACLUS_SPHERICAL_H

#include <Rcpp.h>

// Mean Earth radius in meters (WGS-84 mean)
constexpr double EARTH_RADIUS_M = 6371000.0;

// Numerical guard for acos clamping
constexpr double SPHERE_ZERO_THRESHOLD = 1e-15;

// Convert degrees to radians
double deg2rad(double deg);

// Convert radians to degrees
double rad2deg(double rad);

// Haversine distance between two points (lon/lat in degrees), returns meters
double haversine_dist(double lon1, double lat1, double lon2, double lat2);

// Initial bearing (forward azimuth) from point 1 to point 2 (lon/lat in degrees)
// Returns bearing in degrees [0, 360)
double initial_bearing(double lon1, double lat1, double lon2, double lat2);

// Cross-track distance: shortest distance from point (plon, plat) to the
// great circle defined by (lon1, lat1)-(lon2, lat2). Returns ABSOLUTE value in meters.
double cross_track_dist(double plon, double plat,
                        double lon1, double lat1, double lon2, double lat2);

// Signed along-track distance: distance along the great circle from (lon1, lat1)
// to the projection of (plon, plat) onto the great circle through (lon1,lat1)-(lon2,lat2).
// Positive means in the direction of lon1->lon2, negative means behind lon1.
// Returns value in meters.
double along_track_signed(double plon, double plat,
                          double lon1, double lat1, double lon2, double lat2);

// Spherical perpendicular distance between two segments (Paper Def. 1 adapted)
// Li = (lon_si, lat_si)-(lon_ei, lat_ei), Lj = (lon_sj, lat_sj)-(lon_ej, lat_ej)
// Uses cross-track distances and Lehmer mean of order 2
double d_perp_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                  double lon_sj, double lat_sj, double lon_ej, double lat_ej);

// Spherical parallel distance between two segments (Paper Def. 2 adapted)
double d_par_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                 double lon_sj, double lat_sj, double lon_ej, double lat_ej);

// Spherical angle distance between two segments (Paper Def. 3 adapted)
double d_angle_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                   double lon_sj, double lat_sj, double lon_ej, double lat_ej);

// Weighted total spherical distance with early termination
double traclus_dist_sph(double lon_si, double lat_si, double lon_ei, double lat_ei,
                        double lon_sj, double lat_sj, double lon_ej, double lat_ej,
                        double w_perp, double w_par, double w_angle,
                        double eps);

#endif // TRACLUS_SPHERICAL_H
