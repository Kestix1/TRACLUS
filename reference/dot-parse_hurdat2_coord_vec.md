# Vectorised HURDAT2 coordinate parsing

Converts a character vector of coordinate strings (e.g., "27.6W",
"9.7N") to signed numeric values. Vectorised for performance on large
files.

## Usage

``` r
.parse_hurdat2_coord_vec(coord_strs, directions)
```

## Arguments

- coord_strs:

  Character vector of coordinate strings.

- directions:

  Character of length 1: "NS" or "EW".

## Value

Numeric vector of coordinate values.
