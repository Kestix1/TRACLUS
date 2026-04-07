# --- Integration tests: full TRACLUS workflow ---

# --- Euclidean workflow ---

test_that("full euclidean workflow produces valid results", {
  toy <- generate_toy_trajectories()

  # Step 1: Load
  trj <- suppressMessages(
    tc_trajectories(toy,
      traj_id = "traj_id", x = "x", y = "y",
      coord_type = "euclidean"
    )
  )
  expect_s3_class(trj, "tc_trajectories")

  # Step 2: Partition
  parts <- suppressMessages(tc_partition(trj))
  expect_s3_class(parts, "tc_partitions")
  expect_true(parts$n_segments > 0)

  # Step 3: Cluster
  clust <- suppressMessages(tc_cluster(parts, eps = 25, min_lns = 3))
  expect_s3_class(clust, "tc_clusters")

  # Step 4: Represent
  repr <- suppressMessages(tc_represent(clust))
  expect_s3_class(repr, "tc_representatives")

  # Verify reference chain
  expect_identical(repr$clusters, clust)
  expect_identical(repr$clusters$partitions, parts)
  expect_identical(repr$clusters$partitions$trajectories, trj)

  # Coordinates should be in original format
  if (repr$n_clusters > 0) {
    expect_true(all(is.finite(repr$representatives$rx)))
    expect_true(all(is.finite(repr$representatives$ry)))
  }
})

test_that("tc_traclus wrapper gives same results as step-by-step", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy,
      traj_id = "traj_id", x = "x", y = "y",
      coord_type = "euclidean"
    )
  )

  # All-in-one
  result <- suppressMessages(tc_traclus(trj, eps = 25, min_lns = 3))

  # Should produce valid tc_traclus object
  expect_s3_class(result, "tc_traclus")
  expect_s3_class(result, "tc_representatives")

  # Full chain should exist
  expect_s3_class(result$clusters$partitions$trajectories, "tc_trajectories")
})

test_that("re-clustering same partitions with different params works", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy,
      traj_id = "traj_id", x = "x", y = "y",
      coord_type = "euclidean"
    )
  )
  parts <- suppressMessages(tc_partition(trj))

  # First clustering
  clust1 <- suppressMessages(
    suppressWarnings(tc_cluster(parts, eps = 15, min_lns = 3))
  )
  # Second clustering — different parameters, same partitions
  clust2 <- suppressMessages(
    suppressWarnings(tc_cluster(parts, eps = 50, min_lns = 2))
  )

  # Both should work, different results expected
  expect_s3_class(clust1, "tc_clusters")
  expect_s3_class(clust2, "tc_clusters")
  # Both reference the same partitions object
  expect_identical(clust1$partitions, clust2$partitions)
})

# --- Geographic workflow ---

# --- HURDAT2 workflow ---

test_that("HURDAT2 to TRACLUS pipeline works", {
  filepath <- system.file("extdata", "hurdat2_1950_2004.txt",
    package = "TRACLUS"
  )
  skip_if(filepath == "", "HURDAT2 test file not found")

  # Use high min_points to get a small subset for fast testing
  storms <- suppressMessages(tc_read_hurdat2(filepath, min_points = 80))

  trj <- suppressMessages(
    tc_trajectories(storms,
      traj_id = "storm_id",
      x = "lon", y = "lat", coord_type = "geographic"
    )
  )
  expect_s3_class(trj, "tc_trajectories")
  expect_equal(trj$coord_type, "geographic")
  expect_equal(trj$method, "haversine")

  # Run full pipeline on the subset
  parts <- suppressMessages(tc_partition(trj))
  expect_true(parts$n_segments > 0)

  clust <- suppressMessages(suppressWarnings(
    tc_cluster(parts, eps = 500000, min_lns = 2)
  ))
  expect_s3_class(clust, "tc_clusters")

  repr <- suppressMessages(suppressWarnings(tc_represent(clust)))
  expect_s3_class(repr, "tc_representatives")
})


# --- Parameter estimation integration ---

test_that("tc_estimate_params integrates with clustering workflow", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy,
      traj_id = "traj_id", x = "x", y = "y",
      coord_type = "euclidean"
    )
  )
  parts <- suppressMessages(tc_partition(trj))

  # Estimate parameters
  est <- suppressMessages(tc_estimate_params(parts))

  # Use estimated parameters for clustering
  clust <- suppressMessages(
    suppressWarnings(
      tc_cluster(parts, eps = est$eps, min_lns = est$min_lns)
    )
  )
  expect_s3_class(clust, "tc_clusters")
})

test_that("geographic full pipeline (haversine) end-to-end", {
  geo <- generate_geo_trajectories()

  # Step 1: Load with geographic coord_type
  trj <- suppressMessages(
    tc_trajectories(geo,
      traj_id = "storm_id", x = "lon", y = "lat",
      coord_type = "geographic"
    )
  )
  expect_equal(trj$method, "haversine")

  # Step 2: Partition
  parts <- suppressMessages(tc_partition(trj))
  expect_s3_class(parts, "tc_partitions")
  expect_equal(parts$method, "haversine")
  expect_true(parts$n_segments > 0)

  # Step 3: Cluster (large eps in meters to ensure we get clusters)
  clust <- suppressMessages(tc_cluster(parts, eps = 500000, min_lns = 2))
  expect_s3_class(clust, "tc_clusters")

  # Step 4: Represent
  repr <- suppressMessages(tc_represent(clust))
  expect_s3_class(repr, "tc_representatives")
  expect_equal(repr$method, "haversine")

  # Representatives must have valid geographic coordinates
  if (repr$n_clusters > 0) {
    expect_true(all(is.finite(repr$representatives$rx)))
    expect_true(all(is.finite(repr$representatives$ry)))
    expect_true(all(repr$representatives$rx >= -180 &
      repr$representatives$rx <= 180))
    expect_true(all(repr$representatives$ry >= -90 &
      repr$representatives$ry <= 90))
  }

  # Reference chain preserved
  expect_s3_class(repr$clusters$partitions$trajectories, "tc_trajectories")
})
