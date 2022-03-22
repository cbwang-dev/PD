function VAD_STFT_out = VAD_STFT(VAD, STFT_mics, speech_percentage_threshold)
  % NOW ASSUME THAT THERE IS 50% OVERLAP ONLY!!!
  num_frames = size(STFT_mics, 3);
  num_freq = size(STFT_mics, 2);
  VAD_STFT_out = zeros(num_frames);
  for i = 1:num_frames
    VAD_truncated = VAD( 1+(i-1)*num_freq/2 : (i-1)*num_freq/2+num_freq);
    speech_percentage = sum(VAD_truncated)/num_freq;
    if speech_percentage > speech_percentage_threshold
      VAD_STFT_out(i) = 1;
    end
  end
end