#' Leaflet map for TRACLUS objects
#'
#' Creates interactive Leaflet maps for geographic TRACLUS data.
#' Only available when `coord_type = "geographic"` — euclidean data
#' will produce an error. Requires the `leaflet` package.
#'
#' @param x A TRACLUS workflow object with `coord_type = "geographic"`.
#' @param ... Additional arguments (method-specific, see individual methods).
#'
#' @return A `leaflet` htmlwidget object (can be further customized
#'   via piping, e.g., `tc_leaflet(x) |> leaflet::setView(...)`).
#'
#' @examples
#' \donttest{
#' if (requireNamespace("leaflet", quietly = TRUE)) {
#'   storms <- tc_read_hurdat2(
#'     system.file("extdata", "hurdat2_1950_2004.txt", package = "TRACLUS"),
#'     min_points = 80
#'   )
#'   trj <- tc_trajectories(storms, traj_id = "storm_id",
#'                          x = "lon", y = "lat", coord_type = "geographic")
#'   tc_leaflet(trj)
#' }
#' }
#'
#' @name tc_leaflet
#' @family workflow functions
#' @export
tc_leaflet <- function(x, ...) {
  UseMethod("tc_leaflet")
}


# ============================================================================
# Internal helpers
# ============================================================================

# Validate geographic data and check leaflet availability
.leaflet_check <- function(x) {
  if (x$coord_type != "geographic") {
    stop("tc_leaflet() is only available for geographic data ",
         "(coord_type = 'geographic'). Use plot() for euclidean data.",
         call. = FALSE)
  }
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    stop("Package 'leaflet' is required for interactive maps. ",
         "Install it with install.packages('leaflet').",
         call. = FALSE)
  }
}

# Create base leaflet map with 3 tile layers
.leaflet_base <- function() {
  m <- leaflet::leaflet()
  m <- leaflet::addProviderTiles(m, "CartoDB.Positron", group = "CartoDB Positron")
  m <- leaflet::addProviderTiles(m, "OpenStreetMap", group = "OpenStreetMap")
  m <- leaflet::addProviderTiles(m, "Esri.WorldImagery", group = "Esri World Imagery")
  m <- leaflet::addLayersControl(
    m,
    baseGroups = c("CartoDB Positron", "OpenStreetMap", "Esri World Imagery"),
    options = leaflet::layersControlOptions(collapsed = TRUE)
  )
  m
}


# ============================================================================
# tc_leaflet.tc_trajectories
# ============================================================================

#' @rdname tc_leaflet
#' @export
tc_leaflet.tc_trajectories <- function(x, ...) {
  .leaflet_check(x)

  data <- x$data
  traj_ids <- unique(data$traj_id)
  n_trajs <- length(traj_ids)
  cols <- viridisLite::viridis(n_trajs)
  col_map <- stats::setNames(cols, traj_ids)

  m <- .leaflet_base()

  for (tid in traj_ids) {
    idx <- data$traj_id == tid
    col <- unname(col_map[tid])
    m <- leaflet::addPolylines(
      m,
      lng = data$x[idx], lat = data$y[idx],
      color = col, weight = 2, opacity = 0.8,
      label = tid,
      group = "Trajectories"
    )
    m <- leaflet::addCircleMarkers(
      m,
      lng = data$x[idx], lat = data$y[idx],
      radius = 3, color = col, fillColor = col,
      fillOpacity = 0.8, opacity = 0.8, weight = 1,
      label = tid,
      group = "Points"
    )
  }

  # Legend (suppress for >10 trajectories)
  if (n_trajs <= 10) {
    m <- leaflet::addLegend(
      m, position = "bottomright",
      colors = cols,
      labels = as.character(traj_ids),
      opacity = 0.8
    )
  }

  m
}


# ============================================================================
# tc_leaflet.tc_partitions
# ============================================================================

