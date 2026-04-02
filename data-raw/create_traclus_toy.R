# data-raw/create_traclus_toy.R
#
# Reproduces data/traclus_toy.rda from the source CSV.
# Run this script manually to regenerate the dataset after modifying the CSV.
# This script is not sourced by the package (data-raw/ is in .Rbuildignore).
#
# Requires: usethis
# Run this script from the package root directory (open TRACLUS.Rproj in RStudio first).

traclus_toy <- read.csv("data-raw/traclus_toy.csv", stringsAsFactors = FALSE)

usethis::use_data(traclus_toy, overwrite = TRUE)
