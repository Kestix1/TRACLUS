#' Validate and prepare trajectory data
#'
#' `r lifecycle::badge("stable")`
#'
#' Validates input data, resolves coordinate types and distance methods, and
#' creates a `tc_trajectories` object for use in the TRACLUS pipeline. This is
#' the entry point for all TRACLUS analyses.
#'
#' @param data A `data.frame`, `tibble`, or `sf` object containing trajectory
#'   point data in tidy format (one row per point).
#' @param traj_id Character string naming the column that identifies
#'   trajectories. Values can be character, integer, or factor; they are stored
#'   internally as character.
#' @param x Character string naming the column with x-coordinates (longitude
#'   for geographic data). Required for `data.frame` input; ignored for `sf`
#'   input (extracted from geometry).
#' @param y Character string naming the column with y-coordinates (latitude
#'   for geographic data). Required for `data.frame` input; ignored for `sf`
#'   input (extracted from geometry).
#' @param coord_type Character string: `"euclidean"` or `"geographic"`.
#'   Required for `data.frame` input. For `sf` input, inferred from the CRS.
#'   Geographic data uses the convention x = longitude (-180 to 180),
#'   y = latitude (-90 to 90).
#' @param method Character string specifying the distance calculation method.
#'   Default `NULL` resolves to `"haversine"` for geographic data and
#'   `"euclidean"` for euclidean data. Options for `coord_type = "geographic"`:
#'   \describe{
#'     \item{`"haversine"`}{(default) Exact great-circle distances in meters.
#'       Most accurate, but slowest for large datasets.}
#'     \item{`"projected"`}{Equirectangular projection to meters, then
#'       euclidean distances. 5-10x faster than haversine with < 2\% error
#'       for regional datasets (e.g., hurricane basins, taxi data).
#'       Recommended for most geographic use cases.}
#'     \item{`"euclidean"`}{Raw degree values treated as cartesian coordinates.
#'       Only for paper replication mode.}
#'   }
#' @param verbose Logical; if `TRUE` (default), prints an informative summary
#'   after validation.
#'
#' @return A `tc_trajectories` S3 object (list) with elements:
#' \describe{
#'   \item{data}{`data.frame` with columns `traj_id` (character), `x`
#'     (numeric), `y` (numeric), ordered by trajectory.}
#'   \item{coord_type}{Resolved coordinate type (`"euclidean"` or
#'     `"geographic"`).}
#'   \item{method}{Resolved distance method (`"euclidean"`,
#'     `"haversine"`, or `"projected"`).}
#'   \item{n_trajectories}{Integer count of valid trajectories.}
#'   \item{n_points}{Integer total number of points.}
#' }
#'
#' @details
#' Validation is performed in four stages:
#' \enumerate{
#'   \item **Base checks**: Column existence, numeric and finite coordinates,
#'     plausibility warnings (e.g., swapped lon/lat).
#'   \item **Filtering** (in order): (a) Remove rows with non-finite x/y or
#'     NA traj_id. (b) Remove consecutive duplicate points within
#'     trajectories. (c) Remove trajectories with fewer than 2 points.
#'   \item **Warnings**: Report what was removed, truncating IDs to the first
#'     5 if many are affected.
#'   \item **Final check**: Error if fewer than 2 valid trajectories remain.
#' }
#'
#' **sf input requirements:**
#' \itemize{
#'   \item **Geometry type**: The sf object must contain `POINT` geometry.
#'     Other types (e.g., `LINESTRING`, `MULTIPOINT`) must be cast first:
#'     `sf::st_cast(data, "POINT")`.
#'   \item **CRS**: A coordinate reference system must be set on the object.
#'     If no CRS is present, assign one with
#'     `sf::st_set_crs(data, 4326)` (WGS-84) before calling
#'     `tc_trajectories()`.
#'   \item **Z/M dimensions**: Elevation (Z) or measure (M) coordinates are
#'     dropped automatically. Only X and Y are retained.
#' }
#'
#' @family workflow functions
#' @export
#'
#' @examples
#' # Euclidean example with built-in toy data
#' trj <- tc_trajectories(traclus_toy,
#'   traj_id = "traj_id",
#'   x = "x", y = "y", coord_type = "euclidean"
#' )
#' print(trj)
#'
#' # Geographic example
#' geo <- data.frame(
#'   id = rep(c("A", "B", "C"), each = 5),
#'   lon = c(-80, -78, -76, -74, -72, -82, -79, -76, -73, -70, -60, -58, -56, -54, -52),
#'   lat = c(25, 26, 27, 28, 29, 24, 25, 26, 27, 28, 30, 31, 32, 33, 34)
#' )
#' trj_geo <- tc_trajectories(geo,
#'   traj_id = "id", x = "lon", y = "lat",
#'   coord_type = "geographic"
#' )
#'
#' # sf input (coord_type inferred from CRS)
#' \donttest{
#' if (requireNamespace("sf", quietly = TRUE)) {
#'   geo_sf <- sf::st_as_sf(geo, coords = c("lon", "lat"), crs = 4326)
#'   trj_sf <- tc_trajectories(geo_sf, traj_id = "id")
#' }
#' }
tc_trajectories <- function(data, traj_id, x = NULL, y = NULL,
                            coord_type = NULL, method = NULL,
                            verbose = TRUE) {
  # --- Class check on data argument ---
  if (!inherits(data, "sf") && !is.data.frame(data)) {
    stop("'data' must be a data.frame, tibble, or sf object.", call. = FALSE)
  }

  # --- sf handling ---
  if (inherits(data, "sf")) {
    sf_result <- .handle_sf_input(data, traj_id, x, y, coord_type, method)
    data <- sf_result$data
    x <- sf_result$x
    y <- sf_result$y
    coord_type <- sf_result$coord_type
    method <- sf_result$method
  } else {
    # data.frame / tibble: x, y, coord_type are required
    if (is.null(x) || is.null(y) || is.null(coord_type)) {
      stop("x, y, and coord_type are required for data.frame input.",
        call. = FALSE
      )
    }
  }

  # --- Validate coord_type (before resolve_method) ---
  if (!is.character(coord_type) || length(coord_type) != 1 ||
    !coord_type %in% c("euclidean", "geographic")) {
    stop("'coord_type' must be 'euclidean' or 'geographic'.", call. = FALSE)
  }

  # --- Resolve method ---
  method <- .resolve_method(coord_type, method, verbose)

  # --- Column existence ---
  required_cols <- c(traj_id, x, y)
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop(sprintf(
      "Column(s) not found in data: %s",
      paste(missing_cols, collapse = ", ")
    ), call. = FALSE)
  }

  # Coerce to plain data.frame to avoid tibble issues
  data <- as.data.frame(data)

  # Extract and rename columns
  id_vals <- data[[traj_id]]
  x_vals <- data[[x]]
  y_vals <- data[[y]]

  # Convert traj_id to character
  id_vals <- as.character(id_vals)

  # --- Stage 1: Base checks ---
  if (!is.numeric(x_vals)) {
    stop(sprintf("Column '%s' must be numeric.", x), call. = FALSE)
  }
  if (!is.numeric(y_vals)) {
    stop(sprintf("Column '%s' must be numeric.", y), call. = FALSE)
  }

  # Plausibility warnings for geographic data
  if (coord_type == "geographic") {
    finite_x <- x_vals[is.finite(x_vals)]
    finite_y <- y_vals[is.finite(y_vals)]
    if (length(finite_x) > 0 && length(finite_y) > 0) {
      # Out of range warning
      if (any(finite_x < -180 | finite_x > 180)) {
        warning("Some x values are outside [-180, 180]. ",
          "For geographic data, x = longitude (-180 to 180).",
          call. = FALSE
        )
      }
      if (any(finite_y < -90 | finite_y > 90)) {
        warning("Some y values are outside [-90, 90]. ",
          "For geographic data, y = latitude (-90 to 90).",
          call. = FALSE
        )
      }
      # Swapped coordinate detection
      if (all(finite_x >= -90 & finite_x <= 90) &&
        any(finite_y < -90 | finite_y > 90)) {
        warning("It looks like x and y might be swapped. ",
          "For geographic data, x = longitude (-180 to 180) ",
          "and y = latitude (-90 to 90).",
          call. = FALSE
        )
      }
    }
  }

  if (coord_type == "euclidean") {
    finite_x <- x_vals[is.finite(x_vals)]
    finite_y <- y_vals[is.finite(y_vals)]
    if (length(finite_x) > 10 && length(finite_y) > 10) {
      # Only warn if values span a range typical for lon/lat coordinates
      # (not just small values that happen to fit in the range)
      x_range <- range(finite_x)
      y_range <- range(finite_y)
      x_span <- x_range[2] - x_range[1]
      y_span <- y_range[2] - y_range[1]
      looks_like_lon <- all(finite_x >= -180 & finite_x <= 180) && x_span > 1
      looks_like_lat <- all(finite_y >= -90 & finite_y <= 90) && y_span > 1
      # Require stronger evidence: values must span ranges typical for real
      # lon/lat data, not just small euclidean coordinates that happen to fit.
      # Real geographic data typically has negative values or values > 90 in x
      # (longitude), and y-range is bounded but not trivially small.
      has_negative_or_large <- any(finite_x < -10 | finite_x > 90) ||
        any(finite_y < -10 | finite_y > 60)
      if (looks_like_lon && looks_like_lat && has_negative_or_large) {
        warning("Coordinate values look like geographic data (lon/lat range). ",
          "Did you mean coord_type = 'geographic'?",
          call. = FALSE
        )
      }
    }
  }

  # Build internal data.frame
  df <- data.frame(
    traj_id = id_vals,
    x = x_vals,
    y = y_vals
  )

  # --- Stage 1b: Antimeridian check (before filtering) ---
  if (coord_type == "geographic" && nrow(df) > 0) {
    .check_antimeridian(df)
  }

  # --- Stage 2: Filtering ---

  # (a) Remove rows with non-finite x, y or NA traj_id
  bad_rows <- !is.finite(df$x) | !is.finite(df$y) | is.na(df$traj_id)
  n_nonfinite <- sum(bad_rows)
  if (n_nonfinite > 0) {
    df <- df[!bad_rows, , drop = FALSE]
  }

  # Group by traj_id preserving original order
  df <- .group_by_traj_id(df)

  # (b) Remove consecutive duplicates within trajectories
  dup_result <- .remove_consecutive_duplicates(df)
  df <- dup_result$data
  n_dups <- dup_result$n_removed

  # (c) Remove trajectories with < 2 points
  short_result <- .remove_short_trajectories(df, min_points = 2)
  df <- short_result$data
  removed_short_ids <- short_result$removed_ids

  # --- Stage 3: Warnings ---
  if (n_nonfinite > 0) {
    warning(sprintf(
      "Removed %d row(s) with non-finite coordinates or NA traj_id.",
      n_nonfinite
    ), call. = FALSE)
  }
  if (n_dups > 0) {
    warning(sprintf("Removed %d consecutive duplicate point(s).", n_dups),
      call. = FALSE
    )
  }
  if (length(removed_short_ids) > 0) {
    id_msg <- .truncate_ids(removed_short_ids, max_show = 5)
    warning(sprintf(
      "Removed %d trajectory(ies) with < 2 points: %s",
      length(removed_short_ids), id_msg
    ), call. = FALSE)
  }

  # --- Stage 4: Final check ---
  unique_ids <- unique(df$traj_id)
  if (length(unique_ids) < 2) {
    stop("Fewer than 2 valid trajectories remain after filtering. ",
      "TRACLUS requires multiple trajectories for clustering.",
      call. = FALSE
    )
  }

  # Reset row names
  rownames(df) <- NULL

  # --- Compute projection parameters for method = "projected" ---
  proj_params <- NULL
  if (method == "projected") {
    proj_params <- list(
      lat_mean = mean(df$y, na.rm = TRUE),
      lon_mean = mean(df$x, na.rm = TRUE)
    )
  }

  # --- Construct S3 object ---
  result <- .new_tc_trajectories(
    data = df,
    coord_type = coord_type,
    method = method,
    proj_params = proj_params
  )

  if (verbose) {
    message(sprintf(
      "Loaded %d trajectories (%d points).",
      result$n_trajectories, result$n_points
    ))
  }

  result
}


