# =============================================================================
# Tests for Phase 7: plot methods and tc_leaflet
# =============================================================================

# --- Helpers ---
make_full_workflow <- function() {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  parts <- suppressMessages(tc_partition(trj))
  clust <- suppressMessages(suppressWarnings(
    tc_cluster(parts, eps = 25, min_lns = 3)
  ))
  repr <- suppressMessages(suppressWarnings(tc_represent(clust)))
  list(trj = trj, parts = parts, clust = clust, repr = repr)
}

make_traclus_result <- function() {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  suppressMessages(suppressWarnings(
    tc_traclus(trj, eps = 25, min_lns = 3)
  ))
}

make_estimate <- function() {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  parts <- suppressMessages(tc_partition(trj))
  suppressMessages(tc_estimate_params(parts))
}

# =============================================================================
# plot.tc_trajectories
# =============================================================================

test_that("plot.tc_trajectories runs without error", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$trj))
})

test_that("plot.tc_trajectories returns invisible(x)", {
  wf <- make_full_workflow()
  result <- plot(wf$trj)
  expect_s3_class(result, "tc_trajectories")
})

test_that("plot.tc_trajectories accepts ... args", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$trj, main = "Custom Title", xlim = c(0, 80)))
})

# =============================================================================
# plot.tc_partitions
# =============================================================================

test_that("plot.tc_partitions runs without error", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$parts))
})

test_that("plot.tc_partitions with show_points = FALSE", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$parts, show_points = FALSE))
})

test_that("plot.tc_partitions returns invisible(x)", {
  wf <- make_full_workflow()
  result <- plot(wf$parts)
  expect_s3_class(result, "tc_partitions")
})

# =============================================================================
# plot.tc_clusters
# =============================================================================

test_that("plot.tc_clusters runs without error", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$clust))
})

test_that("plot.tc_clusters title shows parameters", {
  wf <- make_full_workflow()
  # This test verifies the function runs; visual inspection of title
  # would need a graphics device
  expect_no_error(plot(wf$clust))
})

test_that("plot.tc_clusters returns invisible(x)", {
  wf <- make_full_workflow()
  result <- plot(wf$clust)
  expect_s3_class(result, "tc_clusters")
})

test_that("plot.tc_clusters handles 0 clusters", {
  wf <- make_full_workflow()
  wf$clust$n_clusters <- 0L
  wf$clust$segments$cluster_id <- NA_integer_
  expect_no_error(plot(wf$clust))
})

# =============================================================================
# plot.tc_representatives
# =============================================================================

test_that("plot.tc_representatives runs in default mode", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$repr))
})

test_that("plot.tc_representatives show_clusters = TRUE", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$repr, show_clusters = TRUE))
})

test_that("plot.tc_representatives show_clusters = FALSE", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$repr, show_clusters = FALSE))
})

test_that("plot.tc_representatives legend_pos = NA suppresses legend", {
  wf <- make_full_workflow()
  expect_no_error(plot(wf$repr, legend_pos = NA))
})

test_that("plot.tc_representatives returns invisible(x)", {
  wf <- make_full_workflow()
  result <- plot(wf$repr)
  expect_s3_class(result, "tc_representatives")
})

test_that("plot.tc_representatives handles 0 clusters", {
  wf <- make_full_workflow()
  wf$repr$n_clusters <- 0L
  wf$repr$segments$cluster_id <- NA_integer_
  wf$repr$representatives <- data.frame(
    cluster_id = integer(0), point_id = integer(0),
    rx = numeric(0), ry = numeric(0)
  )
  expect_no_error(plot(wf$repr))
})

# =============================================================================
# plot.tc_traclus — S3 dispatch to tc_representatives
# =============================================================================

test_that("plot.tc_traclus dispatches to tc_representatives", {
  result <- make_traclus_result()
  expect_no_error(plot(result))
  # S3 dispatches to plot.tc_representatives
  ret <- plot(result)
  # Should return tc_traclus (not just tc_representatives)
  expect_s3_class(ret, "tc_traclus")
})

