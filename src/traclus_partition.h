#ifndef TRACLUS_PARTITION_H
#define TRACLUS_PARTITION_H

#include <Rcpp.h>

// Partition bias constant (Paper Section 4.1.3)
// Additive constant on costnopar to suppress over-partitioning.
// The paper recommends increasing partition length by 20-30%.
static const double PARTITION_BIAS = 1.0;

// Safe log2: log2(max(x, 1.0)) to avoid negative values (Paper delta = 1)
double safe_log2(double x);

// MDL cost of the partition hypothesis L(H): log2 of partition segment length
// Paper Formula 6
double mdl_lh(double seg_len);

// MDL cost of data given hypothesis L(D|H) for one sub-segment:
// log2(d_perp) + log2(d_angle) — uses perpendicular and angle distance only
// Paper Formula 7
double mdl_ldh_component_euc(double part_sx, double part_sy,
                              double part_ex, double part_ey,
                              double sub_sx, double sub_sy,
                              double sub_ex, double sub_ey);

double mdl_ldh_component_sph(double part_lon_s, double part_lat_s,
                              double part_lon_e, double part_lat_e,
                              double sub_lon_s, double sub_lat_s,
                              double sub_lon_e, double sub_lat_e);

#endif // TRACLUS_PARTITION_H
