#include <Rcpp.h>
#include <algorithm>
#include <cmath>
#include <string>
#include <vector>
#include "traclus_distances.h"
#include "traclus_spherical.h"

// ============================================================================
// C++ helpers for tc_estimate_params():
//
//   .cpp_compute_pairwise_dists()   — Phase 1: all n*(n-1)/2 distances in one call
//   .cpp_count_neighbours_multi_eps() — Phase 2: neighbourhood counts for all
//                                       eps candidates in one pass (binary search)
// ============================================================================


//' Compute all pairwise TRACLUS distances for a sample of segments (C++)
//'
//' Computes the full triangular distance matrix for `n` segments in a single
//' C++ call, replacing the R loop of n*(n-1)/2 individual C++ dispatches used
//' in Phase 1 of [tc_estimate_params()].
//'
//' The result is stored in row-major triangular order: the k-th element
//' corresponds to pair (i, j) with i < j (0-indexed) where
//' k = i*(n-1) - i*(i-1)/2 + (j-i-1).
//'
//' @param sx,sy,ex,ey NumericVectors of segment start/end coordinates.
//' @param w_perp,w_par,w_angle Distance weights.
//' @param method `"euclidean"` or `"haversine"`.
//' @return NumericVector of length n*(n-1)/2 with pairwise distances.
//' @keywords internal
// [[Rcpp::export(name = ".cpp_compute_pairwise_dists")]]
Rcpp::NumericVector cpp_compute_pairwise_dists(Rcpp::NumericVector sx,
                                                Rcpp::NumericVector sy,
                                                Rcpp::NumericVector ex,
                                                Rcpp::NumericVector ey,
                                                double w_perp,
                                                double w_par,
                                                double w_angle,
                                                std::string method) {
  int n = sx.size();
  int n_pairs = n * (n - 1) / 2;
  Rcpp::NumericVector pair_dists(n_pairs);

  bool use_haversine = (method == "haversine");

  int k = 0;
  for (int i = 0; i < n - 1; i++) {
    if (i % 100 == 0) Rcpp::checkUserInterrupt();

    double sxi = sx[i], syi = sy[i], exi = ex[i], eyi = ey[i];

    for (int j = i + 1; j < n; j++) {
      double dist;
      if (use_haversine) {
        dist = traclus_dist_sph(sxi, syi, exi, eyi,
                                sx[j], sy[j], ex[j], ey[j],
                                w_perp, w_par, w_angle,
                                R_PosInf);
      } else {
        dist = traclus_dist_euc(sxi, syi, exi, eyi,
                                sx[j], sy[j], ex[j], ey[j],
                                w_perp, w_par, w_angle,
                                R_PosInf);
      }
      pair_dists[k++] = dist;
    }
  }

  return pair_dists;
}


//' Count neighbourhood sizes for multiple eps candidates (C++)
//'
//' Replaces Phase 2 of [tc_estimate_params()]: given a pre-computed triangular
//' distance matrix and a sorted grid of eps candidates, counts neighbourhood
//' sizes for every segment and every eps in a single O(n_pairs * log(n_eps)) pass.
//'
//' For each pair (i,j) with distance d, binary search finds all eps candidates
//' >= d; the counts for segment i and j are incremented for those eps values.
//' Self-inclusion (+1) is added at the end.
//'
//' @param pair_dists NumericVector of length n*(n-1)/2 (triangular, row-major,
//'   i < j ordering produced by `.cpp_compute_pairwise_dists()`).
//' @param n_sample Integer; number of sampled segments.
//' @param eps_grid NumericVector of eps candidates, sorted ascending.
//' @return List with:
//'   \item{mean_nb_sizes}{mean neighbourhood size per eps (length n_eps)}
//'   \item{entropy_vals}{distribution entropy per eps (length n_eps)}
//' @keywords internal
// [[Rcpp::export(name = ".cpp_count_neighbours_multi_eps")]]
Rcpp::List cpp_count_neighbours_multi_eps(Rcpp::NumericVector pair_dists,
                                           int n_sample,
                                           Rcpp::NumericVector eps_grid) {
  int n_eps = eps_grid.size();

  // nb_counts[i * n_eps + g] = number of OTHER segments within eps_grid[g] of i
  std::vector<int> nb_counts(n_sample * n_eps, 0);

  // Single pass through the triangular distance matrix
  int k = 0;
  for (int i = 0; i < n_sample - 1; i++) {
    for (int j = i + 1; j < n_sample; j++) {
      double d = pair_dists[k++];

      // Binary search: first eps > d → all eps[0..cutoff-1] qualify (>= d)
      int cutoff = (int)(std::upper_bound(eps_grid.begin(), eps_grid.end(), d) -
                         eps_grid.begin());
      if (cutoff == 0) continue;

      // Both i and j are within eps_grid[0..cutoff-1] of each other
      for (int g = 0; g < cutoff; g++) {
        nb_counts[i * n_eps + g]++;
        nb_counts[j * n_eps + g]++;
      }
    }
  }

  // Compute mean_nb_sizes and entropy_vals per eps candidate
  Rcpp::NumericVector mean_nb_sizes(n_eps);
  Rcpp::NumericVector entropy_vals(n_eps);

  for (int g = 0; g < n_eps; g++) {
    double total = 0.0;

    for (int i = 0; i < n_sample; i++) {
      // +1 for self-inclusion (Paper: |N_eps(xi)| includes xi itself)
      total += nb_counts[i * n_eps + g] + 1;
    }

    mean_nb_sizes[g] = total / n_sample;

    // Entropy: H = -sum(p_i * log2(p_i)) where p_i = size_i / total
    if (total == 0.0) {
      entropy_vals[g] = 0.0;
    } else {
      double H = 0.0;
      for (int i = 0; i < n_sample; i++) {
        double size_i = nb_counts[i * n_eps + g] + 1;
        double p = size_i / total;
        if (p > 0.0) H -= p * std::log2(p);
      }
      entropy_vals[g] = H;
    }
  }

  return Rcpp::List::create(
    Rcpp::Named("mean_nb_sizes") = mean_nb_sizes,
    Rcpp::Named("entropy_vals") = entropy_vals
  );
}
