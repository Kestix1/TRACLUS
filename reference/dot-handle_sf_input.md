# Handle sf input: extract coordinates, infer coord_type

Handle sf input: extract coordinates, infer coord_type

## Usage

``` r
.handle_sf_input(data, traj_id, x, y, coord_type, method)
```

## Arguments

- data:

  sf object.

- traj_id:

  Column name for trajectory ID.

- x, y, coord_type, method:

  User-provided values (may be NULL).

## Value

List with data (data.frame), x, y, coord_type, method.
