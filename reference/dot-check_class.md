# Validate S3 class of workflow objects

Checks that the input object has the expected S3 class and throws an
informative error pointing the user to the correct function.

## Usage

``` r
.check_class(x, expected_class, next_function)
```

## Arguments

- x:

  The object to check.

- expected_class:

  The expected S3 class name (character).

- next_function:

  The function that should have produced the object (character), used in
  the error message.

## Value

`NULL` (invisible). Throws [`stop()`](https://rdrr.io/r/base/stop.html)
on class mismatch.
