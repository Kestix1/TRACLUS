# Parallel distance between two line segments

Computes the parallel distance between two line segments as defined in
the TRACLUS paper (Definition 2). The endpoints of the shorter segment
(Lj) are projected onto the **line** through the longer segment (Li).
The parallel distance of each projected point is its distance to the
nearer endpoint of Li. The overall parallel distance is \\d\_\parallel =
\min(l_1, l_2)\\.

## Usage

``` r
tc_dist_parallel(si, ei, sj, ej, method = "euclidean")
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

A single non-negative numeric value representing the parallel distance.

## Details

The swap convention from the original paper is applied internally: the
longer segment becomes Li. For `method = "haversine"`, signed
along-track distances are used to compute parallel offsets on the
sphere.

## See also

Other distance functions:
[`tc_dist_angle()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_angle.md),
[`tc_dist_perpendicular()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_perpendicular.md),
[`tc_dist_segments()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_segments.md)

## Examples

``` r
# Overlapping segments: parallel distance is 0
tc_dist_parallel(c(0, 0), c(10, 0), c(2, 1), c(8, 1))
#> [1] 2

# Non-overlapping segments
tc_dist_parallel(c(0, 0), c(10, 0), c(12, 1), c(15, 1))
#> [1] 2
```
