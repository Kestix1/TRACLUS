# Compute all pairwise TRACLUS distances for a sample of segments (C++)

Computes the full triangular distance matrix for `n` segments in a
single C++ call, replacing the R loop of n\*(n-1)/2 individual C++
dispatches used in Phase 1 of
[`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md).

## Usage

``` r
.cpp_compute_pairwise_dists(sx, sy, ex, ey, w_perp, w_par, w_angle, method)
```

## Arguments

- sx, sy, ex, ey:

  NumericVectors of segment start/end coordinates.

- w_perp, w_par, w_angle:

  Distance weights.

- method:

  `"euclidean"` or `"haversine"`.

## Value

NumericVector of length n\*(n-1)/2 with pairwise distances.

## Details

The result is stored in row-major triangular order: the k-th element
corresponds to pair (i, j) with i \< j (0-indexed) where k = i\*(n-1) -
i\*(i-1)/2 + (j-i-1).
