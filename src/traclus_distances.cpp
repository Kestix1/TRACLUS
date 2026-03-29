#include "traclus_distances.h"
#include <cmath>
#include <algorithm>

// --- Internal helper functions ---

// Euclidean distance between two 2D points
double euclidean_dist(double x1, double y1, double x2, double y2) {
  double dx = x2 - x1;
  double dy = y2 - y1;
  return std::sqrt(dx * dx + dy * dy);
}

// Length of a 2D line segment
double segment_length_euc(double sx, double sy, double ex, double ey) {
  return euclidean_dist(sx, sy, ex, ey);
}

// Project point onto the LINE through ls-le (not clamped to segment).
// Returns scalar t where projection = ls + t * (le - ls).
double project_onto_line(double px, double py,
                         double lsx, double lsy, double lex, double ley) {
  double dx = lex - lsx;
  double dy = ley - lsy;
  double len_sq = dx * dx + dy * dy;
  // Degenerate segment: return 0
  if (len_sq < ZERO_THRESHOLD) return 0.0;
  return ((px - lsx) * dx + (py - lsy) * dy) / len_sq;
}

// Perpendicular distance from point to the LINE through ls-le
double point_to_line_dist(double px, double py,
                          double lsx, double lsy, double lex, double ley) {
  double t = project_onto_line(px, py, lsx, lsy, lex, ley);
  // Projected point on the line
  double proj_x = lsx + t * (lex - lsx);
  double proj_y = lsy + t * (ley - lsy);
  return euclidean_dist(px, py, proj_x, proj_y);
}

// --- Swap convention: Li = longer segment, Lj = shorter ---
// This is applied internally before each distance computation.
// At tie, the first segment (i) stays as Li — consistent with R implementation.

// Perpendicular distance (Paper Definition 1)
// Lehmer mean of order 2: (l1^2 + l2^2) / (l1 + l2)
double d_perp_euc(double sx_i, double sy_i, double ex_i, double ey_i,
                  double sx_j, double sy_j, double ex_j, double ey_j) {
  // Apply swap convention: Li = longer segment
  double len_i = segment_length_euc(sx_i, sy_i, ex_i, ey_i);
  double len_j = segment_length_euc(sx_j, sy_j, ex_j, ey_j);

  if (len_j > len_i) {
    // Swap so that (i) is the longer segment
    std::swap(sx_i, sx_j); std::swap(sy_i, sy_j);
    std::swap(ex_i, ex_j); std::swap(ey_i, ey_j);
  }

  // Project endpoints of Lj onto the LINE through Li
  double l_perp1 = point_to_line_dist(sx_j, sy_j, sx_i, sy_i, ex_i, ey_i);
  double l_perp2 = point_to_line_dist(ex_j, ey_j, sx_i, sy_i, ex_i, ey_i);

  double sum = l_perp1 + l_perp2;
  // Guard: avoid 0/0 for nearly collinear segments
  if (sum < ZERO_THRESHOLD) return 0.0;

  return (l_perp1 * l_perp1 + l_perp2 * l_perp2) / sum;
}

// Parallel distance (Paper Definition 2)
// d_par = min(l_par1, l_par2)
double d_par_euc(double sx_i, double sy_i, double ex_i, double ey_i,
                 double sx_j, double sy_j, double ex_j, double ey_j) {
  // Apply swap convention: Li = longer segment
  double len_i = segment_length_euc(sx_i, sy_i, ex_i, ey_i);
  double len_j = segment_length_euc(sx_j, sy_j, ex_j, ey_j);

  if (len_j > len_i) {
    std::swap(sx_i, sx_j); std::swap(sy_i, sy_j);
    std::swap(ex_i, ex_j); std::swap(ey_i, ey_j);
    std::swap(len_i, len_j);
  }

  // Project endpoints of Lj onto the LINE through Li
  double t_sj = project_onto_line(sx_j, sy_j, sx_i, sy_i, ex_i, ey_i);
  double t_ej = project_onto_line(ex_j, ey_j, sx_i, sy_i, ex_i, ey_i);

  // Projected points on the line through Li
  double proj_sj_x = sx_i + t_sj * (ex_i - sx_i);
  double proj_sj_y = sy_i + t_sj * (ey_i - sy_i);
  double proj_ej_x = sx_i + t_ej * (ex_i - sx_i);
  double proj_ej_y = sy_i + t_ej * (ey_i - sy_i);

  // l_par1: distance from projected sj to the NEARER endpoint of Li
  double d_sj_to_si = euclidean_dist(proj_sj_x, proj_sj_y, sx_i, sy_i);
  double d_sj_to_ei = euclidean_dist(proj_sj_x, proj_sj_y, ex_i, ey_i);
  double l_par1 = std::min(d_sj_to_si, d_sj_to_ei);

  // l_par2: distance from projected ej to the NEARER endpoint of Li
  double d_ej_to_si = euclidean_dist(proj_ej_x, proj_ej_y, sx_i, sy_i);
  double d_ej_to_ei = euclidean_dist(proj_ej_x, proj_ej_y, ex_i, ey_i);
  double l_par2 = std::min(d_ej_to_si, d_ej_to_ei);

  return std::min(l_par1, l_par2);
}

