# Plot method for tc_estimate objects

Displays the entropy curve across the eps grid for visual inspection.
Use the shape of the curve — pronounced drops or elbows — to choose an
appropriate `eps` value.

## Usage

``` r
# S3 method for class 'tc_estimate'
plot(x, ...)
```

## Arguments

- x:

  A `tc_estimate` object from
  [`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md).

- ...:

  Additional arguments passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

`x`, invisibly.

## Examples

``` r
# \donttest{
trj <- tc_trajectories(traclus_toy,
  traj_id = "traj_id",
  x = "x", y = "y", coord_type = "euclidean"
)
#> Loaded 6 trajectories (40 points).
parts <- tc_partition(trj)
#> Partitioned 6 trajectories into 10 line segments.
est <- tc_estimate_params(parts)
#> Estimated parameters: eps = 64.31, min_lns = 3 (grid: 8.234 to 78.69, 50 points).
plot(est)

# }
```
