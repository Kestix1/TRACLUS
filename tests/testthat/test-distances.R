# --- Tests for R-reference euclidean distance functions ---
# Paper Definitions 1, 2, 3 and weighted total distance

test_that("perpendicular distance: parallel horizontal segments", {
  # Two parallel horizontal segments at y=0 and y=5.
  # Both perpendicular distances l1 and l2 are 5.
  # Lehmer mean: (25 + 25) / (5 + 5) = 5
  d <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
  expect_equal(d, 5.0, tolerance = 1e-10)
})

test_that("perpendicular distance: identical segments", {
  d <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 0), c(10, 0))
  expect_equal(d, 0.0, tolerance = 1e-10)
})

test_that("perpendicular distance: collinear overlapping segments", {
  # Both endpoints of Lj are on the line through Li, so perp = 0

  d <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(3, 0), c(7, 0))
  expect_equal(d, 0.0, tolerance = 1e-10)
})

test_that("perpendicular distance: asymmetric perpendicular offsets use Lehmer mean", {
  # Li: (0,0)-(10,0), Lj: (5,2)-(5,6)
  # After swap: Li = (0,0)-(10,0) (length 10), Lj = (5,2)-(5,6) (length 4)
  # l1 = dist from (5,2) to line y=0 = 2
  # l2 = dist from (5,6) to line y=0 = 6
  # Lehmer: (4 + 36) / (2 + 6) = 40 / 8 = 5
  d <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(5, 2), c(5, 6))
  expect_equal(d, 5.0, tolerance = 1e-10)
})

test_that("perpendicular distance: swap convention is applied", {
  # Arguments reversed: (short, long) vs (long, short) should give same result
  d1 <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 5), c(5, 5))
  d2 <- tc_dist_perpendicular(c(0, 5), c(5, 5), c(0, 0), c(10, 0))
  expect_equal(d1, d2, tolerance = 1e-10)
})

test_that("perpendicular distance: zero-length segment", {
  # Lj is a point at (5, 3)
  # After swap, Li = (0,0)-(10,0), Lj = (5,3)-(5,3)
  # l1 = l2 = 3
  # Lehmer: (9+9)/(3+3) = 3
  d <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(5, 3), c(5, 3))
  expect_equal(d, 3.0, tolerance = 1e-10)
})

test_that("parallel distance: overlapping segments", {
  # Li: (0,0)-(10,0), Lj: (3,5)-(7,5)
  # Projections of sj=(3,5) and ej=(7,5) onto line y=0: (3,0) and (7,0)
  # l_par1 = min(dist(3,0, 0,0), dist(3,0, 10,0)) = min(3, 7) = 3
  # l_par2 = min(dist(7,0, 0,0), dist(7,0, 10,0)) = min(7, 3) = 3
  # d_par = min(3, 3) = 3
  d <- tc_dist_parallel(c(0, 0), c(10, 0), c(3, 5), c(7, 5))
  expect_equal(d, 3.0, tolerance = 1e-10)
})

