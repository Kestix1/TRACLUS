# --- Unit tests for internal helper functions ---
# Covers: .check_antimeridian(), .validate_dist_inputs(), .truncate_ids()
# Trivial helpers (.merge_plot_args, .group_by_traj_id, .check_class) are
# sufficiently covered by the main function tests.

# --- .check_antimeridian() -------------------------------------------------

test_that(".check_antimeridian: no crossing — no warning", {
  df <- data.frame(
    traj_id = c("A", "A", "A"),
    x = c(10, 20, 30),
    y = c(0, 0, 0)
  )
  expect_no_warning(TRACLUS:::.check_antimeridian(df))
})

test_that(".check_antimeridian: simple crossing within one trajectory — warning", {
  df <- data.frame(
    traj_id = c("A", "A"),
    x = c(179, -179),   # abs diff = 358 > 180
    y = c(0, 0)
  )
  expect_warning(
    TRACLUS:::.check_antimeridian(df),
    "antimeridian"
  )
})

test_that(".check_antimeridian: crossing spans two different trajectories — no warning", {
  # The large lon gap is between the last point of A and the first point of B,
  # so same_traj is FALSE at that index — no warning expected.
  df <- data.frame(
    traj_id = c("A", "B"),
    x = c(179, -179),
    y = c(0, 0)
  )
  expect_no_warning(TRACLUS:::.check_antimeridian(df))
})

test_that(".check_antimeridian: multiple trajectories, only one crosses — warns with correct ID", {
  df <- data.frame(
    traj_id = c("OK", "OK", "CROSS", "CROSS"),
    x = c(10, 20, 179, -179),
    y = c(0, 0, 0, 0)
  )
  expect_warning(
    TRACLUS:::.check_antimeridian(df),
    "CROSS"
  )
})

test_that(".check_antimeridian: single-row data.frame — no warning", {
  df <- data.frame(traj_id = "A", x = 10, y = 0)
  expect_no_warning(TRACLUS:::.check_antimeridian(df))
})

# --- .validate_dist_inputs() -----------------------------------------------

test_that(".validate_dist_inputs: valid inputs — no error", {
  expect_no_error(
    TRACLUS:::.validate_dist_inputs(
      si = c(0, 0), ei = c(1, 0),
      sj = c(0, 1), ej = c(1, 1),
      method = "euclidean"
    )
  )
})

test_that(".validate_dist_inputs: Inf in ej — error", {
  expect_error(
    TRACLUS:::.validate_dist_inputs(
      si = c(0, 0), ei = c(1, 0),
      sj = c(0, 1), ej = c(Inf, 1),
      method = "euclidean"
    ),
    "finite"
  )
})

test_that(".validate_dist_inputs: non-numeric sj — error", {
  expect_error(
    TRACLUS:::.validate_dist_inputs(
      si = c(0, 0), ei = c(1, 0),
      sj = c("a", "b"), ej = c(1, 1),
      method = "euclidean"
    ),
    "sj"
  )
})

# --- .truncate_ids() -------------------------------------------------------

test_that(".truncate_ids: few IDs — no truncation", {
  result <- TRACLUS:::.truncate_ids(c("A", "B", "C"), max_show = 5)
  expect_equal(result, "A, B, C")
})

test_that(".truncate_ids: exactly max_show IDs — no truncation", {
  result <- TRACLUS:::.truncate_ids(c("A", "B", "C", "D", "E"), max_show = 5)
  expect_equal(result, "A, B, C, D, E")
})

test_that(".truncate_ids: more IDs than max_show — truncates", {
  result <- TRACLUS:::.truncate_ids(c("A", "B", "C", "D", "E", "F"), max_show = 5)
  expect_match(result, "and 1 more")
  expect_match(result, "^A, B, C, D, E")
})

test_that(".truncate_ids: many IDs — shows correct count", {
  ids <- paste0("T", 1:20)
  result <- TRACLUS:::.truncate_ids(ids, max_show = 5)
  expect_match(result, "and 15 more")
  expect_match(result, "^T1, T2, T3, T4, T5")
})

test_that(".truncate_ids: single ID — returned as-is", {
  result <- TRACLUS:::.truncate_ids("ONLY_ONE", max_show = 5)
  expect_equal(result, "ONLY_ONE")
})
