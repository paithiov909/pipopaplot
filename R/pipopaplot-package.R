#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @useDynLib pipopaplot, .registration = TRUE
#' @import dplyr
#' @importFrom scales rescale
## usethis namespace: end
NULL

.onUnload <- function(libpath) {
  library.dynam.unload("pipopaplot", libpath)
}
