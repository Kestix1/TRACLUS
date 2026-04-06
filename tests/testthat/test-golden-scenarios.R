# --- Golden-value test scenarios ---
# End-to-end tests with analytically computed expected values.
# Each scenario tests a specific TRACLUS property.
# All expected values are computed by hand and verified against the paper
# (Lee, Han & Whang 2007).
#
# Notation:
#   Phase 1 = tc_partition  (MDL)
#   Phase 2 = tc_cluster    (DBSCAN)
#   Phase 3 = tc_represent  (Sweep-Line)

# --- Shared helper: build trajectories from coordinate vectors ---
make_trajs <- function(ids, xs, ys) {
  df <- data.frame(traj_id = ids, x = xs, y = ys)
  tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                  coord_type = "euclidean", verbose = FALSE)
}

# --- Scenario 1 | Two parallel, equal-length segments ---
# T1: (0,0) -> (10,0)      T2: (0,1) -> (10,1)
# dist = d_perp(1) + d_par(0) + d_angle(0) = 1.0

test_that("S01 Phase1: straight lines collapse to 1 segment each", {
  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2"),
    xs  = c(0, 10, 0, 10),
    ys  = c(0, 0, 1, 1)
  )
  part <- suppressMessages(tc_partition(trj))
  expect_equal(nrow(part$segments), 2)
})

test_that("S01 Phase2: eps threshold separates cluster from noise", {
  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2"),
    xs  = c(0, 10, 0, 10),
    ys  = c(0, 0, 1, 1)
  )
  part <- suppressMessages(tc_partition(trj))

  # dist = 1.0. eps=0.9 < 1.0 => no neighbours, all noise
  clu1 <- suppressMessages(suppressWarnings(
    tc_cluster(part, eps = 0.9, min_lns = 2)
  ))
  expect_equal(clu1$n_clusters, 0)
  expect_equal(clu1$n_noise, 2)

  # eps=1.1 >= 1.0 => neighbours, 1 cluster
  clu2 <- suppressMessages(tc_cluster(part, eps = 1.1, min_lns = 2))
  expect_equal(clu2$n_clusters, 1)
  expect_equal(clu2$n_noise, 0)

  # eps=1.1 but min_lns=3 => |Neps|=2 < 3, all noise
  clu3 <- suppressMessages(suppressWarnings(
    tc_cluster(part, eps = 1.1, min_lns = 3)
  ))
  expect_equal(clu3$n_clusters, 0)
  expect_equal(clu3$n_noise, 2)
})

test_that("S01 Phase3: representative is midline y=0.5", {
  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2"),
    xs  = c(0, 10, 0, 10),
    ys  = c(0, 0, 1, 1)
  )
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 1.1, min_lns = 2))
  repr <- suppressMessages(tc_represent(clu, gamma = 1))

  expect_equal(repr$n_clusters, 1)
  reps <- repr$representatives
  expect_equal(nrow(reps), 2)
  expect_equal(reps$rx, c(0, 10), tolerance = 1e-10)
  expect_equal(reps$ry, c(0.5, 0.5), tolerance = 1e-10)
})

# --- Scenario 3 | Opposing-direction segments (180 deg) ---
# T1: (0,0) -> (10,0)  [East]
# T2: (10,0.5) -> (0,0.5)  [West]
#
# Swap: len(T2) = sqrt(100.25) > 10 = len(T1) => Li=T2, Lj=T1
# d_perp = 0.5  (Lehmer of equal perps)
# d_par  = 0.0  (projections land on Li endpoints)
# d_angle = 10.0  (theta ~ 177 deg >= 90 => full Lj length)
# Total = 10.5

test_that("S03 Phase2: angular distance prevents clustering at 180 deg", {
  # Verify the distance value first
  d <- tc_dist_segments(c(0, 0), c(10, 0), c(10, 0.5), c(0, 0.5))
  expect_equal(d, 10.5, tolerance = 0.01)

  # eps=2.0 << 10.5 => no cluster
  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2"),
    xs  = c(0, 10, 10, 0),
    ys  = c(0, 0, 0.5, 0.5)
  )
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(suppressWarnings(
    tc_cluster(part, eps = 2.0, min_lns = 2)
  ))
  expect_equal(clu$n_clusters, 0)
  expect_equal(clu$n_noise, 2)
})

