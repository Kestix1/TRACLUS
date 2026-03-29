# =============================================================================
# Test data generators for TRACLUS unit tests
#
# All generators return deterministic data suitable for testing.
# Each test file should use these generators to avoid duplicating
# test data definitions.
# =============================================================================

#' Generate simple euclidean toy trajectories
#'
#' Creates a data.frame with 6 trajectories in local km coordinates.
#' TR1-TR5 are roughly horizontal (7 points each), TR6 is a near-vertical
#' outlier (5 points). Suitable for testing basic TRACLUS workflow.
#'
#' @return data.frame with columns traj_id, x, y
generate_toy_trajectories <- function() {
  data.frame(
    traj_id = c(rep("TR1", 7), rep("TR2", 7), rep("TR3", 7),
                rep("TR4", 7), rep("TR5", 7), rep("TR6", 5)),
    x = c(
       0, 10, 20, 30, 40, 50, 60,    # TR1
       5, 15, 25, 35, 45, 52, 55,    # TR2
      10, 20, 30, 40, 50, 60, 70,    # TR3
       8, 18, 28, 38, 48, 50, 52,    # TR4
       0, 10, 20, 30, 40, 55, 70,    # TR5
      35, 35, 36, 37, 38             # TR6
    ),
    y = c(
       0,  2,  4,  4,  4,  8, 15,    # TR1
      -5,  1,  3,  5,  5, 12, 20,    # TR2
       0,  3,  4,  5,  4,  0, -5,    # TR3
       2,  4,  5,  6,  6, 15, 25,    # TR4
      12,  8,  5,  4,  4,  2, -2,    # TR5
      35, 25, 15,  5, -5             # TR6
    )
  )
}

#' Generate geographic test trajectories (Atlantic hurricanes-like)
#'
#' Creates a data.frame with 3 trajectories using realistic lon/lat
#' coordinates in the North Atlantic.
#'
#' @return data.frame with columns storm_id, lon, lat
generate_geo_trajectories <- function() {
  data.frame(
    storm_id = rep(c("STORM_A", "STORM_B", "STORM_C"), each = 5),
    lon = c(
      -80, -78, -76, -74, -72,           # A: west to east
      -82, -79, -76, -73, -70,           # B: similar path, slightly south
      -60, -58, -56, -54, -52            # C: further east
    ),
    lat = c(
      25, 26, 27, 28, 29,
      24, 25, 26, 27, 28,
      30, 31, 32, 33, 34
    )
  )
}

#' Generate edge-case test data: two-point trajectories
#'
#' @return data.frame with 2 trajectories of exactly 2 points each
generate_two_point_trajectories <- function() {
  data.frame(
    traj_id = rep(c("A", "B"), each = 2),
    x = c(0, 10, 0, 10),
    y = c(0, 0, 5, 5)
  )
}

#' Generate test segments for distance calculations
#'
#' Returns a named list of segment endpoint pairs for testing distance
#' functions. Each element is a list with si, ei, sj, ej.
#'
#' @return Named list of segment configurations
generate_test_segments <- function() {
  list(
    # Parallel horizontal segments offset vertically
    parallel_horizontal = list(
      si = c(0, 0), ei = c(10, 0),
      sj = c(0, 5), ej = c(10, 5)
    ),
    # Perpendicular segments
    perpendicular = list(
      si = c(0, 0), ei = c(10, 0),
      sj = c(5, -3), ej = c(5, 3)
    ),
    # Identical segments
    identical = list(
      si = c(0, 0), ei = c(10, 0),
      sj = c(0, 0), ej = c(10, 0)
    ),
    # Short segment near long segment (swap test)
    swap_needed = list(
      si = c(0, 0), ei = c(2, 0),    # short segment
      sj = c(0, 1), ej = c(10, 1)    # long segment — should become Li after swap
    ),
    # Overlapping collinear segments
    collinear_overlap = list(
      si = c(0, 0), ei = c(10, 0),
      sj = c(3, 0), ej = c(7, 0)
    ),
    # Non-overlapping collinear segments
    collinear_gap = list(
      si = c(0, 0), ei = c(5, 0),
      sj = c(8, 0), ej = c(12, 0)
    ),
    # Opposite direction (180 degrees)
    opposite = list(
      si = c(0, 0), ei = c(10, 0),
      sj = c(10, 2), ej = c(0, 2)
    ),
    # 45-degree angle
    angled_45 = list(
      si = c(0, 0), ei = c(10, 0),
      sj = c(0, 0), ej = c(5, 5)
    ),
    # Zero-length segment (degenerate)
    zero_length = list(
      si = c(0, 0), ei = c(10, 0),
      sj = c(5, 3), ej = c(5, 3)
    )
  )
}

#' Generate geographic test segments for spherical distance calculations
#'
#' @return Named list of segment configurations with lon/lat coordinates
generate_geo_test_segments <- function() {
  list(
    # Two segments near London-Paris
    london_paris = list(
      si = c(-0.1278, 51.5074),  # London
      ei = c(2.3522, 48.8566),   # Paris
      sj = c(0.5, 50.5),         # Near English Channel
      ej = c(3.0, 49.5)          # Near Belgian coast
    ),
    # Parallel segments near equator
    equatorial = list(
      si = c(0, 0), ei = c(5, 0),
      sj = c(0, 1), ej = c(5, 1)
    ),
    # Segments at different latitudes (meridian convergence test)
    high_lat = list(
      si = c(0, 60), ei = c(10, 60),
      sj = c(0, 61), ej = c(10, 61)
    ),
    # Nearly identical geographic segments
    nearly_identical = list(
      si = c(-74.006, 40.7128),  # New York
      ei = c(-73.935, 40.730),
      sj = c(-74.005, 40.7130),
      ej = c(-73.936, 40.731)
    )
  )
}
