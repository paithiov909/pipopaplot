#' Dump a MIDI file
#'
#' @param filename The path to the MIDI file.
#' @param print If `TRUE`, print the contents of the MIDI file to the console.
#' @returns The contents of the MIDI file as a character vector is invisibly returned.
#' @export
#' @keywords internal
dump_midi <- function(filename, print = TRUE) {
  filename <- normalizePath(filename, winslash = "/", mustWork = TRUE)
  midi_str <- dump_midi_impl(filename)
  if (isTRUE(print)) {
    cat(midi_str)
  }
  invisible(midi_str)
}
