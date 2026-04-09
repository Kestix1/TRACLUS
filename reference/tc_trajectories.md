# Validate and prepare trajectory data

**\[stable\]**

## Usage

``` r
tc_trajectories(
  data,
  traj_id,
  x = NULL,
  y = NULL,
  coord_type = NULL,
  method = NULL,
  verbose = TRUE
)
```

## Arguments

- data:

  A `data.frame`, `tibble`, or `sf` object containing trajectory point
  data in tidy format (one row per point).

- traj_id:

  Character string naming the column that identifies trajectories.
  Values can be character, integer, or factor; they are stored
  internally as character.

- x:

  Character string naming the column with x-coordinates (longitude for
  geographic data). Required for `data.frame` input; ignored for `sf`
  input (extracted from geometry).

- y:

  Character string naming the column with y-coordinates (latitude for
  geographic data). Required for `data.frame` input; ignored for `sf`
  input (extracted from geometry).

- coord_type:

  Character string: `"euclidean"` or `"geographic"`. Required for
  `data.frame` input. For `sf` input, inferred from the CRS. Geographic
  data uses the convention x = longitude (-180 to 180), y = latitude
  (-90 to 90).

- method:

  Character string specifying the distance calculation method. Default
  `NULL` resolves to `"haversine"` for geographic data and `"euclidean"`
  for euclidean data. Options for `coord_type = "geographic"`:

  `"haversine"`

  :   (default) Exact great-circle distances in meters. Most accurate,
      but slowest for large datasets.

  `"projected"`

  :   Equirectangular projection to meters, then euclidean distances.
      5-10x faster than haversine with \< 2\\ for regional datasets
      (e.g., hurricane basins, taxi data). Recommended for most
      geographic use cases.

  `"euclidean"`

  :   Raw degree values treated as cartesian coordinates. Only for paper
      replication mode.

- verbose:

  Logical; if `TRUE` (default), prints an informative summary after
  validation.

## Value

A `tc_trajectories` S3 object (list) with elements:

- data:

  `data.frame` with columns `traj_id` (character), `x` (numeric), `y`
  (numeric), ordered by trajectory.

- coord_type:

  Resolved coordinate type (`"euclidean"` or `"geographic"`).

- method:

  Resolved distance method (`"euclidean"`, `"haversine"`, or
  `"projected"`).

- n_trajectories:

  Integer count of valid trajectories.

- n_points:

  Integer total number of points.

## Details

Validates input data, resolves coordinate types and distance methods,
and creates a `tc_trajectories` object for use in the TRACLUS pipeline.
This is the entry point for all TRACLUS analyses.

Validation is performed in four stages:

1.  **Base checks**: Column existence, numeric and finite coordinates,
    plausibility warnings (e.g., swapped lon/lat).

2.  **Filtering** (in order): (a) Remove rows with non-finite x/y or NA
    traj_id. (b) Remove consecutive duplicate points within
    trajectories. (c) Remove trajectories with fewer than 2 points.

3.  **Warnings**: Report what was removed, truncating IDs to the first 5
    if many are affected.

4.  **Final check**: Error if fewer than 2 valid trajectories remain.

**sf input requirements:**

- **Geometry type**: The sf object must contain `POINT` geometry. Other
  types (e.g., `LINESTRING`, `MULTIPOINT`) must be cast first:
  `sf::st_cast(data, "POINT")`.

- **CRS**: A coordinate reference system must be set on the object. If
  no CRS is present, assign one with `sf::st_set_crs(data, 4326)`
  (WGS-84) before calling `tc_trajectories()`.

- **Z/M dimensions**: Elevation (Z) or measure (M) coordinates are
  dropped automatically. Only X and Y are retained.

## See also

Other workflow functions:
[`plot.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/plot.TRACLUS.md),
[`print.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/print.TRACLUS.md),
[`summary.TRACLUS`](https://martinhoblisch.github.io/TRACLUS/reference/summary.TRACLUS.md),
[`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md),
[`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md),
[`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md),
[`tc_plot()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_plot.md),
[`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md),
[`tc_traclus()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_traclus.md)

## Examples

``` r
# Euclidean example with built-in toy data
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

# Geographic example
geo <- data.frame(
  id = rep(c("A", "B", "C"), each = 5),
  lon = c(-80, -78, -76, -74, -72, -82, -79, -76, -73, -70, -60, -58, -56, -54, -52),
  lat = c(25, 26, 27, 28, 29, 24, 25, 26, 27, 28, 30, 31, 32, 33, 34)
)
trj_geo <- tc_trajectories(geo,
  traj_id = "id", x = "lon", y = "lat",
  coord_type = "geographic"
)
#> Loaded 3 trajectories (15 points).

# sf input (coord_type inferred from CRS)
# \donttest{
if (requireNamespace("sf", quietly = TRUE)) {
  geo_sf <- sf::st_as_sf(geo, coords = c("lon", "lat"), crs = 4326)
  trj_sf <- tc_trajectories(geo_sf, traj_id = "id")
}
#> Loaded 3 trajectories (15 points).
# }
```