#' @rdname tc_leaflet
#' @param show_points Logical; if `TRUE` (default for `tc_partitions`),
#'   characteristic points are drawn as black cross markers at segment
#'   endpoints (matching the base `plot()` style).
#' @export
tc_leaflet.tc_partitions <- function(x, show_points = TRUE, ...) {
  .leaflet_check(x)

  segs <- x$segments
  traj_ids <- unique(segs$traj_id)
  n_trajs <- length(traj_ids)
  cols <- viridisLite::viridis(n_trajs)
  col_map <- stats::setNames(cols, traj_ids)

  m <- .leaflet_base()

  for (i in seq_len(nrow(segs))) {
    lbl <- sprintf("%s, Seg %d", segs$traj_id[i], segs$seg_id[i])
    m <- leaflet::addPolylines(
      m,
      lng = c(segs$sx[i], segs$ex[i]),
      lat = c(segs$sy[i], segs$ey[i]),
      color = unname(col_map[segs$traj_id[i]]), weight = 2, opacity = 0.8,
      label = lbl,
      group = "Segments"
    )
  }

  # Legend (suppress for >10 trajectories)
  if (n_trajs <= 10) {
    m <- leaflet::addLegend(
      m, position = "bottomright",
      colors = cols,
      labels = as.character(traj_ids),
      opacity = 0.8
    )
  }

  # Characteristic points at segment endpoints (black cross, matching base plot pch=4)
  if (show_points) {
    all_lng <- c(segs$sx, segs$ex)
    all_lat <- c(segs$sy, segs$ey)
    cross_label <- "\u2715"  # multiplication sign (X shape)
    m <- leaflet::addLabelOnlyMarkers(
      m,
      lng = all_lng, lat = all_lat,
      label = cross_label,
      labelOptions = leaflet::labelOptions(
        noHide = TRUE,
        textOnly = TRUE,
        style = list(
          "color" = "black",
          "font-size" = "14px",
          "font-weight" = "bold",
          "text-shadow" = "none"
        ),
        direction = "center"
      ),
      group = "Characteristic Points"
    )
  }

  m
}


# ============================================================================
# tc_leaflet.tc_clusters
# ============================================================================

#' @rdname tc_leaflet
#' @export
tc_leaflet.tc_clusters <- function(x, ...) {
  .leaflet_check(x)

  segs <- x$segments
  m <- .leaflet_base()

  # Noise segments
  noise <- is.na(segs$cluster_id)
  if (any(noise)) {
    for (i in which(noise)) {
      m <- leaflet::addPolylines(
        m,
        lng = c(segs$sx[i], segs$ex[i]),
        lat = c(segs$sy[i], segs$ey[i]),
        color = "#666666", weight = 1, opacity = 0.6, dashArray = "5,5",
        label = sprintf("Noise, %s", segs$traj_id[i]),
        group = "Noise"
      )
    }
  }

  # Clustered segments
  if (x$n_clusters > 0) {
    cluster_ids <- sort(unique(segs$cluster_id[!noise]))
    cols <- viridisLite::viridis(length(cluster_ids))
    col_map <- stats::setNames(cols, as.character(cluster_ids))

    for (i in which(!noise)) {
      cid <- segs$cluster_id[i]
      lbl <- sprintf("Cluster %d, %s", cid, segs$traj_id[i])
      m <- leaflet::addPolylines(
        m,
        lng = c(segs$sx[i], segs$ex[i]),
        lat = c(segs$sy[i], segs$ey[i]),
        color = unname(col_map[as.character(cid)]), weight = 2, opacity = 0.8,
        label = lbl,
        group = sprintf("Cluster %d", cid)
      )
    }

    # Legend (suppress for >10 clusters)
    if (length(cluster_ids) <= 10) {
      leg_colors <- cols
      leg_labels <- paste("Cluster", cluster_ids)
      if (any(noise)) {
        leg_colors <- c(leg_colors, "#666666")
        leg_labels <- c(leg_labels, "Noise")
      }
      m <- leaflet::addLegend(
        m, position = "bottomright",
        colors = leg_colors,
        labels = leg_labels,
        opacity = 0.8
      )
    } else {
      message("Legend suppressed (>10 clusters). ",
              "Use summary() to see cluster details.")
    }
  }

  m
}


# ============================================================================
# tc_leaflet.tc_representatives
# ============================================================================