test_that("parallel distance: exactly aligned segments", {
  # Both projected endpoints coincide with Li endpoints
  d <- tc_dist_parallel(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
  expect_equal(d, 0.0, tolerance = 1e-10)
})

test_that("parallel distance: non-overlapping gap", {
  # Li: (0,0)-(5,0), Lj: (8,0)-(12,0)
  # After swap: Li = (8,0)-(12,0) (len 4), Lj = (0,0)-(5,0) (len 5)
  # Wait — Lj is longer so it becomes Li after swap
  # Li = (0,0)-(5,0), Lj = (8,0)-(12,0)
  # Projections of (8,0) and (12,0) onto line x-axis through (0,0)-(5,0): (8,0), (12,0)
  # l_par1 = min(dist(8,0,0,0), dist(8,0,5,0)) = min(8, 3) = 3
  # l_par2 = min(dist(12,0,0,0), dist(12,0,5,0)) = min(12, 7) = 7
  # d_par = min(3, 7) = 3
  d <- tc_dist_parallel(c(0, 0), c(5, 0), c(8, 0), c(12, 0))
  expect_equal(d, 3.0, tolerance = 1e-10)
})

test_that("parallel distance: swap convention gives same result", {
  d1 <- tc_dist_parallel(c(0, 0), c(10, 0), c(12, 5), c(15, 5))
  d2 <- tc_dist_parallel(c(12, 5), c(15, 5), c(0, 0), c(10, 0))
  expect_equal(d1, d2, tolerance = 1e-10)
})

test_that("angle distance: parallel segments give 0", {
  d <- tc_dist_angle(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
  expect_equal(d, 0.0, tolerance = 1e-10)
})

test_that("angle distance: perpendicular segments give len(Lj)", {
  # Li: (0,0)-(10,0), Lj: (5,-3)-(5,3), len_j = 6
  # theta = 90 degrees, so d_angle = len_j = 6
  d <- tc_dist_angle(c(0, 0), c(10, 0), c(5, -3), c(5, 3))
  expect_equal(d, 6.0, tolerance = 1e-10)
})

test_that("angle distance: opposite direction gives len(Lj)", {
  # Li: (0,0)-(10,0), Lj: (10,2)-(0,2)
  # Angle is 180 degrees > 90, so d_angle = len_j
  segs <- generate_test_segments()$opposite
  d <- tc_dist_angle(segs$si, segs$ei, segs$sj, segs$ej)
  len_j <- sqrt((segs$ej[1] - segs$sj[1])^2 + (segs$ej[2] - segs$sj[2])^2)
  # After swap Li is still the longer one (both length 10, so first stays)
  # Wait: both have length 10 — tied. At tie, first stays as Li.
  # Lj direction is (0,2)-(10,2) wait no Lj stays as (10,2)-(0,2)
  # Actually, both segments have length ~10. At exact tie, first stays.
  # d_angle = len_j (since 180 > 90)
  expect_equal(d, len_j, tolerance = 1e-10)
})

test_that("angle distance: 45-degree angle", {
  # Li: (0,0)-(10,0), Lj: (0,0)-(5,5)
  # After swap: Li stays (length 10 > ~7.07)
  # theta = 45 degrees, sin(45) = sqrt(2)/2
  # d_angle = len_j * sin(45) = sqrt(50) * sqrt(2)/2 = 5
  d <- tc_dist_angle(c(0, 0), c(10, 0), c(0, 0), c(5, 5))
  expect_equal(d, 5.0, tolerance = 1e-10)
})

test_that("angle distance: zero-length Lj gives 0", {
  d <- tc_dist_angle(c(0, 0), c(10, 0), c(5, 3), c(5, 3))
  expect_equal(d, 0.0, tolerance = 1e-10)
})

test_that("angle distance: swap gives same result", {
  d1 <- tc_dist_angle(c(0, 0), c(10, 0), c(0, 0), c(5, 5))
  d2 <- tc_dist_angle(c(0, 0), c(5, 5), c(0, 0), c(10, 0))
  expect_equal(d1, d2, tolerance = 1e-10)
})

test_that("weighted total distance with default weights", {
  d_total <- tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
  d_perp <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
  d_par <- tc_dist_parallel(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
  d_ang <- tc_dist_angle(c(0, 0), c(10, 0), c(0, 5), c(10, 5))
  expect_equal(d_total, d_perp + d_par + d_ang, tolerance = 1e-10)
})

test_that("weighted total distance with zero weights", {
  # Only perpendicular
  d <- tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(10, 5),
    w_perp = 1, w_par = 0, w_angle = 0
  )
  expect_equal(d, 5.0, tolerance = 1e-10)
})

test_that("weighted total distance with custom weights", {
  d_perp <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 5), c(8, 6))
  d_par <- tc_dist_parallel(c(0, 0), c(10, 0), c(0, 5), c(8, 6))
  d_ang <- tc_dist_angle(c(0, 0), c(10, 0), c(0, 5), c(8, 6))

  d_custom <- tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(8, 6),
    w_perp = 2, w_par = 0.5, w_angle = 3
  )
  expect_equal(d_custom, 2 * d_perp + 0.5 * d_par + 3 * d_ang, tolerance = 1e-10)
})

test_that("distance functions reject invalid inputs", {
  expect_error(
    tc_dist_perpendicular(c(0), c(10, 0), c(0, 5), c(10, 5)),
    "length 2"
  )
  expect_error(
    tc_dist_perpendicular("a", c(10, 0), c(0, 5), c(10, 5)),
    "numeric"
  )
  expect_error(
    tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 5), c(10, 5),
      method = "invalid"
    ),
    "method"
  )
  expect_error(
    tc_dist_perpendicular(c(NA, 0), c(10, 0), c(0, 5), c(10, 5)),
    "finite"
  )
  expect_error(
    tc_dist_perpendicular(c(Inf, 0), c(10, 0), c(0, 5), c(10, 5)),
    "finite"
  )
})

