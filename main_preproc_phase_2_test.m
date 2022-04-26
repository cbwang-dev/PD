% The script do:
% 1) preprocess all EEG and audio data 
% 2) store the data in ./data_phase_2/preprocessed_CNN/ and ./data_phase_2/preprocessed_LR/

%% hyperparameters
% hyperparameters (fixed)
audio_downsample_fs_step_2 = 8e3;
audio_downsample_fs_step_5_LR = 20;
audio_downsample_fs_step_5_CNN = 70;
eeg_downsample_fs_LR = audio_downsample_fs_step_5_LR;
eeg_downsample_fs_CNN = audio_downsample_fs_step_5_CNN;
BPF_BW_LR = 9;
BPF_BW_CNN = 32;
envelope_dir = './data_phase_2/env_test_sub_40_41_42/';
eeg_dir = './data_phase_2/eeg_test_sub_40_41_42/';
addpath('./func_preproc/')
load audioprepro_constants.mat % gamma tone filter bank coefficients
% LUT_EEG_1 = {'001/' '002/' '003/' '004/' '005/' '006/' '007/' '008/' '009/' '010/' '011/' '012/' '013/' '014/' '015/' '016/' '017/' '018/' '019/' ...
%              '020/' '021/' '022/' '023/' '024/' '025/' '026/' '027/' '028/' '029/' '030/' '031/' '032/' '033/' '034/' '035/' '036/' '037/' };
LUT_EEG_1 = {'040/' '041/' '042/'};
% hyperparameters (tunable)

flag_LR_CNN = false; % true for 'LR', false for 'CNN'

if flag_LR_CNN % true for 'LR'
  preproc_save_dir = './data_phase_2/preprocessed_LR_test_sub_40_41_42';
else           % false for 'CNN'
  preproc_save_dir = './data_phase_2/preprocessed_CNN_test_sub_40_41_42';
end

%% preprocess one eeg and one audio
for i=1:length(LUT_EEG_1)
  allFiles = dir(strcat(eeg_dir, LUT_EEG_1{i}));
  LUT_EEG_2 = {allFiles.name};
  for j=1:length(LUT_EEG_2) % skip '.' and '..'
    if strcmp(LUT_EEG_2{j}(1), '.')
      continue
    end
    eeg_filename = strcat(LUT_EEG_1{i}, LUT_EEG_2{j});
    load(strcat(eeg_dir,eeg_filename));
    original_eeg = trial.RawData.EegData;
    eeg_SampleRate = trial.FileHeader.SampleRate;
    Track_1_filename = trial.track1.Envelope;
    Track_2_filename = trial.track2.Envelope;
    % fprintf("INFO: %s, attended %s, unattended %s\n", eeg_filename, Track_1_filename, Track_2_filename);
    preprocessed_eeg = preproc_eeg(eeg_filename, original_eeg, eeg_SampleRate, flag_LR_CNN, eeg_downsample_fs_LR, eeg_downsample_fs_CNN, BPF_BW_LR, BPF_BW_CNN);
    preprocessed_track_1 = preproc_audio(envelope_dir, Track_1_filename, audio_downsample_fs_step_2, g, flag_LR_CNN, audio_downsample_fs_step_5_LR, audio_downsample_fs_step_5_CNN, BPF_BW_LR, BPF_BW_CNN);
    preprocessed_track_2 = preproc_audio(envelope_dir, Track_2_filename, audio_downsample_fs_step_2, g, flag_LR_CNN, audio_downsample_fs_step_5_LR, audio_downsample_fs_step_5_CNN, BPF_BW_LR, BPF_BW_CNN);
    trial.ProcessedEegData = preprocessed_eeg;
    trial.Processedtrack1 = preprocessed_track_1;
    trial.Processedtrack2 = preprocessed_track_2;
    save_filename = strcat(preproc_save_dir,'/',eeg_filename);
    save(save_filename,'trial')
    fprintf('INFO: save file in %s\n',save_filename)
  end
end