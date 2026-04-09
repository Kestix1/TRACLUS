# TRACLUS: Trajectory Clustering Using Line Segments

Implements the TRACLUS (TRAjectory CLUStering) algorithm for
partitioning, clustering, and summarizing trajectory data. The algorithm
works in three phases: (1) partition trajectories into line segments
using minimum description length (MDL), (2) cluster segments using
density-based spatial clustering (DBSCAN), and (3) generate
representative trajectories using a sweep-line algorithm. Supports
euclidean, spherical (haversine), and equirectangular-projected distance
calculations.

## References

Lee, J.-G., Han, J., & Whang, K.-Y. (2007). Trajectory clustering: A
partition-and-group framework. In *Proceedings of the 2007 ACM SIGMOD
International Conference on Management of Data* (pp. 593–604).
[doi:10.1145/1247480.1247546](https://doi.org/10.1145/1247480.1247546)

## See also

Useful links:

- <https://github.com/MartinHoblisch/TRACLUS>

- <https://martinhoblisch.github.io/TRACLUS>

- Report bugs at <https://github.com/MartinHoblisch/TRACLUS/issues>

## Author

**Maintainer**: Martin Hoblisch <m.hoblisch@gmail.com>
