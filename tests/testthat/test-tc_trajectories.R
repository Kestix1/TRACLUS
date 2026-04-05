# =============================================================================
# Tests for tc_trajectories() — input validation, sf-handling, coord_type/
# method resolution, filtering, grouping, edge cases
# =============================================================================

# --- Basic happy path ---

test_that("tc_trajectories creates valid object from data.frame", {
  toy <- generate_toy_trajectories()
  trj <- tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_s3_class(trj, "tc_trajectories")
  expect_equal(trj$n_trajectories, 6L)
  expect_equal(trj$n_points, 40L)
  expect_equal(trj$coord_type, "euclidean")
  expect_equal(trj$method, "euclidean")
  expect_true(is.data.frame(trj$data))
  expect_equal(names(trj$data), c("traj_id", "x", "y"))
})

test_that("tc_trajectories works with geographic data", {
  geo <- generate_geo_trajectories()
  trj <- tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                         coord_type = "geographic", verbose = FALSE)
  expect_equal(trj$coord_type, "geographic")
  expect_equal(trj$method, "haversine")
  expect_equal(trj$n_trajectories, 3L)
})

test_that("tc_trajectories returns correct column names", {
  toy <- generate_toy_trajectories()
  trj <- tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_equal(names(trj$data), c("traj_id", "x", "y"))
})

# --- coord_type / method resolution ---

test_that("method defaults to 'haversine' for geographic", {
  geo <- generate_geo_trajectories()
  trj <- tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                         coord_type = "geographic", verbose = FALSE)
  expect_equal(trj$method, "haversine")
})

test_that("method defaults to 'euclidean' for euclidean", {
  toy <- generate_toy_trajectories()
  trj <- tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_equal(trj$method, "euclidean")
})

test_that("paper replication mode: geographic + euclidean method", {
  geo <- generate_geo_trajectories()
  expect_message(
    trj <- tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                           coord_type = "geographic", method = "euclidean",
                           verbose = TRUE),
    "paper replication mode"
  )
  expect_equal(trj$method, "euclidean")
  expect_equal(trj$coord_type, "geographic")
})

test_that("method = 'projected' works with geographic data", {
  geo <- generate_geo_trajectories()
  trj <- tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                         coord_type = "geographic", method = "projected",
                         verbose = FALSE)
  expect_equal(trj$method, "projected")
  expect_equal(trj$coord_type, "geographic")
  expect_false(is.null(trj$proj_params))
  expect_true(is.numeric(trj$proj_params$lat_mean))
  expect_true(is.numeric(trj$proj_params$lon_mean))
  # Data should still contain original lon/lat
  expect_true(all(trj$data$x >= -180 & trj$data$x <= 180))
})

test_that("method = 'projected' is rejected for euclidean data", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", method = "projected",
                    verbose = FALSE),
    "not compatible"
  )
})

test_that("haversine + euclidean coord_type is rejected", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", method = "haversine",
                    verbose = FALSE),
    "not compatible"
  )
})

# --- Input validation ---

test_that("missing x, y, coord_type for data.frame input stops", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", verbose = FALSE),
    "required for data.frame"
  )
})

test_that("non-existent column names stop with error", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "nonexistent", x = "x", y = "y",
                    coord_type = "euclidean", verbose = FALSE),
    "not found"
  )
})

test_that("non-numeric x/y columns stop with error", {
  bad <- data.frame(traj_id = rep("A", 3), x = c("a", "b", "c"),
                    y = c(1, 2, 3), stringsAsFactors = FALSE)
  expect_error(
    tc_trajectories(bad, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", verbose = FALSE),
    "numeric"
  )
})

# --- Filtering ---

test_that("rows with NA coordinates are removed", {
  df <- data.frame(
    traj_id = rep(c("A", "B"), each = 4),
    x = c(0, 1, NA, 3, 0, 1, 2, 3),
    y = c(0, 1, 2, 3, 0, 1, 2, 3)
  )
  expect_warning(
    trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                           coord_type = "euclidean", verbose = FALSE),
    "non-finite"
  )
  expect_equal(trj$n_points, 7L)
})

