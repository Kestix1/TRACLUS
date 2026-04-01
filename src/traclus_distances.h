#ifndef TRACLUS_DISTANCES_H
#define TRACLUS_DISTANCES_H

#include <Rcpp.h>

// Numerical guard: values below this are treated as zero
constexpr double ZERO_THRESHOLD = 1e-15;

// Euclidean distance between two 2D points
double euclidean_dist(double x1, double y1, double x2, double y2);

// Length of a 2D line segment
double segment_length_euc(double sx, double sy, double ex, double ey);

// Project point (px, py) onto the line through (lsx, lsy)-(lex, ley).
// Returns the scalar parameter t such that projection = ls + t * (le - ls).
// Projection is onto the LINE (not segment), so t can be outside [0, 1].
double project_onto_line(double px, double py,
                         double lsx, double lsy, double lex, double ley);

// Perpendicular distance from point (px, py) to the line through (lsx, lsy)-(lex, ley)
double point_to_line_dist(double px, double py,
                          double lsx, double lsy, double lex, double ley);

// Euclidean perpendicular distance between two segments (Paper Def. 1)
// Uses Lehmer mean of order 2: (l1^2 + l2^2) / (l1 + l2)
double d_perp_euc(double sx_i, double sy_i, double ex_i, double ey_i,
                  double sx_j, double sy_j, double ex_j, double ey_j);

// Euclidean parallel distance between two segments (Paper Def. 2)
// d_par = min(l_par1, l_par2)
double d_par_euc(double sx_i, double sy_i, double ex_i, double ey_i,
                 double sx_j, double sy_j, double ex_j, double ey_j);

// Euclidean angle distance between two segments (Paper Def. 3)
// d_angle = len(Lj) * sin(theta) if theta < 90, else len(Lj)
double d_angle_euc(double sx_i, double sy_i, double ex_i, double ey_i,
                   double sx_j, double sy_j, double ex_j, double ey_j);

// Weighted total distance: w_perp * d_perp + w_par * d_par + w_angle * d_angle
// with early termination when accumulated distance exceeds eps
double traclus_dist_euc(double sx_i, double sy_i, double ex_i, double ey_i,
                        double sx_j, double sy_j, double ex_j, double ey_j,
                        double w_perp, double w_par, double w_angle,
                        double eps);

#endif // TRACLUS_DISTANCES_H
