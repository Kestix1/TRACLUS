# Compute MDL cost of partitioning (costpar) for testing

Compute MDL cost of partitioning (costpar) for testing

## Usage

``` r
.cpp_mdl_costpar(part_sx, part_sy, part_ex, part_ey, sub_x, sub_y, method)
```

## Arguments

- part_sx, part_sy, part_ex, part_ey:

  Partition segment coordinates.

- sub_x:

  Numeric vector of sub-segment x-coordinates (all points).

- sub_y:

  Numeric vector of sub-segment y-coordinates (all points).

- method:

  Integer: 0 for euclidean, 1 for haversine.

## Value

The MDL costpar value (double).
