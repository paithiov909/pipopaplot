library(ggplot2)

test_that("as_notes works", {
  gp <-
    ggplot(mtcars, aes(mpg, wt)) +
    geom_point()

  notes <- as_notes(gp)
  expect_snapshot_value(notes, style = "json2")
})

test_that("rollup works", {
  gp <-
    ggplot(mtcars, aes(mpg, wt)) +
    geom_point()

  notes <- as_notes(gp)

  rollup_x <- rollup(notes, x)
  rollup_y <- rollup(notes, y)

  expect_snapshot_value(rollup_x, style = "json2")
  expect_snapshot_value(rollup_y, style = "json2")
})

test_that("sonify works", {
  gp <-
    ggplot(mtcars, aes(mpg, wt)) +
    geom_point()

  notes <- as_notes(gp)

  sonified <- sonify(notes)
  expect_snapshot_value(sonified, style = "json2")
})

test_that("write_midi works", {
  gp <-
    ggplot(mtcars, aes(mpg, wt)) +
    geom_point()

  sonified <-
    as_notes(gp) |>
    sonify()

  tmp <- tempfile(fileext = ".mid")
  write_midi(sonified, tmp)
  dump <- dump_midi(tmp) |>
    read.delim(text = _, header = FALSE, comment.char = ";")

  expect_snapshot_value(dump, style = "json2")
})
