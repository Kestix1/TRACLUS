#include <Rcpp.h>
#include <vector>
#include <string>
#include "traclus_distances.h"
#include "traclus_spherical.h"

#include <progress.hpp>
#include <progress_bar.hpp>

// ============================================================================
// Epsilon-neighbourhood computation using triangular matrix approach.
// Exploits symmetry: dist(i,j) = dist(j,i), so only i < j is computed.
// Results are stored bidirectionally in adjacency lists.
// Early termination in distance calculation when accumulated dist > eps.
// Periodic checkUserInterrupt() for CRAN compliance.
// RcppProgress bar for large segment counts (n > 5000).
// ============================================================================

//' Compute epsilon-neighbourhoods for all segments (C++)
//'
//' Computes pairwise distances between all line segments using the TRACLUS
//' weighted distance function. Uses a triangular loop (i < j) to exploit
//' symmetry and early termination when accumulated distance exceeds eps.
//' Returns adjacency lists of segment indices within eps distance.
//'
//' @param sx NumericVector of segment start x-coordinates
//' @param sy NumericVector of segment start y-coordinates
//' @param ex NumericVector of segment end x-coordinates
//' @param ey NumericVector of segment end y-coordinates
//' @param eps Distance threshold
//' @param w_perp Weight for perpendicular distance
//' @param w_par Weight for parallel distance
//' @param w_angle Weight for angle distance
//' @param method Distance method: "euclidean" or "haversine"
//' @param show_progress Whether to show progress bar (only for n > 5000)
//' @return List of integer vectors (adjacency lists, 1-indexed for R).
//'   Each element contains the indices of neighbouring segments within eps.
//' @keywords internal
// [[Rcpp::export(name = ".cpp_compute_neighbourhoods")]]
Rcpp::List cpp_compute_neighbourhoods(Rcpp::NumericVector sx,
                                      Rcpp::NumericVector sy,
                                      Rcpp::NumericVector ex,
                                      Rcpp::NumericVector ey,
                                      double eps,
                                      double w_perp,
                                      double w_par,
                                      double w_angle,
                                      std::string method,
                                      bool show_progress) {
  int n = sx.size();
  bool use_haversine = (method == "haversine");

  // Pre-allocate adjacency lists as vectors of vectors
  std::vector<std::vector<int>> adj(n);

  // Show progress bar only for large datasets (n > 5000) and when requested
  bool display_progress = show_progress && (n > 5000);
  // Total comparisons in triangular loop: n*(n-1)/2
  // We track progress by outer loop iterations
  Progress progress(n, display_progress);

  // Triangular loop: compute dist(i,j) only for i < j, store bidirectionally
  for (int i = 0; i < n - 1; i++) {
    // CRAN compliance: allow user interrupts every 1000 outer iterations
    if (i % 1000 == 0) {
      Rcpp::checkUserInterrupt();
    }

    if (Progress::check_abort()) {
      Rcpp::stop("User aborted neighbourhood computation.");
    }
    progress.increment();

    double sxi = sx[i], syi = sy[i], exi = ex[i], eyi = ey[i];

    for (int j = i + 1; j < n; j++) {
      double dist;

      if (use_haversine) {
        // Spherical distance: coordinates are (lon, lat) in degrees
        dist = traclus_dist_sph(sxi, syi, exi, eyi,
                                sx[j], sy[j], ex[j], ey[j],
                                w_perp, w_par, w_angle, eps);
      } else {
        // Euclidean distance
        dist = traclus_dist_euc(sxi, syi, exi, eyi,
                                sx[j], sy[j], ex[j], ey[j],
                                w_perp, w_par, w_angle, eps);
      }

      // Only store if within epsilon (early termination already returns
      // values > eps when exceeded, but we check explicitly for safety)
      if (dist <= eps) {
        // Store 1-indexed for R
        adj[i].push_back(j + 1);
        adj[j].push_back(i + 1);
      }
    }
  }
  // Process last segment's progress increment
  progress.increment();

  // Convert to Rcpp::List of IntegerVectors
  Rcpp::List neighbours(n);
  for (int i = 0; i < n; i++) {
    if (adj[i].empty()) {
      neighbours[i] = Rcpp::IntegerVector(0);
    } else {
      neighbours[i] = Rcpp::IntegerVector(adj[i].begin(), adj[i].end());
    }
  }

  return neighbours;
}
