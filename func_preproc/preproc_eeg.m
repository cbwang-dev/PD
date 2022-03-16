function preprocessed_eeg = preproc_eeg(eeg_filename, original_eeg, eeg_SampleRate, flag_LR_CNN, ...
    eeg_downsample_fs_LR, eeg_downsample_fs_CNN, BPF_BW_LR, BPF_BW_CNN)
  if flag_LR_CNN % true for LR
    flag_LR_CNN_str = 'LR';
    eeg_step_2 = resample(cast(original_eeg,'double'), eeg_downsample_fs_LR, eeg_SampleRate);
    eeg_step_3 = bandpass(eeg_step_2, [1 BPF_BW_LR], eeg_downsample_fs_LR);
  else           % false for CNN
    flag_LR_CNN_str = 'CNN';
    eeg_step_2 = resample(cast(original_eeg,'double'), eeg_downsample_fs_CNN, eeg_SampleRate);
    eeg_step_3 = bandpass(eeg_step_2, [1 BPF_BW_CNN], eeg_downsample_fs_CNN);
  end
  preprocessed_eeg = eeg_step_3;
  fprintf('PROC: (%s) preprocessed EEG %s\n', flag_LR_CNN_str, eeg_filename);
end