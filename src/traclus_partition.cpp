#include "traclus_partition.h"
#include "traclus_distances.h"
#include "traclus_spherical.h"
#include <cmath>
#include <vector>
#include <algorithm>

// ============================================================================
// MDL helper functions
// ============================================================================

// Safe log2: log2(max(x, 1.0)) — Paper uses delta = 1 to avoid negative
// values when distances or lengths are < 1.
double safe_log2(double x) {
  return std::log2(std::max(x, 1.0));
}

// MDL cost of hypothesis L(H): log2 of partition segment length
// Paper Formula 6: L(H) = log2(len(p_i, p_j))
double mdl_lh(double seg_len) {
  return safe_log2(seg_len);
}

// MDL cost component for one sub-segment (euclidean)
// Paper Formula 7: L(D|H) = sum of [log2(d_perp) + log2(d_angle)]
// The partition segment is typically longer (Li in swap convention),
// but swap is applied unconditionally inside d_perp/d_angle.
double mdl_ldh_component_euc(double part_sx, double part_sy,
                              double part_ex, double part_ey,
                              double sub_sx, double sub_sy,
                              double sub_ex, double sub_ey) {
  double dp = d_perp_euc(part_sx, part_sy, part_ex, part_ey,
                          sub_sx, sub_sy, sub_ex, sub_ey);
  double da = d_angle_euc(part_sx, part_sy, part_ex, part_ey,
                           sub_sx, sub_sy, sub_ex, sub_ey);
  return safe_log2(dp) + safe_log2(da);
}

// MDL cost component for one sub-segment (spherical)
double mdl_ldh_component_sph(double part_lon_s, double part_lat_s,
                              double part_lon_e, double part_lat_e,
                              double sub_lon_s, double sub_lat_s,
                              double sub_lon_e, double sub_lat_e) {
  double dp = d_perp_sph(part_lon_s, part_lat_s, part_lon_e, part_lat_e,
                          sub_lon_s, sub_lat_s, sub_lon_e, sub_lat_e);
  double da = d_angle_sph(part_lon_s, part_lat_s, part_lon_e, part_lat_e,
                           sub_lon_s, sub_lat_s, sub_lon_e, sub_lat_e);
  return safe_log2(dp) + safe_log2(da);
}

// ============================================================================
// Approximate Trajectory Partitioning — Paper Figure 8
// ============================================================================

// Partition a single trajectory given as vectors of x and y coordinates.
// Returns a vector of characteristic point indices (0-based).
// method: 0 = euclidean, 1 = haversine
static std::vector<int> partition_trajectory_impl(
    const std::vector<double>& x,
    const std::vector<double>& y,
    int method) {

  int n = static_cast<int>(x.size());

  // Trajectories with <= 2 points: no split possible, return start and end
  if (n <= 2) {
    std::vector<int> cp;
    cp.push_back(0);
    if (n == 2) cp.push_back(1);
    return cp;
  }

  // Paper Figure 8 algorithm
  std::vector<int> cp;
  cp.push_back(0);  // First point is always a characteristic point

  int start_idx = 0;
  int length = 1;  // Current scan length (number of sub-segments from start)

  while (start_idx + length < n - 1) {
    // Current candidate partition: from start_idx to start_idx + length + 1
    int end_candidate = start_idx + length + 1;

    // Partition segment: start_idx -> end_candidate
    double part_sx = x[start_idx];
    double part_sy = y[start_idx];
    double part_ex = x[end_candidate];
    double part_ey = y[end_candidate];

    // Compute costpar = L(H) + L(D|H) for partition segment
    double seg_len;
    if (method == 0) {
      seg_len = segment_length_euc(part_sx, part_sy, part_ex, part_ey);
    } else {
      seg_len = haversine_dist(part_sx, part_sy, part_ex, part_ey);
    }
    double costpar = mdl_lh(seg_len);

    // Sum L(D|H) over all sub-segments within the partition
    for (int k = start_idx; k < end_candidate; k++) {
      if (method == 0) {
        costpar += mdl_ldh_component_euc(
          part_sx, part_sy, part_ex, part_ey,
          x[k], y[k], x[k + 1], y[k + 1]);
      } else {
        costpar += mdl_ldh_component_sph(
          part_sx, part_sy, part_ex, part_ey,
          x[k], y[k], x[k + 1], y[k + 1]);
      }
    }

    // Compute costnopar = sum of log2(len(sub-segment_k))
    // Paper Section 4.1.3: add partition_bias to suppress over-partitioning
    double costnopar = PARTITION_BIAS;
    for (int k = start_idx; k < end_candidate; k++) {
      double sub_len;
      if (method == 0) {
        sub_len = segment_length_euc(x[k], y[k], x[k + 1], y[k + 1]);
      } else {
        sub_len = haversine_dist(x[k], y[k], x[k + 1], y[k + 1]);
      }
      costnopar += safe_log2(sub_len);
    }

    // Paper Figure 8, Line 7: if partitioning increases MDL cost, insert
    // characteristic point at the PREVIOUS position
    if (costpar > costnopar) {
      // The previous point (start_idx + length) becomes a characteristic point
      cp.push_back(start_idx + length);
      start_idx = start_idx + length;
      length = 1;
    } else {
      // Extend the partition candidate
      length++;
    }
  }

  // Last point is always a characteristic point
  cp.push_back(n - 1);

  return cp;
}

