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
envelope_dir = './data_phase_2/envelope_train/';
eeg_dir = './data_phase_2/eeg_train/';
addpath('./func_preproc/')
load audioprepro_constants.mat % gamma tone filter bank coefficients
LUT_EEG_1 = {'001/' '002/' '003/' '004/' '005/' '006/' '007/' '008/' '009/' '010/' '011/' '012/' '013/' '014/' '015/' '016/' '017/' '018/' '019/' ...
             '020/' '021/' '022/' '023/' '024/' '025/' '026/' '027/' '028/' '029/' '030/' '031/' '032/' '033/' '034/' '035/' '036/' '037/' };
% hyperparameters (tunable)
flag_LR_CNN = true; % true for 'LR', false for 'CNN'
if flag_LR_CNN % true for 'LR'
  preproc_save_dir = './data_phase_2/preprocessed_LR';
else           % false for 'CNN'
  preproc_save_dir = './data_phase_2/preprocessed_CNN';
end

%% preprocess one eeg and one audio
for i=1:length(LUT_EEG_1)
  allFiles = dir(strcat(eeg_dir, LUT_EEG_1{i}));
  LUT_EEG_2 = {allFiles.name};
  for j=3:length(LUT_EEG_2) % skip '.' and '..'
    eeg_filename = strcat(LUT_EEG_1{i}, LUT_EEG_2{j});
    load(strcat(eeg_dir,eeg_filename));
    original_eeg = trial.RawData.EegData;
    eeg_SampleRate = trial.FileHeader.SampleRate;
    AttendedTrack_filename = trial.AttendedTrack.Envelope;
    UnattendedTrack_filename = trial.UnattendedTrack.Envelope;
    % fprintf("INFO: %s, attended %s, unattended %s\n", eeg_filename, AttendedTrack_filename, UnattendedTrack_filename);
    preprocessed_eeg = preproc_eeg(eeg_filename, original_eeg, eeg_SampleRate, flag_LR_CNN, eeg_downsample_fs_LR, eeg_downsample_fs_CNN, BPF_BW_LR, BPF_BW_CNN);
    preprocessed_attended = preproc_audio(envelope_dir, AttendedTrack_filename, audio_downsample_fs_step_2, g, flag_LR_CNN, audio_downsample_fs_step_5_LR, audio_downsample_fs_step_5_CNN, BPF_BW_LR, BPF_BW_CNN);
    preprocessed_unattended = preproc_audio(envelope_dir, UnattendedTrack_filename, audio_downsample_fs_step_2, g, flag_LR_CNN, audio_downsample_fs_step_5_LR, audio_downsample_fs_step_5_CNN, BPF_BW_LR, BPF_BW_CNN);
    trial.ProcessedEegData = preprocessed_eeg;
    trial.ProcessedAttendedTrack = preprocessed_attended;
    trial.ProcessedUnattendedTrack = preprocessed_unattended;
    save_filename = strcat(preproc_save_dir,'/',eeg_filename);
    save(save_filename,'trial')
    fprintf('INFO: save file in %s\n',save_filename)
  end
end



