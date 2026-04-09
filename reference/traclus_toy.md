# Toy trajectory dataset

A small euclidean trajectory dataset for testing and demonstration
purposes. Contains 6 trajectories in local km coordinates: five roughly
horizontal trajectories (TR1–TR5) with 7 points each and one nearly
vertical outlier trajectory (TR6) with 5 points.

## Usage

``` r
traclus_toy
```

## Format

A data.frame with 40 rows and 3 columns:

- traj_id:

  Character trajectory identifier (`"TR1"` through `"TR6"`).

- x:

  Numeric x-coordinate.

- y:

  Numeric y-coordinate.

## Source

Synthetic data created for the TRACLUS package.

## Examples

``` r
head(traclus_toy)
#>   traj_id  x y
#> 1     TR1  0 0
#> 2     TR1 10 2
#> 3     TR1 20 4
#> 4     TR1 30 4
#> 5     TR1 40 4
#> 6     TR1 50 8
trj <- tc_trajectories(traclus_toy,
  traj_id = "traj_id",
  x = "x", y = "y", coord_type = "euclidean"
)
#> Loaded 6 trajectories (40 points).
```