# ============================================================================
# S3 constructor
# ============================================================================

#' Construct a tc_trajectories object
#'
#' Low-level constructor that assembles the S3 list. No validation is
#' performed — use [tc_trajectories()] for the validated public API.
#'
#' @param data data.frame with columns traj_id, x, y.
#' @param coord_type Character: "euclidean" or "geographic".
#' @param method Character: "euclidean", "haversine", or "projected".
#' @param proj_params Optional list with lat_mean and lon_mean for
#'   method = "projected". NULL for other methods.
#' @return A tc_trajectories S3 object.
#' @keywords internal
.new_tc_trajectories <- function(data, coord_type, method,
                                 proj_params = NULL) {
  obj <- list(
    data = data,
    coord_type = coord_type,
    method = method,
    n_trajectories = length(unique(data$traj_id)),
    n_points = nrow(data)
  )
  if (!is.null(proj_params)) {
    obj$proj_params <- proj_params
  }
  structure(obj, class = "tc_trajectories")
}


# ============================================================================
# Internal helpers
# ============================================================================

#' Resolve the distance method from coord_type and user input
#' @param coord_type Character: "euclidean" or "geographic".
#' @param method Character or NULL.
#' @param verbose Logical.
#' @return Resolved method string.
#' @keywords internal
.resolve_method <- function(coord_type, method, verbose) {
  if (coord_type == "euclidean") {
    if (!is.null(method) && method %in% c("haversine", "projected")) {
      stop(
        sprintf(
          "method = '%s' is not compatible with coord_type = 'euclidean'. ",
          method
        ),
        "Haversine and projected require geographic coordinates.",
        call. = FALSE
      )
    }
    return("euclidean")
  }

  if (coord_type == "geographic") {
    if (is.null(method)) {
      return("haversine")
    }
    if (method == "euclidean") {
      # Paper replication mode — always inform user
      message(
        "Using euclidean distances on geographic coordinates ",
        "(paper replication mode)."
      )
      return("euclidean")
    }
    if (method == "haversine") {
      return("haversine")
    }
    if (method == "projected") {
      return("projected")
    }
    stop("'method' must be 'euclidean', 'haversine', or 'projected'.",
      call. = FALSE
    )
  }

  stop("'coord_type' must be 'euclidean' or 'geographic'.", call. = FALSE)
}