test_that("weight validation rejects negative values", {
  expect_error(
    tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(10, 5),
      w_perp = -1
    ),
    "non-negative"
  )
})

test_that("distance symmetry: dist(A,B) == dist(B,A)", {
  # The swap convention should make all distances symmetric
  si <- c(3, 7)
  ei <- c(15, 2)
  sj <- c(1, 4)
  ej <- c(8, 9)

  expect_equal(
    tc_dist_perpendicular(si, ei, sj, ej),
    tc_dist_perpendicular(sj, ej, si, ei),
    tolerance = 1e-10
  )
  expect_equal(
    tc_dist_parallel(si, ei, sj, ej),
    tc_dist_parallel(sj, ej, si, ei),
    tolerance = 1e-10
  )
  expect_equal(
    tc_dist_angle(si, ei, sj, ej),
    tc_dist_angle(sj, ej, si, ei),
    tolerance = 1e-10
  )
  expect_equal(
    tc_dist_segments(si, ei, sj, ej),
    tc_dist_segments(sj, ej, si, ei),
    tolerance = 1e-10
  )
})

test_that("all distance components are non-negative", {
  segs <- generate_test_segments()
  for (name in names(segs)) {
    s <- segs[[name]]
    expect_gte(tc_dist_perpendicular(s$si, s$ei, s$sj, s$ej), 0,
      label = paste("perp:", name)
    )
    expect_gte(tc_dist_parallel(s$si, s$ei, s$sj, s$ej), 0,
      label = paste("par:", name)
    )
    expect_gte(tc_dist_angle(s$si, s$ei, s$sj, s$ej), 0,
      label = paste("angle:", name)
    )
  }
})

# --- Golden-Value Tests ---
# Hand-computed expected values for two segment pairs.
# All derivations follow Paper Definitions 1-3 and the spec formulas.

test_that("golden: Pair A (orthogonal) — all three components", {
  # Li = (0,0)->(10,0)  horizontal, length = 10
  # Lj = (3,0)->(3,4)   vertical,   length = 4
  # Li is longer (10 > 4) => no swap.
  #
  # --- d_perp (Definition 1) ---
  # Project sj=(3,0) onto LINE y=0:
  #   t = ((3-0)*10 + (0-0)*0) / (10^2) = 30/100 = 0.3
  #   proj_sj = (0,0) + 0.3*(10,0) = (3, 0)
  #   l1 = dist((3,0), (3,0)) = 0
  # Project ej=(3,4) onto LINE y=0:
  #   t = ((3-0)*10 + (4-0)*0) / 100 = 30/100 = 0.3
  #   proj_ej = (3, 0)
  #   l2 = dist((3,4), (3,0)) = 4
  # Lehmer mean: (0^2 + 4^2) / (0 + 4) = 16/4 = 4.0
  expect_equal(
    tc_dist_perpendicular(c(0, 0), c(10, 0), c(3, 0), c(3, 4)),
    4.0,
    tolerance = 1e-10
  )

  # --- d_par (Definition 2) ---
  # proj_sj = (3, 0):
  #   l_par1 = min(dist((3,0),(0,0)), dist((3,0),(10,0))) = min(3, 7) = 3
  # proj_ej = (3, 0):
  #   l_par2 = min(dist((3,0),(0,0)), dist((3,0),(10,0))) = min(3, 7) = 3
  # d_par = min(3, 3) = 3.0
  expect_equal(
    tc_dist_parallel(c(0, 0), c(10, 0), c(3, 0), c(3, 4)),
    3.0,
    tolerance = 1e-10
  )

  # --- d_angle (Definition 3) ---
  # dir_Li = (10, 0), dir_Lj = (0, 4)
  # cos(theta) = (10*0 + 0*4) / (10*4) = 0  =>  theta = 90°
  # theta >= 90°  =>  d_angle = |Lj| = 4.0
  expect_equal(
    tc_dist_angle(c(0, 0), c(10, 0), c(3, 0), c(3, 4)),
    4.0,
    tolerance = 1e-10
  )
})