test_that("S03: distance components verify paper formulas", {
  # d_perp: Lehmer mean of equal perpendicular distances
  d_perp <- TRACLUS:::.r_d_perp_euc(c(10, 0.5), c(0, 0.5), c(0, 0), c(10, 0))
  expect_equal(d_perp, 0.5, tolerance = 1e-10)

  # d_par: projections land on endpoints
  d_par <- TRACLUS:::.r_d_par_euc(c(10, 0.5), c(0, 0.5), c(0, 0), c(10, 0))
  expect_equal(d_par, 0.0, tolerance = 1e-10)

  # d_angle: theta >= 90 => len(Lj) = 10.0
  d_angle <- TRACLUS:::.r_d_angle_euc(c(10, 0.5), c(0, 0.5), c(0, 0), c(10, 0))
  expect_equal(d_angle, 10.0, tolerance = 1e-10)
})

# --- Scenario 4 | Offset segments with overlap cutoff ---
# S1: (0,0) -> (10,0)    S2: (2,1) -> (12,1)
# Directly to .sweep_line_representative, min_lns=2.
#
# Events: Entry S1@x=0, Entry S2@x=2, Exit S1@x=10, Exit S2@x=12
# Overlap region: [2, 10]. Margins [0,2] and [10,12] cut off (count < 2).
# WP(2, 0.5) and WP(10, 0.5).

test_that("S04 Phase3: representative only in overlap region", {
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 2), sy = c(0, 1),
    ex = c(10, 12), ey = c(0, 1),
    traj_id = c("A", "B"),
    min_lns = 2, gamma = 0.001
  )

  expect_false(is.null(result))
  expect_equal(nrow(result), 2)
  expect_equal(result$rx, c(2, 10), tolerance = 1e-10)
  expect_equal(result$ry, c(0.5, 0.5), tolerance = 1e-10)
})

# --- Scenario 6 | The funnel (angular gradient) ---
# T1: (0,0) -> (10,0)      0 deg,    len = 10
# T2: (0,1) -> (10,2)    ~ 5.7 deg,  len = sqrt(101)
# T3: (0,2) -> (10,5)    ~16.7 deg,  len = sqrt(109)
#
# Hand-computed pairwise distances (w=1,1,1):
#   dist(T1,T2) = 50/(3*sqrt(101)) + 1/sqrt(101) + 10/sqrt(101) = 2.753
#   dist(T1,T3) = 290/(7*sqrt(109)) + 6/sqrt(109) + 30/sqrt(109) = 7.416
#   dist(T2,T3) = 25/sqrt(109) + 3/sqrt(109) + 20/sqrt(109) = 4.598
#
# With eps=3.0, min_lns=2: T1+T2 cluster, T3 noise.

test_that("S06 Phase2: angular gradient separates similar from different", {
  d12 <- tc_dist_segments(c(0, 0), c(10, 0), c(0, 1), c(10, 2))
  d13 <- tc_dist_segments(c(0, 0), c(10, 0), c(0, 2), c(10, 5))
  d23 <- tc_dist_segments(c(0, 1), c(10, 2), c(0, 2), c(10, 5))

  # Verify hand-computed distances
  expect_equal(d12, 50 / (3 * sqrt(101)) + 1 / sqrt(101) + 10 / sqrt(101),
               tolerance = 1e-4)
  expect_equal(d13, 290 / (7 * sqrt(109)) + 6 / sqrt(109) + 30 / sqrt(109),
               tolerance = 1e-4)
  expect_equal(d23, 25 / sqrt(109) + 3 / sqrt(109) + 20 / sqrt(109),
               tolerance = 1e-4)

  # eps=3.0: T1+T2 cluster, T3 noise
  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2", "T3", "T3"),
    xs  = c(0, 10, 0, 10, 0, 10),
    ys  = c(0, 0, 1, 2, 2, 5)
  )
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 3.0, min_lns = 2))

  expect_equal(clu$n_clusters, 1)
  expect_equal(clu$n_noise, 1)

  # T3 segment is noise (cluster_id = NA)
  segs <- clu$segments
  t3_seg <- segs[segs$traj_id == "T3", ]
  expect_true(is.na(t3_seg$cluster_id))
})

