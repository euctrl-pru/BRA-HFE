#' Utility functions to cast lat/lon data frame/tibble to sf-points and/or linestring
#'
#' Harmonized helper functions to work with different trajectory data sources
#' (ADS-B, radar surveillance, etc.)
#'
#' @name sf_latlon_helpers
#' @return utility functions
NULL

#' Cast lat/lon dataframe to sf POINT geometry
#'
#' @rdname sf_latlon_helpers
#'
#' @param .df dataframe/tibble of lat/lon positions
#' @param lon_col name of longitude column (default: "LON")
#' @param lat_col name of latitude column (default: "LAT")
#' @param .crs coordinate reference system (default: 4326 := WGS84)
#' @param .drop_coord remove (or keep) lat/lon columns (default: TRUE := remove, FALSE := keep)
#'
#' @return pts_sf a POINT sf-object
#' @export
#'
#' @examples
#' \dontrun{
#' # ADS-B data with LON/LAT columns
#' cast_latlon_to_pts(adsb_df)
#'
#' # Brazil radar data with longitude/latitude columns
#' cast_latlon_to_pts(radar_df, lon_col = "longitude", lat_col = "latitude")
#' }
cast_latlon_to_pts <- function(.df, lon_col = "LON", lat_col = "LAT",
                                .crs = 4326, .drop_coord = TRUE) {
  pts_sf <- .df |>
    sf::st_as_sf(coords = c(lon_col, lat_col), crs = .crs, remove = .drop_coord)
  return(pts_sf)
}

#' Cast sf POINT geometry to LINESTRING
#'
#' @rdname sf_latlon_helpers
#'
#' @param .pts_sf sf object with POINT geometry
#' @param .group_var optional grouping variable (e.g., flight ID, trajectory ID)
#'                   If NULL, creates single linestring from all points
#'
#' @return ls_sf a LINESTRING sf-object
#' @export
#'
#' @examples
#' \dontrun{
#' # Single trajectory
#' pts_sf |> cast_pts_to_ls()
#'
#' # Multiple trajectories grouped by flight ID
#' pts_sf |> cast_pts_to_ls(.group_var = fid)
#' }
cast_pts_to_ls <- function(.pts_sf, .group_var = NULL) {
  if (is.null(.group_var)) {
    ls_sf <- .pts_sf |>
      dplyr::summarise(do_union = FALSE, .groups = "drop") |>
      sf::st_cast("LINESTRING")
  } else {
    ls_sf <- .pts_sf |>
      dplyr::group_by({{ .group_var }}) |>
      dplyr::summarise(do_union = FALSE, .groups = "drop") |>
      sf::st_cast("LINESTRING")
  }
  return(ls_sf)
}

#' Cast lat/lon dataframe directly to LINESTRING (convenience wrapper)
#'
#' @rdname sf_latlon_helpers
#'
#' @param .group_var optional grouping variable for multiple trajectories
#'
#' @return ls_sf a LINESTRING sf-object
#' @export
#'
#' @examples
#' \dontrun{
#' cast_latlon_to_ls(radar_df, lon_col = "longitude", lat_col = "latitude",
#'                   .group_var = fid)
#' }
cast_latlon_to_ls <- function(.df, lon_col = "LON", lat_col = "LAT",
                               .crs = 4326, .drop_coord = TRUE,
                               .group_var = NULL) {
  pts_sf <- cast_latlon_to_pts(.df, lon_col, lat_col, .crs, .drop_coord)
  ls_sf  <- cast_pts_to_ls(pts_sf, .group_var = {{ .group_var }})
  return(ls_sf)
}

#' Cast sf POINT geometry back to lat/lon columns
#'
#' @rdname sf_latlon_helpers
#'
#' @param .df_pts dataframe with sf POINT geometry
#' @param lon_col name for longitude output column (default: "LON")
#' @param lat_col name for latitude output column (default: "LAT")
#' @param .drop_geometry flag whether to drop geometry (default: TRUE)
#'
#' @return df with LAT/LON coordinates
#' @export
#'
#' @examples
#' \dontrun{
#' pts_sf |> cast_pts_to_latlon()
#' pts_sf |> cast_pts_to_latlon(lon_col = "longitude", lat_col = "latitude")
#' }
cast_pts_to_latlon <- function(.df_pts, lon_col = "LON", lat_col = "LAT",
                                .drop_geometry = TRUE) {
  coords <- sf::st_coordinates(.df_pts)

  df <- .df_pts |>
    dplyr::mutate(
      !!lon_col := coords[, 1],
      !!lat_col := coords[, 2]
    )

  if (isTRUE(.drop_geometry)) {
    df <- df |> sf::st_drop_geometry()
  }

  return(df)
}