#' Handle sf input: extract coordinates, infer coord_type
#' @param data sf object.
#' @param traj_id Column name for trajectory ID.
#' @param x,y,coord_type,method User-provided values (may be NULL).
#' @return List with data (data.frame), x, y, coord_type, method.
#' @keywords internal
.handle_sf_input <- function(data, traj_id, x, y, coord_type, method) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Package 'sf' is required to process sf objects. ",
      "Install it with install.packages('sf').",
      call. = FALSE
    )
  }

  # Geometry must be POINT
  geom_type <- unique(as.character(sf::st_geometry_type(data)))
  point_types <- c("POINT", "POINT Z", "POINT M", "POINT ZM")
  if (!all(geom_type %in% point_types)) {
    stop("sf input must have POINT geometry. ",
      "Use sf::st_cast('POINT') to convert LINESTRING geometry.",
      call. = FALSE
    )
  }

  # CRS must be present
  crs <- sf::st_crs(data)
  if (is.na(crs)) {
    stop("sf object must have a valid CRS. ",
      "Set one with sf::st_set_crs().",
      call. = FALSE
    )
  }

  # Determine coord_type from CRS
  sf_is_longlat <- sf::st_is_longlat(data)
  sf_coord_type <- if (isTRUE(sf_is_longlat)) "geographic" else "euclidean"

  # Check consistency if user provided coord_type
  if (!is.null(coord_type) && coord_type != sf_coord_type) {
    warning(sprintf(
      "Specified coord_type = '%s' conflicts with sf CRS (detected '%s'). Using '%s'.",
      coord_type, sf_coord_type, sf_coord_type
    ), call. = FALSE)
  }
  coord_type <- sf_coord_type

  # Extract coordinates
  coords <- sf::st_coordinates(data)

  # Check for Z/M dimensions and warn
  if (ncol(coords) > 2) {
    message("Dropping Z/M dimensions from sf geometry (only X and Y are used).")
  }

  # Build output data.frame
  df <- as.data.frame(data)
  # Remove geometry column
  df <- df[, !vapply(df, inherits, logical(1), "sfc"), drop = FALSE]
  df$.tc_x <- coords[, 1]
  df$.tc_y <- coords[, 2]

  # Check consistency if user provided x/y
  if (!is.null(x) && x %in% names(df)) {
    if (!all(df[[x]] == df$.tc_x, na.rm = TRUE)) {
      warning("Specified 'x' column differs from sf geometry x-coordinates. ",
        "Using coordinates from geometry.",
        call. = FALSE
      )
    }
  }
  if (!is.null(y) && y %in% names(df)) {
    if (!all(df[[y]] == df$.tc_y, na.rm = TRUE)) {
      warning("Specified 'y' column differs from sf geometry y-coordinates. ",
        "Using coordinates from geometry.",
        call. = FALSE
      )
    }
  }

  list(
    data = df,
    x = ".tc_x",
    y = ".tc_y",
    coord_type = coord_type,
    method = method
  )
}

