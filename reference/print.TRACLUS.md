# Print methods for TRACLUS objects

Compact summaries of TRACLUS workflow objects, printed via
[`cat()`](https://rdrr.io/r/base/cat.html). All methods return the
object invisibly for pipe compatibility.

## Usage

``` r
# S3 method for class 'tc_trajectories'
print(x, ...)

# S3 method for class 'tc_partitions'
print(x, ...)

# S3 method for class 'tc_clusters'
print(x, ...)

# S3 method for class 'tc_representatives'
print(x, ...)

# S3 method for class 'tc_traclus'
print(x, ...)
```

## Arguments

- x:

  A TRACLUS object.

- ...:

  Further arguments (ignored).

## Value

`x`, invisibly.

## See also

Other workflow functions:
[`plot.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md),
[`summary.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md),
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md),
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
print(trj)
#> TRACLUS Trajectories
#>   Trajectories: 6
#>   Points:       40
#>   Coord type:   euclidean
#>   Method:       euclidean
#>   Status:       loaded (run tc_partition next)
```
