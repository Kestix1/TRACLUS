# Angle distance between two line segments

Computes the angle distance between two line segments as defined in the
TRACLUS paper (Definition 3). The angle \\\theta\\ between the direction
vectors of Li and Lj determines the result: \\d\_\theta = \\Lj\\
\sin(\theta)\\ if \\\theta \< 90°\\, otherwise \\d\_\theta = \\Lj\\\\.

## Usage

``` r
tc_dist_angle(si, ei, sj, ej, method = "euclidean")
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

- method:

  Character string specifying the distance method. One of `"euclidean"`
  (default) or `"haversine"`. When `"haversine"`, coordinates are
  interpreted as (longitude, latitude) in decimal degrees and distances
  are returned in meters.

## Value

A single non-negative numeric value representing the angle distance.

## Details

The swap convention is applied internally: the longer segment becomes
Li. For `method = "haversine"`, the forward azimuth bearing difference
is used instead of the euclidean direction vector angle.

## See also

Other distance functions:
[`tc_dist_parallel()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_parallel.md),
[`tc_dist_perpendicular()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_perpendicular.md),
[`tc_dist_segments()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_segments.md)

## Examples

``` r
# Parallel segments: angle distance is 0
tc_dist_angle(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
#> [1] 0

# Perpendicular segments
tc_dist_angle(c(0, 0), c(10, 0), c(5, 0), c(5, 5))
#> [1] 5
```
