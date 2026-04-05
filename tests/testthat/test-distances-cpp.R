# =============================================================================
# Tests for R vs C++ consistency of distance functions
# Tolerance of 1e-10 accounts for floating-point differences between
# R and compiled C++ code.
# =============================================================================

# --- Euclidean: R vs C++ ---

test_that("C++ d_perp_euc matches R reference", {
  segs <- generate_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- tc_dist_perpendicular(s$si, s$ei, s$sj, s$ej, method = "euclidean")
    cpp_val <- TRACLUS:::.cpp_d_perp_euc(s$si[1], s$si[2], s$ei[1], s$ei[2],
                               s$sj[1], s$sj[2], s$ej[1], s$ej[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("d_perp_euc:", name))
  }
})

test_that("C++ d_par_euc matches R reference", {
  segs <- generate_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- tc_dist_parallel(s$si, s$ei, s$sj, s$ej, method = "euclidean")
    cpp_val <- TRACLUS:::.cpp_d_par_euc(s$si[1], s$si[2], s$ei[1], s$ei[2],
                              s$sj[1], s$sj[2], s$ej[1], s$ej[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("d_par_euc:", name))
  }
})

test_that("C++ d_angle_euc matches R reference", {
  segs <- generate_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- tc_dist_angle(s$si, s$ei, s$sj, s$ej, method = "euclidean")
    cpp_val <- TRACLUS:::.cpp_d_angle_euc(s$si[1], s$si[2], s$ei[1], s$ei[2],
                                s$sj[1], s$sj[2], s$ej[1], s$ej[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("d_angle_euc:", name))
  }
})

test_that("C++ traclus_dist_euc matches R reference (no early termination)", {
  segs <- generate_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- tc_dist_segments(s$si, s$ei, s$sj, s$ej, method = "euclidean")
    # Use very large eps to prevent early termination
    cpp_val <- TRACLUS:::.cpp_traclus_dist_euc(s$si[1], s$si[2], s$ei[1], s$ei[2],
                                     s$sj[1], s$sj[2], s$ej[1], s$ej[2],
                                     1.0, 1.0, 1.0, 1e30)
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("traclus_dist_euc:", name))
  }
})

test_that("C++ early termination returns value >= actual distance", {
  # With a very small eps, early termination should still return a value
  # that is >= the partial accumulated distance
  s <- generate_test_segments()$parallel_horizontal
  d_full <- TRACLUS:::.cpp_traclus_dist_euc(s$si[1], s$si[2], s$ei[1], s$ei[2],
                                  s$sj[1], s$sj[2], s$ej[1], s$ej[2],
                                  1.0, 1.0, 1.0, 1e30)
  # With eps = 1 (smaller than the full distance of 5)
  d_early <- TRACLUS:::.cpp_traclus_dist_euc(s$si[1], s$si[2], s$ei[1], s$ei[2],
                                   s$sj[1], s$sj[2], s$ej[1], s$ej[2],
                                   1.0, 1.0, 1.0, 1.0)
  # Early termination result should be > eps (since it exceeded eps)
  expect_gt(d_early, 1.0)
  # But may be less than full distance due to skipped components
  expect_lte(d_early, d_full + 1e-10)
})

# --- Spherical: R vs C++ ---

test_that("C++ haversine_dist matches R reference", {
  segs <- generate_geo_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- TRACLUS:::.r_haversine(s$si, s$ei)
    cpp_val <- TRACLUS:::.cpp_haversine_dist(s$si[1], s$si[2], s$ei[1], s$ei[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("haversine:", name))
  }
})

test_that("C++ initial_bearing matches R reference", {
  segs <- generate_geo_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- TRACLUS:::.r_bearing(s$si, s$ei)
    cpp_val <- TRACLUS:::.cpp_initial_bearing(s$si[1], s$si[2], s$ei[1], s$ei[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("bearing:", name))
  }
})

