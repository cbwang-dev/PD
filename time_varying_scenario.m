function time_varying_mic = time_varying_scenario(...
    computed_RIRs_LUT, bool_time_varying_reverb, ...
    speech_filename_1, speech_filename_2, noise_filename, ...
    fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
    bool_play_audio_micsigs, bool_plot_audio_micsigs, bool_noise)
  % assume easy scenario: switch direction immediately
  if bool_time_varying_reverb
    RIRs = computed_RIRs_LUT(6:10);
  else
    RIRs = computed_RIRs_LUT(1:5);
  end
  time_varying_mic=[];
  for i=1:length(RIRs)
    load(RIRs{i});
    mic_temp = create_micsigs(speech_filename_1, speech_filename_2, noise_filename, ...
                fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
                bool_play_audio_micsigs, bool_plot_audio_micsigs, bool_noise);
    time_varying_mic = [time_varying_mic; mic_temp];
  end
end