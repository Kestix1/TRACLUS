# TRACLUS 1.0.0

* First stable release.
* Full implementation of the TRACLUS algorithm (Lee, Han & Whang, SIGMOD 2007).
* **Partitioning:** MDL-based trajectory partitioning (`tc_partition()`).
* **Clustering:** DBSCAN density-based clustering with trajectory cardinality
  filtering (`tc_cluster()`).
* **Representation:** Sweep-line representative trajectory generation
  (`tc_represent()`).
* **Wrapper:** One-call pipeline via `tc_traclus()`.
* **Parameter estimation:** Entropy-based heuristic for `eps` and `min_lns`
  (`tc_estimate_params()`).
* **Distance methods:** Three methods for geographic data —
  `"haversine"` (exact spherical, slowest), `"projected"` (equirectangular
  projection to metres then euclidean, 5–10× faster with < 2 % error for
  regional datasets, **recommended default**), and `"euclidean"` (raw
  degree-unit distances, paper replication only).
* **Distance functions:** Euclidean and spherical (haversine) distance
  components exported as `tc_dist_perpendicular()`, `tc_dist_parallel()`,
  `tc_dist_angle()`, and `tc_dist_segments()`.
* **Data import:** HURDAT2 Best-Track file parser (`tc_read_hurdat2()`).
* **Visualisation:** Base R `plot()` methods for all workflow stages;
  interactive Leaflet maps via `tc_leaflet()` (geographic data only).
* Built-in toy dataset (`traclus_toy`) and bundled HURDAT2 subset
  (826 Atlantic storms, 1950–2004).
* S3 class hierarchy with `print()`, `summary()`, and `plot()` methods
  for every stage.
* C++ backend via Rcpp for distance computation, neighbourhood search,
  and MDL partitioning.
* 4 vignettes: Getting Started, Real-World Example, Parameter Guide,
  Geographic Distance Methods.
* pkgdown site, GitHub Actions CI (R-CMD-check on 5 platforms), Codecov
  test coverage.
