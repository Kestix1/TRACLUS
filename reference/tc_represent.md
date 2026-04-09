# Generate representative trajectories for clusters

**\[stable\]**

## Usage

``` r
tc_represent(x, gamma = 1, min_lns = NULL, verbose = TRUE)
```

## Arguments

- x:

  A `tc_clusters` object created by
  [`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md).

- gamma:

  Positive numeric smoothing parameter: minimum distance between
  consecutive waypoints (default 1). Unit: meters for
  `method = "haversine"` or `"projected"`, coordinate units for
  `method = "euclidean"`.

- min_lns:

  Positive integer or `NULL` (default). Minimum number of crossing
  segments required to generate a waypoint. If `NULL`, inherits from
  `x$params$min_lns` (clustering value). Override for advanced use.

- verbose:

  Logical; if `TRUE` (default), prints an informative summary.

## Value

A `tc_representatives` S3 object (list) with elements:

- segments:

  `data.frame` — own copy of segment data with updated `cluster_id`
  (renumbered, failed clusters degraded to noise).

- representatives:

  `data.frame` with columns `cluster_id` (integer), `point_id` (integer,
  1-based), `rx`, `ry` (numeric waypoint coordinates in original
  format).

- clusters:

  Reference to the input `tc_clusters` object (unmodified, pre-cleanup
  IDs for traceability).

- n_clusters:

  Integer number of clusters with valid representatives.

- n_noise:

  Integer number of noise segments (updated after cleanup).

- params:

  List with `min_lns` and `gamma` used for representation.

- coord_type:

  Coordinate type inherited from input.

- method:

  Distance method inherited from input.

## Details

Computes a representative trajectory for each cluster using the
sweep-line algorithm (Paper Figure 15). The representative captures the
"average path" of all line segments in the cluster.

For geographic data (`coord_type = "geographic"`), segment coordinates
are locally projected to meters using equirectangular approximation
before the sweep-line runs, then transformed back. This ensures gamma
operates in meters, consistent with eps.

Clusters that produce fewer than 2 waypoints are degraded to noise. The
remaining cluster IDs are renumbered (1..K) and the segments data.frame
is updated accordingly.

**Trajectory diversity check (deviation from paper):** The sweep-line
checks segment density (`count >= min_lns`, per Paper Figure 15) AND
additionally requires at least 2 distinct trajectories among the active
segments at each waypoint position. This prevents degenerate
representatives from consecutive segments of a single trajectory whose
shared characteristic points create artificial count peaks via
entry-before-exit tie-breaking. The check only affects results when
`min_lns < 3`; at higher values, the segment density threshold is
already sufficient. See `vignette("algorithm-details")` for a detailed
explanation.

## See also

Other workflow functions:
[`plot.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md),
[`print.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md),
[`summary.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md),
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md),
[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md),
[`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md),
[`tc_plot()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_plot.md),
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
# \donttest{
clust <- tc_cluster(parts, eps = 25, min_lns = 3)
#> Clustering: 1 cluster(s), 1 noise segment(s).
repr <- tc_represent(clust)
#> Representatives: 1 trajectory(ies).
print(repr)
#> TRACLUS Representatives
#>   Clusters:     1
#>   Noise segs:   1
#>   Waypoints:    10 total (10 per representative)
#>   gamma:        1
#>   min_lns:      3
#>   Coord type:   euclidean
#>   Method:       euclidean
#>   Status:       complete
# }
```
