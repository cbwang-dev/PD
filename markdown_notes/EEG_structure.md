# EEG Training Set Description

In every trial, the EEG signal length is always 50 seconds.

- `RawData`
  - `EegData`: always 6400*64
- `FileHeader`
  - `SampleRate`: always 128
  - `SNR`: 4 or 100
- `AttendedTrack`
  - `Envelope`: 'envelope_track_$NUM$.wav'
  - `Locus`: 'L', 'R', or 'F'
  - `SexOfSpeaker` 'F' or 'M'
- `UnattendedTrack`
  - `Envelope`: 'envelope_track_$NUM$.wav'
  - `Locus`: 'L', 'R', or 'F'
  - `SexOfSpeaker` 'F' or 'M'