test_that("rows with Inf coordinates are removed", {
  df <- data.frame(
    traj_id = rep(c("A", "B"), each = 3),
    x = c(0, Inf, 2, 0, 1, 2),
    y = c(0, 1, 2, 0, 1, 2)
  )
  expect_warning(
    trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                           coord_type = "euclidean", verbose = FALSE),
    "non-finite"
  )
  expect_equal(trj$n_points, 5L)
})

test_that("rows with NaN coordinates are removed", {
  df <- data.frame(
    traj_id = rep(c("A", "B"), each = 3),
    x = c(0, NaN, 2, 0, 1, 2),
    y = c(0, 1, 2, 0, 1, 2)
  )
  expect_warning(
    trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                           coord_type = "euclidean", verbose = FALSE),
    "non-finite"
  )
})

test_that("consecutive duplicates are removed", {
  df <- data.frame(
    traj_id = rep(c("A", "B"), each = 4),
    x = c(0, 0, 1, 2, 0, 1, 1, 2),
    y = c(0, 0, 1, 2, 0, 1, 1, 2)
  )
  expect_warning(
    trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                           coord_type = "euclidean", verbose = FALSE),
    "consecutive duplicate"
  )
  expect_equal(trj$n_points, 6L)
})

test_that("trajectories with < 2 points are removed", {
  df <- data.frame(
    traj_id = c("A", "B", "B", "C", "C", "C"),
    x = c(0, 0, 1, 0, 1, 2),
    y = c(0, 0, 1, 0, 1, 2)
  )
  expect_warning(
    trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                           coord_type = "euclidean", verbose = FALSE),
    "< 2 points"
  )
  expect_false("A" %in% trj$data$traj_id)
})

test_that("filtering to < 2 trajectories stops with error", {
  df <- data.frame(
    traj_id = rep("A", 5),
    x = c(0, 1, 2, 3, 4),
    y = c(0, 1, 2, 3, 4)
  )
  expect_error(
    tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", verbose = FALSE),
    "Fewer than 2"
  )
})

# --- Grouping ---

test_that("unsorted input is grouped correctly by traj_id", {
  df <- data.frame(
    traj_id = c("B", "A", "B", "A", "B", "A"),
    x = c(10, 0, 11, 1, 12, 2),
    y = c(10, 0, 11, 1, 12, 2)
  )
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  # Check that within each trajectory, points are in original order
  a_data <- trj$data[trj$data$traj_id == "A", ]
  expect_equal(a_data$x, c(0, 1, 2))
  b_data <- trj$data[trj$data$traj_id == "B", ]
  expect_equal(b_data$x, c(10, 11, 12))
})

test_that("first-appearance order of traj_ids is preserved", {
  df <- data.frame(
    traj_id = c("B", "A", "B", "A", "B", "A"),
    x = c(10, 0, 11, 1, 12, 2),
    y = c(10, 0, 11, 1, 12, 2)
  )
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  # B appeared first, so B's data should come before A's
  first_ids <- unique(trj$data$traj_id)
  expect_equal(first_ids[1], "B")
})

# --- traj_id type conversion ---

test_that("integer traj_id is converted to character", {
  df <- data.frame(
    traj_id = rep(1:3, each = 3),
    x = rep(c(0, 1, 2), 3),
    y = rep(c(0, 1, 2), 3)
  )
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_true(is.character(trj$data$traj_id))
})

test_that("factor traj_id is converted to character", {
  df <- data.frame(
    traj_id = factor(rep(c("A", "B", "C"), each = 3)),
    x = rep(c(0, 1, 2), 3),
    y = rep(c(0, 1, 2), 3)
  )
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_true(is.character(trj$data$traj_id))
})

