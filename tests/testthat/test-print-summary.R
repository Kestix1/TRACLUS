# =============================================================================
# Tests for print and summary methods
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

# =============================================================================
# print methods: return invisible(x)
# =============================================================================

test_that("print.tc_clusters returns invisible(x)", {
  wf <- make_full_workflow()
  result <- print(wf$clust)
  expect_s3_class(result, "tc_clusters")
})

test_that("print.tc_traclus returns invisible(x)", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  result_obj <- suppressMessages(suppressWarnings(
    tc_traclus(trj, eps = 25, min_lns = 3)
  ))
  result <- print(result_obj)
  expect_s3_class(result, "tc_traclus")
})

test_that("print.tc_estimate returns invisible(x)", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  parts <- suppressMessages(tc_partition(trj))
  est <- suppressMessages(tc_estimate_params(parts))
  result <- print(est)
  expect_s3_class(result, "tc_estimate")
})

# =============================================================================
# print methods: output content
# =============================================================================

test_that("print.tc_trajectories shows trajectory count", {
  wf <- make_full_workflow()
  out <- capture.output(print(wf$trj))
  expect_true(any(grepl("Trajectories", out)))
  expect_true(any(grepl("Status", out)))
})


test_that("print.tc_clusters shows haversine unit for geographic data", {
  geo <- generate_geo_trajectories()
  trj <- suppressMessages(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "geographic")
  )
  parts <- suppressMessages(tc_partition(trj))
  clust <- suppressMessages(suppressWarnings(
    tc_cluster(parts, eps = 500000, min_lns = 2)
  ))
  out <- capture.output(print(clust))
  expect_true(any(grepl("meters", out)))
})


# =============================================================================
# summary methods: return invisible(object)
# =============================================================================

test_that("summary.tc_trajectories returns invisible(object)", {
  wf <- make_full_workflow()
  result <- summary(wf$trj)
  expect_s3_class(result, "tc_trajectories")
})

test_that("summary.tc_partitions returns invisible(object)", {
  wf <- make_full_workflow()
  result <- summary(wf$parts)
  expect_s3_class(result, "tc_partitions")
})

test_that("summary.tc_clusters returns invisible(object)", {
  wf <- make_full_workflow()
  result <- summary(wf$clust)
  expect_s3_class(result, "tc_clusters")
})

test_that("summary.tc_representatives returns invisible(object)", {
  wf <- make_full_workflow()
  result <- summary(wf$repr)
  expect_s3_class(result, "tc_representatives")
})

test_that("summary.tc_traclus returns invisible(object)", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  result_obj <- suppressMessages(suppressWarnings(
    tc_traclus(trj, eps = 25, min_lns = 3)
  ))
  result <- summary(result_obj)
  expect_s3_class(result, "tc_traclus")
})

# =============================================================================
# summary methods: output content
# =============================================================================

test_that("summary.tc_trajectories shows points per traj stats", {
  wf <- make_full_workflow()
  out <- capture.output(summary(wf$trj))
  expect_true(any(grepl("Points per traj", out)))
  expect_true(any(grepl("min", out)))
})


test_that("summary.tc_clusters shows noise percentage", {
  wf <- make_full_workflow()
  out <- capture.output(summary(wf$clust))
  expect_true(any(grepl("Noise", out)))
  expect_true(any(grepl("%", out)))
})


test_that("summary.tc_traclus shows full pipeline stats", {
  toy <- generate_toy_trajectories()
  trj <- suppressMessages(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean")
  )
  result <- suppressMessages(suppressWarnings(
    tc_traclus(trj, eps = 25, min_lns = 3)
  ))
  out <- capture.output(summary(result))
  expect_true(any(grepl("Input trajs", out)))
  expect_true(any(grepl("Partitioned into", out)))
})
