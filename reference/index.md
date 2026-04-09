# Package index

## Workflow

Core TRACLUS pipeline functions

- [`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md)
  **\[stable\]** : Validate and prepare trajectory data
- [`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md)
  **\[stable\]** : Partition trajectories using MDL-based approximation
- [`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md)
  **\[stable\]** : Cluster line segments using density-based clustering
- [`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md)
  **\[stable\]** : Generate representative trajectories for clusters
- [`tc_traclus()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_traclus.md)
  **\[stable\]** : Run the complete TRACLUS algorithm

## Helpers

Parameter estimation and data import

- [`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md)
  **\[stable\]** : Estimate clustering parameters from data
- [`tc_read_hurdat2()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_read_hurdat2.md)
  **\[stable\]** : Read HURDAT2 Best-Track data

## Distance Functions

Exported distance components

- [`tc_dist_perpendicular()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_perpendicular.md)
  **\[stable\]** : Perpendicular distance between two line segments
- [`tc_dist_parallel()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_parallel.md)
  : Parallel distance between two line segments
- [`tc_dist_angle()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_angle.md)
  : Angle distance between two line segments
- [`tc_dist_segments()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_segments.md)
  : Weighted total distance between two line segments

## Visualisation

Plot methods and interactive maps

- [`plot(`*`<tc_trajectories>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md)
  [`plot(`*`<tc_partitions>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md)
  [`plot(`*`<tc_clusters>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md)
  [`plot(`*`<tc_representatives>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md)
  [`plot(`*`<tc_traclus>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md)
  : Plot methods for TRACLUS objects
- [`plot(`*`<tc_estimate>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/plot.tc_estimate.md)
  : Plot method for tc_estimate objects
- [`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md)
  **\[stable\]** : Leaflet map for TRACLUS objects
- [`tc_plot()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_plot.md)
  : Plot TRACLUS objects

## Print and Summary

S3 print and summary methods

- [`print(`*`<tc_trajectories>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md)
  [`print(`*`<tc_partitions>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md)
  [`print(`*`<tc_clusters>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md)
  [`print(`*`<tc_representatives>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md)
  [`print(`*`<tc_traclus>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md)
  : Print methods for TRACLUS objects
- [`print(`*`<tc_estimate>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/print.tc_estimate.md)
  : Print method for tc_estimate objects
- [`summary(`*`<tc_trajectories>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md)
  [`summary(`*`<tc_partitions>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md)
  [`summary(`*`<tc_clusters>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md)
  [`summary(`*`<tc_representatives>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md)
  [`summary(`*`<tc_traclus>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md)
  [`summary(`*`<tc_estimate>`*`)`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md)
  : Summary methods for TRACLUS objects

## Data

Included datasets

- [`traclus_toy`](https://martinhoblisch.github.io/TRACLUS/reference/traclus_toy.md)
  : Toy trajectory dataset

## Package

- [`TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/TRACLUS-package.md)
  [`TRACLUS-package`](https://martinhoblisch.github.io/TRACLUS/reference/TRACLUS-package.md)
  : TRACLUS: Trajectory Clustering Using Line Segments
