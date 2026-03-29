# =============================================================================
# Tests for R-reference spherical (haversine) distance functions
# =============================================================================

test_that("haversine: known distance London to Paris", {
  # London: (-0.1278, 51.5074), Paris: (2.3522, 48.8566)
  # Expected ~340 km (approx)
  d <- TRACLUS:::.r_haversine(c(-0.1278, 51.5074), c(2.3522, 48.8566))
  expect_gt(d, 330000)
  expect_lt(d, 350000)
})

test_that("haversine: same point gives 0", {
  d <- TRACLUS:::.r_haversine(c(10, 50), c(10, 50))
  expect_equal(d, 0.0)
})

test_that("haversine: symmetry", {
  d1 <- TRACLUS:::.r_haversine(c(-0.1278, 51.5074), c(2.3522, 48.8566))
  d2 <- TRACLUS:::.r_haversine(c(2.3522, 48.8566), c(-0.1278, 51.5074))
  expect_equal(d1, d2)
})

test_that("haversine: equatorial distance is consistent", {
  # 1 degree of longitude at equator ~ 111.32 km
  d <- TRACLUS:::.r_haversine(c(0, 0), c(1, 0))
  expect_equal(d, 111320, tolerance = 100)
})

test_that("bearing: north is 0 degrees", {
  b <- TRACLUS:::.r_bearing(c(0, 0), c(0, 10))
  expect_equal(b, 0.0, tolerance = 0.01)
})

test_that("bearing: east is 90 degrees", {
  b <- TRACLUS:::.r_bearing(c(0, 0), c(10, 0))
  expect_equal(b, 90.0, tolerance = 0.5)
})

test_that("bearing: south is 180 degrees", {
  b <- TRACLUS:::.r_bearing(c(0, 10), c(0, 0))
  expect_equal(b, 180.0, tolerance = 0.01)
})

test_that("bearing: west is 270 degrees", {
  b <- TRACLUS:::.r_bearing(c(10, 0), c(0, 0))
  expect_equal(b, 270.0, tolerance = 0.5)
})

test_that("cross-track: point on the great circle gives 0", {
  # Point exactly on the equator between 0 and 10 degrees lon
  d <- TRACLUS:::.r_cross_track(c(5, 0), c(0, 0), c(10, 0))
  expect_equal(d, 0.0, tolerance = 1)
})

test_that("cross-track: point offset 1 degree lat from equator", {
  # Great circle: equator from 0 to 10 degrees lon

  # Point at (5, 1): ~ 111 km north
  d <- TRACLUS:::.r_cross_track(c(5, 1), c(0, 0), c(10, 0))
  expect_equal(d, 111320, tolerance = 500)
})

test_that("cross-track: always returns absolute value", {
  # Point south of the equator
  d_north <- TRACLUS:::.r_cross_track(c(5, 1), c(0, 0), c(10, 0))
  d_south <- TRACLUS:::.r_cross_track(c(5, -1), c(0, 0), c(10, 0))
  expect_gt(d_north, 0)
  expect_gt(d_south, 0)
  expect_equal(d_north, d_south, tolerance = 1)
})

test_that("along-track signed: projection within segment is positive", {
  # Great circle: equator from (0,0) to (10,0)
  # Point at (5,1): projection should be around (5,0), which is at ~556 km along
  d <- TRACLUS:::.r_along_track_signed(c(5, 1), c(0, 0), c(10, 0))
  expect_gt(d, 0)
  seg_len <- TRACLUS:::.r_haversine(c(0, 0), c(10, 0))
  expect_lt(d, seg_len)
})

test_that("along-track signed: projection behind start is negative", {
  # Point at (-5, 0): behind start of (0,0)-(10,0)
  d <- TRACLUS:::.r_along_track_signed(c(-5, 0), c(0, 0), c(10, 0))
  expect_lt(d, 0)
})

test_that("spherical perpendicular: parallel equatorial segments", {
  # Two parallel segments near equator offset by 1 degree latitude
  # Should give approximately 111 km perpendicular distance
  d <- tc_dist_perpendicular(c(0, 0), c(5, 0), c(0, 1), c(5, 1),
                             method = "haversine")
  expect_equal(d, 111320, tolerance = 500)
})