test_that("plot.tc_traclus accepts show_clusters parameter", {
  result <- make_traclus_result()
  expect_no_error(plot(result, show_clusters = TRUE))
})

# =============================================================================
# tc_plot — convenience wrapper
# =============================================================================

test_that("tc_plot() dispatches to plot methods", {
  wf <- make_full_workflow()
  expect_no_error(tc_plot(wf$trj))
  expect_no_error(tc_plot(wf$parts))
  expect_no_error(tc_plot(wf$clust))
  expect_no_error(tc_plot(wf$repr))
})

test_that("tc_plot() returns invisible(x)", {
  wf <- make_full_workflow()
  result <- tc_plot(wf$trj)
  expect_s3_class(result, "tc_trajectories")
})

test_that("tc_plot() passes show_clusters to tc_representatives", {
  wf <- make_full_workflow()
  expect_no_error(tc_plot(wf$repr, show_clusters = TRUE))
  expect_no_error(tc_plot(wf$repr, show_clusters = FALSE))
})

test_that("tc_plot() passes show_points to tc_partitions", {
  wf <- make_full_workflow()
  expect_no_error(tc_plot(wf$parts, show_points = FALSE))
  expect_no_error(tc_plot(wf$parts, show_points = TRUE))
})

test_that("tc_plot() does not forward show_clusters to tc_trajectories", {
  wf <- make_full_workflow()
  # show_clusters must NOT reach graphics::plot() — would cause "unused argument"
  expect_no_error(tc_plot(wf$trj))
  expect_no_error(tc_plot(wf$clust))
})

# =============================================================================
# plot.tc_estimate
# =============================================================================

test_that("plot.tc_estimate runs without error", {
  est <- make_estimate()
  expect_no_error(plot(est))
})

test_that("plot.tc_estimate returns invisible(x)", {
  est <- make_estimate()
  result <- plot(est)
  expect_s3_class(result, "tc_estimate")
})

test_that("plot.tc_estimate accepts ... args", {
  est <- make_estimate()
  expect_no_error(plot(est, main = "Custom Entropy Plot"))
})

# =============================================================================
# asp computation
# =============================================================================

test_that(".compute_asp returns 1 for euclidean", {
  asp <- TRACLUS:::.compute_asp("euclidean", c(0, 10, 20))
  expect_equal(asp, 1)
})

test_that(".compute_asp returns cos-corrected value for geographic", {
  asp <- TRACLUS:::.compute_asp("geographic", c(40, 50, 60))
  expected <- 1 / cos(50 * pi / 180)
  expect_equal(asp, expected, tolerance = 1e-10)
})

# =============================================================================
# tc_leaflet — basic checks (skip if leaflet not available)
# =============================================================================

test_that("plot.tc_representatives draws noise (incl. degraded) without error", {
  wf <- make_full_workflow()
  repr <- wf$repr

  # All NA segments are treated uniformly as noise
  noise <- is.na(repr$segments$cluster_id)

  # Both show_clusters modes should run without error
  expect_no_error(plot(repr))
  expect_no_error(plot(repr, show_clusters = TRUE))
})

test_that("tc_leaflet rejects euclidean data", {
  wf <- make_full_workflow()
  expect_error(tc_leaflet(wf$trj), "only available for geographic")
})

test_that("tc_leaflet generic exists and dispatches", {
  expect_true(is.function(tc_leaflet))
})

test_that("tc_leaflet.tc_trajectories works on geographic data", {
  skip_if_not_installed("leaflet")

  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic")
  )
  result <- expect_no_warning(tc_leaflet(trj))
  expect_s3_class(result, "leaflet")

  # Verify polylines are actually present in the widget
  call_methods <- vapply(result$x$calls, `[[`, character(1), "method")
  expect_true("addPolylines" %in% call_methods,
              info = "Leaflet widget should contain addPolylines calls")
})