#' Group data by traj_id preserving original point order within groups
#' @param df data.frame with traj_id column.
#' @return data.frame reordered by traj_id groups.
#' @keywords internal
.group_by_traj_id <- function(df) {
  if (nrow(df) == 0) {
    return(df)
  }
  # Preserve first-appearance order of traj_ids
  unique_ids <- unique(df$traj_id)
  id_order <- match(df$traj_id, unique_ids)
  # Stable sort: within same traj_id, original row order is preserved
  df[order(id_order), , drop = FALSE]
}

#' Remove consecutive duplicate points within each trajectory
#' @param df data.frame with columns traj_id, x, y.
#' @return List with data (filtered df) and n_removed (integer).
#' @keywords internal
.remove_consecutive_duplicates <- function(df) {
  if (nrow(df) <= 1) {
    return(list(data = df, n_removed = 0L))
  }

  # A point is a consecutive duplicate if it has the same traj_id, x, y
  # as the previous row
  same_id <- df$traj_id[-1] == df$traj_id[-nrow(df)]
  same_x <- df$x[-1] == df$x[-nrow(df)]
  same_y <- df$y[-1] == df$y[-nrow(df)]

  is_dup <- c(FALSE, same_id & same_x & same_y)
  n_removed <- sum(is_dup)

  list(
    data = df[!is_dup, , drop = FALSE],
    n_removed = n_removed
  )
}

