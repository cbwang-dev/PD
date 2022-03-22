clear;
project_parameters; % load parameters in project_parameters.m
speech_filename_2 = strcat(audio_file_dir, 'speech2.wav'); % preferably noise. 
desired_len = 5;

time_varying_mic = time_varying_scenario(...
    computed_RIRs_LUT, bool_time_varying_reverb, ...
    speech_filename_1, speech_filename_2, noise_filename, ...
    fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
    bool_play_audio_micsigs, bool_plot_audio_micsigs, bool_noise);

% test
soundsc(time_varying_mic(:,1), fs_RIR);
figure;plot(time_varying_mic(:,1)); %checked correctness