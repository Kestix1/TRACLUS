# Meters per degree of latitude (and per degree of longitude at the equator).
# Used in the equirectangular approximation for both projection and inverse.
.m_per_deg <- 111320

#' Local equirectangular projection to meters
#'
#' Projects geographic coordinates (lon/lat in degrees) to a local planar
#' coordinate system in meters using the equirectangular approximation:
#' x' = lon * cos(lat_mean) * .m_per_deg, y' = lat * .m_per_deg.
#' Accurate for typical TRACLUS cluster sizes (a few degrees).
#'
#' @param lon Numeric vector of longitudes in degrees.
#' @param lat Numeric vector of latitudes in degrees.
#' @param lat_mean Mean latitude (in degrees) for the cos correction.
#' @return A list with elements `x` and `y` (numeric vectors in meters).
#' @keywords internal
.equirectangular_proj <- function(lon, lat, lat_mean) {
  cos_lat <- cos(lat_mean * pi / 180)
  list(
    x = lon * cos_lat * .m_per_deg,
    y = lat * .m_per_deg
  )
}


#' Inverse equirectangular projection (meters to lon/lat)
#'
#' Converts local planar coordinates back to geographic coordinates.
#' Inverse of [.equirectangular_proj()].
#'
#' @param x Numeric vector of x-coordinates in meters.
#' @param y Numeric vector of y-coordinates in meters.
#' @param lat_mean Mean latitude (in degrees) used for the forward projection.
#' @return A list with elements `lon` and `lat` (numeric vectors in degrees).
#' @keywords internal
.equirectangular_inverse <- function(x, y, lat_mean) {
  cos_lat <- cos(lat_mean * pi / 180)
  list(
    lon = x / (cos_lat * .m_per_deg),
    lat = y / .m_per_deg
  )
}