test_that("C++ cross_track_dist matches R reference", {
  segs <- generate_geo_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    # Use sj as the point, si-ei as the great circle
    r_val <- TRACLUS:::.r_cross_track(s$sj, s$si, s$ei)
    cpp_val <- TRACLUS:::.cpp_cross_track_dist(s$sj[1], s$sj[2],
                                     s$si[1], s$si[2], s$ei[1], s$ei[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("cross_track:", name))
  }
})

test_that("C++ along_track_signed matches R reference", {
  segs <- generate_geo_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- TRACLUS:::.r_along_track_signed(s$sj, s$si, s$ei)
    cpp_val <- TRACLUS:::.cpp_along_track_signed(s$sj[1], s$sj[2],
                                       s$si[1], s$si[2], s$ei[1], s$ei[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("along_track:", name))
  }
})

test_that("C++ d_perp_sph matches R reference", {
  segs <- generate_geo_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- tc_dist_perpendicular(s$si, s$ei, s$sj, s$ej, method = "haversine")
    cpp_val <- TRACLUS:::.cpp_d_perp_sph(s$si[1], s$si[2], s$ei[1], s$ei[2],
                               s$sj[1], s$sj[2], s$ej[1], s$ej[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("d_perp_sph:", name))
  }
})

test_that("C++ d_par_sph matches R reference", {
  segs <- generate_geo_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- tc_dist_parallel(s$si, s$ei, s$sj, s$ej, method = "haversine")
    cpp_val <- TRACLUS:::.cpp_d_par_sph(s$si[1], s$si[2], s$ei[1], s$ei[2],
                              s$sj[1], s$sj[2], s$ej[1], s$ej[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("d_par_sph:", name))
  }
})

test_that("C++ d_angle_sph matches R reference", {
  segs <- generate_geo_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- tc_dist_angle(s$si, s$ei, s$sj, s$ej, method = "haversine")
    cpp_val <- TRACLUS:::.cpp_d_angle_sph(s$si[1], s$si[2], s$ei[1], s$ei[2],
                                s$sj[1], s$sj[2], s$ej[1], s$ej[2])
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("d_angle_sph:", name))
  }
})

test_that("C++ traclus_dist_sph matches R reference (no early termination)", {
  segs <- generate_geo_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    r_val <- tc_dist_segments(s$si, s$ei, s$sj, s$ej, method = "haversine")
    cpp_val <- TRACLUS:::.cpp_traclus_dist_sph(s$si[1], s$si[2], s$ei[1], s$ei[2],
                                     s$sj[1], s$sj[2], s$ej[1], s$ej[2],
                                     1.0, 1.0, 1.0, 1e30)
    expect_equal(cpp_val, r_val, tolerance = 1e-10,
                 label = paste("traclus_dist_sph:", name))
  }
})

# =============================================================================
# New tests: CRITICAL + HIGH gaps (Session 1)
# =============================================================================

test_that("C07 / C-4: early termination fires after d_perp alone exceeds eps", {
  # Li=(0,0)-(10,0), Lj=(5,3)-(5,7): d_perp=5.8, d_par=5, d_angle=4
  # With eps=1: w_perp*d_perp = 5.8 > 1 → terminate after perp, return 5.8
  si <- c(0, 0); ei <- c(10, 0); sj <- c(5, 3); ej <- c(5, 7)
  d_perp_only <- TRACLUS:::.cpp_traclus_dist_euc(
    si[1], si[2], ei[1], ei[2], sj[1], sj[2], ej[1], ej[2],
    1.0, 1.0, 1.0, 1.0
  )
  expected_perp <- tc_dist_perpendicular(si, ei, sj, ej)
  # After early termination, returns exactly d_perp (first accumulated component)
  expect_equal(d_perp_only, expected_perp, tolerance = 1e-10)
})

