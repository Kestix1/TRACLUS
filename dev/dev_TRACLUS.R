devtools::load_all()
data <- read.csv2("C:/R/TRACLUS/dev/traclus_toy - Kopie.csv")
data <- tc_trajectories(data, traj_id = "traj_id",
                       x = "x", y = "y", coord_type = "euclidean")

tc_plot(data)
part1 <- tc_partition(data)
tc_plot(part1, )
clu1 <- tc_cluster(part1, eps = 20, min_lns = 2)
tc_plot(clu1)
rep1 <- tc_represent(clu1, gamma = 1)
tc_plot(rep1, )

rep1 <- data %>%
  tc_traclus(eps = 11, min_lns = 2, gamma = 1) %>%
  plot()

#### GPS

devtools::load_all()
data2 <- read.csv2("C:/R/TRACLUS/dev/traclus_toyGPS.csv")
data2 <- tc_trajectories(data2, traj_id = "traj_id",
                       x = "x", y = "y", coord_type = "geographic")
tc_plot(data2)
tc_leaflet(data2)
part2 <- tc_partition(data2)
tc_plot(part2)
tc_leaflet(part2, show_points = TRUE)
clu2 <- tc_cluster(part2, eps = 130, min_lns = 2)
tc_plot(clu2)
tc_leaflet(clu2)
rep2 <- tc_represent(clu2, gamma = 1)
tc_plot(rep2)
tc_leaflet(rep2, show_clusters = TRUE)

tc_plot(rep2, )

test <- tc_traclus(data2, eps = 130, min_lns = 2, gamma = 1, )
tc_leaflet(test, show_clusters = TRUE)

est2 <- tc_estimate_params(part2)
plot(est2)


########

# Read HURDAT2 Best-Track data (826 Atlantic storms, 1950-2004)
# Use min_points to select long-lived storms for a manageable subset
storms <- tc_read_hurdat2(
  system.file("extdata", "hurdat2_1950_2004.txt", package = "TRACLUS"),
  min_points = 20
)

trj <- tc_trajectories(storms, traj_id = "storm_id",
                       x = "lon", y = "lat", coord_type = "geographic", method = "projected")

tc_plot(trj)
tc_leaflet(trj)

part <- tc_partition(trj)
tc_plot(part)
tc_leaflet(part)

tc_estimate_params(part)

clu <- tc_cluster(part, eps = 100000, min_lns =5)
tc_plot(clu)
tc_leaflet(clu)

rep <- tc_represent(clu, gamma = 100000)
tc_plot(rep)
tc_leaflet(rep)
