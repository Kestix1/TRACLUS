# Construct a tc_representatives object

Low-level constructor that assembles the S3 list. No validation is
performed — use
[`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md)
for the validated public API.

## Usage

``` r
.new_tc_representatives(
  segments,
  representatives,
  clusters,
  n_clusters,
  n_noise,
  params,
  coord_type,
  method
)
```

## Arguments

- segments:

  data.frame with updated cluster_ids.

- representatives:

  data.frame with columns cluster_id, point_id, rx, ry.

- clusters:

  The source tc_clusters object (unmodified).

- n_clusters:

  Integer number of valid clusters.

- n_noise:

  Integer number of noise segments.

- params:

  List with min_lns and gamma.

- coord_type:

  Character: "euclidean" or "geographic".

- method:

  Character: "euclidean" or "haversine".

## Value

A tc_representatives S3 object.
