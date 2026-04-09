# Renumber cluster IDs to be sequential starting from 1

After trajectory cardinality filtering, cluster IDs may have gaps (e.g.,
1, 3, 5). This function renumbers them to 1, 2, 3 for consistent colour
assignment in plots.

## Usage

``` r
.renumber_clusters(cluster_ids)
```

## Arguments

- cluster_ids:

  Integer vector of cluster assignments (0 or NA = noise).

## Value

Integer vector with renumbered cluster IDs. Noise remains 0.
