# Compute epsilon-neighbourhoods for all segments (C++)

Computes pairwise distances between all line segments using the TRACLUS
weighted distance function. Uses a triangular loop (i \< j) to exploit
symmetry and early termination when accumulated distance exceeds eps.
Returns adjacency lists of segment indices within eps distance.

## Usage

``` r
.cpp_compute_neighbourhoods(
  sx,
  sy,
  ex,
  ey,
  eps,
  w_perp,
  w_par,
  w_angle,
  method,
  show_progress
)
```

## Arguments

- sx:

  NumericVector of segment start x-coordinates

- sy:

  NumericVector of segment start y-coordinates

- ex:

  NumericVector of segment end x-coordinates

- ey:

  NumericVector of segment end y-coordinates

- eps:

  Distance threshold

- w_perp:

  Weight for perpendicular distance

- w_par:

  Weight for parallel distance

- w_angle:

  Weight for angle distance

- method:

  Distance method: "euclidean" or "haversine"

- show_progress:

  Whether to show progress bar (only for n \> 5000)

## Value

List of integer vectors (adjacency lists, 1-indexed for R). Each element
contains the indices of neighbouring segments within eps.
