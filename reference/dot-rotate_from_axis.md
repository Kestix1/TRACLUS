# Rotate coordinates back from aligned system

Inverse of
[`.rotate_to_axis()`](https://martinhoblisch.github.io/TRACLUS/reference/dot-rotate_to_axis.md):
rotates from the aligned coordinate system back to the original.

## Usage

``` r
.rotate_from_axis(x, y, dir_vec)
```

## Arguments

- x, y:

  Numeric vectors of rotated coordinates.

- dir_vec:

  Numeric vector of length 2: unit direction vector.

## Value

A list with elements `x` and `y` (original coordinates).
