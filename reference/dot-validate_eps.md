# Validate eps parameter

Checks that eps is a single positive finite numeric value.

## Usage

``` r
.validate_eps(eps)
```

## Arguments

- eps:

  The eps value to validate.

## Value

`NULL` (invisible). Throws [`stop()`](https://rdrr.io/r/base/stop.html)
on invalid input.
