# Partition trajectories using MDL-based approximation

**\[stable\]**

## Usage

``` r
tc_partition(x, verbose = TRUE)
```

## Arguments

- x:

  A `tc_trajectories` object created by
  [`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md).

- verbose:

  Logical; if `TRUE` (default), prints an informative summary after
  partitioning.

## Value

A `tc_partitions` S3 object (list) with elements:

- segments:

  `data.frame` with columns `traj_id` (character), `seg_id` (integer),
  `sx`, `sy`, `ex`, `ey` (numeric).

- trajectories:

  Reference to the input `tc_trajectories` object.

- n_segments:

  Integer total number of segments.

- coord_type:

  Coordinate type inherited from input.

- method:

  Distance method inherited from input.

## Details

Applies the approximate trajectory partitioning algorithm (Paper Figure
8) to identify characteristic points in each trajectory, then connects
them into line segments. The MDL (Minimum Description Length) principle
balances compression (fewer segments) against fidelity (preserving
trajectory shape).

The partitioning uses only perpendicular and angle distance in the MDL
cost function, as described in the original paper (Formulas 6 and 7).
The weighting parameters `w_perp`, `w_par`, `w_angle` have no influence
on partitioning — they only affect the clustering step.

Consistent with Paper Section 4.1.3, a small additive bias is applied to
the no-partition cost to suppress over-partitioning. This produces
longer segments that generally improve clustering quality.

Zero-length segments (from numerical rounding or very dense GPS points)
are removed with a warning. If no segments remain after partitioning, an
error is thrown.

## See also

Other workflow functions:
[`plot.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md),
[`print.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md),
[`summary.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md),
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md),
[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md),
[`tc_plot()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_plot.md),
[`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md),
[`tc_traclus()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_traclus.md),
[`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md)

## Examples

``` r
trj <- tc_trajectories(traclus_toy,
  traj_id = "traj_id",
  x = "x", y = "y", coord_type = "euclidean"
)
#> Loaded 6 trajectories (40 points).
parts <- tc_partition(trj)
#> Partitioned 6 trajectories into 10 line segments.
print(parts)
#> TRACLUS Partitions
#>   Trajectories: 6
#>   Segments:     10
#>   Coord type:   euclidean
#>   Method:       euclidean
#>   Status:       partitioned (run tc_cluster next)
```
