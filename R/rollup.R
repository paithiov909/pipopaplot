#' Aggregate or transform note data before sonification
#'
#' `rollup()` provides a simple mechanism to summarize or reshape
#' note-level data prior to sonification.
#' By default, it performs numeric aggregation within each
#' `(channel, group, by)` combination.
#'
#' @param d A data frame returned by [as_notes()].
#' @param by A variable or expression used for grouping within each
#'   `(channel, group)` pair.
#' @param .fun A summary function applied to numeric columns.
#'   Defaults to [base::mean()].
#'
#' @return A data frame containing the same key columns
#'   (`x`, `y`, `channel`, `group`, `duration`, `velocity`)
#'   and suitable for use in [sonify()].
#'
#' @details
#' Although `rollup()` uses summarization by default,
#' any transformation that returns a data frame with the expected
#' columns will work in a sonification pipeline.
#' Users can define their own custom `rollup` functions,
#' including those that duplicate rows to generate chords or
#' parallel voices.
#'
#' @export
rollup <- function(d, by, .fun = base::mean) {
  grouping_vars <- rlang::syms(c("channel", "group"))
  # nolint start
  group_by(d, !!!grouping_vars, {{ by }}) |>
    summarise(
      across(where(is.numeric), .fun),
      .groups = "drop"
    )
  # nolint end
}
