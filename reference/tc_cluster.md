# Cluster line segments using density-based clustering

**\[stable\]**

## Usage

``` r
tc_cluster(x, eps, min_lns, w_perp = 1, w_par = 1, w_angle = 1, verbose = TRUE)
```

## Arguments

- x:

  A `tc_partitions` object created by
  [`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md).

- eps:

  Positive numeric distance threshold. Segments within `eps` distance
  are considered neighbours. Unit: meters for `method = "haversine"` or
  `"projected"`, coordinate units for `method = "euclidean"`.
  **Required** — no default. Use trial and error or
  [`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md)
  for guidance.

- min_lns:

  Positive integer (\>= 1). Minimum neighbourhood size for a segment to
  be a core segment in DBSCAN, AND minimum number of distinct source
  trajectories for a cluster to be retained. **Required** — no default.

- w_perp:

  Non-negative weight for perpendicular distance (default 1).

- w_par:

  Non-negative weight for parallel distance (default 1).

- w_angle:

  Non-negative weight for angle distance (default 1).

- verbose:

  Logical; if `TRUE` (default), prints an informative summary after
  clustering.

## Value

A `tc_clusters` S3 object (list) with elements:

- segments:

  `data.frame` with columns `traj_id`, `seg_id`, `sx`, `sy`, `ex`, `ey`,
  `cluster_id` (integer, `NA` for noise).

- cluster_summary:

  `data.frame` with per-cluster statistics: `cluster_id`, `n_segments`,
  `n_trajectories`.

- n_clusters:

  Integer number of clusters (excluding noise).

- n_noise:

  Integer number of noise segments.

- params:

  List with `eps`, `min_lns`, `w_perp`, `w_par`, `w_angle`.

- partitions:

  Reference to the input `tc_partitions` object.

- coord_type:

  Coordinate type inherited from input.

- method:

  Distance method inherited from input.

## Details

Applies a modified DBSCAN algorithm to group similar line segments into
clusters. Segments that are not dense enough are classified as noise
(cluster_id = NA). After clustering, a trajectory cardinality check
removes clusters whose segments originate from fewer than `min_lns`
distinct trajectories (Paper Section 4.3).

The weighted distance between two segments is:
`dist = w_perp * d_perp + w_par * d_par + w_angle * d_angle` (Paper
Section 2.3). Early termination skips remaining components when the
accumulated distance already exceeds `eps`.

The DBSCAN modification from the paper: noise segments CAN be absorbed
into a cluster during expansion, but they do NOT trigger further
expansion (Paper Figure 12, Lines 23-26).

**Choosing `min_lns`:** The paper recommends `min_lns` =
avg\|N_eps(L)\| + 1 to 3, typically yielding values of 5–9 (Section
4.4). Use
[`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md)
for a data-driven starting point. Values below 3 can lead to clusters
dominated by a single trajectory and degenerate representative
trajectories — see
[`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md)
details for the trajectory diversity check that mitigates this.

## See also

Other workflow functions:
[`plot.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md),
[`print.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md),
[`summary.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md),
[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md),
[`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md),
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
# \donttest{
clust <- tc_cluster(parts, eps = 10, min_lns = 3)
#> Warning: No clusters found (all segments are noise). Consider increasing 'eps' or decreasing 'min_lns'.
#> Clustering: 0 cluster(s), 10 noise segment(s).
print(clust)
#> TRACLUS Clusters
#>   Clusters:     0
#>   Noise segs:   10
#>   Total segs:   10
#>   eps:          10 (coordinate units)
#>   min_lns:      3
#>   Coord type:   euclidean
#>   Method:       euclidean
#>   Status:       clustered (run tc_represent next)
# }
```