# --- Plausibility warnings ---

test_that("geographic data warns about swapped coordinates", {
  # x values in [-90, 90] (latitude range) but y values outside [-90, 90]
  # (longitude range) — suggests x and y are swapped
  df <- data.frame(
    traj_id = rep(c("A", "B"), each = 3),
    x = c(25, 26, 27, 30, 31, 32),       # lat range in x
    y = c(-120, -118, -116, -100, -98, -96)  # lon range in y (outside [-90,90])
  )
  expect_warning(
    tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "geographic", verbose = FALSE),
    "swapped"
  )
})

test_that("euclidean data warns about potential geographic values", {
  geo <- generate_geo_trajectories()
  expect_warning(
    tc_trajectories(geo, traj_id = "storm_id", x = "lon", y = "lat",
                    coord_type = "euclidean", verbose = FALSE),
    "geographic"
  )
})

# --- verbose ---

test_that("verbose = TRUE produces message", {
  toy <- generate_toy_trajectories()
  expect_message(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", verbose = TRUE),
    "Loaded"
  )
})

test_that("verbose = FALSE suppresses messages", {
  toy <- generate_toy_trajectories()
  expect_no_message(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", verbose = FALSE)
  )
})

# --- print and summary ---

test_that("print.tc_trajectories returns invisible(x)", {
  toy <- generate_toy_trajectories()
  trj <- tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  out <- capture.output(result <- print(trj))
  expect_identical(result, trj)
  expect_true(any(grepl("TRACLUS Trajectories", out)))
  expect_true(any(grepl("tc_partition", out)))
})

test_that("summary.tc_trajectories returns invisible(object)", {
  toy <- generate_toy_trajectories()
  trj <- tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  out <- capture.output(result <- summary(trj))
  expect_identical(result, trj)
  expect_true(any(grepl("Summary", out)))
  expect_true(any(grepl("Points per traj", out)))
})

# --- sf handling ---

test_that("sf input works when sf is available", {
  skip_if_not_installed("sf")

  pts <- data.frame(
    storm_id = rep(c("A", "B", "C"), each = 3),
    lon = c(-80, -78, -76, -82, -80, -78, -60, -58, -56),
    lat = c(25, 26, 27, 24, 25, 26, 30, 31, 32)
  )
  sf_pts <- sf::st_as_sf(pts, coords = c("lon", "lat"), crs = 4326)

  trj <- tc_trajectories(sf_pts, traj_id = "storm_id", verbose = FALSE)
  expect_s3_class(trj, "tc_trajectories")
  expect_equal(trj$coord_type, "geographic")
  expect_equal(trj$method, "haversine")
  expect_equal(trj$n_trajectories, 3L)
})

test_that("sf input without CRS stops", {
  skip_if_not_installed("sf")

  pts <- data.frame(
    id = rep(c("A", "B"), each = 3),
    x = c(0, 1, 2, 3, 4, 5),
    y = c(0, 1, 2, 3, 4, 5)
  )
  sf_pts <- sf::st_as_sf(pts, coords = c("x", "y"))

  expect_error(
    tc_trajectories(sf_pts, traj_id = "id", verbose = FALSE),
    "valid CRS"
  )
})

test_that("sf input with consecutive duplicate points: warning and correct point count", {
  skip_if_not_installed("sf")

  # Build an sf POINT object (CRS 4326) with consecutive duplicates in traj "A"
  pts <- data.frame(
    storm_id = c("A", "A", "A", "A", "B", "B", "B"),
    lon = c(-80, -80, -78, -76,   # A: point 1 duplicated consecutively
            -82, -79, -76),
    lat = c(25, 25, 27, 29,
            24, 26, 28)
  )
  sf_pts <- sf::st_as_sf(pts, coords = c("lon", "lat"), crs = 4326)

  expect_warning(
    trj <- tc_trajectories(sf_pts, traj_id = "storm_id", verbose = FALSE),
    "duplicate"
  )

  # A had 4 points: 1 duplicate removed → 3 points remain
  a_pts <- trj$data[trj$data$traj_id == "A", ]
  expect_equal(nrow(a_pts), 3L)

  # B had no duplicates → all 3 points retained
  b_pts <- trj$data[trj$data$traj_id == "B", ]
  expect_equal(nrow(b_pts), 3L)
})

