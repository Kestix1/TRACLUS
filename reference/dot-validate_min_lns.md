# Validate min_lns parameter

Checks that min_lns is a single positive integer (\>= 1).

## Usage

``` r
.validate_min_lns(min_lns)
```

## Arguments

- min_lns:

  The min_lns value to validate.

## Value

`NULL` (invisible). Throws [`stop()`](https://rdrr.io/r/base/stop.html)
on invalid input.
