# DBSCAN expansion for TRACLUS line segment clustering

Implements the modified DBSCAN algorithm from Paper Figure 12. Core
logic: segments with \>= min_lns neighbours are "core segments" that
seed cluster expansion. The key modification from standard DBSCAN is
that noise segments CAN be reassigned to a cluster, but they do NOT
trigger further expansion (Paper Figure 12, Lines 23-26).

## Usage

``` r
.dbscan_expand(neighbours, min_lns)
```

## Arguments

- neighbours:

  List of integer vectors (1-indexed adjacency lists from C++
  neighbourhood computation).

- min_lns:

  Minimum neighbourhood size for core segments (integer \>= 1).

## Value

Integer vector of cluster assignments. 0 = unclassified (will become NA
noise). Cluster IDs are 1-indexed and sequential.
