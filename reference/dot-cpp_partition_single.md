# Partition a single trajectory (for testing)

Returns a vector of characteristic point indices (1-based, for R).

## Usage

``` r
.cpp_partition_single(x_coords, y_coords, method)
```

## Arguments

- x_coords:

  Numeric vector of x-coordinates.

- y_coords:

  Numeric vector of y-coordinates.

- method:

  Integer: 0 for euclidean, 1 for haversine.

## Value

Integer vector of characteristic point indices (1-based).
