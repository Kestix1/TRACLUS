# Partition all trajectories using MDL-based approximate partitioning

Implements the approximate trajectory partitioning algorithm from Paper
Figure 8. Each trajectory is partitioned independently based on the MDL
principle. Returns a data.frame of line segments connecting consecutive
characteristic points.

## Usage

``` r
.cpp_partition_all(traj_ids, x_coords, y_coords, method)
```

## Arguments

- traj_ids:

  Character vector of trajectory IDs (one per point).

- x_coords:

  Numeric vector of x-coordinates (or longitudes).

- y_coords:

  Numeric vector of y-coordinates (or latitudes).

- method:

  Integer: 0 for euclidean, 1 for haversine.

## Value

A List with elements: traj_id, seg_id, sx, sy, ex, ey.
