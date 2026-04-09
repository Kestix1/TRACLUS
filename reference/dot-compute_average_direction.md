# Compute average direction vector for a cluster

Sums raw (unnormalized) direction vectors of all segments, then
normalizes. Longer segments contribute proportionally more to the
cluster direction (Paper Definition 11).

## Usage

``` r
.compute_average_direction(sx, sy, ex, ey)
```

## Arguments

- sx, sy, ex, ey:

  Numeric vectors of segment coordinates.

## Value

Numeric vector of length 2: unit direction vector (dx, dy). Falls back
to c(1, 0) if segments cancel out.
