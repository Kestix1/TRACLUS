# Inverse equirectangular projection (meters to lon/lat)

Converts local planar coordinates back to geographic coordinates.
Inverse of
[`.equirectangular_proj()`](https://martinhoblisch.github.io/TRACLUS/reference/dot-equirectangular_proj.md).

## Usage

``` r
.equirectangular_inverse(x, y, lat_mean)
```

## Arguments

- x:

  Numeric vector of x-coordinates in meters.

- y:

  Numeric vector of y-coordinates in meters.

- lat_mean:

  Mean latitude (in degrees) used for the forward projection.

## Value

A list with elements `lon` and `lat` (numeric vectors in degrees).
