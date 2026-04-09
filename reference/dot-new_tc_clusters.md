# Construct a tc_clusters object

Low-level constructor that assembles the S3 list. No validation is
performed — use
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md)
for the validated public API.

## Usage

``` r
.new_tc_clusters(
  segments,
  cluster_summary,
  n_clusters,
  n_noise,
  params,
  partitions,
  coord_type,
  method
)
```

## Arguments

- segments:

  data.frame with columns traj_id, seg_id, sx, sy, ex, ey, cluster_id.

- cluster_summary:

  data.frame with per-cluster statistics.

- n_clusters:

  Integer number of clusters.

- n_noise:

  Integer number of noise segments.

- params:

  List of clustering parameters.

- partitions:

  The source tc_partitions object.

- coord_type:

  Character: "euclidean" or "geographic".

- method:

  Character: "euclidean" or "haversine".

## Value

A tc_clusters S3 object.