test_that("golden: Pair B (oblique, projection outside segment) — all three components", {
  # Li = (0,0)->(6,0)   horizontal, length = 6
  # Lj = (8,1)->(10,3)  oblique,    length = sqrt((10-8)^2+(3-1)^2) = sqrt(8) = 2*sqrt(2)
  # Li is longer (6 > 2*sqrt(2) ~ 2.828) => no swap.
  #
  # --- d_perp ---
  # Project sj=(8,1) onto LINE y=0:
  #   t = ((8-0)*6 + (1-0)*0) / 36 = 48/36 = 4/3
  #   proj_sj = (0,0) + (4/3)*(6,0) = (8, 0)
  #   l1 = dist((8,1),(8,0)) = 1
  # Project ej=(10,3) onto LINE y=0:
  #   t = ((10-0)*6 + (3-0)*0) / 36 = 60/36 = 5/3
  #   proj_ej = (0,0) + (5/3)*(6,0) = (10, 0)
  #   l2 = dist((10,3),(10,0)) = 3
  # Lehmer mean: (1^2 + 3^2) / (1 + 3) = (1+9)/4 = 10/4 = 2.5
  expect_equal(
    tc_dist_perpendicular(c(0, 0), c(6, 0), c(8, 1), c(10, 3)),
    2.5,
    tolerance = 1e-10
  )

  # --- d_par ---
  # proj_sj = (8, 0):
  #   l_par1 = min(dist((8,0),(0,0)), dist((8,0),(6,0))) = min(8, 2) = 2
  # proj_ej = (10, 0):
  #   l_par2 = min(dist((10,0),(0,0)), dist((10,0),(6,0))) = min(10, 4) = 4
  # d_par = min(2, 4) = 2.0
  # NOTE: l_par > 0 because both projections lie outside Li.
  expect_equal(
    tc_dist_parallel(c(0, 0), c(6, 0), c(8, 1), c(10, 3)),
    2.0,
    tolerance = 1e-10
  )

  # --- d_angle ---
  # dir_Li = (6, 0), dir_Lj = (2, 2)
  # cos(theta) = (6*2 + 0*2) / (6 * 2*sqrt(2)) = 12 / (12*sqrt(2)) = 1/sqrt(2)
  # theta = acos(1/sqrt(2)) = pi/4 = 45°
  # theta < 90°  =>  d_angle = |Lj| * sin(45°) = 2*sqrt(2) * (1/sqrt(2)) = 2.0
  expect_equal(
    tc_dist_angle(c(0, 0), c(6, 0), c(8, 1), c(10, 3)),
    2.0,
    tolerance = 1e-10
  )
})

test_that("golden: weighted total distance for Pair A and Pair B", {
  # Pair A: d_perp=4.0, d_par=3.0, d_angle=4.0
  # w=(1,1,1): 4+3+4 = 11.0
  expect_equal(
    tc_dist_segments(c(0, 0), c(10, 0), c(3, 0), c(3, 4)),
    11.0,
    tolerance = 1e-10
  )
  # w=(2,0,1): 2*4 + 0*3 + 1*4 = 12.0
  expect_equal(
    tc_dist_segments(c(0, 0), c(10, 0), c(3, 0), c(3, 4),
      w_perp = 2, w_par = 0, w_angle = 1
    ),
    12.0,
    tolerance = 1e-10
  )

  # Pair B: d_perp=2.5, d_par=2.0, d_angle=2.0
  # w=(1,1,1): 2.5+2+2 = 6.5
  expect_equal(
    tc_dist_segments(c(0, 0), c(6, 0), c(8, 1), c(10, 3)),
    6.5,
    tolerance = 1e-10
  )
  # w=(2,0,1): 2*2.5 + 0*2 + 1*2 = 7.0
  expect_equal(
    tc_dist_segments(c(0, 0), c(6, 0), c(8, 1), c(10, 3),
      w_perp = 2, w_par = 0, w_angle = 1
    ),
    7.0,
    tolerance = 1e-10
  )
})

test_that("all weights = 0 yields distance 0 for any segment pair", {
  # With w_perp=w_par=w_angle=0, tc_dist_segments returns 0 regardless of geometry
  d1 <- tc_dist_segments(c(0, 0), c(10, 0), c(0, 5), c(10, 5),
    w_perp = 0, w_par = 0, w_angle = 0
  )
  expect_equal(d1, 0.0)

  # Very dissimilar segments — still 0
  d2 <- tc_dist_segments(c(0, 0), c(10, 0), c(100, 100), c(200, 200),
    w_perp = 0, w_par = 0, w_angle = 0
  )
  expect_equal(d2, 0.0)

  # Perpendicular segments — still 0
  d3 <- tc_dist_segments(c(0, 0), c(10, 0), c(5, -3), c(5, 3),
    w_perp = 0, w_par = 0, w_angle = 0
  )
  expect_equal(d3, 0.0)
})

