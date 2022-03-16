clear;project_parameters; % load parameters in project_parameters.m
desired_len=5;
mu= 0.1;
W_save=zeros(L,num_mic-1)';
VAD_TD_threshold=1e-3;
speech_percentage_threshold=0.9;
fprintf("This test script compares the result of DAS BF and FAS BF. \n");
load("Computed_RIRs_phase_1/Computed_RIRs_week_4_setup_4_T60_0_30_141.mat");
% speech_filename_2 = strcat(audio_file_dir, 'speech2.wav');
fprintf('====> parameters registered.\n')
mic = create_micsigs(speech_filename_1, speech_filename_2, noise_filename, ...
                     fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
                     bool_play_audio_micsigs, bool_plot_audio_micsigs, bool_noise);
[DOA_est,STFT_mic] = MUSIC_wideband(mic, fs_RIR, Q, dist_mic, c, bool_displayDOA, L, overlap_ratio, num_mic); 
DOA_speech = DOA_est(2); % DOA of speech source
% DOA_speech=140;
DOA_noise  = DOA_est(1); % DOA of noise source (according to setup, noise is always on the right hand side)
speech_DAS_delayed = DAS_BF(mic, DOA_speech, num_mic, dist_mic, c, fs_RIR);
noise_DAS_delayed  = DAS_BF(mic, DOA_noise, num_mic, dist_mic, c, fs_RIR);
GSC_td_out = GSC(speech_DAS_delayed, speech_filename_1, desired_len, fs_RIR, num_mic, bool_VAD_time_domain, VAD_TD_threshold);
% figure;plot(mic(:,1));hold on;plot(mean(speech_DAS_delayed,2));hold on;plot(GSC_td_out);ylim([-3e-3 3e-3]);xlim([0 220500])
% fprintf("playing mic averaged\n");soundsc(mean(mic,2),fs_RIR);pause;
% fprintf("playing speech DAS BF averaged\n");soundsc(mean(speech_DAS_delayed,2), fs_RIR);pause;
% fprintf("playing noise DAS BF averaged\n");soundsc(mean(noise_DAS_delayed,2), fs_RIR);pause;

GSC_fd_output=GSC_fd(STFT_mic, RIR_sources,2,fs_RIR,overlap_ratio,mu, ...
  speech_filename_1, desired_len, VAD_TD_threshold, ...
  speech_percentage_threshold,W_save);

% save SIR
SIR_mic=0;
SIR_DAS=0;
SIR_FAS=0;
SIR_td_GSC=0;
SIR_fd_GSC=0;


% figure;plot(mic(:,1));hold on;plot(mean(speech_DAS_delayed,2));hold on;plot(GSC_fd_output);xlim([1 100000])

load('variables_GSC_fd.mat');
VAD = compute_VAD(speech_filename_1,desired_len,fs_RIR,VAD_TD_threshold);
VAD_STFT_out = VAD_STFT(VAD, STFT_mic, speech_percentage_threshold);

figure;
subplot(3,2,1);plot(VAD);xlim([1 size(STFT_mic,2)*size(STFT_mic,3)/2+512]);ylim([0 1.1]);
title("VAD for time domain");subtitle(sprintf("VAD TD threshold: %.3f", VAD_TD_threshold));
subplot(3,2,2);plot(VAD_STFT_out);xlim([1 length(VAD_STFT_out)]);ylim([0 1.1]);
title("VAD for frequency domain");subtitle(sprintf("speech percentage threshold: %.3f", speech_percentage_threshold));
subplot(3,1,2);plot(mic(:,1));hold on;plot(FAS_td_output);hold on;
plot(GSC_fd_output);xlim([0 length(GSC_fd_output)-1000]);
legend('original mic','FAS BF result','GSC fd result');
title("Comparison between FAS BF and GSC fd")
subtitle(sprintf("mu = %.3f, signal length = %d, STFT window = %d, VAD STFT thres = %.1f",mu,desired_len,L,speech_percentage_threshold));
subplot(3,1,3);plot(mic(:,1));hold on;plot(mean(speech_DAS_delayed,2));hold on;plot(GSC_td_out);hold on;xlim([0 length(GSC_fd_output)-1000])
legend('original mic','DAS BF result','GSC td result');
title("Comparison between DAS BF and GSC td")
% subtitle(sprintf("SIR: (mic %.3f) (DAS %.3f) (FAS %.3f) (GSC td %.3f) (GSC fd %.3f)",SIR_mic,SIR_DAS,SIR_FAS,SIR_td_GSC,SIR_fd_GSC));

figure;
subplot(3,1,1);plot(VAD_STFT_out);xlim([1 length(VAD_STFT_out)]);ylim([0 1.1]);
subplot(3,1,2);plot(GSC_fd_output);xlim([0 length(GSC_fd_output)-1000]);
subplot(3,1,3);plot(mic(:,1));xlim([0 length(GSC_fd_output)-1000]);ylim([-5e-3 5e-3])

% Questions: 
% 1. windowing in the time varying scenario 
% 2. result should be same for das and fas fas better dereverb. 
% 3. does the calculation of fas includes DOA? Implicitly used. 
% 4. result of fas bf is real, not complex. check the w refactor the code.
% 5. how can h replace g (5,361 dim)?

% figure;
% subplot(2,1,1)
% plot(mic(:,1));hold on;plot(mean(speech_DAS_delayed,2));hold on;plot(GSC_td_out);ylim([-3e-3 3e-3]);xlim([0 220500])
% legend('original mic','DAS BF result','GSC td result');
% title("Comparison between DAS BF and GSC td (with T60=1s)")
% subplot(2,1,2)
% title("Pseudospectrum of MUSIC wideband (with T60=1s)")
% load variables_MUSIC.mat
% plot(theta,real(p_music_geo_avg))