// ============================================================================
// Rcpp-exported functions
// ============================================================================

//' Partition all trajectories using MDL-based approximate partitioning
//'
//' Implements the approximate trajectory partitioning algorithm from
//' Paper Figure 8. Each trajectory is partitioned independently based on
//' the MDL principle. Returns a data.frame of line segments connecting
//' consecutive characteristic points.
//'
//' @param traj_ids Character vector of trajectory IDs (one per point).
//' @param x_coords Numeric vector of x-coordinates (or longitudes).
//' @param y_coords Numeric vector of y-coordinates (or latitudes).
//' @param method Integer: 0 for euclidean, 1 for haversine.
//' @return A List with elements: traj_id, seg_id, sx, sy, ex, ey.
//' @keywords internal
// [[Rcpp::export(name = ".cpp_partition_all")]]
Rcpp::List cpp_partition_all(Rcpp::CharacterVector traj_ids,
                              Rcpp::NumericVector x_coords,
                              Rcpp::NumericVector y_coords,
                              int method) {

  int n = traj_ids.size();

  // --- Group points by trajectory (preserving order) ---
  // Find unique trajectory IDs in order of first appearance
  std::vector<std::string> unique_ids;
  std::vector<std::vector<int>> groups;  // indices into the input vectors

  {
    std::string current_id = "";
    int current_group = -1;
    for (int i = 0; i < n; i++) {
      std::string id = Rcpp::as<std::string>(traj_ids[i]);
      if (id != current_id) {
        // Check if this ID was seen before (data should be grouped already)
        current_id = id;
        // Start new group
        unique_ids.push_back(id);
        groups.push_back(std::vector<int>());
        current_group = static_cast<int>(groups.size()) - 1;
      }
      groups[current_group].push_back(i);
    }
  }

  // --- Pre-allocate output vectors ---
  // Estimate: each trajectory with m points produces at most m-1 segments
  // (but typically fewer after partitioning)
  std::vector<std::string> out_traj_id;
  std::vector<int> out_seg_id;
  std::vector<double> out_sx, out_sy, out_ex, out_ey;

  int n_null_removed = 0;

  // Reserve space (rough estimate)
  out_traj_id.reserve(n);
  out_seg_id.reserve(n);
  out_sx.reserve(n);
  out_sy.reserve(n);
  out_ex.reserve(n);
  out_ey.reserve(n);

  // --- Partition each trajectory ---
  for (size_t g = 0; g < groups.size(); g++) {
    const std::vector<int>& idx = groups[g];
    int m = static_cast<int>(idx.size());

    // Extract coordinates for this trajectory
    std::vector<double> tx(m), ty(m);
    for (int j = 0; j < m; j++) {
      tx[j] = x_coords[idx[j]];
      ty[j] = y_coords[idx[j]];
    }

    // Run partitioning
    std::vector<int> cp = partition_trajectory_impl(tx, ty, method);

    // Build segments from consecutive characteristic points
    std::string tid = unique_ids[g];
    int seg_num = 1;
    for (size_t s = 0; s + 1 < cp.size(); s++) {
      int ci = cp[s];
      int cj = cp[s + 1];

      double sx = tx[ci];
      double sy = ty[ci];
      double ex = tx[cj];
      double ey = ty[cj];

      // Skip null segments (length below numerical tolerance)
      double seg_len;
      if (method == 0) {
        seg_len = segment_length_euc(sx, sy, ex, ey);
      } else {
        seg_len = haversine_dist(sx, sy, ex, ey);
      }
      if (seg_len < ZERO_THRESHOLD) {
        n_null_removed++;
        continue;
      }

      out_traj_id.push_back(tid);
      out_seg_id.push_back(seg_num);
      out_sx.push_back(sx);
      out_sy.push_back(sy);
      out_ex.push_back(ex);
      out_ey.push_back(ey);
      seg_num++;
    }

    // User interrupt check (once per trajectory, not per iteration)
    if ((g + 1) % 100 == 0) {
      Rcpp::checkUserInterrupt();
    }
  }

  return Rcpp::List::create(
    Rcpp::Named("traj_id") = Rcpp::wrap(out_traj_id),
    Rcpp::Named("seg_id") = Rcpp::wrap(out_seg_id),
    Rcpp::Named("sx") = Rcpp::wrap(out_sx),
    Rcpp::Named("sy") = Rcpp::wrap(out_sy),
    Rcpp::Named("ex") = Rcpp::wrap(out_ex),
    Rcpp::Named("ey") = Rcpp::wrap(out_ey),
    Rcpp::Named("n_null_removed") = n_null_removed
  );
}