test_that("spherical perpendicular: identical segments give 0", {
  d <- tc_dist_perpendicular(c(0, 0), c(5, 0), c(0, 0), c(5, 0),
                             method = "haversine")
  expect_equal(d, 0.0, tolerance = 1)
})

test_that("spherical perpendicular: swap gives same result", {
  segs <- generate_geo_test_segments()$london_paris
  d1 <- tc_dist_perpendicular(segs$si, segs$ei, segs$sj, segs$ej,
                              method = "haversine")
  d2 <- tc_dist_perpendicular(segs$sj, segs$ej, segs$si, segs$ei,
                              method = "haversine")
  expect_equal(d1, d2, tolerance = 1)
})

test_that("spherical parallel: aligned segments give 0", {
  d <- tc_dist_parallel(c(0, 0), c(5, 0), c(0, 1), c(5, 1),
                        method = "haversine")
  # Both projections coincide with endpoints of Li approximately
  expect_lt(d, 5000)
})

test_that("spherical parallel: swap gives same result", {
  segs <- generate_geo_test_segments()$london_paris
  d1 <- tc_dist_parallel(segs$si, segs$ei, segs$sj, segs$ej,
                         method = "haversine")
  d2 <- tc_dist_parallel(segs$sj, segs$ej, segs$si, segs$ei,
                         method = "haversine")
  expect_equal(d1, d2, tolerance = 1)
})

test_that("spherical angle: nearly parallel segments give small angle distance", {
  d <- tc_dist_angle(c(0, 0), c(5, 0), c(0, 1), c(5, 1),
                     method = "haversine")
  # Both segments head roughly east; bearing difference is small but non-zero

  # because bearings converge towards poles (meridian convergence)
  len_j <- TRACLUS:::.r_haversine(c(0, 1), c(5, 1))
  expect_lt(d, len_j * 0.01)
})

test_that("spherical angle: orthogonal segments give len(Lj)", {
  # Li heading east, Lj heading north
  # Li: (0,0) to (5,0) — heading east (bearing ~90)
  # Lj: (2,0) to (2,3) — heading north (bearing ~0)
  d <- tc_dist_angle(c(0, 0), c(5, 0), c(2, 0), c(2, 3),
                     method = "haversine")
  len_j <- TRACLUS:::.r_haversine(c(2, 0), c(2, 3))
  expect_equal(d, len_j, tolerance = 100)
})

test_that("spherical angle: swap gives same result", {
  segs <- generate_geo_test_segments()$london_paris
  d1 <- tc_dist_angle(segs$si, segs$ei, segs$sj, segs$ej,
                      method = "haversine")
  d2 <- tc_dist_angle(segs$sj, segs$ej, segs$si, segs$ei,
                      method = "haversine")
  expect_equal(d1, d2, tolerance = 1)
})

test_that("spherical total distance: sum of weighted components", {
  segs <- generate_geo_test_segments()$london_paris
  d_total <- tc_dist_segments(segs$si, segs$ei, segs$sj, segs$ej,
                              method = "haversine")
  d_p <- tc_dist_perpendicular(segs$si, segs$ei, segs$sj, segs$ej,
                               method = "haversine")
  d_l <- tc_dist_parallel(segs$si, segs$ei, segs$sj, segs$ej,
                          method = "haversine")
  d_a <- tc_dist_angle(segs$si, segs$ei, segs$sj, segs$ej,
                       method = "haversine")
  expect_equal(d_total, d_p + d_l + d_a, tolerance = 1)
})

test_that("all spherical components are non-negative", {
  segs_list <- generate_geo_test_segments()
  for (name in names(segs_list)) {
    s <- segs_list[[name]]
    expect_gte(tc_dist_perpendicular(s$si, s$ei, s$sj, s$ej,
                                     method = "haversine"), 0,
               label = paste("perp:", name))
    expect_gte(tc_dist_parallel(s$si, s$ei, s$sj, s$ej,
                                method = "haversine"), 0,
               label = paste("par:", name))
    expect_gte(tc_dist_angle(s$si, s$ei, s$sj, s$ej,
                             method = "haversine"), 0,
               label = paste("angle:", name))
  }
})