// Angle distance (Paper Definition 3)
// d_angle = len(Lj) * sin(theta) if theta < 90, else len(Lj)
double d_angle_euc(double sx_i, double sy_i, double ex_i, double ey_i,
                   double sx_j, double sy_j, double ex_j, double ey_j) {
  // Apply swap convention: Li = longer segment
  double len_i = segment_length_euc(sx_i, sy_i, ex_i, ey_i);
  double len_j = segment_length_euc(sx_j, sy_j, ex_j, ey_j);

  if (len_j > len_i) {
    std::swap(sx_i, sx_j); std::swap(sy_i, sy_j);
    std::swap(ex_i, ex_j); std::swap(ey_i, ey_j);
    std::swap(len_i, len_j);
  }

  // Degenerate: if Lj has zero length, angle distance is 0
  if (len_j < ZERO_THRESHOLD) return 0.0;
  // If Li has zero length, angle is undefined; return len_j as worst case
  if (len_i < ZERO_THRESHOLD) return len_j;

  // Direction vectors
  double dx_i = ex_i - sx_i;
  double dy_i = ey_i - sy_i;
  double dx_j = ex_j - sx_j;
  double dy_j = ey_j - sy_j;

  // Cosine of angle between direction vectors
  double dot = dx_i * dx_j + dy_i * dy_j;
  double cos_theta = dot / (len_i * len_j);
  // Clamp to avoid NaN from acos due to floating point
  cos_theta = std::max(-1.0, std::min(1.0, cos_theta));

  double theta = std::acos(cos_theta);

  // Paper uses the acute/right angle interpretation:
  // If theta > 90 degrees, the segments point in roughly opposite directions
  if (theta >= M_PI / 2.0) {
    // Paper: d_angle = len(Lj) when theta >= 90
    return len_j;
  }

  return len_j * std::sin(theta);
}

// Weighted total distance with early termination
// Paper Section 2.3: dist(Li, Lj) = w_perp * d_perp + w_par * d_par + w_angle * d_angle
// eps parameter enables early termination: if accumulated distance exceeds eps,
// remaining components can be skipped since all components are non-negative.
double traclus_dist_euc(double sx_i, double sy_i, double ex_i, double ey_i,
                        double sx_j, double sy_j, double ex_j, double ey_j,
                        double w_perp, double w_par, double w_angle,
                        double eps) {
  // Swap convention is applied inside each sub-function (d_perp_euc, etc.)
  // so we do NOT swap here to avoid double-swap cancellation.

  double total = 0.0;

  // Perpendicular component
  if (w_perp > 0.0) {
    total += w_perp * d_perp_euc(sx_i, sy_i, ex_i, ey_i,
                                  sx_j, sy_j, ex_j, ey_j);
    if (total > eps) return total;
  }

  // Parallel component
  if (w_par > 0.0) {
    total += w_par * d_par_euc(sx_i, sy_i, ex_i, ey_i,
                                sx_j, sy_j, ex_j, ey_j);
    if (total > eps) return total;
  }

  // Angle component
  if (w_angle > 0.0) {
    total += w_angle * d_angle_euc(sx_i, sy_i, ex_i, ey_i,
                                    sx_j, sy_j, ex_j, ey_j);
  }

  return total;
}

// --- Rcpp exports for R-level access (used in tests and tc_distances.R) ---

//' Compute euclidean perpendicular distance between two segments (C++)
//' @param si_x,si_y,ei_x,ei_y Coordinates of segment i
//' @param sj_x,sj_y,ej_x,ej_y Coordinates of segment j
//' @return Perpendicular distance (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_d_perp_euc")]]
double cpp_d_perp_euc(double si_x, double si_y, double ei_x, double ei_y,
                      double sj_x, double sj_y, double ej_x, double ej_y) {
  return d_perp_euc(si_x, si_y, ei_x, ei_y, sj_x, sj_y, ej_x, ej_y);
}

//' Compute euclidean parallel distance between two segments (C++)
//' @param si_x,si_y,ei_x,ei_y Coordinates of segment i
//' @param sj_x,sj_y,ej_x,ej_y Coordinates of segment j
//' @return Parallel distance (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_d_par_euc")]]
double cpp_d_par_euc(double si_x, double si_y, double ei_x, double ei_y,
                     double sj_x, double sj_y, double ej_x, double ej_y) {
  return d_par_euc(si_x, si_y, ei_x, ei_y, sj_x, sj_y, ej_x, ej_y);
}

//' Compute euclidean angle distance between two segments (C++)
//' @param si_x,si_y,ei_x,ei_y Coordinates of segment i
//' @param sj_x,sj_y,ej_x,ej_y Coordinates of segment j
//' @return Angle distance (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_d_angle_euc")]]
double cpp_d_angle_euc(double si_x, double si_y, double ei_x, double ei_y,
                       double sj_x, double sj_y, double ej_x, double ej_y) {
  return d_angle_euc(si_x, si_y, ei_x, ei_y, sj_x, sj_y, ej_x, ej_y);
}

//' Compute weighted total euclidean distance between two segments (C++)
//' @param si_x,si_y,ei_x,ei_y Coordinates of segment i
//' @param sj_x,sj_y,ej_x,ej_y Coordinates of segment j
//' @param w_perp,w_par,w_angle Distance component weights
//' @param eps Epsilon threshold for early termination
//' @return Weighted total distance (double)
//' @keywords internal
// [[Rcpp::export(name = ".cpp_traclus_dist_euc")]]
double cpp_traclus_dist_euc(double si_x, double si_y, double ei_x, double ei_y,
                            double sj_x, double sj_y, double ej_x, double ej_y,
                            double w_perp, double w_par, double w_angle,
                            double eps) {
  return traclus_dist_euc(si_x, si_y, ei_x, ei_y,
                          sj_x, sj_y, ej_x, ej_y,
                          w_perp, w_par, w_angle, eps);
}
