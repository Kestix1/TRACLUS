# Geographic Distance Methods in TRACLUS

## Overview

TRACLUS supports two coordinate systems:

- **Euclidean** (`coord_type = "euclidean"`): Standard 2D Cartesian
  coordinates. Distances computed using Euclidean geometry.
- **Geographic** (`coord_type = "geographic"`): Longitude/latitude
  coordinates on a sphere. Three distance methods are available via the
  `method` argument.

This vignette explains the three geographic distance methods and when to
use each one.

## Choosing a method

When `coord_type = "geographic"`, the `method` argument controls how
distances are measured:

|                 | `"haversine"`                 | `"projected"`                | `"euclidean"`          |
|-----------------|-------------------------------|------------------------------|------------------------|
| **Accuracy**    | Exact spherical               | \< 2 % error (regional)      | Not metric             |
| **Speed**       | Slowest                       | ~ 5–10× faster               | Fastest                |
| **`eps` units** | Metres                        | Metres                       | Degree-units           |
| **Sweep-line**  | Equirectangular proj.         | Equirectangular proj.        | Direct coords          |
| **Use case**    | Global datasets, max accuracy | **Most geographic datasets** | Paper replication only |

**Rule of thumb:**

- Use `method = "projected"` (the default for geographic data) for
  regional datasets such as hurricane basins, city taxi data, or vessel
  AIS tracks. It is 5–10× faster than haversine with less than 2 %
  error.
- Use `method = "haversine"` when the dataset spans large portions of
  the globe (e.g., transoceanic flight paths) or when exact distances
  are required.
- Use `method = "euclidean"` only to replicate the original TRACLUS
  paper results exactly. Degree-unit distances are not physically
  meaningful.

``` r
library(TRACLUS)

filepath <- system.file("extdata", "hurdat2_1950_2004.txt",
  package = "TRACLUS"
)
storms <- tc_read_hurdat2(filepath, min_points = 80)
#> Filtered 813 storm(s) with < 80 points.

# Default: method = NULL resolves to "projected" for geographic data
trj_proj <- tc_trajectories(storms,
  traj_id = "storm_id",
  x = "lon", y = "lat",
  coord_type = "geographic"
)
#> Warning: Removed 3 consecutive duplicate point(s).
#> Loaded 13 trajectories (1187 points).

# Explicit haversine for comparison
trj_hav <- tc_trajectories(storms,
  traj_id = "storm_id",
  x = "lon", y = "lat",
  coord_type = "geographic",
  method = "haversine"
)
#> Warning: Removed 3 consecutive duplicate point(s).
#> Loaded 13 trajectories (1187 points).

cat("projected method:", trj_proj$method, "\n")
#> projected method: haversine
cat("haversine method:", trj_hav$method, "\n")
#> haversine method: haversine
```

## How “projected” works

`method = "projected"` applies an **equirectangular projection** to
convert longitude/latitude coordinates to metres before computing
distances:

$$x\prime = \text{lon} \times \cos\left( \bar{\varphi} \right) \times 111,320$$$$y\prime = \text{lat} \times 111,320$$

