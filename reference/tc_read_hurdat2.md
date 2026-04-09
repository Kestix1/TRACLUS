# Read HURDAT2 Best-Track data

**\[stable\]**

## Usage

``` r
tc_read_hurdat2(filepath, min_points = 3L)
```

## Arguments

- filepath:

  Character path to a HURDAT2 text file.

- min_points:

  Integer minimum number of track points per storm (default 3). Storms
  with fewer observations are filtered out.

## Value

A data.frame with columns:

- storm_id:

  Character: storm identifier (e.g., "AL092004").

- lat:

  Numeric: latitude in degrees (-90 to 90). South latitudes are
  negative.

- lon:

  Numeric: longitude in degrees (-180 to 180). West longitudes are
  negative.

## Details

Parses NOAA National Hurricane Center's HURDAT2 (Hurricane Database 2)
format and returns a tidy data.frame ready for
[`tc_trajectories()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_trajectories.md).

The HURDAT2 format uses two types of lines:

- **Header lines**: Storm ID, name, and number of data entries.

- **Data lines**: Date, time, status, latitude (with N/S suffix),
  longitude (with E/W suffix), and meteorological data.

West-longitudes (suffix "W") are converted to negative values and
East-longitudes (suffix "E") remain positive, following the package
convention of x = longitude (-180 to 180).

The bundled file `hurdat2_1950_2004.txt` contains 826 Atlantic storms
from 1950 to 2004 (22,455 track points).

The output is directly compatible with:

    tc_trajectories(data, traj_id = "storm_id",
                    x = "lon", y = "lat", coord_type = "geographic")

## See also

Other helper functions:
[`tc_estimate_params()`](https://martinhoblisch.github.io/TRACLUS/reference/tc_estimate_params.md)

## Examples

``` r
# Read the bundled HURDAT2 dataset (Atlantic 1950-2004, 826 storms)
filepath <- system.file("extdata", "hurdat2_1950_2004.txt",
  package = "TRACLUS"
)
# \donttest{
storms <- tc_read_hurdat2(filepath)
#> Filtered 1 storm(s) with < 3 points.
head(storms)
#>   storm_id  lat   lon
#> 1 AL011950 17.1 -55.5
#> 2 AL011950 17.7 -56.3
#> 3 AL011950 18.2 -57.4
#> 4 AL011950 19.0 -58.6
#> 5 AL011950 20.0 -60.0
#> 6 AL011950 20.7 -61.1
# }
```
