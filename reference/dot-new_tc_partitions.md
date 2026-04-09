# Construct a tc_partitions object

Low-level constructor that assembles the S3 list. No validation is
performed — use
[`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md)
for the validated public API.

## Usage

``` r
.new_tc_partitions(segments, trajectories, coord_type, method)
```

## Arguments

- segments:

  data.frame with columns traj_id, seg_id, sx, sy, ex, ey.

- trajectories:

  The source tc_trajectories object.

- coord_type:

  Character: "euclidean" or "geographic".

- method:

  Character: "euclidean" or "haversine".

## Value

A tc_partitions S3 object.