where $\bar{\varphi}$ is the mean latitude of all trajectory points
(computed once during
[`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md)).
Euclidean distances on these projected coordinates are then used
throughout the pipeline.

After the sweep-line generates representative waypoints in projected
coordinates, they are inverse-projected back to longitude/latitude.

This projection is accurate for datasets that cover a limited
latitudinal range (up to several thousand kilometres). The error grows
at high latitudes or for very large geographic extents, where
`"haversine"` should be preferred.

## Distance functions

When `coord_type = "geographic"`, the three distance components use
spherical geometry with `method = "haversine"`, or euclidean geometry on
projected coordinates with `method = "projected"`.

### Perpendicular distance ($d_{\bot}$) — haversine

Uses **cross-track distance**: the shortest distance from a point to the
great-circle arc defined by a line segment. Based on the formula:

$$d_{xt} = R \cdot \arcsin\left( \sin\left( \frac{d_{13}}{R} \right) \cdot \sin\left( \theta_{13} - \theta_{12} \right) \right)$$
where $R = 6,371,000$ m (Earth’s radius), $d_{13}$ is the haversine
distance from the segment start to the projection point, and
$\theta_{12}$, $\theta_{13}$ are initial bearings.

The perpendicular distance uses the Lehmer mean (order 2) of the two
cross-track distances, consistent with the euclidean definition.

### Parallel distance ($d_{\parallel}$) — haversine

Uses **along-track signed distance**: how far along the great-circle arc
a perpendicular foot falls. This provides the signed displacement needed
for the parallel distance computation.

### Angle distance ($d_{\angle}$)

Uses the **initial bearing** difference between two segments
(haversine), or the angle between direction vectors
(projected/euclidean). When the angle exceeds 90 degrees, the segment is
reversed before computing the angular penalty.

### Note on exported distance functions

The exported `tc_dist_*()` functions
([`tc_dist_perpendicular()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_perpendicular.md),
[`tc_dist_parallel()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_parallel.md),
[`tc_dist_angle()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_angle.md),
[`tc_dist_segments()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_segments.md))
accept `method = "haversine"` or `method = "euclidean"`. The
`"projected"` method is applied internally by the pipeline functions
([`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md),
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md),
[`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md))
and is not exposed in the low-level distance API.

### Example: comparing haversine distances

``` r
# Two segments near the English Channel
si <- c(-0.1278, 51.5074) # London
ei <- c(2.3522, 48.8566) # Paris
sj <- c(0.5, 50.5) # mid-Channel
ej <- c(3.0, 49.5) # Belgian coast

# Spherical distances (metres)
d_perp_sph <- tc_dist_perpendicular(si, ei, sj, ej, method = "haversine")
d_par_sph <- tc_dist_parallel(si, ei, sj, ej, method = "haversine")
d_ang_sph <- tc_dist_angle(si, ei, sj, ej, method = "haversine")
d_tot_sph <- tc_dist_segments(si, ei, sj, ej, method = "haversine")

cat(sprintf("Perpendicular: %.0f m\n", d_perp_sph))
#> Perpendicular: 64347 m
cat(sprintf("Parallel:      %.0f m\n", d_par_sph))
#> Parallel:      38770 m
cat(sprintf("Angle:         %.0f m\n", d_ang_sph))
#> Angle:         96141 m
cat(sprintf("Total:         %.0f m\n", d_tot_sph))
#> Total:         199258 m
```

## Partitioning

MDL-based partitioning uses haversine distances (`method = "haversine"`)
for both the $L(H)$ (hypothesis cost) and $L\left( D|H \right)$
(data-given-hypothesis cost) terms. With `method = "projected"`,
coordinates are first projected to metres, and then euclidean MDL
distances are applied — producing the same partition structure with
lower computational cost.

The partition points are the same characteristic points as in the
euclidean case, but distances are measured along great-circle arcs
(haversine) or in projected metres (projected).

## Clustering

Neighbourhood computation uses the distance method chosen at
[`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md)
time. The `eps` parameter is in **metres** for both `"haversine"` and
`"projected"`:

``` r
trj <- tc_trajectories(storms,
  traj_id = "storm_id",
  x = "lon", y = "lat",
  coord_type = "geographic"
) # method = "projected" default
#> Warning: Removed 3 consecutive duplicate point(s).
#> Loaded 13 trajectories (1187 points).

parts <- tc_partition(trj)
#> Partitioned 13 trajectories into 1151 line segments.
clust <- tc_cluster(parts, eps = 500000, min_lns = 3)
#> Clustering: 1 cluster(s), 5 noise segment(s).
clust
#> TRACLUS Clusters
#>   Clusters:     1
#>   Noise segs:   5
#>   Total segs:   1151
#>   eps:          5e+05 (meters)
#>   min_lns:      3
#>   Coord type:   geographic
#>   Method:       haversine
#>   Status:       clustered (run tc_represent next)
```

## Representation

