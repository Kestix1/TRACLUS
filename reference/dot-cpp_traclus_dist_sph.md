# Compute weighted total spherical distance between two segments (C++)

Compute weighted total spherical distance between two segments (C++)

## Usage

``` r
.cpp_traclus_dist_sph(
  lon_si,
  lat_si,
  lon_ei,
  lat_ei,
  lon_sj,
  lat_sj,
  lon_ej,
  lat_ej,
  w_perp,
  w_par,
  w_angle,
  eps
)
```

## Arguments

- lon_si, lat_si, lon_ei, lat_ei:

  Segment i endpoints in degrees

- lon_sj, lat_sj, lon_ej, lat_ej:

  Segment j endpoints in degrees

- w_perp, w_par, w_angle:

  Distance component weights

- eps:

  Epsilon threshold for early termination

## Value

Weighted total distance in meters (double)
