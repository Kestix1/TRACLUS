# Sweep-line representative trajectory generation

Internal functions implementing the sweep-line algorithm from Paper
Figure 15. The algorithm computes a representative trajectory for a
single cluster by:

1.  Computing the average direction vector (Paper Definition 11)

2.  Rotating coordinates so X'-axis aligns with average direction

3.  Normalizing segments (left_x \< right_x)

4.  Sweeping through entry/exit events, generating waypoints where
    segment density \>= min_lns and spacing \>= gamma

5.  Rotating waypoints back to original coordinate system
