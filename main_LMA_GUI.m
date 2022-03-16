%% preparation
clear;
project_parameters; % load parameters in project_parameters.m
fprintf('====> parameters registered.\n')
% generate mic signal (regular case)
% The sceario is set to GUI_setup/w2_p3.mat. Load the file using mySA_GUI
% before executing this block. 
load computed_RIRs_phase_1/Computed_RIRs_week_4_setup_4_T60_1_30_141.mat
% load computed_RIRs_phase_1/Computed_RIRs_week_4_setup_4_T60_1_30_141.mat
% this mic signal is not for time varying scenario!!!
mic = create_micsigs(speech_filename_1, speech_filename_2, noise_filename, ...
                     fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
                     bool_play_audio_micsigs, bool_plot_audio_micsigs, true); % select true to add nonise
mic_SIR_reference = create_micsigs_single_source(speech_filename_1, speech_filename_2, noise_filename, ...
                     fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
                     bool_play_audio_micsigs, bool_plot_audio_micsigs, false);

% SIR calculation for mic 
y=mic(:,1);
x1=mic_SIR_reference(:,1);
x2=y-x1;
ground_truth = compute_VAD(speech_filename_1,desired_len,fs_RIR,VAD_TD_threshold);
[SIR]=compute_SIR(y,x1,x2,ground_truth)

% estimate DOA using wideband MUSIC algorithm. 2 desired sources are hard coded in wideband MUSIC. 
[DOA_est,STFT_mic] = MUSIC_wideband(mic, fs_RIR, Q, dist_mic, c, bool_displayDOA, L, overlap_ratio, num_mic); 
% according to setup, speech is always on the left hand side -> speech DOA > 90!!!
DOA_speech = DOA_est(2); % DOA of speech source 
DOA_noise  = DOA_est(1); % DOA of noise source (according to setup, noise is always on the right hand side)
%% time domain GSC using DAS BF, assume that there are 2 desired sources
speech_DAS_delayed = DAS_BF(mic, DOA_speech, num_mic, dist_mic, c, fs_RIR);
noise_DAS_delayed  = DAS_BF(mic, DOA_noise, num_mic, dist_mic, c, fs_RIR);
reference_DAS_delayed = DAS_BF(mic_SIR_reference, DOA_speech, num_mic, dist_mic, c, fs_RIR);

y=mean(speech_DAS_delayed,2);
x1=mean(reference_DAS_delayed,2);
x2=y-x1;
ground_truth = compute_VAD(speech_filename_1,desired_len,fs_RIR,VAD_TD_threshold);
[SIR]=compute_SIR(y,x1,x2,ground_truth)

[GSC_out,X] = GSC(speech_DAS_delayed, speech_filename_1, desired_len, fs_RIR, num_mic, bool_VAD_time_domain, VAD_TD_threshold);

y=GSC_out;
x1=mic_SIR_reference(:,1);
% x1=GSC(reference_DAS_delayed, speech_filename_1, desired_len, fs_RIR, num_mic, bool_VAD_time_domain, VAD_TD_threshold);
x2=y-x1;
ground_truth = compute_VAD(speech_filename_1,desired_len,fs_RIR,VAD_TD_threshold);
[SIR]=compute_SIR(y,x1,x2,ground_truth)
%% storage of resulting sound 
% TODO
%% evaluation (DAS BF, GSC_td)
% figure; % comparison between DAS BF of speech and noise
% plot(mean(mic,2),'b');hold on;
% plot(mean(noise_DAS_delayed,2),'g');hold on;
% plot(mean(speech_DAS_delayed,2),'r');hold on;
% legend("noisy mic", "DAS BF noise (averaged)", "DAS BF speech (averaged)");
% title("Comparison between DAS BF speech, and DAS BF noise");
% subtitle(computed_RIRs_LUT{RIR_GUI_LMA},'interpreter','none','fontsize',10);
figure; % comparison between mic signal, DAS BF, and GSC
plot(mean(noise_DAS_delayed,2),'b');hold on;
plot(mean(speech_DAS_delayed,2),'r');hold on;
plot(GSC_out,'g');hold on;
legend("mic signal (averaged)", "DAS BF (averaged)", "GSC");
title("comparison between mic signal, DAS BF, and GSC");
subtitle(computed_RIRs_LUT{RIR_GUI_LMA},'interpreter','none','fontsize',10);
if bool_play_audio_universal % whether to play audio
  fprintf('INFO: playing DAS_BF result. Press any key to continue.\n');soundsc(mean(speech_DAS_delayed,2),fs_RIR);pause;
  fprintf('INFO: playing GSC result. Press any key to continue.\n');soundsc(GSC_out,fs_RIR);pause;
end
%% frequency domain GSC 
% GSC_out_fd = GSC_fd(STFT_mic, fs_RIR, L, overlap_ratio, Q, dist_mic, c, 1, mu, bool_test_use_DAS_BF, mic_DAS_delayed_1); 
%% evaluation (GSC_fd)
