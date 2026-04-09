# Summary methods for TRACLUS objects

Detailed summaries of TRACLUS workflow objects, printed via
[`cat()`](https://rdrr.io/r/base/cat.html). All methods return the
object invisibly.

## Usage

``` r
# S3 method for class 'tc_trajectories'
summary(object, ...)

# S3 method for class 'tc_partitions'
summary(object, ...)

# S3 method for class 'tc_clusters'
summary(object, ...)

# S3 method for class 'tc_representatives'
summary(object, ...)

# S3 method for class 'tc_traclus'
summary(object, ...)

# S3 method for class 'tc_estimate'
summary(object, ...)
```

## Arguments

- object:

  A TRACLUS object.

- ...:

  Further arguments (ignored).

## Value

`object`, invisibly.

## See also

Other workflow functions:
[`plot.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md),
[`print.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md),
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
summary(trj)
#> TRACLUS Trajectories - Summary
#>   Trajectories:       6
#>   Total points:       40
#>   Points per traj:    min = 5, median = 7, max = 7
#>   Coord type:         euclidean
#>   Method:             euclidean
```
