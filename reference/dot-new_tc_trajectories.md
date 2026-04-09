# Construct a tc_trajectories object

Low-level constructor that assembles the S3 list. No validation is
performed — use
[`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md)
for the validated public API.

## Usage

``` r
.new_tc_trajectories(data, coord_type, method, proj_params = NULL)
```

## Arguments

- data:

  data.frame with columns traj_id, x, y.

- coord_type:

  Character: "euclidean" or "geographic".

- method:

  Character: "euclidean", "haversine", or "projected".

- proj_params:

  Optional list with lat_mean and lon_mean for method = "projected".
  NULL for other methods.

## Value

A tc_trajectories S3 object.