test_that("S06 Phase3: tilted representative from non-horizontal cluster", {
  # T1+T2 cluster. Average direction: (10,0)+(10,1) = (20,1).
  # Representative goes from approximately (0.025, 0.5) to (9.950, 0.995).
  # Exact: WP1 = (1/40, 1/2), WP2 = (2000/201, 200/201).
  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2", "T3", "T3"),
    xs  = c(0, 10, 0, 10, 0, 10),
    ys  = c(0, 0, 1, 2, 2, 5)
  )
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 3.0, min_lns = 2))
  repr <- suppressMessages(tc_represent(clu, gamma = 1))

  expect_equal(repr$n_clusters, 1)
  reps <- repr$representatives
  expect_equal(nrow(reps), 2)

  # Exact golden values
  expect_equal(reps$rx[1], 1 / 40, tolerance = 1e-6)
  expect_equal(reps$ry[1], 0.5, tolerance = 1e-6)
  expect_equal(reps$rx[2], 2000 / 201, tolerance = 1e-6)
  expect_equal(reps$ry[2], 200 / 201, tolerance = 1e-6)

  # Representative is tilted upward (not horizontal)
  expect_true(reps$ry[2] > reps$ry[1])
})

# --- Scenario 7 | Short overlapping segment ---
# S1: (0,0) -> (10,0)   len 10
# S2: (4,1) -> (6,1)    len 2
# Directly to .sweep_line_representative, min_lns=2.
#
# The short segment determines the extent of the representative.
# WP at x=4 (Entry S2) and x=6 (Exit S2, before deactivation).
# Representative: (4, 0.5) -> (6, 0.5).

test_that("S07 Phase3: short segment determines representative extent", {
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 4), sy = c(0, 1),
    ex = c(10, 6), ey = c(0, 1),
    traj_id = c("A", "B"),
    min_lns = 2, gamma = 0.001
  )

  expect_false(is.null(result))
  expect_equal(nrow(result), 2)
  expect_equal(result$rx, c(4, 6), tolerance = 1e-10)
  expect_equal(result$ry, c(0.5, 0.5), tolerance = 1e-10)
})

# --- Scenario 8 | L-shaped trajectory splits into two clusters ---
# T1: (0,0) -> (5,0) -> (5,5)     L-shape, MDL splits into 2 segments
# T2: (0,0.5) -> (5,0.5)          parallel to S1a (horizontal)
# T3: (4.5,0) -> (4.5,5)          parallel to S1b (vertical)
# eps=1.0, min_lns=2
#
# Distances:
#   dist(S1a, T2) = 0.5   (parallel horizontal, d_perp=0.5)
#   dist(S1b, T3) = 0.5   (parallel vertical, d_perp=0.5)
#   dist(S1a, T3) >> 1.0  (90 deg angle, d_angle=5.0)
#   dist(S1b, T2) >> 1.0  (90 deg angle, d_angle=5.0)
#
# Result: C1={S1a, T2}, C2={S1b, T3}
# Segments of T1 end up in DIFFERENT clusters.

test_that("S08 Phase1: L-shape trajectory splits at the corner", {
  trj <- make_trajs(
    ids = c("T1", "T1", "T1", "T2", "T2", "T3", "T3"),
    xs  = c(0, 5, 5, 0, 5, 4.5, 4.5),
    ys  = c(0, 0, 5, 0.5, 0.5, 0, 5)
  )
  part <- suppressMessages(tc_partition(trj))

  # T1: 2 segments, T2: 1, T3: 1 => 4 total
  expect_equal(nrow(part$segments), 4)

  t1_segs <- part$segments[part$segments$traj_id == "T1", ]
  expect_equal(nrow(t1_segs), 2)
})