# --- Edge cases ---

test_that("two-point trajectories are valid", {
  df <- generate_two_point_trajectories()
  trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_equal(trj$n_trajectories, 2L)
  expect_equal(trj$n_points, 4L)
})

test_that("NA in traj_id column is removed", {
  df <- data.frame(
    traj_id = c("A", "A", NA, "B", "B", "B"),
    x = c(0, 1, 2, 3, 4, 5),
    y = c(0, 1, 2, 3, 4, 5)
  )
  expect_warning(
    trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                           coord_type = "euclidean", verbose = FALSE),
    "non-finite|NA"
  )
  expect_false(any(is.na(trj$data$traj_id)))
})

test_that("dedup then short-traj removal chain works correctly", {
  # Trajectory A: (0,0), (0,0), (1,1) -> after dedup: (0,0), (1,1) -> 2 points, ok
  # Trajectory B: (2,2), (2,2) -> after dedup: (2,2) -> 1 point, removed
  # Trajectory C: (3,3), (4,4), (5,5) -> 3 points, ok
  df <- data.frame(
    traj_id = c("A", "A", "A", "B", "B", "C", "C", "C"),
    x = c(0, 0, 1, 2, 2, 3, 4, 5),
    y = c(0, 0, 1, 2, 2, 3, 4, 5)
  )
  suppressWarnings(
    trj <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                           coord_type = "euclidean", verbose = FALSE)
  )
  expect_equal(trj$n_trajectories, 2L)
  expect_true("A" %in% trj$data$traj_id)
  expect_true("C" %in% trj$data$traj_id)
  expect_false("B" %in% trj$data$traj_id)
})

# --- Antimeridian warning ---

test_that("antimeridian crossing produces warning for geographic data", {
  df <- data.frame(
    traj_id = rep(c("A", "B"), each = 3),
    x = c(170, -170, -160, -80, -78, -76),   # A crosses antimeridian
    y = c(30, 30, 30, 25, 26, 27)
  )
  expect_warning(
    tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "geographic", verbose = FALSE),
    "antimeridian"
  )
})

# =============================================================================
# New tests: HIGH gaps (Session 1)
# =============================================================================

test_that("D04 / H-7: invalid coord_type gives informative error", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "cartesian", verbose = FALSE),
    "'coord_type'"
  )
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "WGS84", verbose = FALSE),
    "'coord_type'"
  )
})

test_that("D05 / H-8: missing x column gives informative error", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", x = "lon", y = "y",
                    coord_type = "euclidean", verbose = FALSE),
    "not found"
  )
})

test_that("D06 / H-8: missing y column gives informative error", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "lat",
                    coord_type = "euclidean", verbose = FALSE),
    "not found"
  )
})

# --- traclus_toy dataset ---

test_that("traclus_toy dataset loads and works", {
  expect_true(is.data.frame(traclus_toy))
  expect_equal(nrow(traclus_toy), 40L)
  expect_true(all(c("traj_id", "x", "y") %in% names(traclus_toy)))
  trj <- tc_trajectories(traclus_toy, traj_id = "traj_id", x = "x", y = "y",
                         coord_type = "euclidean", verbose = FALSE)
  expect_s3_class(trj, "tc_trajectories")
  expect_equal(trj$n_trajectories, 6L)
})

# =============================================================================
# New tests: MEDIUM + LOW gaps (Session 2)
# =============================================================================