//' Partition a single trajectory (for testing)
//'
//' Returns a vector of characteristic point indices (1-based, for R).
//'
//' @param x_coords Numeric vector of x-coordinates.
//' @param y_coords Numeric vector of y-coordinates.
//' @param method Integer: 0 for euclidean, 1 for haversine.
//' @return Integer vector of characteristic point indices (1-based).
//' @keywords internal
// [[Rcpp::export(name = ".cpp_partition_single")]]
Rcpp::IntegerVector cpp_partition_single(Rcpp::NumericVector x_coords,
                                          Rcpp::NumericVector y_coords,
                                          int method) {
  int n = x_coords.size();
  std::vector<double> x(n), y(n);
  for (int i = 0; i < n; i++) {
    x[i] = x_coords[i];
    y[i] = y_coords[i];
  }

  std::vector<int> cp = partition_trajectory_impl(x, y, method);

  // Convert to 1-based for R
  Rcpp::IntegerVector result(cp.size());
  for (size_t i = 0; i < cp.size(); i++) {
    result[i] = cp[i] + 1;
  }
  return result;
}

//' Compute MDL cost of partitioning (costpar) for testing
//'
//' @param part_sx,part_sy,part_ex,part_ey Partition segment coordinates.
//' @param sub_x Numeric vector of sub-segment x-coordinates (all points).
//' @param sub_y Numeric vector of sub-segment y-coordinates (all points).
//' @param method Integer: 0 for euclidean, 1 for haversine.
//' @return The MDL costpar value (double).
//' @keywords internal
// [[Rcpp::export(name = ".cpp_mdl_costpar")]]
double cpp_mdl_costpar(double part_sx, double part_sy,
                        double part_ex, double part_ey,
                        Rcpp::NumericVector sub_x,
                        Rcpp::NumericVector sub_y,
                        int method) {
  double seg_len;
  if (method == 0) {
    seg_len = segment_length_euc(part_sx, part_sy, part_ex, part_ey);
  } else {
    seg_len = haversine_dist(part_sx, part_sy, part_ex, part_ey);
  }

  double cost = mdl_lh(seg_len);

  int n = sub_x.size();
  for (int k = 0; k < n - 1; k++) {
    if (method == 0) {
      cost += mdl_ldh_component_euc(
        part_sx, part_sy, part_ex, part_ey,
        sub_x[k], sub_y[k], sub_x[k + 1], sub_y[k + 1]);
    } else {
      cost += mdl_ldh_component_sph(
        part_sx, part_sy, part_ex, part_ey,
        sub_x[k], sub_y[k], sub_x[k + 1], sub_y[k + 1]);
    }
  }
  return cost;
}

//' Compute MDL cost of no-partitioning (costnopar) for testing
//'
//' @param sub_x Numeric vector of point x-coordinates.
//' @param sub_y Numeric vector of point y-coordinates.
//' @param method Integer: 0 for euclidean, 1 for haversine.
//' @return The MDL costnopar value (double).
//' @keywords internal
// [[Rcpp::export(name = ".cpp_mdl_costnopar")]]
double cpp_mdl_costnopar(Rcpp::NumericVector sub_x,
                          Rcpp::NumericVector sub_y,
                          int method) {
  double cost = PARTITION_BIAS;
  int n = sub_x.size();
  for (int k = 0; k < n - 1; k++) {
    double sub_len;
    if (method == 0) {
      sub_len = segment_length_euc(sub_x[k], sub_y[k],
                                    sub_x[k + 1], sub_y[k + 1]);
    } else {
      sub_len = haversine_dist(sub_x[k], sub_y[k],
                                sub_x[k + 1], sub_y[k + 1]);
    }
    cost += safe_log2(sub_len);
  }
  return cost;
}