test_that("S08 Phase2: same trajectory in two different clusters", {
  trj <- make_trajs(
    ids = c("T1", "T1", "T1", "T2", "T2", "T3", "T3"),
    xs  = c(0, 5, 5, 0, 5, 4.5, 4.5),
    ys  = c(0, 0, 5, 0.5, 0.5, 0, 5)
  )
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 1.0, min_lns = 2))

  expect_equal(clu$n_clusters, 2)
  expect_equal(clu$n_noise, 0)

  # T1 segments are in different clusters
  t1_cids <- clu$segments$cluster_id[clu$segments$traj_id == "T1"]
  expect_equal(length(t1_cids), 2)
  expect_false(t1_cids[1] == t1_cids[2])
})

test_that("S08 Phase3: two independent representatives", {
  trj <- make_trajs(
    ids = c("T1", "T1", "T1", "T2", "T2", "T3", "T3"),
    xs  = c(0, 5, 5, 0, 5, 4.5, 4.5),
    ys  = c(0, 0, 5, 0.5, 0.5, 0, 5)
  )
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 1.0, min_lns = 2))
  repr <- suppressMessages(tc_represent(clu, gamma = 1))

  expect_equal(repr$n_clusters, 2)

  # Find horizontal and vertical representatives by their extent
  reps <- repr$representatives
  cids <- unique(reps$cluster_id)
  expect_equal(length(cids), 2)

  for (cid in cids) {
    pts <- reps[reps$cluster_id == cid, ]
    expect_equal(nrow(pts), 2)

    dx <- abs(pts$rx[2] - pts$rx[1])
    dy <- abs(pts$ry[2] - pts$ry[1])

    if (dx > dy) {
      # Horizontal representative: midline of S1a and T2
      # Expected: (0, 0.25) -> (5, 0.25)
      expect_equal(pts$rx, c(0, 5), tolerance = 1e-6)
      expect_equal(pts$ry, c(0.25, 0.25), tolerance = 1e-6)
    } else {
      # Vertical representative: midline of S1b and T3
      # Expected: (4.75, 0) -> (4.75, 5)
      expect_equal(pts$rx, c(4.75, 4.75), tolerance = 1e-6)
      expect_equal(pts$ry, c(0, 5), tolerance = 1e-6)
    }
  }
})

# --- Scenario 9 | Vertical segments (dx=0) ---
# T1: (0,0) -> (0,10)     T2: (1,0) -> (1,10)
# dist = d_perp(1) + d_par(0) + d_angle(0) = 1.0
#
# Sweep-line: dir=(0,1). Rotation maps vertical to horizontal.
# After rotation and back: representative at (0.5, 0) -> (0.5, 10).

test_that("S09 Phase2: vertical segments cluster correctly", {
  d <- tc_dist_segments(c(0, 0), c(0, 10), c(1, 0), c(1, 10))
  expect_equal(d, 1.0, tolerance = 1e-10)

  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2"),
    xs  = c(0, 0, 1, 1),
    ys  = c(0, 10, 0, 10)
  )
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 1.1, min_lns = 2))

  expect_equal(clu$n_clusters, 1)
  expect_equal(clu$n_noise, 0)
})

test_that("S09 Phase3: vertical representative via rotation", {
  # Directly test sweep-line with vertical segments
  # dir=(0,1), rotation maps (x,y) to (y,-x), inverse maps (x',y') to (-y',x')
  result <- TRACLUS:::.sweep_line_representative(
    sx = c(0, 1), sy = c(0, 0),
    ex = c(0, 1), ey = c(10, 10),
    traj_id = c("A", "B"),
    min_lns = 2, gamma = 0.001
  )

  expect_false(is.null(result))
  expect_equal(nrow(result), 2)
  expect_equal(result$rx, c(0.5, 0.5), tolerance = 1e-10)
  expect_equal(result$ry, c(0, 10), tolerance = 1e-10)
})

