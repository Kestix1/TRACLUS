# Sweep-line representative trajectory for one cluster

Implements the full sweep-line algorithm (Paper Figure 15) for a single
cluster of line segments. Returns waypoint coordinates in the original
coordinate system.

## Usage

``` r
.sweep_line_representative(sx, sy, ex, ey, traj_id, min_lns, gamma)
```

## Arguments

- sx, sy, ex, ey:

  Numeric vectors of segment coordinates (already in the working
  coordinate system — meters for geographic, raw for euclidean).

- traj_id:

  Character or integer vector identifying which trajectory each segment
  belongs to. Must have the same length as `sx`. Used for the trajectory
  diversity check.

- min_lns:

  Minimum number of crossing segments to generate a waypoint (Paper
  Figure 15, Line 7).

- gamma:

  Minimum distance between consecutive waypoints.

## Value

A data.frame with columns `rx`, `ry` (waypoint coordinates in the
working coordinate system), or NULL if \< 2 waypoints.

## Details

**Deviation from paper:** In addition to the segment density check
(`count >= min_lns`), a trajectory diversity check requires at least 2
distinct trajectories among the active segments at each waypoint
position. This prevents degenerate representatives from consecutive
segments of a single trajectory whose entry-before-exit overlap at
shared characteristic points artificially inflates the segment count.
See package documentation for details.
