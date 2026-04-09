# Remove trajectories with fewer than min_points points

Remove trajectories with fewer than min_points points

## Usage

``` r
.remove_short_trajectories(df, min_points = 2)
```

## Arguments

- df:

  data.frame with traj_id column.

- min_points:

  Minimum number of points required.

## Value

List with data (filtered df) and removed_ids (character vector).
