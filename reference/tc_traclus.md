# Run the complete TRACLUS algorithm

**\[stable\]**

## Usage

``` r
tc_traclus(
  x,
  eps,
  min_lns,
  gamma = 1,
  repr_min_lns = NULL,
  w_perp = 1,
  w_par = 1,
  w_angle = 1,
  verbose = TRUE
)
```

## Arguments

- x:

  A `tc_trajectories` object created by
  [`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md).

- eps:

  Positive numeric distance threshold for clustering. Unit: meters for
  `method = "haversine"` or `"projected"`, coordinate units for
  `method = "euclidean"`. **Required** — no default.

- min_lns:

  Positive integer (\>= 1). Used for both clustering (minimum
  neighbourhood size / trajectory cardinality) and representation
  (minimum segment density for waypoints). **Required** — no default.

- gamma:

  Positive numeric smoothing parameter for representative generation
  (default 1). Minimum distance between consecutive waypoints.

- repr_min_lns:

  Optional positive integer. If provided, overrides `min_lns` for the
  representation step only (power-user option). Corresponds to the
  `min_lns` parameter of
  [`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md).
  If `NULL` (default), the clustering `min_lns` is used for both phases.

- w_perp, w_par, w_angle:

  Non-negative weights for perpendicular, parallel, and angle distance
  components (each default 1).

- verbose:

  Logical; if `TRUE` (default), prints informative messages after each
  step. Passed through to all three sub-functions.

## Value

A `tc_traclus` object (inherits from `tc_representatives`). The full
reference chain is preserved: `result$clusters$partitions$trajectories`.

## Details

Convenience wrapper that executes all three TRACLUS steps in sequence:
partitioning
([`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md)),
clustering
([`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md)),
and representative trajectory generation
([`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md)).

This wrapper is equivalent to:

    x |> tc_partition() |>
      tc_cluster(eps, min_lns, w_perp, w_par, w_angle) |>
      tc_represent(gamma, min_lns)

For iterative parameter tuning, use the step-by-step approach instead:
partition once with
[`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md),
then re-cluster the same partitions object with different
`eps`/`min_lns` values.

## See also

Other workflow functions:
[`plot.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md),
[`print.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md),
[`summary.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md),
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md),
[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md),
[`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md),
[`tc_plot()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_plot.md),
[`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md),
[`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md)

## Examples

``` r
trj <- tc_trajectories(traclus_toy,
  traj_id = "traj_id",
  x = "x", y = "y", coord_type = "euclidean"
)
#> Loaded 6 trajectories (40 points).
# \donttest{
result <- tc_traclus(trj, eps = 25, min_lns = 3)
#> Partitioned 6 trajectories into 10 line segments.
#> Clustering: 1 cluster(s), 1 noise segment(s).
#> Representatives: 1 trajectory(ies).
print(result)
#> TRACLUS Result (all-in-one)
#>   Clusters:     1
#>   Noise segs:   1
#>   Waypoints:    10 total (10 per representative)
#>   eps:          25 (coordinate units)
#>   min_lns:      3
#>   gamma:        1
#>   Coord type:   euclidean
#>   Method:       euclidean
#>   Status:       complete
# }
```
