function preprocessed_audio = preproc_audio(envelope_dir, audio_filename, audio_downsample_fs_step_2, g, ...
    flag_LR_CNN, audio_downsample_fs_step_5_LR, audio_downsample_fs_step_5_CNN, BPF_BW_LR, BPF_BW_CNN)
  audio_dir = strcat(envelope_dir, audio_filename);
  [audio_step_1,fs_audio] = audioread(audio_dir);
  audio_step_2 = resample(audio_step_1, audio_downsample_fs_step_2, fs_audio);
  audio_step_3 = zeros(length(audio_step_2), length(g));
  for i = 1:length(g) % problem: how do we use offset in g?
      audio_step_3(:,i) = fftfilt(g{i}.h,audio_step_2);
      % signal_subband(:,i) = delayseq(signal_subband(:,i),-1*g{i}.offset);
  end
  audio_step_4 = abs(audio_step_3).^0.6;
  if flag_LR_CNN % true for LR
    flag_LR_CNN_str = 'LR';
    audio_step_5 = resample(audio_step_4, audio_downsample_fs_step_5_LR, audio_downsample_fs_step_2);
    audio_step_6 = sum(audio_step_5, 2);
    audio_step_7 = bandpass(audio_step_6, [1 BPF_BW_LR], audio_downsample_fs_step_5_LR);
  else           % false for CNN
    flag_LR_CNN_str = 'CNN';
    audio_step_5 = resample(audio_step_4, audio_downsample_fs_step_5_CNN, audio_downsample_fs_step_2);
    audio_step_6 = sum(audio_step_5, 2);
    audio_step_7 = bandpass(audio_step_6, [1 BPF_BW_CNN], audio_downsample_fs_step_5_CNN);
  end
  preprocessed_audio = audio_step_7;
  fprintf('PROC: (%s) preprocessed %s\n', flag_LR_CNN_str, audio_filename);
end

