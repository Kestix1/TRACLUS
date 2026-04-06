#' Validate eps parameter
#'
#' Checks that eps is a single positive finite numeric value.
#'
#' @param eps The eps value to validate.
#' @return `NULL` (invisible). Throws `stop()` on invalid input.
#' @keywords internal
.validate_eps <- function(eps) {
  if (!is.numeric(eps) || length(eps) != 1 || !is.finite(eps) || eps <= 0) {
    stop("'eps' must be a single positive numeric value.", call. = FALSE)
  }
  invisible(NULL)
}

#' Validate min_lns parameter
#'
#' Checks that min_lns is a single positive integer (>= 1).
#'
#' @param min_lns The min_lns value to validate.
#' @return `NULL` (invisible). Throws `stop()` on invalid input.
#' @keywords internal
.validate_min_lns <- function(min_lns) {
  if (!is.numeric(min_lns) || length(min_lns) != 1 || !is.finite(min_lns) ||
    min_lns < 1 || min_lns != as.integer(min_lns)) {
    stop("'min_lns' must be a positive integer (>= 1).", call. = FALSE)
  }
  invisible(NULL)
}

#' Validate gamma parameter
#'
#' Checks that gamma is a single positive finite numeric value.
#'
#' @param gamma The gamma value to validate.
#' @return `NULL` (invisible). Throws `stop()` on invalid input.
#' @keywords internal
.validate_gamma <- function(gamma) {
  if (!is.numeric(gamma) || length(gamma) != 1 || !is.finite(gamma) ||
    gamma <= 0) {
    stop("'gamma' must be a single positive numeric value.", call. = FALSE)
  }
  invisible(NULL)
}

#' Validate distance weight parameters
#'
#' Checks that w_perp, w_par, and w_angle are non-negative finite numeric
#' values.
#'
#' @param w_perp Weight for perpendicular distance.
#' @param w_par Weight for parallel distance.
#' @param w_angle Weight for angle distance.
#' @return `NULL` (invisible). Throws `stop()` on invalid input.
#' @keywords internal
.validate_weights <- function(w_perp, w_par, w_angle) {
  if (!is.numeric(w_perp) || length(w_perp) != 1 || !is.finite(w_perp) ||
    w_perp < 0) {
    stop("'w_perp' must be a single non-negative numeric value.", call. = FALSE)
  }
  if (!is.numeric(w_par) || length(w_par) != 1 || !is.finite(w_par) ||
    w_par < 0) {
    stop("'w_par' must be a single non-negative numeric value.", call. = FALSE)
  }
  if (!is.numeric(w_angle) || length(w_angle) != 1 || !is.finite(w_angle) ||
    w_angle < 0) {
    stop("'w_angle' must be a single non-negative numeric value.",
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' Validate S3 class of workflow objects
#'
#' Checks that the input object has the expected S3 class and throws an
#' informative error pointing the user to the correct function.
#'
#' @param x The object to check.
#' @param expected_class The expected S3 class name (character).
#' @param next_function The function that should have produced the object
#'   (character), used in the error message.
#' @return `NULL` (invisible). Throws `stop()` on class mismatch.
#' @keywords internal
.check_class <- function(x, expected_class, next_function) {
  if (!inherits(x, expected_class)) {
    stop(
      sprintf(
        "Expected a '%s' object. Run %s() first.",
        expected_class, next_function
      ),
      call. = FALSE
    )
  }
  invisible(NULL)
}