test_that("d_perp: l1=l2=0 Lehmer guard returns 0 not NaN", {
  # Both Lj endpoints are exactly on the line through Li → l1 = l2 = 0
  # Lehmer mean would be 0/0 without the guard; guard must return 0
  d <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(2, 0), c(8, 0))
  expect_equal(d, 0.0, tolerance = 1e-10)
  expect_false(is.nan(d))
  expect_true(is.finite(d))

  # Another collinear case: endpoint exactly at start of Li
  d2 <- tc_dist_perpendicular(c(0, 0), c(10, 0), c(0, 0), c(5, 0))
  expect_equal(d2, 0.0, tolerance = 1e-10)
  expect_false(is.nan(d2))
})

test_that("zero-length Li (before swap) returns 0 via swap convention", {
  # si == ei (zero-length i segment), sj != ej (positive-length j segment)
  # Swap: j becomes new Li (length > 0), i becomes new Lj (length 0)
  # → len_j < 1e-15 guard fires → returns 0
  d <- tc_dist_angle(c(5, 5), c(5, 5), c(0, 0), c(10, 0))
  expect_equal(d, 0.0, tolerance = 1e-10)
  expect_false(is.nan(d))
  expect_true(is.finite(d))

  # Also verify perpendicular and parallel for same case
  dp <- tc_dist_perpendicular(c(5, 5), c(5, 5), c(0, 0), c(10, 0))
  expect_true(is.finite(dp))
  expect_gte(dp, 0)

  dl <- tc_dist_parallel(c(5, 5), c(5, 5), c(0, 0), c(10, 0))
  expect_true(is.finite(dl))
  expect_gte(dl, 0)
})

test_that("golden: swap symmetry — dist(Li,Lj) == dist(Lj,Li)", {
  # Pair A
  si_a <- c(0, 0)
  ei_a <- c(10, 0)
  sj_a <- c(3, 0)
  ej_a <- c(3, 4)
  expect_equal(
    tc_dist_segments(si_a, ei_a, sj_a, ej_a),
    tc_dist_segments(sj_a, ej_a, si_a, ei_a),
    tolerance = 1e-10
  )
  # Pair B
  si_b <- c(0, 0)
  ei_b <- c(6, 0)
  sj_b <- c(8, 1)
  ej_b <- c(10, 3)
  expect_equal(
    tc_dist_segments(si_b, ei_b, sj_b, ej_b),
    tc_dist_segments(sj_b, ej_b, si_b, ei_b),
    tolerance = 1e-10
  )
})

test_that("TRACLUS d_perp can violate the triangle inequality (not a metric)", {
  # Concrete counter-example:
  #   A = (0,0)->(100,0)   horizontal, length 100
  #   B = (50,0)->(50,100) vertical,   length 100
  #   C = (50,50)->(50,150) vertical,  length 100
  #
  # d_perp(A,B): project B onto line y=0  → l1=0, l2=100 → Lehmer=100
  # d_perp(B,C): project C onto line x=50 → l1=0, l2=0   → Lehmer=0
  # d_perp(A,C): project C onto line y=0  → l1=50, l2=150 → Lehmer=125
  #
  # Triangle inequality violated: d(A,C) = 125 > d(A,B) + d(B,C) = 100 + 0

  d_ab <- tc_dist_perpendicular(c(0, 0), c(100, 0), c(50, 0), c(50, 100))
  d_bc <- tc_dist_perpendicular(c(50, 0), c(50, 100), c(50, 50), c(50, 150))
  d_ac <- tc_dist_perpendicular(c(0, 0), c(100, 0), c(50, 50), c(50, 150))

  expect_equal(d_ab, 100, tolerance = 1e-10)
  expect_equal(d_bc, 0, tolerance = 1e-10)
  expect_equal(d_ac, 125, tolerance = 1e-10)

  # The triangle inequality d(A,C) <= d(A,B) + d(B,C) is violated here:
  expect_gt(d_ac, d_ab + d_bc)
})