#' @rdname tc_leaflet
#' @param show_clusters Logical; if `FALSE` (default), cluster member segments
#'   are drawn in grey and only representatives are highlighted in colour.
#'   If `TRUE`, cluster segments are drawn in full colour.
#'   See [plot.tc_representatives()] for details.
#' @export
tc_leaflet.tc_representatives <- function(x, show_clusters = FALSE,
                                           ...) {
  .leaflet_check(x)

  segs <- x$segments
  repr <- x$representatives
  m <- .leaflet_base()

  # --- Noise segments (includes cleanup-degraded segments) ---
  orig_ids <- x$clusters$segments$cluster_id
  curr_ids <- segs$cluster_id
  noise <- is.na(curr_ids)

  if (any(noise)) {
    for (i in which(noise)) {
      m <- leaflet::addPolylines(
        m,
        lng = c(segs$sx[i], segs$ex[i]),
        lat = c(segs$sy[i], segs$ey[i]),
        color = "#666666", weight = 1, opacity = 0.6, dashArray = "5,5",
        label = sprintf("Noise, %s", segs$traj_id[i]),
        group = "Noise"
      )
    }
  }

  if (x$n_clusters == 0) return(m)

  cluster_ids <- sort(unique(repr$cluster_id))
  n_cl <- length(cluster_ids)

  # Colour consistency: use the same palette as tc_cluster() by generating
  # colours based on the original (pre-cleanup) cluster count, then subsetting.
  orig_n_clusters <- x$clusters$n_clusters
  orig_cols <- viridisLite::viridis(orig_n_clusters)
  orig_cluster_ids <- sort(unique(
    x$clusters$segments$cluster_id[!is.na(x$clusters$segments$cluster_id)]
  ))
  orig_col_map <- stats::setNames(orig_cols, as.character(orig_cluster_ids))
  # Find which original IDs survived cleanup
  surviving_orig_ids <- integer(0)
  for (cid in cluster_ids) {
    seg_idx <- which(segs$cluster_id == cid & !is.na(segs$cluster_id))[1]
    if (!is.na(seg_idx)) {
      orig_cid <- orig_ids[seg_idx]
      surviving_orig_ids <- c(surviving_orig_ids, orig_cid)
    }
  }
  cols <- unname(orig_col_map[as.character(surviving_orig_ids)])
  col_map <- stats::setNames(cols, as.character(cluster_ids))

  # Cluster summary for labels
  cl_summary <- x$clusters$cluster_summary

  if (!show_clusters) {
    # Active cluster segments in grey
    clustered <- !is.na(curr_ids)
    if (any(clustered)) {
      for (i in which(clustered)) {
        cid <- segs$cluster_id[i]
        m <- leaflet::addPolylines(
          m,
          lng = c(segs$sx[i], segs$ex[i]),
          lat = c(segs$sy[i], segs$ey[i]),
          color = "#B3B3B3", weight = 1, opacity = 0.8,
          label = sprintf("Cluster %d, %s", cid, segs$traj_id[i]),
          group = "Segments"
        )
      }
    }
  } else {
    # Active cluster segments in colour
    for (i in which(!is.na(curr_ids))) {
      cid <- segs$cluster_id[i]
      m <- leaflet::addPolylines(
        m,
        lng = c(segs$sx[i], segs$ex[i]),
        lat = c(segs$sy[i], segs$ey[i]),
        color = unname(col_map[as.character(cid)]), weight = 1.5, opacity = 0.7,
        label = sprintf("Cluster %d, %s", cid, segs$traj_id[i]),
        group = sprintf("Cluster %d", cid)
      )
    }
  }

  # Representatives: black outline + colour
  for (cid in cluster_ids) {
    pts <- repr[repr$cluster_id == cid, ]
    col <- unname(col_map[as.character(cid)])

    # Look up segment count for label
    n_segs_in_cluster <- sum(segs$cluster_id == cid, na.rm = TRUE)
    lbl <- sprintf("Representative %d (%d segments)", cid, n_segs_in_cluster)

    # Black outline
    m <- leaflet::addPolylines(
      m,
      lng = pts$rx, lat = pts$ry,
      color = "black", weight = 5, opacity = 0.9,
      label = lbl,
      group = "Representatives"
    )
    # Coloured line on top
    m <- leaflet::addPolylines(
      m,
      lng = pts$rx, lat = pts$ry,
      color = col, weight = 3, opacity = 0.9,
      label = lbl,
      group = "Representatives"
    )
  }

  # Legend (suppress for >10 clusters)
  if (n_cl <= 10) {
    leg_colors <- cols
    leg_labels <- paste("Representative", cluster_ids)
    if (any(noise)) {
      leg_colors <- c(leg_colors, "#666666")
      leg_labels <- c(leg_labels, "Noise")
    }
    m <- leaflet::addLegend(
      m, position = "bottomright",
      colors = leg_colors,
      labels = leg_labels,
      opacity = 0.8
    )
  } else {
    message("Legend suppressed (>10 clusters). ",
            "Use summary() to see cluster details.")
  }

  m
}


# ============================================================================
# tc_leaflet.tc_traclus
# ============================================================================

#' @rdname tc_leaflet
#' @export
tc_leaflet.tc_traclus <- function(x, ...) {
  NextMethod()
}
