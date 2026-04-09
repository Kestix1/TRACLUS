# Plot methods for TRACLUS objects

Base R visualizations for each stage of the TRACLUS workflow. All
methods use the viridis colour palette (via
[`viridisLite::viridis()`](https://sjmgarnier.github.io/viridisLite/reference/viridis.html))
for colourblind-safe display and accept `...` for standard plot
parameters (`main`, `xlim`, `ylim`, `cex`, etc.).

## Usage

``` r
# S3 method for class 'tc_trajectories'
plot(x, ...)

# S3 method for class 'tc_partitions'
plot(x, show_points = TRUE, ...)

# S3 method for class 'tc_clusters'
plot(x, ...)

# S3 method for class 'tc_representatives'
plot(x, show_clusters = FALSE, legend_pos = "bottomright", ...)

# S3 method for class 'tc_traclus'
plot(x, ...)
```

## Arguments

- x:

  A TRACLUS workflow object.

- ...:

  Additional arguments passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) or
  [`segments()`](https://rdrr.io/r/graphics/segments.html). Use to
  override default parameters like `main`, `xlim`, `ylim`.

- show_points:

  Logical; if `TRUE` (default for `tc_partitions`), characteristic
  points are drawn as black X markers.

- show_clusters:

  Logical; if `FALSE` (default), cluster member segments are drawn in
  grey and only the representative lines appear in colour. If `TRUE`,
  cluster segments are drawn in full colour with representatives
  overlaid.

- legend_pos:

  Character; legend position (default `"bottomright"`). Set to `NA` to
  suppress the legend.

## Value

`x`, invisibly.

## See also

Other workflow functions:
[`print.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md),
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
plot(trj)

```
