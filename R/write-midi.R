#' @keywords internal
verify_notes <- function(notes, opt) {
  if (!is.data.frame(notes)) {
    cli::cli_abort("notes must be a data frame")
  }
  if (
    !all(
      c("channel", "group", "tick_on", "tick_off", "pitch", "velocity") %in%
        colnames(notes)
    )
  ) {
    cli::cli_abort("notes must have columns tick_on, tick_off, pitch, velocity")
  }
  if (!all(c(is.factor(notes[["channel"]]), is.factor(notes[["group"]])))) {
    cli::cli_abort("channel and group must be factors")
  }
  if (
    !all(c(
      is.integer(notes[["tick_on"]]),
      is.integer(notes[["tick_off"]]),
      is.integer(notes[["pitch"]]),
      is.integer(notes[["velocity"]])
    ))
  ) {
    cli::cli_abort("tick_on, tick_off, pitch, velocity must be integers")
  }
  range_pitch <- range(notes[["pitch"]])
  if (range_pitch[1] < 0 || range_pitch[2] > 127 || anyNA(range_pitch)) {
    cli::cli_abort("pitch must be between 0 and 127")
  }
  range_velocity <- range(notes[["velocity"]])
  if (range_velocity[1] < 0 || range_velocity[2] > 127 || anyNA(range_velocity)) {
    cli::cli_abort("velocity must be between 0 and 127")
  }
  if (length(opt[["programs"]]) != nlevels(notes[["channel"]])) {
    cli::cli_abort(
      "length of programs must be equal to the number of levels of channel"
    )
  }
  range_program <- range(opt[["programs"]])
  if (range_program[1] < 0 || range_program[2] > 127 || anyNA(range_program)) {
    cli::cli_abort("programs must be between 0 and 127")
  }
  invisible(TRUE)
}

#' Write a data frame of notes to a Standard MIDI file
#'
#' @param notes A data frame containing columns
#'   `tick_on`, `tick_off`, `pitch`, and `velocity`.
#'   `tick_on` and `tick_off` should be integers.
#'   `pitch` and `velocity` should be integers.
#'   `channel` and `group` should be factors; other columns should be numeric.
#' @param filename Name of the output file.
#' @param opt A list of options.
#'
#' @returns The path to the output file is invisibly returned.
#' @export
write_midi <- function(
  notes,
  filename = "test.mid",
  opt = list()
) {
  opt <-
    utils::modifyList(
      list(
        tempo = 120, # currently unused
        tpq = 480,
        programs = seq_len(nlevels(notes[["channel"]])) - 1L
      ),
      opt
    )

  # nolint start
  # NOTE: filter out invalid events implicitly
  notes <-
    dplyr::filter(notes,
      is.finite(.data$tick_on),
      is.finite(.data$tick_off),
      .data$tick_on >= 0,
      .data$tick_off >= 0
    )
  # nolint end
  verify_notes(notes, opt)

  fp <-
    write_midi_impl(
      filename,
      tpq = opt[["tpq"]],
      programs = opt[["programs"]],
      channels = as.integer(notes[["channel"]]) - 1L,
      tick_on = notes[["tick_on"]],
      tick_off = notes[["tick_off"]],
      keys = notes[["pitch"]],
      velocities = notes[["velocity"]]
    )
  invisible(fp)
}
