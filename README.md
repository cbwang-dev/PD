# P&D ISSP

## Introduction

This is the project of P&D in Signal Processing track, KU Leuven. The general purpose of this project is to develop a hearing aid whose input is 1) EEG signal and 2) hearing aid microphone signal, so that it can steer the desired speech signal (indicated by EEG) in a cocktail party scenario.

- Audio processing: narrowband/wideband [MUSIC](https://en.wikipedia.org/wiki/MUSIC_(algorithm)) algorithm, [DAS beamformer](http://www.labbookpages.co.uk/audio/beamforming/delaySum.html), GSC with VAD, FAS beamformer and frequency domain GSC.

## Start

### Phase 2

- Run `test_preproc_phase_2` twice, one with variable `flag_LR_CNN` is set to `true` and `false`. This can take several hours. Before running this script, make sure:
  - original EEG data is stored in `./data_phase_2/eeg_train`
    - Regarding to non-disclosure aggrement, EEG files are not uploaded in this repository.
  - original envelope audio files are stored in `./data_phase_2/envelope_train`
  - empty folders `./data_phase_2/preprocessed_CNN` and `./data_phase_2/preprocessed_LR` and its sub folders are created. The subfolder structure is identical to `./data_phase_2/eeg_train`.
- Run `main_LR_phase_2`.

## Useful Commands (in root directory)

- Making report: `pandoc report_phase1.md -o Documents/report_phase1.pdf`
