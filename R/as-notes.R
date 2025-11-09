#' Convert data to a standardized notes tibble
#'
#' `as_notes()` converts an arbitrary data frame or a `ggplot` object into
#' a tibble containing the required columns for MIDI sonification:
#' `x`, `y`, `channel`, `group`, `duration`, and `velocity`.
#'
#' @param d A data frame or a `ggplot2` object.
#'   When a `ggplot2` object is given, the layer data is extracted using
#'   [ggplot2::get_layer_data()] with the layer index specified by `.id`.
#' @param ... Optional name mappings.
#'   Provide named arguments to override the default column names
#'   (e.g., `as_notes(d, duration = "fill")` will use `fill` as the duration column).
#' @param .id Layer index to extract from a ggplot object. Defaults to `1`.
#'
#' @returns A tibble with columns:
#'   - `x`, `y` – coordinate-like values to be mapped to time and pitch
#'   - `channel` – grouping for MIDI channels
#'   - `group` – sub-group within each channel
#'   - `duration`, `velocity` – numeric modifiers for note length and intensity
#'
#' @details
#' The returned tibble serves as the standard 'notes' format accepted by [sonify()].
#' Numeric or logical columns are converted to numeric and missing values are replaced with `1`.
#'
#' @export
as_notes <- function(d, ...) {
  UseMethod("as_notes")
}

#' @rdname as_notes
#' @export
as_notes.default <- function(d, ...) {
  d <- as.data.frame(d)
  dots <- rlang::list2(...)
  # nolint start
  out <-
    # NOTE: this way cannot map a single column to multiple variables.
    select(
      d,
      all_of(c(
        dots[["x"]] %||% "x",
        dots[["y"]] %||% "y",
        dots[["channel"]] %||% "PANEL",
        dots[["group"]] %||% "group",
        dots[["velocity"]] %||% "size",
        dots[["duration"]] %||% "alpha"
      ))
    ) |>
    rename_with(~ c("x", "y", "channel", "group", "velocity", "duration")) |>
    mutate(
      across(
        where(~ is.numeric(.) || is.logical(.)),
        ~ if_else(is.na(.), 1, .)
      )
    )
  as_tibble(out)
  # nolint end
}

#' @rdname as_notes
#' @export
as_notes.ggplot <- function(d, ..., .id = 1) {
  d <- ggplot2::get_layer_data(d, i = .id)
  NextMethod(d, ...)
}
