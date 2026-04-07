#' Read HURDAT2 Best-Track data
#'
#' Parses NOAA National Hurricane Center's HURDAT2 (Hurricane Database 2)
#' format and returns a tidy data.frame ready for [tc_trajectories()].
#'
#' @param filepath Character path to a HURDAT2 text file.
#' @param min_points Integer minimum number of track points per storm
#'   (default 3). Storms with fewer observations are filtered out.
#'
#' @return A data.frame with columns:
#' \describe{
#'   \item{storm_id}{Character: storm identifier (e.g., "AL092004").}
#'   \item{lat}{Numeric: latitude in degrees (-90 to 90). South
#'     latitudes are negative.}
#'   \item{lon}{Numeric: longitude in degrees (-180 to 180). West
#'     longitudes are negative.}
#' }
#'
#' @details
#' The HURDAT2 format uses two types of lines:
#' \itemize{
#'   \item **Header lines**: Storm ID, name, and number of data entries.
#'   \item **Data lines**: Date, time, status, latitude (with N/S suffix),
#'     longitude (with E/W suffix), and meteorological data.
#' }
#'
#' West-longitudes (suffix "W") are converted to negative values and
#' East-longitudes (suffix "E") remain positive, following the package
#' convention of x = longitude (-180 to 180).
#'
#' The bundled file `hurdat2_1950_2004.txt` contains 826 Atlantic storms
#' from 1950 to 2004 (22,455 track points).
#'
#' The output is directly compatible with:
#' ```
#' tc_trajectories(data, traj_id = "storm_id",
#'                 x = "lon", y = "lat", coord_type = "geographic")
#' ```
#'
#' @family helper functions
#' @export
#'
#' @examples
#' # Read the bundled HURDAT2 dataset (Atlantic 1950-2004, 826 storms)
#' filepath <- system.file("extdata", "hurdat2_1950_2004.txt",
#'   package = "TRACLUS"
#' )
#' \donttest{
#' storms <- tc_read_hurdat2(filepath)
#' head(storms)
#' }
tc_read_hurdat2 <- function(filepath, min_points = 3L) {
  # --- Validate inputs ---
  if (!is.character(filepath) || length(filepath) != 1) {
    stop("'filepath' must be a single character string.", call. = FALSE)
  }
  if (!file.exists(filepath)) {
    stop(sprintf("File not found: %s", filepath), call. = FALSE)
  }
  if (!is.numeric(min_points) || length(min_points) != 1 ||
    !is.finite(min_points) || min_points < 1) {
    stop("'min_points' must be a positive integer >= 1.", call. = FALSE)
  }
  min_points <- as.integer(min_points)

  # --- Read all lines ---
  lines <- readLines(filepath, warn = FALSE)

  if (length(lines) == 0) {
    stop("File is empty or contains no valid lines.", call. = FALSE)
  }

  # --- Vectorised parse ---
  # Identify header lines: start with 2-letter basin code + digit
  is_header <- grepl("^[A-Z]{2}[0-9]", lines)

  if (!any(is_header)) {
    stop("No valid header lines found in file.", call. = FALSE)
  }

  # Extract storm IDs from header lines
  header_ids <- trimws(sub(",.*", "", lines[is_header]))

  # Map each line to its storm ID using cumulative sum of headers
  line_group <- cumsum(is_header)

  # Data lines: everything that is not a header and not empty
  data_mask <- !is_header & nchar(trimws(lines)) > 0
  data_groups <- line_group[data_mask]

  if (!any(data_mask)) {
    stop("No valid track points found in file.", call. = FALSE)
  }

  # Read data lines as fixed-width CSV: extract fields 5 (lat) and 6 (lon)
  # Use a fast regex approach: extract the 5th and 6th comma-separated fields
  data_lines <- lines[data_mask]

  # Regex to capture 5th and 6th fields from comma-separated line
  # Fields: date, time, record_id, status, lat, lon, ...
  coord_pattern <- "^[^,]*,[^,]*,[^,]*,[^,]*,\\s*([^,]+),\\s*([^,]+)"
  matches <- regmatches(data_lines, regexec(coord_pattern, data_lines))

  # Extract lat/lon strings
  has_match <- vapply(matches, length, integer(1)) == 3L
  lat_strs <- vapply(matches[has_match], `[`, character(1), 2L)
  lon_strs <- vapply(matches[has_match], `[`, character(1), 3L)
  data_groups <- data_groups[has_match]

  # Vectorised coordinate parsing
  lats <- .parse_hurdat2_coord_vec(lat_strs, "NS")
  lons <- .parse_hurdat2_coord_vec(lon_strs, "EW")

  # Remove NAs from failed coordinate parsing
  coord_valid <- !is.na(lats) & !is.na(lons)
  lats <- lats[coord_valid]
  lons <- lons[coord_valid]
  data_groups <- data_groups[coord_valid]

  if (length(lats) == 0) {
    stop("No valid track points found in file.", call. = FALSE)
  }

  # Map group indices to storm IDs
  storm_ids <- header_ids[data_groups]

  # --- Build data.frame (spec: storm_id, lat, lon) ---
  result <- data.frame(
    storm_id = storm_ids,
    lat = lats,
    lon = lons
  )

  # --- Filter storms with < min_points observations ---
  counts <- table(result$storm_id)
  keep <- names(counts[counts >= min_points])

  if (length(keep) == 0) {
    stop(sprintf(
      "No storms have >= %d track points. Try a lower 'min_points'.",
      min_points
    ), call. = FALSE)
  }

  n_removed <- length(counts) - length(keep)
  result <- result[result$storm_id %in% keep, ]
  rownames(result) <- NULL

  if (n_removed > 0) {
    message(sprintf(
      "Filtered %d storm(s) with < %d points.",
      n_removed, min_points
    ))
  }

  result
}