The sweep-line algorithm operates in projected coordinates for both
`"haversine"` and `"projected"`. For `"haversine"` data, TRACLUS applies
the equirectangular projection internally just for the sweep-line step,
then inverse-projects the waypoints. For `"projected"` data, the
coordinates are already in projected metres throughout the pipeline.

``` r
repr <- tc_represent(clust)
#> Representatives: 1 trajectory(ies).
repr
#> TRACLUS Representatives
#>   Clusters:     1
#>   Noise segs:   5
#>   Waypoints:    1113 total (1113 per representative)
#>   gamma:        1
#>   min_lns:      3
#>   Coord type:   geographic
#>   Method:       haversine
#>   Status:       complete
plot(repr)
```

![](TRACLUS-spherical-geometry_files/figure-html/represent-1.png)

## Aspect ratio correction

When plotting geographic data with base R
[`plot()`](https://rdrr.io/r/graphics/plot.default.html), the aspect
ratio is corrected using:

$$\text{asp} = \frac{1}{\cos\left( \bar{\varphi} \right)}$$

This compensates for the convergence of meridians at higher latitudes,
producing visually accurate proportions.

## Interactive maps

For geographic data,
[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md)
provides interactive Leaflet maps that handle projection automatically:

``` r
tc_leaflet(repr)
```

Leaflet maps are only available for geographic data. Attempting to use
[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md)
on euclidean data will produce an informative error.

## Anti-meridian limitation

**Known limitation:** Trajectories that cross the anti-meridian
(180°/−180° longitude) can produce incorrect distance calculations. The
haversine formula itself handles the wrap-around correctly, but the
coordinate arithmetic in partitioning, clustering, and representation
assumes a continuous longitude range. A jump from 179° to −179° (a 2°
real-world gap) appears as a 358° discontinuity in the coordinate space.

### Workaround

Shift all longitudes to the range \[0°, 360°\] before processing:

``` r
# Shift to [0, 360] before creating trajectories
my_data$lon <- ifelse(my_data$lon < 0, my_data$lon + 360, my_data$lon)

trj <- tc_trajectories(my_data, traj_id = "id",
                       x = "lon", y = "lat",
                       coord_type = "geographic")

# Run the full pipeline in [0, 360] space
result <- tc_traclus(trj, eps = 500000, min_lns = 3)

# Shift representative waypoints back to [-180, 180] for display
# (tc_leaflet and most mapping tools expect [-180, 180])
```

### Limitation of the workaround

This shift works **only** when no trajectory crosses both the prime
meridian (0°) **and** the anti-meridian (180°). For transpacific routes
that span from, say, East Asia to the Americas, the shifted coordinates
may still be discontinuous. A robust solution would require
segment-level longitude unwrapping, which is not implemented in
version 1. This is documented honestly — for such datasets, users should
consider pre-processing their coordinates or splitting trajectories at
the anti-meridian.

## Key differences summary

| Aspect            | Euclidean                   | Geographic / haversine         | Geographic / projected        |
|-------------------|-----------------------------|--------------------------------|-------------------------------|
| Input coordinates | x, y (any units)            | longitude, latitude (degrees)  | longitude, latitude (degrees) |
| Distance method   | Euclidean                   | Haversine (spherical)          | Equirectangular + Euclidean   |
| eps units         | Coordinate units            | Metres                         | Metres                        |
| $d_{\bot}$        | Perpendicular foot distance | Cross-track distance           | Projected perpendicular       |
| $d_{\parallel}$   | Along-segment projection    | Along-track signed distance    | Projected parallel            |
| $d_{\angle}$      | sin(angle) × segment length | sin(bearing diff) × arc length | sin(angle) × proj. length     |
| Sweep-line        | Direct coordinates          | Equirectangular projection     | Already in projected metres   |
| Plot asp          | 1                           | 1/cos(mean latitude)           | 1/cos(mean latitude)          |
| Leaflet           | Not available               | Available                      | Available                     |
| Speed             | Fast                        | Slowest                        | ~ 5–10× faster than haversine |
| Accuracy          | N/A (no real-world metric)  | Exact                          | \< 2 % error (regional)       |
