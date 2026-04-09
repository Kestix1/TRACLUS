# Changelog

## TRACLUS 1.0.0

- First stable release.
- Full implementation of the TRACLUS algorithm (Lee, Han & Whang, SIGMOD
  2007).
- **Partitioning:** MDL-based trajectory partitioning
  ([`tc_partition()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_partition.md)).
- **Clustering:** DBSCAN density-based clustering with trajectory
  cardinality filtering
  ([`tc_cluster()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_cluster.md)).
- **Representation:** Sweep-line representative trajectory generation
  ([`tc_represent()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_represent.md)).
- **Wrapper:** One-call pipeline via
  [`tc_traclus()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_traclus.md).
- **Parameter estimation:** Entropy-based heuristic for `eps` and
  `min_lns`
  ([`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md)).
- **Distance methods:** Three methods for geographic data —
  `"haversine"` (exact spherical, slowest), `"projected"`
  (equirectangular projection to metres then euclidean, 5–10× faster
  with \< 2 % error for regional datasets, **recommended default**), and
  `"euclidean"` (raw degree-unit distances, paper replication only).
- **Distance functions:** Euclidean and spherical (haversine) distance
  components exported as
  [`tc_dist_perpendicular()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_perpendicular.md),
  [`tc_dist_parallel()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_parallel.md),
  [`tc_dist_angle()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_angle.md),
  and
  [`tc_dist_segments()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_dist_segments.md).
- **Data import:** HURDAT2 Best-Track file parser
  ([`tc_read_hurdat2()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_read_hurdat2.md)).
- **Visualisation:** Base R
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods for
  all workflow stages; interactive Leaflet maps via
  [`tc_leaflet()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_leaflet.md)
  (geographic data only).
- Built-in toy dataset (`traclus_toy`) and bundled HURDAT2 subset (826
  Atlantic storms, 1950–2004).
- S3 class hierarchy with
  [`print()`](https://rdrr.io/r/base/print.html),
  [`summary()`](https://rdrr.io/r/base/summary.html), and
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods for
  every stage.
- C++ backend via Rcpp for distance computation, neighbourhood search,
  and MDL partitioning.
- 4 vignettes: Getting Started, Real-World Example, Parameter Guide,
  Geographic Distance Methods.
- pkgdown site, GitHub Actions CI (R-CMD-check on 5 platforms), Codecov
  test coverage.
