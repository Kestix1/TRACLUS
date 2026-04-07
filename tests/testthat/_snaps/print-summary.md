# print.tc_trajectories output snapshot

    Code
      print(wf$trj)
    Output
      TRACLUS Trajectories
        Trajectories: 6
        Points:       40
        Coord type:   euclidean
        Method:       euclidean
        Status:       loaded (run tc_partition next)

# print.tc_clusters output snapshot (geographic)

    Code
      print(clust)
    Output
      TRACLUS Clusters
        Clusters:     1
        Noise segs:   4
        Total segs:   12
        eps:          5e+05 (meters)
        min_lns:      2
        Coord type:   geographic
        Method:       haversine
        Status:       clustered (run tc_represent next)
        Note:         min_lns = 2 may produce representatives dominated by
                      a single trajectory. Consider min_lns >= 3.
                      See ?tc_represent or vignette('TRACLUS-parameter-guide').

# summary.tc_trajectories output snapshot

    Code
      summary(wf$trj)
    Output
      TRACLUS Trajectories - Summary
        Trajectories:       6
        Total points:       40
        Points per traj:    min = 5, median = 7, max = 7
        Coord type:         euclidean
        Method:             euclidean

# summary.tc_clusters output snapshot

    Code
      summary(wf$clust)
    Output
      TRACLUS Clusters - Summary
        Clusters:           1
        Total segments:     10
        Noise segments:     1 (10.0%)
        Segs per cluster:   min = 9, median = 9, max = 9
        Trajs per cluster:  min = 5, median = 5, max = 5
        eps:                25 (coordinate units)
        min_lns:            3
        Coord type:         euclidean
        Method:             euclidean

# summary.tc_traclus output snapshot

    Code
      summary(result)
    Output
      TRACLUS Result - Summary
        Input trajs:        6
        Partitioned into:   10 segments
        Clusters:           1
        Total segments:     10
        Noise segments:     1 (10.0%)
        WPs per repr:       min = 10, median = 10, max = 10
        eps:                25 (coordinate units)
        min_lns:            3
        gamma:              1
        Coord type:         euclidean
        Method:             euclidean

