# TRACLUS ![](reference/figures/logo.png)

**TRACLUS** implements the TRAjectory CLUStering algorithm by Lee, Han &
Whang (SIGMOD 2007) as a self-contained R package. The algorithm works
in three phases:

1.  **Partition** trajectories into line segments using Minimum
    Description Length (MDL).
2.  **Cluster** segments via density-based spatial clustering (DBSCAN).
3.  **Represent** each cluster with a representative trajectory using a
    sweep-line algorithm.

Both **euclidean** and **geographic** (haversine / spherical) distance
calculations are supported. Geographic data can be visualised on
interactive Leaflet maps.

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("MartinHoblisch/TRACLUS")
```

## Quick start

``` r
library(TRACLUS)

# Built-in toy dataset (euclidean)
trj <- tc_trajectories(traclus_toy, traj_id = "traj_id",
                       x = "x", y = "y", coord_type = "euclidean")

# Full pipeline in one call
result <- tc_traclus(trj, eps = 25, min_lns = 3)
result
plot(result)

# Step-by-step workflow
parts <- tc_partition(trj)
clust <- tc_cluster(parts, eps = 25, min_lns = 3)
repr  <- tc_represent(clust)
plot(repr)
```

### Geographic data (e.g., hurricanes)

``` r
# Read HURDAT2 Best-Track data (826 Atlantic storms, 1950-2004)
# Use min_points to select long-lived storms for a manageable subset
storms <- tc_read_hurdat2(
  system.file("extdata", "hurdat2_1950_2004.txt", package = "TRACLUS"),
  min_points = 80
)

trj <- tc_trajectories(storms, traj_id = "storm_id",
                       x = "lon", y = "lat", coord_type = "geographic")

result <- tc_traclus(trj, eps = 500000, min_lns = 3)
plot(result)

# Interactive Leaflet map (requires the leaflet package)
if (requireNamespace("leaflet", quietly = TRUE)) {
  tc_leaflet(result)
}
```

### Parameter estimation

``` r
parts <- tc_partition(trj)
est <- tc_estimate_params(parts)
est
plot(est)
```

## Workflow

| Step   | Function                                                                                           | Description                               |
|--------|----------------------------------------------------------------------------------------------------|-------------------------------------------|
| 1      | [`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md)       | Validate and wrap input data              |
| 2      | [`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md)             | MDL-based partitioning                    |
| 3      | [`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md)                 | DBSCAN density clustering                 |
| 4      | [`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md)             | Sweep-line representative trajectories    |
| All    | [`tc_traclus()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_traclus.md)                 | Steps 2–4 in one call                     |
| Helper | [`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md) | Entropy-based parameter estimation        |
| Helper | [`tc_read_hurdat2()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_read_hurdat2.md)       | Parse HURDAT2 Best-Track files            |
| Viz    | [`plot()`](https://rdrr.io/r/graphics/plot.default.html)                                           | Base R visualisation for any stage        |
| Viz    | [`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md)                 | Interactive Leaflet map (geographic only) |

Every workflow object has
[`print()`](https://rdrr.io/r/base/print.html),
[`summary()`](https://rdrr.io/r/base/summary.html), and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods.

## References

Lee, J.-G., Han, J., & Whang, K.-Y. (2007). Trajectory clustering: A
partition-and-group framework. *Proceedings of the 2007 ACM SIGMOD
International Conference on Management of Data*, 593–604. doi:
[10.1145/1247480.1247546](https://doi.org/10.1145/1247480.1247546)

## Documentation

Full documentation and vignettes are available at
<https://martinhoblisch.github.io/TRACLUS/>.

## Code of Conduct

Please note that the TRACLUS project is released with a [Contributor
Code of
Conduct](https://martinhoblisch.github.io/TRACLUS/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## License

GPL-3