test_that("C08 / C-4: early termination fires after d_perp + d_par exceeds eps", {
  # Li=(0,0)-(10,0), Lj=(5,3)-(5,7): d_perp=5.8, d_par=5, d_angle=4
  # eps=8: d_perp=5.8 <= 8, then d_perp+d_par=10.8 > 8 → terminate after par
  si <- c(0, 0); ei <- c(10, 0); sj <- c(5, 3); ej <- c(5, 7)
  eps_val <- 8.0  # d_perp (5.8) passes, d_perp+d_par (10.8) triggers

  d_after_par <- TRACLUS:::.cpp_traclus_dist_euc(
    si[1], si[2], ei[1], ei[2], sj[1], sj[2], ej[1], ej[2],
    1.0, 1.0, 1.0, eps_val
  )
  expected_perp_par <- tc_dist_perpendicular(si, ei, sj, ej) +
    tc_dist_parallel(si, ei, sj, ej)
  # Returns d_perp + d_par (not the full distance including d_angle)
  expect_equal(d_after_par, expected_perp_par, tolerance = 1e-10)

  # Verify this is less than the full distance (d_angle would add more)
  d_full <- tc_dist_segments(si, ei, sj, ej)
  expect_lt(d_after_par, d_full)
})

test_that("C10 / H-6: w_perp=0 skips perp component entirely", {
  # Perp is skipped → no early termination from it
  # With eps=1 and w_perp=0, w_par=1: only par (d_par=5) triggers early term
  si <- c(0, 0); ei <- c(10, 0); sj <- c(5, 3); ej <- c(5, 7)
  d_no_perp <- TRACLUS:::.cpp_traclus_dist_euc(
    si[1], si[2], ei[1], ei[2], sj[1], sj[2], ej[1], ej[2],
    0.0, 1.0, 1.0, 1.0
  )
  # Perp skipped; par (5) > eps (1) → returns d_par
  expect_equal(d_no_perp, tc_dist_parallel(si, ei, sj, ej), tolerance = 1e-10)
})

test_that("C11 / H-6: w_par=0 skips par component entirely", {
  # Par is skipped; perp (5.8) > eps (1) → early term after perp
  si <- c(0, 0); ei <- c(10, 0); sj <- c(5, 3); ej <- c(5, 7)
  d_no_par <- TRACLUS:::.cpp_traclus_dist_euc(
    si[1], si[2], ei[1], ei[2], sj[1], sj[2], ej[1], ej[2],
    1.0, 0.0, 1.0, 1.0
  )
  expect_equal(d_no_par, tc_dist_perpendicular(si, ei, sj, ej), tolerance = 1e-10)
})

test_that("C12 / H-6: w_angle=0 skips angle component entirely", {
  # Angle skipped → full result = d_perp + d_par only
  si <- c(0, 0); ei <- c(10, 0); sj <- c(5, 3); ej <- c(5, 7)
  d_no_angle <- TRACLUS:::.cpp_traclus_dist_euc(
    si[1], si[2], ei[1], ei[2], sj[1], sj[2], ej[1], ej[2],
    1.0, 1.0, 0.0, 1e30
  )
  expect_equal(d_no_angle,
               tc_dist_perpendicular(si, ei, sj, ej) + tc_dist_parallel(si, ei, sj, ej),
               tolerance = 1e-10)

  # And verify it differs from the full distance (which includes d_angle)
  d_full <- tc_dist_segments(si, ei, sj, ej)
  expect_lt(d_no_angle, d_full)
})

test_that("C++ euclidean: tie-break at equal segment length keeps first as Li", {
  # Two segments of exactly equal length — result should be identical
  # regardless of argument order, thanks to the swap convention (first stays at tie)
  si <- c(0, 0)
  ei <- c(10, 0)
  sj <- c(0, 5)
  ej <- c(10, 5)
  # Both have length exactly 10

  d1 <- TRACLUS:::.cpp_d_perp_euc(si[1], si[2], ei[1], ei[2],
                        sj[1], sj[2], ej[1], ej[2])
  d2 <- TRACLUS:::.cpp_d_perp_euc(sj[1], sj[2], ej[1], ej[2],
                        si[1], si[2], ei[1], ei[2])
  # Due to symmetry of this specific configuration, both should give 5
  expect_equal(d1, d2, tolerance = 1e-10)
  expect_equal(d1, 5.0, tolerance = 1e-10)
})
