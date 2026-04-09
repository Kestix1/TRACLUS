# Rotate coordinates so X'-axis aligns with direction vector

Applies a 2D rotation matrix to align the given direction vector with
the positive X-axis (Paper Formula 9).

## Usage

``` r
.rotate_to_axis(x, y, dir_vec)
```

## Arguments

- x, y:

  Numeric vectors of coordinates.

- dir_vec:

  Numeric vector of length 2: unit direction vector.

## Value

A list with elements `x` and `y` (rotated coordinates).