#' Parse a HURDAT2 coordinate string
#'
#' Converts strings like "27.6W" or "9.7N" to signed numeric values.
#' W and S are negative, E and N are positive.
#'
#' @param coord_str Character coordinate string with direction suffix.
#' @param directions Character of length 2: positive and negative
#'   direction letters (e.g., "NS" for latitude, "EW" for longitude).
#' @return Numeric coordinate value, or NA if parsing fails.
#' @keywords internal
.parse_hurdat2_coord <- function(coord_str, directions) {
  coord_str <- trimws(coord_str)
  if (nchar(coord_str) < 2) {
    return(NA_real_)
  }

  # Extract direction suffix (last character)
  dir_char <- substr(coord_str, nchar(coord_str), nchar(coord_str))
  num_str <- substr(coord_str, 1, nchar(coord_str) - 1)

  val <- suppressWarnings(as.numeric(num_str))
  if (is.na(val)) {
    return(NA_real_)
  }

  # Apply sign based on direction
  pos_dir <- substr(directions, 1, 1) # N or E
  neg_dir <- substr(directions, 2, 2) # S or W

  if (dir_char == neg_dir) {
    val <- -val
  } else if (dir_char != pos_dir) {
    return(NA_real_) # Unknown direction
  }

  val
}


#' Vectorised HURDAT2 coordinate parsing
#'
#' Converts a character vector of coordinate strings (e.g., "27.6W",
#' "9.7N") to signed numeric values. Vectorised for performance on
#' large files.
#'
#' @param coord_strs Character vector of coordinate strings.
#' @param directions Character of length 1: "NS" or "EW".
#' @return Numeric vector of coordinate values.
#' @keywords internal
.parse_hurdat2_coord_vec <- function(coord_strs, directions) {
  coord_strs <- trimws(coord_strs)
  n <- nchar(coord_strs)

  # Extract direction suffix and numeric part

  dir_chars <- substr(coord_strs, n, n)
  num_strs <- substr(coord_strs, 1, n - 1L)

  vals <- suppressWarnings(as.numeric(num_strs))

  pos_dir <- substr(directions, 1, 1)
  neg_dir <- substr(directions, 2, 2)

  # Apply sign: negative for S/W
  vals[dir_chars == neg_dir] <- -vals[dir_chars == neg_dir]
  # Invalid direction → NA
  vals[dir_chars != pos_dir & dir_chars != neg_dir] <- NA_real_
  # Too-short strings → NA
  vals[n < 2] <- NA_real_

  vals
}
