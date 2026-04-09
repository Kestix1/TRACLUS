# Print method for tc_estimate objects

Print method for tc_estimate objects

## Usage

``` r
# S3 method for class 'tc_estimate'
print(x, ...)
```

## Arguments

- x:

  A `tc_estimate` object from
  [`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md).

- ...:

  Further arguments (ignored).

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
print(est)
#> TRACLUS Parameter Estimate
#>   Optimal eps:  64.31 (coordinate units)
#>   Est. min_lns: 3
#>   Grid range:   8.234 to 78.69 (50 points)
# }
```
