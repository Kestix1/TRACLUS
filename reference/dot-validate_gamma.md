# Validate gamma parameter

Checks that gamma is a single positive finite numeric value.

## Usage

``` r
.validate_gamma(gamma)
```

## Arguments

- gamma:

  The gamma value to validate.

## Value

`NULL` (invisible). Throws [`stop()`](https://rdrr.io/r/base/stop.html)
on invalid input.
