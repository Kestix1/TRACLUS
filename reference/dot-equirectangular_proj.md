# Local equirectangular projection to meters

Projects geographic coordinates (lon/lat in degrees) to a local planar
coordinate system in meters using the equirectangular approximation: x'
= lon \* cos(lat_mean) \* 111320, y' = lat \* 111320. Accurate for
typical TRACLUS cluster sizes (a few degrees).

## Usage

``` r
.equirectangular_proj(lon, lat, lat_mean)
```

## Arguments

- lon:

  Numeric vector of longitudes in degrees.

- lat:

  Numeric vector of latitudes in degrees.

- lat_mean:

  Mean latitude (in degrees) for the cos correction.

## Value

A list with elements `x` and `y` (numeric vectors in meters).
