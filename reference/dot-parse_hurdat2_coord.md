# Parse a HURDAT2 coordinate string

Converts strings like "27.6W" or "9.7N" to signed numeric values. W and
S are negative, E and N are positive.

## Usage

``` r
.parse_hurdat2_coord(coord_str, directions)
```

## Arguments

- coord_str:

  Character coordinate string with direction suffix.

- directions:

  Character of length 2: positive and negative direction letters (e.g.,
  "NS" for latitude, "EW" for longitude).

## Value

Numeric coordinate value, or NA if parsing fails.
