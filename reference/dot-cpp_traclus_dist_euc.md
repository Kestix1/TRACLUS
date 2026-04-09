# Compute weighted total euclidean distance between two segments (C++)

Compute weighted total euclidean distance between two segments (C++)

## Usage

``` r
.cpp_traclus_dist_euc(
  si_x,
  si_y,
  ei_x,
  ei_y,
  sj_x,
  sj_y,
  ej_x,
  ej_y,
  w_perp,
  w_par,
  w_angle,
  eps
)
```

## Arguments

- si_x, si_y, ei_x, ei_y:

  Coordinates of segment i

- sj_x, sj_y, ej_x, ej_y:

  Coordinates of segment j

- w_perp, w_par, w_angle:

  Distance component weights

- eps:

  Epsilon threshold for early termination

## Value

Weighted total distance (double)
