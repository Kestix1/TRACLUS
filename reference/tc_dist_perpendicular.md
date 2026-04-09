# Perpendicular distance between two line segments

**\[stable\]**

## Usage

``` r
tc_dist_perpendicular(si, ei, sj, ej, method = "euclidean")
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

A single non-negative numeric value representing the perpendicular
distance. Units are coordinate units for `"euclidean"` or meters for
`"haversine"`.

## Details

Computes the perpendicular distance between two line segments as defined
in the TRACLUS paper (Definition 1). The longer segment is treated as
the reference line (Li), and the endpoints of the shorter segment (Lj)
are projected onto the **line** (not the segment) through Li. The two
perpendicular distances are combined using the Lehmer mean of order 2:
\\d\_\perp = (l_1^2 + l_2^2) / (l_1 + l_2)\\.

The swap convention from the original paper is applied internally: the
longer segment becomes Li regardless of argument order. At exact length
equality (floating-point `==`), the first segment (i) is kept as Li.

For `method = "haversine"`, perpendicular distances are computed as
absolute cross-track distances to the great circle through Li, then
combined with the same Lehmer formula.

## See also

Other distance functions:
[`tc_dist_angle()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_angle.md),
[`tc_dist_parallel()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_parallel.md),
[`tc_dist_segments()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_segments.md)

## Examples

``` r
# Two parallel horizontal segments offset vertically
tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
#> [1] 5

# Geographic example (London to Paris great circle, point near Brussels)
tc_dist_perpendicular(
  c(-0.1278, 51.5074), c(2.3522, 48.8566),
  c(0.5, 50.5), c(3.0, 49.5),
  method = "haversine"
)
#> [1] 64346.98
```
