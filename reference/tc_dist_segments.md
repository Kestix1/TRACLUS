# Weighted total distance between two line segments

Computes the weighted combination of perpendicular, parallel, and angle
distances between two line segments (Paper Section 2.3): \$\$dist(L_i,
L_j) = w\_\perp \cdot d\_\perp + w\_\parallel \cdot d\_\parallel +
w\_\theta \cdot d\_\theta\$\$

## Usage

``` r
tc_dist_segments(
  si,
  ei,
  sj,
  ej,
  w_perp = 1,
  w_par = 1,
  w_angle = 1,
  method = "euclidean"
)
```

## Arguments

- si:

  Numeric vector of length 2: start point of segment i `(x, y)` or
  `(longitude, latitude)`.

- ei:

  Numeric vector of length 2: end point of segment i.

- sj:

  Numeric vector of length 2: start point of segment j.

- ej:

  Numeric vector of length 2: end point of segment j.

- w_perp:

  Non-negative numeric weight for perpendicular distance. Default is 1.

- w_par:

  Non-negative numeric weight for parallel distance. Default is 1.

- w_angle:

  Non-negative numeric weight for angle distance. Default is 1.

- method:

  Character string specifying the distance method. One of `"euclidean"`
  (default) or `"haversine"`. When `"haversine"`, coordinates are
  interpreted as (longitude, latitude) in decimal degrees and distances
  are returned in meters.

## Value

A single non-negative numeric value representing the weighted total
distance.

## Details

Each distance component is computed only if its weight is positive. The
swap convention (longer segment = Li) is applied independently by each
sub-function.

## See also

Other distance functions:
[`tc_dist_angle()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_angle.md),
[`tc_dist_parallel()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_parallel.md),
[`tc_dist_perpendicular()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_perpendicular.md)

## Examples

``` r
# Default equal weights
tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(8, 6))
#> [1] 6.545455

# Custom weights emphasising perpendicular distance
tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(8, 6),
  w_perp = 2, w_par = 0.5, w_angle = 1
)
#> [1] 12.09091
```