test_that("spherical distance symmetry for all test segments", {
  segs_list <- generate_geo_test_segments()
  for (name in names(segs_list)) {
    s <- segs_list[[name]]
    expect_equal(
      tc_dist_segments(s$si, s$ei, s$sj, s$ej, method = "haversine"),
      tc_dist_segments(s$sj, s$ej, s$si, s$ei, method = "haversine"),
      tolerance = 1,
      label = paste("symmetry:", name)
    )
  }
})

test_that("bearing normalisation: result is always in [0, 360)", {
  # Various directions
  expect_gte(TRACLUS:::.r_bearing(c(0, 0), c(1, 1)), 0)
  expect_lt(TRACLUS:::.r_bearing(c(0, 0), c(1, 1)), 360)
  expect_gte(TRACLUS:::.r_bearing(c(0, 0), c(-1, -1)), 0)
  expect_lt(TRACLUS:::.r_bearing(c(0, 0), c(-1, -1)), 360)
})

# --- Golden-Value Tests ---
# Hand-computed expected values using Haversine, Cross-Track, Along-Track,
# and Bearing formulas (R = 6371000 m). All derivations shown step-by-step.

test_that("golden: Pair C (mid-latitude NE) — all three components", {
  # Li = (-74.0, 40.0) -> (-73.0, 40.5)   ~101.5 km, bearing ~56.4° (NE)
  # Lj = (-73.8, 40.1) -> (-73.5, 40.3)   ~33.8 km, bearing ~48.8° (NE)
  # Li is longer (101456 > 33819) => no swap.
  #
  # R = 6371000 m throughout.
  #
  # --- d_perp (spherical Definition 1) ---
  # l1 = |cross-track| of sj=(-73.8, 40.1) to great circle through Li
  #     Using formula: sin_xt = sin(d_AP/R) * sin(bearing_AP - bearing_AB)
  #     l1 = 118.99 m  (sj is very close to Li's great circle)
  # l2 = |cross-track| of ej=(-73.5, 40.3) to great circle through Li
  #     l2 = 4464.68 m  (ej is further from Li's great circle)
  # Lehmer mean: (118.99^2 + 4464.68^2) / (118.99 + 4464.68)
  #            = (14158.6 + 19933370.6) / 4583.67
  #            = 19947529.2 / 4583.67 = 4351.87 m
  expect_equal(
    tc_dist_perpendicular(c(-74, 40), c(-73, 40.5), c(-73.8, 40.1), c(-73.5, 40.3),
                          method = "haversine"),
    4351.87, tolerance = 0.5
  )

  # --- d_par (spherical Definition 2) ---
  # Along-track signed distance of sj from Li start: at_sj = 20333.0 m
  #   (projection falls within Li, at ~20% along)
  # Along-track signed distance of ej from Li start: at_ej = 53840.4 m
  #   (projection falls within Li, at ~53%)
  # Li length = 101456.2 m
  # l_par1 = min(|20333.0|, |20333.0 - 101456.2|) = min(20333, 81123) = 20333.0
  # l_par2 = min(|53840.4|, |53840.4 - 101456.2|) = min(53840, 47616) = 47615.9
  # d_par = min(20333.0, 47615.9) = 20333.0 m
  expect_equal(
    tc_dist_parallel(c(-74, 40), c(-73, 40.5), c(-73.8, 40.1), c(-73.5, 40.3),
                     method = "haversine"),
    20333.0, tolerance = 0.5
  )

  # --- d_angle (spherical Definition 3) ---
  # Bearing Li = 56.449°, Bearing Lj = 48.788°
  # Bearing difference = |56.449 - 48.788| = 7.661° (< 90°)
  # d_angle = len_Lj * sin(7.661°) = 33819.4 * sin(7.661°)
  #         = 33819.4 * 0.13336 = 4508.4 m
  expect_equal(
    tc_dist_angle(c(-74, 40), c(-73, 40.5), c(-73.8, 40.1), c(-73.5, 40.3),
                  method = "haversine"),
    4508.4, tolerance = 0.5
  )
})

