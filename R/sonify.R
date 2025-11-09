# TYPE-1 Standard MIDI can have up to 16 channels.
.CHANNEL_MAX <- 15 # nolint

#' Map note data to MIDI event timings and values
#'
#' `sonify()` transforms a notes tibble into a structured data frame of
#' note-on and note-off events that can be written to a Standard MIDI file
#' via [write_midi()].
#'
#' @param notes A tibble containing columns
#'   `x`, `y`, `channel`, `group`, `duration`, and `velocity`.
#'   `channel` and `group` should be factors; other columns should be numeric.
#' @param phrase_len Length of the phrase in beats.
#' @param tpq Ticks per quarter note.
#' @param pitch_range Range of MIDI note numbers to map `y` onto.
#' @param vel_range Range of MIDI velocities to map `velocity` onto.
#' @param duration_range Range of note durations (in ticks) mapped from `duration`.
#'   Default `c(16, 4)` (shorter to longer).
#' @param offset Padding fraction for mapping `x` values.
#'
#' @returns A data frame with factor and integer columns:
#'   `channel`, `group`, `tick_on`, `tick_off`, `pitch`, and `velocity`.
#'   Suitable as input to [write_midi()].
#'
#' @details
#' Value scaling is handled by [scales::rescale()], so the input value ranges
#' are arbitrary but must be finite.
#' Note that because of this rescaling behavior, a `velocity` value of `0`
#' will not be mapped to complete silence by default (i.e., the minimum input
#' value will still be mapped to the lower bound of `vel_range` rather than `0`).
#'
#' Within each channel, duplicated timing values (`x`) are deduplicated
#' using [dplyr::distinct()].
#' To produce simultaneous notes (like chords), you must assign different
#' `channel` values in advance.
#'
#' @export
sonify <- function(
  notes,
  phrase_len = 4,
  tpq = 480,
  pitch_range = c(27, 102),
  vel_range = c(60, 100),
  duration_range = c(16, 4),
  offset = .1
) {
  if (nlevels(factor(notes[["channel"]])) > .CHANNEL_MAX) {
    cli::cli_warn(
      "number of channels is too large. the result may be unexpected."
    )
  }
  total_ticks <- phrase_len * tpq

  # nolint start
  select(
    notes,
    all_of(c("x", "y", "channel", "group", "duration", "velocity"))
  ) |>
    group_by(!!rlang::sym("channel")) |>
    mutate(
      group = forcats::fct_lump(factor(.data$group), n = .CHANNEL_MAX),
      t = rescale(.data$x, to = c(offset, 1 - offset)),
      tick_on = rescale(
        t + (as.integer(.data$group) - 1),
        from = c(0, 1),
        to = c(0, total_ticks * nlevels(.data$group))
      ),
      tick_off = .data$tick_on +
        tpq / rescale(.data$duration, to = duration_range),
      pitch = rescale(.data$y, to = pitch_range),
      velocity = rescale(.data$velocity, to = vel_range),
      .keep = "unused"
    ) |>
    distinct(.data$t, .keep_all = TRUE) |>
    ungroup() |>
    select(all_of(c(
      "channel",
      "group",
      "tick_on",
      "tick_off",
      "pitch",
      "velocity"
    ))) |>
    mutate(
      across(
        where(is.numeric),
        function(x) {
          round(x) |> as.integer()
        }
      )
    )
  # nolint end
}
