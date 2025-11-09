

## Overview

[pipopaplot](https://github.com/paithiov909/pipopaplot) is an
experimental R package for parameter mapping sonification.

Sonification refers to the use of non-speech audio to convey information
or perceptualize data. While data visualization translates data into
shapes, positions, and colors, parameter mapping sonification maps data
into sound parameters such as pitch, velocity, duration, or timing.

pipopaplot is designed to work seamlessly with the
[ggplot2](https://ggplot2.tidyverse.org/) ecosystem: you can use the
same data-mapping logic that you use for visual plots, but instead of
pixels, the output is musical notes.

The package provides a small set of functions to bridge between
ggplot-like data frames and MIDI events:

- `as_notes()` — extract note-like data from ggplot layers or data
  frames
- `rollup()` — aggregate or transform notes before playback
- `sonify()` — convert note data into MIDI-ready event sequences
- (optionally) `write_midi()` — save the resulting notes as a .mid file
  using built-in
  [craigsapp/midifile](https://github.com/craigsapp/midifile) library

Together, these functions allow you to **hear** your data, explore its
temporal patterns, or even compose algorithmic music directly from
statistical graphics.

## Usage

A typical workflow consists of three steps.

### 1. Create note data

You can start from a ggplot object or any data frame. Use `as_notes()`
to extract or format the columns that correspond to sonification
aesthetics:

``` r
library(ggplot2)
# library(pipopaplot)
pkgload::load_all(export_all = FALSE)
#> ℹ Loading pipopaplot

gp <-
  ggplot(mtcars, aes(mpg, wt)) +
  geom_point()

notes <- as_notes(gp)
str(notes)
#> tibble [32 × 6] (S3: tbl_df/tbl/data.frame)
#>  $ x       : num [1:32] 21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...
#>  $ y       : num [1:32] 2.62 2.88 2.32 3.21 3.44 ...
#>  $ channel : Factor w/ 1 level "1": 1 1 1 1 1 1 1 1 1 1 ...
#>  $ group   : num [1:32] -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
#>  $ velocity: num [1:32] 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 ...
#>  $ duration: num [1:32] 1 1 1 1 1 1 1 1 1 1 ...
```

The resulting tibble will contain the columns `x`, `y`, `channel`,
`group`, `duration`, and `velocity`.

### 2. Transform or aggregate notes

You can optionally summarize or reshape the note data before playback
using `rollup()` or your own transformation pipeline:

``` r
notes <- rollup(notes, x)
str(notes)
#> tibble [25 × 6] (S3: tbl_df/tbl/data.frame)
#>  $ channel : Factor w/ 1 level "1": 1 1 1 1 1 1 1 1 1 1 ...
#>  $ group   : num [1:25] -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
#>  $ x       : num [1:25] 10.4 13.3 14.3 14.7 15 15.2 15.5 15.8 16.4 17.3 ...
#>  $ y       : num [1:25] 5.34 3.84 3.57 5.34 3.57 ...
#>  $ velocity: num [1:25] 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 ...
#>  $ duration: num [1:25] 1 1 1 1 1 1 1 1 1 1 ...
```

Custom ‘rollup’ functions can also be defined by users — as long as they
return a data frame with the required note columns.

### 3. Convert to sound

Finally, use `sonify()` to map data values into MIDI pitches,
velocities, and durations. The resulting object can be passed to
`write_midi()` to save as a .mid file:

``` r
midi_data <- sonify(notes)
str(midi_data)
#> tibble [25 × 6] (S3: tbl_df/tbl/data.frame)
#>  $ channel : Factor w/ 1 level "1": 1 1 1 1 1 1 1 1 1 1 ...
#>  $ group   : Factor w/ 1 level "-1": 1 1 1 1 1 1 1 1 1 1 ...
#>  $ tick_on : int [1:25] 192 382 447 473 493 506 525 545 584 643 ...
#>  $ tick_off: int [1:25] 240 430 495 521 541 554 573 593 632 691 ...
#>  $ pitch   : int [1:25] 102 72 67 102 67 68 66 59 77 70 ...
#>  $ velocity: int [1:25] 80 80 80 80 80 80 80 80 80 80 ...

midi <- write_midi(midi_data, tempfile(fileext = ".mid"))
dump_midi(midi) # for printing in the console
#> "MThd"           ; MIDI header chunk marker
#> 4'6          ; bytes to follow in header chunk
#> 2'0          ; file format: Type-0 (single track)
#> 2'1          ; number of tracks
#> 2'480            ; ticks per quarter note
#> 
#> ;;; TRACK 0 ----------------------------------
#> "MTrk"           ; MIDI track chunk marker
#> 4'210            ; bytes to follow in track chunk
#> v0   c0 '0       ; patch-change (acoustic grand piano)
#> v192 90 '102 '80 ; note-on F#7
#> v48  80 '102 '80 ; note-off F#7
#> v142 90 '72 '80  ; note-on C5
#> v48  80 '72 '80  ; note-off C5
#> v17  90 '67 '80  ; note-on G4
#> v26  90 '102 '80 ; note-on F#7
#> v20  90 '67 '80  ; note-on G4
#> v2   80 '67 '80  ; note-off G4
#> v11  90 '68 '80  ; note-on G#4
#> v15  80 '102 '80 ; note-off F#7
#> v4   90 '66 '80  ; note-on F#4
#> v16  80 '67 '80  ; note-off G4
#> v4   90 '59 '80  ; note-on B3
#> v9   80 '68 '80  ; note-off G#4
#> v19  80 '66 '80  ; note-off F#4
#> v11  90 '77 '80  ; note-on F5
#> v9   80 '59 '80  ; note-off B3
#> v39  80 '77 '80  ; note-off F5
#> v11  90 '70 '80  ; note-on A#4
#> v33  90 '64 '80  ; note-on E4
#> v15  80 '70 '80  ; note-off A#4
#> v4   90 '65 '80  ; note-on F4
#> v29  80 '64 '80  ; note-off E4
#> v11  90 '64 '80  ; note-on E4
#> v8   80 '65 '80  ; note-off F4
#> v24  90 '68 '80  ; note-on G#4
#> v16  80 '64 '80  ; note-off E4
#> v17  90 '51 '80  ; note-on D#3
#> v15  80 '68 '80  ; note-off G#4
#> v33  80 '51 '80  ; note-off D#3
#> v37  90 '50 '80  ; note-on D3
#> v26  90 '55 '80  ; note-on G3
#> v7   90 '45 '80  ; note-on A2
#> v15  80 '50 '80  ; note-off D3
#> v26  80 '55 '80  ; note-off G3
#> v7   80 '45 '80  ; note-off A2
#> v36  90 '50 '80  ; note-on D3
#> v48  80 '50 '80  ; note-off D3
#> v57  90 '59 '80  ; note-on B3
#> v48  80 '59 '80  ; note-off B3
#> v57  90 '38 '80  ; note-on D2
#> v48  80 '38 '80  ; note-off D2
#> v37  90 '34 '80  ; note-on A#1
#> v48  80 '34 '80  ; note-off A#1
#> v154 90 '27 '80  ; note-on D#1
#> v48  80 '27 '80  ; note-off D#1
#> v83  90 '40 '80  ; note-on E2
#> v48  80 '40 '80  ; note-off E2
#> v50  90 '32 '80  ; note-on G#1
#> v48  80 '32 '80  ; note-off G#1
#> v0   ff 2f v0    ; end-of-track
```

The default pitch range corresponds to a 76-key piano (27–102 in MIDI
notes), and velocity is mapped roughly to mezzo-forte levels (60–100).
Because values are rescaled internally, input ranges are arbitrary but
must be finite.
