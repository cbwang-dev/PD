clear;
project_parameters;
VAD_TD_threshold=1e-3;
speech_percentage_threshold=0.1;
fprintf("This test script checks the match between VAD time domain and VAD STFT domain.\n")
concentrating_speech_filename=speech_filename_1;
VAD = compute_VAD(concentrating_speech_filename,desired_len,fs_RIR,VAD_TD_threshold);
mic = create_micsigs(speech_filename_1, speech_filename_2, noise_filename, ...
                     fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
                     bool_play_audio_micsigs, bool_plot_audio_micsigs, bool_noise);
% estimate DOA using wideband MUSIC algorithm. 2 desired sources are hard coded in wideband MUSIC. 
[DOA_est,STFT_mic] = MUSIC_wideband(mic, fs_RIR, Q, dist_mic, c, bool_displayDOA, L, overlap_ratio, num_mic); 
VAD_STFT_out = VAD_STFT(VAD, STFT_mic, speech_percentage_threshold);
figure;
subplot(2,1,1);title("VAD for time domain")
subtitle(sprintf("VAD_TD_threshold: %.1f, ", VAD_TD_threshold))
plot(VAD);xlim([1 size(STFT_mic,2)*size(STFT_mic,3)/2+512]);ylim([0 1.1])
subplot(2,1,2);title("VAD for frequency domain")
subtitle(sprintf("speech_percentage_threshold: %.1f, ", speech_percentage_threshold))
plot(VAD_STFT_out);xlim([1 length(VAD_STFT_out)]);ylim([0 1.1])