#' Remove trajectories with fewer than min_points points
#' @param df data.frame with traj_id column.
#' @param min_points Minimum number of points required.
#' @return List with data (filtered df) and removed_ids (character vector).
#' @keywords internal
.remove_short_trajectories <- function(df, min_points = 2) {
  if (nrow(df) == 0) {
    return(list(data = df, removed_ids = character(0)))
  }

  counts <- table(df$traj_id)
  short_ids <- names(counts[counts < min_points])

  if (length(short_ids) == 0) {
    return(list(data = df, removed_ids = character(0)))
  }

  list(
    data = df[!df$traj_id %in% short_ids, , drop = FALSE],
    removed_ids = short_ids
  )
}

#' Check for antimeridian crossing and warn
#' @param df data.frame with traj_id and x columns.
#' @return NULL (invisible). May issue a warning.
#' @keywords internal
.check_antimeridian <- function(df) {
  if (nrow(df) < 2) {
    return(invisible(NULL))
  }

  # Check within each trajectory for consecutive lon difference > 180
  same_traj <- df$traj_id[-1] == df$traj_id[-nrow(df)]
  lon_diff <- abs(df$x[-1] - df$x[-nrow(df)])
  crossing <- same_traj & lon_diff > 180

  if (any(crossing)) {
    crossing_idx <- which(crossing)
    crossing_ids <- unique(df$traj_id[crossing_idx])
    id_msg <- .truncate_ids(crossing_ids, max_show = 5)
    warning(
      sprintf(
        "Trajectory %s appears to cross the antimeridian. ",
        id_msg
      ), "See vignette('TRACLUS-spherical-geometry') for details.",
      call. = FALSE
    )
  }

  invisible(NULL)
}

#' Truncate a vector of IDs for display in warnings
#' @param ids Character vector of IDs.
#' @param max_show Maximum number to show before truncating.
#' @return Formatted string.
#' @keywords internal
.truncate_ids <- function(ids, max_show = 5) {
  if (length(ids) <= max_show) {
    paste(ids, collapse = ", ")
  } else {
    paste0(
      paste(ids[seq_len(max_show)], collapse = ", "),
      sprintf(" (and %d more)", length(ids) - max_show)
    )
  }
}