test_that("S09 Phase3: end-to-end vertical representative", {
  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2"),
    xs  = c(0, 0, 1, 1),
    ys  = c(0, 10, 0, 10)
  )
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 1.1, min_lns = 2))
  repr <- suppressMessages(tc_represent(clu, gamma = 1))

  expect_equal(repr$n_clusters, 1)
  reps <- repr$representatives
  expect_equal(nrow(reps), 2)
  expect_equal(reps$rx, c(0.5, 0.5), tolerance = 1e-6)
  expect_equal(reps$ry, c(0, 10), tolerance = 1e-6)
})

# --- Scenario 10 | Single trajectory ---
# T1: (0,0) -> (10,0)
# Only 1 segment, |Neps|=1 < min_lns=2 => noise.

test_that("S10: single trajectory is rejected by tc_trajectories", {
  # TRACLUS requires >= 2 trajectories (clustering is meaningless with 1)
  expect_error(
    make_trajs(ids = c("T1", "T1"), xs = c(0, 10), ys = c(0, 0)),
    "2 valid trajectories"
  )
})

test_that("S10: isolated trajectory within multi-traj input is all noise", {
  # T1 is far from T2 => both noise, 0 clusters, well-formed output
  trj <- make_trajs(
    ids = c("T1", "T1", "T2", "T2"),
    xs  = c(0, 10, 100, 110),
    ys  = c(0, 0, 100, 100)
  )
  part <- suppressMessages(tc_partition(trj))
  expect_equal(nrow(part$segments), 2)

  # eps=1 is too small for dist >> 1 between segments
  clu <- suppressMessages(suppressWarnings(
    tc_cluster(part, eps = 1, min_lns = 2)
  ))
  expect_equal(clu$n_clusters, 0)
  expect_equal(clu$n_noise, 2)
  expect_true(all(is.na(clu$segments$cluster_id)))

  # tc_represent produces 0 representatives, no crash
  repr <- suppressMessages(suppressWarnings(tc_represent(clu)))
  expect_s3_class(repr, "tc_representatives")
  expect_equal(repr$n_clusters, 0)
  expect_equal(nrow(repr$representatives), 0)
})

# --- Scenario 11 | Eps scaling: two groups merge at large eps ---
# Group A: T1-T3 at y = 0, 1, 2   (horizontal, length 10)
# Group B: T4-T6 at y = 10, 11, 12 (horizontal, length 10)
#
# Intra-group distances: 1.0 or 2.0
# Inter-group distances: 8.0 to 12.0
#
# eps=1.5, min_lns=2 => 2 clusters (groups separated)
# eps=15.0, min_lns=2 => 1 cluster (groups merged)

make_scenario11 <- function() {
  make_trajs(
    ids = rep(paste0("T", 1:6), each = 2),
    xs  = rep(c(0, 10), 6),
    ys  = c(0, 0, 1, 1, 2, 2, 10, 10, 11, 11, 12, 12)
  )
}

test_that("S11 Phase2: eps=1.5 separates two groups", {
  trj  <- make_scenario11()
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 1.5, min_lns = 2))

  expect_equal(clu$n_clusters, 2)
  expect_equal(clu$n_noise, 0)

  # Each cluster has 3 segments
  expect_equal(clu$cluster_summary$n_segments, c(3, 3))
})

test_that("S11 Phase2: eps=15 merges both groups", {
  trj  <- make_scenario11()
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 15.0, min_lns = 2))

  expect_equal(clu$n_clusters, 1)
  expect_equal(clu$n_noise, 0)
  expect_equal(clu$cluster_summary$n_segments[1], 6)
})

test_that("S11 Phase3: two separate representatives at eps=1.5", {
  trj  <- make_scenario11()
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 1.5, min_lns = 2))
  repr <- suppressMessages(tc_represent(clu, gamma = 1))

  expect_equal(repr$n_clusters, 2)
  reps <- repr$representatives

  # Each representative has 2 waypoints
  for (cid in unique(reps$cluster_id)) {
    pts <- reps[reps$cluster_id == cid, ]
    expect_equal(nrow(pts), 2)
    expect_equal(pts$rx, c(0, 10), tolerance = 1e-10)
  }

  # One representative near y=1 (mean of 0,1,2), other near y=11 (mean of 10,11,12)
  mean_ys <- sort(vapply(unique(reps$cluster_id), function(cid) {
    mean(reps$ry[reps$cluster_id == cid])
  }, numeric(1)))

  expect_equal(mean_ys, c(1.0, 11.0), tolerance = 1e-10)
})

