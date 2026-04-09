# Estimate clustering parameters from data

**\[stable\]**

## Usage

``` r
tc_estimate_params(
  x,
  eps_grid = NULL,
  sample_size = 200L,
  w_perp = 1,
  w_par = 1,
  w_angle = 1,
  verbose = TRUE
)
```

## Arguments

- x:

  A `tc_partitions` object created by
  [`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md).

- eps_grid:

  Optional numeric vector of candidate eps values to evaluate. If `NULL`
  (default), an intelligent grid of 50 values is generated from a random
  sample of pairwise distances (5th to 95th percentile).

- sample_size:

  Integer number of segments to sample for pairwise distance computation
  (default 200). Ignored when `eps_grid` is provided explicitly.

- w_perp, w_par, w_angle:

  Non-negative distance weights (each default 1). Used for both grid
  generation and entropy computation.

- verbose:

  Logical; if `TRUE` (default), prints the estimated parameters.

## Value

A `tc_estimate` S3 object (list) with elements:

- eps:

  Numeric: estimated optimal eps value.

- min_lns:

  Integer: estimated min_lns value (ceiling of mean neighbourhood size
  at optimal eps, + 1).

- w_perp,w_par,w_angle:

  Numeric: weight values used (input values, not estimated).

- entropy_df:

  `data.frame` with columns `eps` and `entropy` for the full grid.

## Details

Provides a data-driven starting point for `eps` and `min_lns` by
minimizing the entropy of epsilon-neighbourhood sizes across a grid of
candidate eps values (Paper Section 4.4). This is an optional helper —
the optimal values are typically found by trial and error.

The algorithm works in two stages:

1.  **Grid generation** (when `eps_grid = NULL`): A random sample of
    `sample_size` segments is drawn. All pairwise distances within the
    sample are computed. The grid spans 50 equally spaced values from
    the 5th to 95th percentile of these distances.

2.  **Entropy computation**: For each candidate eps, the neighbourhood
    size of each sampled segment is counted. The entropy of these sizes
    (normalized to a probability distribution) is computed. The eps with
    minimum entropy is selected. Ties are broken by choosing the
    smallest eps.

The estimated `min_lns` is
`ceiling(mean neighbourhood size at optimal eps) + 1`. This typically
yields values of 5 or higher, consistent with the paper's recommendation
(Section 4.4). Values below 3 are rarely appropriate and can produce
degenerate representatives — see
[`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md)
for details.

## Note

This function does not break the pipe chain — it accepts a
`tc_partitions` object and returns a `tc_estimate` object (not a
workflow object). Use `result$eps` and `result$min_lns` to extract the
values for
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md).

## See also

Other helper functions:
[`tc_read_hurdat2()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_read_hurdat2.md)

## Examples

``` r
trj <- tc_trajectories(traclus_toy,
  traj_id = "traj_id",
  x = "x", y = "y", coord_type = "euclidean"
)
#> Loaded 6 trajectories (40 points).
parts <- tc_partition(trj)
#> Partitioned 6 trajectories into 10 line segments.
# \donttest{
est <- tc_estimate_params(parts)
#> Estimated parameters: eps = 64.31, min_lns = 3 (grid: 8.234 to 78.69, 50 points).
print(est)
#> TRACLUS Parameter Estimate
#>   Optimal eps:  64.31 (coordinate units)
#>   Est. min_lns: 3
#>   Grid range:   8.234 to 78.69 (50 points)
# }
```
