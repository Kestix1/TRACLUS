# Count neighbourhood sizes for multiple eps candidates (C++)

Replaces Phase 2 of
[`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md):
given a pre-computed triangular distance matrix and a sorted grid of eps
candidates, counts neighbourhood sizes for every segment and every eps
in a single O(n_pairs \* log(n_eps)) pass.

## Usage

``` r
.cpp_count_neighbours_multi_eps(pair_dists, n_sample, eps_grid)
```

## Arguments

- pair_dists:

  NumericVector of length n\*(n-1)/2 (triangular, row-major, i \< j
  ordering produced by
  [`.cpp_compute_pairwise_dists()`](https://martinhoblisch.github.io/TRACLUS/reference/dot-cpp_compute_pairwise_dists.md)).

- n_sample:

  Integer; number of sampled segments.

- eps_grid:

  NumericVector of eps candidates, sorted ascending.

## Value

List with:

- mean_nb_sizes:

  mean neighbourhood size per eps (length n_eps)

- entropy_vals:

  distribution entropy per eps (length n_eps)

## Details

For each pair (i,j) with distance d, binary search finds all eps
candidates= d; the counts for segment i and j are incremented for those
eps values.Self-inclusion (+1) is added at the end.