test_that("S11 Phase3: one merged representative at eps=15", {
  trj  <- make_scenario11()
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 15.0, min_lns = 2))
  repr <- suppressMessages(tc_represent(clu, gamma = 1))

  expect_equal(repr$n_clusters, 1)
  reps <- repr$representatives
  expect_equal(nrow(reps), 2)
  expect_equal(reps$rx, c(0, 10), tolerance = 1e-10)
  # mean of 0,1,2,10,11,12 = 36/6 = 6.0
  expect_equal(reps$ry, c(6.0, 6.0), tolerance = 1e-10)
})


# --- Scenario P1 | method = "projected" — parallel geographic trajectories ---
# Two parallel east-west routes at ~30N, 1 degree latitude apart.
# Equirectangular distance at lat_mean ≈ 30.5:
#   d_perp ≈ 1 * 111320 = 111320 m
# At eps = 200000 m they should cluster; at eps = 50000 they should not.

make_geo_trajs_for_projected <- function() {
  df <- data.frame(
    traj_id = c("A", "A", "B", "B"),
    x = c(-80, -70, -80, -70),   # lon
    y = c(30, 30, 31, 31)         # lat
  )
  tc_trajectories(df, traj_id = "traj_id", x = "x", y = "y",
                  coord_type = "geographic", method = "projected",
                  verbose = FALSE)
}

test_that("P1-projected: tc_trajectories stores proj_params", {
  trj <- make_geo_trajs_for_projected()
  expect_equal(trj$method, "projected")
  expect_false(is.null(trj$proj_params))
  expect_equal(trj$proj_params$lat_mean, 30.25, tolerance = 0.5)
})

test_that("P1-projected: partition preserves lon/lat coordinates", {
  trj <- make_geo_trajs_for_projected()
  part <- suppressMessages(tc_partition(trj))
  expect_equal(nrow(part$segments), 2)
  # Segments should still be in lon/lat, not meters
  expect_true(all(part$segments$sx >= -180 & part$segments$sx <= 180))
  expect_true(all(part$segments$sy >= -90  & part$segments$sy <= 90))
})

test_that("P1-projected: clustering uses equirectangular distances", {
  trj <- make_geo_trajs_for_projected()
  part <- suppressMessages(tc_partition(trj))

  # 1 degree latitude ≈ 111 km => eps = 200000 m should cluster
  clu_yes <- suppressMessages(
    tc_cluster(part, eps = 200000, min_lns = 2)
  )
  expect_equal(clu_yes$n_clusters, 1)

  # eps = 50000 m => too small, no cluster
  clu_no <- suppressMessages(suppressWarnings(
    tc_cluster(part, eps = 50000, min_lns = 2)
  ))
  expect_equal(clu_no$n_clusters, 0)
})

test_that("P1-projected: representative is in lon/lat midline", {
  trj <- make_geo_trajs_for_projected()
  part <- suppressMessages(tc_partition(trj))
  clu  <- suppressMessages(tc_cluster(part, eps = 200000, min_lns = 2))
  repr <- suppressMessages(tc_represent(clu, gamma = 1))

  expect_equal(repr$n_clusters, 1)
  reps <- repr$representatives
  expect_true(nrow(reps) >= 2)
  # Midline latitude should be ~30.5 (between 30 and 31)
  expect_equal(mean(reps$ry), 30.5, tolerance = 0.1)
  # Longitudes should be within [-80, -70] range
  expect_true(all(reps$rx >= -81 & reps$rx <= -69))
})

test_that("P1-projected: full pipeline via tc_traclus works", {
  trj <- make_geo_trajs_for_projected()
  result <- suppressMessages(
    tc_traclus(trj, eps = 200000, min_lns = 2)
  )
  expect_s3_class(result, "tc_traclus")
  expect_equal(result$n_clusters, 1)
  expect_equal(result$method, "projected")
})