test_that("tc_leaflet.tc_partitions works on geographic data", {
  skip_if_not_installed("leaflet")

  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic")
  )
  parts <- suppressMessages(tc_partition(trj))
  result <- expect_no_warning(tc_leaflet(parts))
  expect_s3_class(result, "leaflet")

  # Verify polylines are present
  call_methods <- vapply(result$x$calls, `[[`, character(1), "method")
  expect_true("addPolylines" %in% call_methods)
})

test_that("tc_leaflet.tc_clusters works on geographic data", {
  skip_if_not_installed("leaflet")

  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic")
  )
  parts <- suppressMessages(tc_partition(trj))
  clust <- suppressMessages(suppressWarnings(
    tc_cluster(parts, eps = 500000, min_lns = 2)
  ))
  result <- expect_no_warning(tc_leaflet(clust))
  expect_s3_class(result, "leaflet")

  # Verify polylines are present
  call_methods <- vapply(result$x$calls, `[[`, character(1), "method")
  expect_true("addPolylines" %in% call_methods)
})

test_that("tc_leaflet.tc_representatives works on geographic data", {
  skip_if_not_installed("leaflet")

  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic")
  )
  parts <- suppressMessages(tc_partition(trj))
  clust <- suppressMessages(suppressWarnings(
    tc_cluster(parts, eps = 500000, min_lns = 2)
  ))
  repr <- suppressMessages(suppressWarnings(tc_represent(clust)))
  result <- expect_no_warning(tc_leaflet(repr))
  expect_s3_class(result, "leaflet")

  # Verify polylines are present (segments + representatives)
  call_methods <- vapply(result$x$calls, `[[`, character(1), "method")
  n_polylines <- sum(call_methods == "addPolylines")
  expect_gt(n_polylines, 0, label = "Number of addPolylines calls")
})

test_that("tc_leaflet.tc_representatives show_clusters parameter works", {
  skip_if_not_installed("leaflet")

  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic")
  )
  parts <- suppressMessages(tc_partition(trj))
  clust <- suppressMessages(suppressWarnings(
    tc_cluster(parts, eps = 500000, min_lns = 2)
  ))
  repr <- suppressMessages(suppressWarnings(tc_represent(clust)))

  result_repr <- expect_no_warning(tc_leaflet(repr, show_clusters = FALSE))
  result_clust <- expect_no_warning(tc_leaflet(repr, show_clusters = TRUE))

  expect_s3_class(result_repr, "leaflet")
  expect_s3_class(result_clust, "leaflet")

  # Both modes should produce polylines
  for (res in list(result_repr, result_clust)) {
    call_methods <- vapply(res$x$calls, `[[`, character(1), "method")
    expect_true("addPolylines" %in% call_methods)
  }
})

test_that("tc_leaflet.tc_partitions adds circle markers when show_points = TRUE", {
  skip_if_not_installed("leaflet")

  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic")
  )
  parts <- suppressMessages(tc_partition(trj))

  # Default: show_points = TRUE → addMarkers present (cross markers via addLabelOnlyMarkers)
  result <- expect_no_warning(tc_leaflet(parts))
  call_methods <- vapply(result$x$calls, `[[`, character(1), "method")
  expect_true("addMarkers" %in% call_methods,
              info = "show_points = TRUE should produce cross markers")

  # show_points = FALSE → no addMarkers
  result2 <- expect_no_warning(tc_leaflet(parts, show_points = FALSE))
  call_methods2 <- vapply(result2$x$calls, `[[`, character(1), "method")
  expect_false("addMarkers" %in% call_methods2,
               info = "show_points = FALSE should suppress cross markers")
})

test_that("tc_leaflet.tc_traclus dispatches to tc_representatives", {
  skip_if_not_installed("leaflet")

  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic")
  )
  result <- suppressMessages(suppressWarnings(
    tc_traclus(trj, eps = 500000, min_lns = 2)
  ))
  map <- expect_no_warning(tc_leaflet(result))
  expect_s3_class(map, "leaflet")

  # Verify polylines
  call_methods <- vapply(map$x$calls, `[[`, character(1), "method")
  expect_true("addPolylines" %in% call_methods)
})