test_that("golden: Pair D (equatorial, perpendicular) — all three components", {
  # Li = (0, 0) -> (1, 0)     along equator, ~111195 m, bearing = 90° (east)
  # Lj = (0.5, 0.5) -> (0.5, 1.0)  along meridian, ~55597 m, bearing = 0° (north)
  # Li is longer => no swap.
  #
  # --- d_perp ---
  # The great circle through Li IS the equator.
  # Cross-track to equator = R * |latitude_in_radians|.
  # l1 = |xt(sj)| = R * 0.5° * pi/180 = 6371000 * pi/360 = 55597.46 m
  # l2 = |xt(ej)| = R * 1.0° * pi/180 = 6371000 * pi/180 = 111194.93 m
  # l2 = 2 * l1 exactly.
  # Lehmer mean: (l1^2 + (2*l1)^2) / (l1 + 2*l1) = 5*l1^2 / (3*l1) = 5*l1/3
  # d_perp = 5/3 * 55597.46 = 92662.44 m
  expect_equal(
    tc_dist_perpendicular(c(0, 0), c(1, 0), c(0.5, 0.5), c(0.5, 1.0),
                          method = "haversine"),
    92662.44, tolerance = 0.5
  )

  # --- d_par ---
  # Both sj and ej are at longitude 0.5°. Their projections on the equator
  # both land at (0.5, 0), which is the midpoint of Li.
  # Along-track = R * 0.5° * pi/180 = 55597.46 m (half of Li).
  # l_par1 = min(55597.46, |55597.46 - 111194.93|) = min(55597.46, 55597.46) = 55597.46
  # l_par2 = same = 55597.46
  # d_par = 55597.46 m
  expect_equal(
    tc_dist_parallel(c(0, 0), c(1, 0), c(0.5, 0.5), c(0.5, 1.0),
                     method = "haversine"),
    55597.46, tolerance = 0.5
  )

  # --- d_angle ---
  # Bearing Li = 90° (east), Bearing Lj = 0° (north)
  # Bearing difference = 90°   =>  d_angle = |Lj| = 55597.46 m
  expect_equal(
    tc_dist_angle(c(0, 0), c(1, 0), c(0.5, 0.5), c(0.5, 1.0),
                  method = "haversine"),
    55597.46, tolerance = 0.5
  )
})

test_that("golden: weighted total distances and symmetry (spherical)", {
  # Pair C: d_perp=4351.87, d_par=20333.0, d_angle=4508.4
  # Total (1,1,1) = 29193.3 m
  expect_equal(
    tc_dist_segments(c(-74, 40), c(-73, 40.5), c(-73.8, 40.1), c(-73.5, 40.3),
                     method = "haversine"),
    29193.3, tolerance = 0.5
  )

  # Pair D: d_perp=92662.44, d_par=55597.46, d_angle=55597.46
  # Total (1,1,1) = 203857.4 m
  expect_equal(
    tc_dist_segments(c(0, 0), c(1, 0), c(0.5, 0.5), c(0.5, 1.0),
                     method = "haversine"),
    203857.4, tolerance = 0.5
  )

  # R = 6371000 is used correctly (sanity check: 1° at equator)
  expect_equal(
    TRACLUS:::.r_haversine(c(0, 0), c(0, 1)),
    6371000 * pi / 180,
    tolerance = 0.01
  )

  # Symmetry: dist(Li,Lj) == dist(Lj,Li)
  expect_equal(
    tc_dist_segments(c(-74, 40), c(-73, 40.5), c(-73.8, 40.1), c(-73.5, 40.3),
                     method = "haversine"),
    tc_dist_segments(c(-73.8, 40.1), c(-73.5, 40.3), c(-74, 40), c(-73, 40.5),
                     method = "haversine"),
    tolerance = 0.5
  )
  expect_equal(
    tc_dist_segments(c(0, 0), c(1, 0), c(0.5, 0.5), c(0.5, 1.0),
                     method = "haversine"),
    tc_dist_segments(c(0.5, 0.5), c(0.5, 1.0), c(0, 0), c(1, 0),
                     method = "haversine"),
    tolerance = 0.5
  )
})