test_that("D09 / M-2: non-numeric y column gives error", {
  bad <- data.frame(traj_id = rep("A", 3), x = c(1, 2, 3),
                    y = c("a", "b", "c"), stringsAsFactors = FALSE)
  expect_error(
    tc_trajectories(bad, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "euclidean", verbose = FALSE),
    "numeric"
  )
})

test_that("D18 / M-3: sf POINT Z input emits message about dropping Z dimension", {
  skip_if_not_installed("sf")
  pts <- data.frame(
    id  = rep(c("A", "B"), each = 3),
    x   = c(0, 1, 2, 3, 4, 5),
    y   = c(0, 1, 2, 3, 4, 5),
    z   = c(10, 20, 30, 10, 20, 30)
  )
  sf_pts <- sf::st_as_sf(pts, coords = c("x", "y", "z"))
  sf_pts <- sf::st_set_crs(sf_pts, 3857)  # projected CRS → euclidean
  expect_message(
    tc_trajectories(sf_pts, traj_id = "id", verbose = FALSE),
    "Z/M"
  )
})

test_that("D19 / M-3: sf non-POINT geometry gives error", {
  skip_if_not_installed("sf")
  line_sf <- sf::st_sf(
    id       = c("A", "B"),
    geometry = sf::st_sfc(
      sf::st_linestring(rbind(c(-80, 25), c(-78, 26), c(-76, 27))),
      sf::st_linestring(rbind(c(-82, 24), c(-80, 25), c(-78, 26)))
    ),
    crs = 4326
  )
  expect_error(
    tc_trajectories(line_sf, traj_id = "id", verbose = FALSE),
    "POINT"
  )
})

test_that("D24 / M-4: non-consecutive duplicate points are NOT removed", {
  # Traj A: (0,0),(1,1),(0,0),(2,2) — identical points at pos 1 and 3 are
  # non-consecutive (pos 2 differs) → all 4 points must be retained.
  df <- data.frame(
    traj_id = c(rep("A", 4), rep("B", 3)),
    x       = c(0, 1, 0, 2,   3, 4, 5),
    y       = c(0, 1, 0, 2,   3, 4, 5)
  )
  trj    <- tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                             coord_type = "euclidean", verbose = FALSE)
  a_pts  <- trj$data[trj$data$traj_id == "A", ]
  expect_equal(nrow(a_pts), 4L)
})

test_that("D29 / M-5: geographic x outside [-180, 180] gives warning", {
  df <- data.frame(
    traj_id = rep(c("A", "B"), each = 3),
    x       = c(185, 186, 187,   10, 11, 12),  # A has longitude > 180
    y       = c(30, 31, 32,      40, 41, 42)
  )
  expect_warning(
    tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "geographic", verbose = FALSE),
    "outside|\\[-180"
  )
})

test_that("D30 / M-5: geographic y outside [-90, 90] gives warning", {
  # B's x values (100,101,102) exceed 90 to prevent the swap-detection warning,
  # ensuring only the out-of-range warning fires.
  df <- data.frame(
    traj_id = rep(c("A", "B"), each = 3),
    x       = c(10, 11, 12,    100, 101, 102),
    y       = c(95, 96, 97,    40,  41,  42)   # A has latitude > 90
  )
  expect_warning(
    tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                    coord_type = "geographic", verbose = FALSE),
    "outside|\\[-90"
  )
})

test_that("D01 / L-2: missing x gives package-specific error", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", y = "y",
                    coord_type = "euclidean", verbose = FALSE),
    "x, y, and coord_type are required"
  )
})

test_that("D02 / L-2: missing y gives package-specific error", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", x = "x",
                    coord_type = "euclidean", verbose = FALSE),
    "x, y, and coord_type are required"
  )
})

test_that("D03 / L-2: missing coord_type gives package-specific error", {
  toy <- generate_toy_trajectories()
  expect_error(
    tc_trajectories(toy, traj_id = "traj_id", x = "x", y = "y",
                    verbose = FALSE),
    "x, y, and coord_type are required"
  )
})

