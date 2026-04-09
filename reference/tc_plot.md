# Plot TRACLUS objects

Convenience wrapper around the S3
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods for
TRACLUS objects. Equivalent to calling `plot(x, ...)` directly, but
discoverable via `?tc_plot` and RStudio's F1 help.

## Usage

``` r
tc_plot(x, show_clusters = FALSE, show_points = TRUE, ...)
```

## Arguments

- x:

  A TRACLUS workflow object (`tc_trajectories`, `tc_partitions`,
  `tc_clusters`, `tc_representatives`, or `tc_traclus`).

- show_clusters:

  Logical; passed to
  [`plot.tc_representatives()`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md)
  when `x` is a `tc_representatives` or `tc_traclus` object. If `FALSE`
  (default), cluster member segments are drawn in grey and only the
  representative lines appear in colour. If `TRUE`, cluster segments are
  drawn in full colour with representatives overlaid.

- show_points:

  Logical; passed to
  [`plot.tc_partitions()`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md)
  when `x` is a `tc_partitions` object. If `TRUE` (default),
  characteristic points are drawn as black X markers.

- ...:

  Additional arguments passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) /
  [`segments()`](https://rdrr.io/r/graphics/segments.html). Use to
  override default parameters like `main`, `xlim`, `ylim`.

## Value

`x`, invisibly.

## Details

All plot methods use the viridis colour palette (via
[`viridisLite::viridis()`](https://sjmgarnier.github.io/viridisLite/reference/viridis.html))
for colourblind-safe display and accept `...` for standard plot
parameters (`main`, `xlim`, `ylim`, `cex`, etc.).

This function calls `plot(x, ...)` with S3 dispatch based on the class
of `x`. Use `tc_plot()` when you want RStudio help lookup (F1) to work,
or [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for standard
R syntax — both produce identical results.

## See also

[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md)
for interactive Leaflet maps (geographic data only).

Other workflow functions:
[`plot.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md),
[`print.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md),
[`summary.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md),
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md),
[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md),
[`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md),
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
tc_plot(trj) # same as plot(trj)

```
