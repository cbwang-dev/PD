function VAD = compute_VAD(concentrating_speech_filename,desired_len,fs_RIR,VAD_TD_threshold)
  speech = audioread(concentrating_speech_filename);
  speech = speech(1:desired_len*fs_RIR);
  VAD = abs(speech(:,1))>std(speech(:,1))*VAD_TD_threshold; 
end