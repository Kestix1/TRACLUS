# Validate distance weight parameters

Checks that w_perp, w_par, and w_angle are non-negative finite numeric
values.

## Usage

``` r
.validate_weights(w_perp, w_par, w_angle)
```

## Arguments

- w_perp:

  Weight for perpendicular distance.

- w_par:

  Weight for parallel distance.

- w_angle:

  Weight for angle distance.

## Value

`NULL` (invisible). Throws [`stop()`](https://rdrr.io/r/base/stop.html)
on invalid input.
