#include "cpp11.hpp"
#include "MidiFile.h"

#include <sstream>

using namespace smf;

[[cpp11::register]]
std::string dump_midi_impl(const std::string filename) {
  if (filename.empty()) {
    cpp11::stop("filename is empty");
  }
  MidiFile input;
  input.read(filename);
  input.splitTracks();
  std::ostringstream os;
  os << input;
  return (os.str());
}

[[cpp11::register]]
std::string write_midi_impl(
    const std::string filename, int tpq,
    const std::vector<int>& programs,     // vector of timbres for each track
    const std::vector<int>& channels, const std::vector<int>& tick_on,
    const std::vector<int>& tick_off, const std::vector<int>& keys,
    const std::vector<int>& velocities) {
  if (filename.empty()) {
    cpp11::stop("filename is empty");
  }
  MidiFile output;

  output.absoluteTicks();
  output.setTicksPerQuarterNote(tpq);
  output.addTracks(programs.size() - 1);

  // Add timbres
  for (std::size_t i = 0; i < programs.size(); i++) {
    output.addTimbre(i, 0, i, programs[i]);
  }

  // Add note_on and note_off
  for (std::size_t i = 0; i < channels.size(); i++) {
    if (i % 100 == 0) {
      cpp11::check_user_interrupt();
    }
    output.addNoteOn(channels[i], tick_on[i], channels[i], keys[i],
                     velocities[i]);
    output.addNoteOff(channels[i], tick_off[i], channels[i], keys[i],
                      velocities[i]);
  }
  output.sortTracks();
  output.write(filename);

  return filename;
}
