# =============================================================================
# Tests for tc_read_hurdat2 (HURDAT2 parser)
# =============================================================================

get_hurdat2_path <- function() {
  system.file("extdata", "hurdat2_1950_2004.txt", package = "TRACLUS")
}

# =============================================================================
# Basic functionality
# =============================================================================

test_that("tc_read_hurdat2 reads bundled file", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  result <- suppressMessages(tc_read_hurdat2(filepath))

  expect_s3_class(result, "data.frame")
  expect_equal(names(result), c("storm_id", "lat", "lon"))
  expect_true(nrow(result) > 0)
})

test_that("bundled file contains expected number of storms", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  result <- suppressMessages(tc_read_hurdat2(filepath, min_points = 1))
  n_storms <- length(unique(result$storm_id))

  # Real HURDAT2 1950-2004: 826 storms, ~22k points
  expect_gt(n_storms, 800)
  expect_lt(n_storms, 900)
  expect_gt(nrow(result), 20000)
})

test_that("storm_ids follow expected pattern", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  result <- suppressMessages(tc_read_hurdat2(filepath))

  # All IDs should match basin pattern (e.g., AL012000)
  expect_true(all(grepl("^[A-Z]{2}[0-9]", result$storm_id)))
})

test_that("longitudes are mostly negative (West Atlantic)", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  result <- suppressMessages(tc_read_hurdat2(filepath))

  # Vast majority of Atlantic storm points have West (negative) longitudes
  # A few storms cross into the East Atlantic (positive longitudes)
  pct_west <- mean(result$lon < 0)
  expect_gt(pct_west, 0.95)
})

test_that("latitudes are in valid range", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  result <- suppressMessages(tc_read_hurdat2(filepath))

  expect_true(all(result$lat >= -90 & result$lat <= 90))
  expect_true(all(result$lon >= -180 & result$lon <= 180))
})

test_that("result is compatible with tc_trajectories", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  # Use high min_points to keep test fast
  storms <- suppressMessages(tc_read_hurdat2(filepath, min_points = 80))

  # Should work directly with tc_trajectories
  trj <- suppressMessages(
    tc_trajectories(storms, traj_id = "storm_id",
                    x = "lon", y = "lat", coord_type = "geographic")
  )
  expect_s3_class(trj, "tc_trajectories")
})

# =============================================================================
# min_points filtering
# =============================================================================

test_that("min_points filters short storms", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  result <- suppressMessages(tc_read_hurdat2(filepath, min_points = 10))
  counts <- table(result$storm_id)
  expect_true(all(counts >= 10))
})

test_that("min_points = 1 keeps all storms", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  result <- suppressMessages(tc_read_hurdat2(filepath, min_points = 1))
  # Should have more storms than with min_points = 10
  result10 <- suppressMessages(tc_read_hurdat2(filepath, min_points = 10))

  expect_gt(length(unique(result$storm_id)),
            length(unique(result10$storm_id)))
})

test_that("filtering produces message about removed storms", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  # With min_points = 3 some storms should be filtered
  expect_message(
    tc_read_hurdat2(filepath, min_points = 3),
    "Filtered"
  )
})

test_that("higher min_points yields fewer storms", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  r5  <- suppressMessages(tc_read_hurdat2(filepath, min_points = 5))
  r50 <- suppressMessages(tc_read_hurdat2(filepath, min_points = 50))

  expect_gt(length(unique(r5$storm_id)),
            length(unique(r50$storm_id)))
})

# =============================================================================
# Performance
# =============================================================================

test_that("parser reads large file in reasonable time", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  elapsed <- system.time(
    suppressMessages(tc_read_hurdat2(filepath, min_points = 1))
  )[["elapsed"]]

  # Should complete in under 10 seconds (vectorised parser)
  expect_lt(elapsed, 10)
})

# =============================================================================
# Input validation
# =============================================================================

test_that("non-existent file gives error", {
  expect_error(tc_read_hurdat2("nonexistent_file.txt"),
               "File not found")
})

test_that("invalid filepath type gives error", {
  expect_error(tc_read_hurdat2(123), "'filepath'")
})

test_that("invalid min_points gives error", {
  filepath <- get_hurdat2_path()
  skip_if(filepath == "", "HURDAT2 test file not found")

  expect_error(tc_read_hurdat2(filepath, min_points = 0), "'min_points'")
  expect_error(tc_read_hurdat2(filepath, min_points = -1), "'min_points'")
})

# =============================================================================
# Coordinate parsing
# =============================================================================

test_that(".parse_hurdat2_coord handles N/S/E/W correctly", {
  # North latitude: positive
  expect_equal(TRACLUS:::.parse_hurdat2_coord("25.0N", "NS"), 25.0)
  # South latitude: negative
  expect_equal(TRACLUS:::.parse_hurdat2_coord("10.5S", "NS"), -10.5)
  # West longitude: negative
  expect_equal(TRACLUS:::.parse_hurdat2_coord("80.0W", "EW"), -80.0)
  # East longitude: positive
  expect_equal(TRACLUS:::.parse_hurdat2_coord("150.2E", "EW"), 150.2)
})

test_that(".parse_hurdat2_coord returns NA for invalid input", {
  expect_true(is.na(TRACLUS:::.parse_hurdat2_coord("", "NS")))
  expect_true(is.na(TRACLUS:::.parse_hurdat2_coord("X", "NS")))
  expect_true(is.na(TRACLUS:::.parse_hurdat2_coord("25.0Q", "NS")))
})

test_that(".parse_hurdat2_coord_vec is consistent with scalar version", {
  strs <- c("25.0N", "10.5S", "80.0W", "150.2E", "", "25.0Q")

  scalar_ns <- sapply(strs[1:2], function(s)
    TRACLUS:::.parse_hurdat2_coord(s, "NS"))
  vec_ns <- TRACLUS:::.parse_hurdat2_coord_vec(strs[1:2], "NS")
  expect_equal(unname(scalar_ns), vec_ns)

  scalar_ew <- sapply(strs[3:4], function(s)
    TRACLUS:::.parse_hurdat2_coord(s, "EW"))
  vec_ew <- TRACLUS:::.parse_hurdat2_coord_vec(strs[3:4], "EW")
  expect_equal(unname(scalar_ew), vec_ew)
})
