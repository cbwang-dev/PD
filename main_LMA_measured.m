clear;
project_parameters; % load parameters in project_parameters.m
dist_mic=0.4; % experiment setup overwrite, 40 cm inter mic distance. 
num_mic=4;    % experiment setup overwrite, 4 microphones.
Q=2;          % experiment setup overwrite, 2 speakers.
RIR_noise=[];
fprintf('====> parameters registered.\n')
%% construct RIRs for left and right sources
LMA_M1_left = audioread("measured_IRs/IR_LMA_M1_left.wav");
LMA_M2_left = audioread("measured_IRs/IR_LMA_M2_left.wav");
LMA_M3_left = audioread("measured_IRs/IR_LMA_M3_left.wav");
LMA_M4_left = audioread("measured_IRs/IR_LMA_M4_left.wav");
LMA_M1_right = audioread("measured_IRs/IR_LMA_M1_right.wav");
LMA_M2_right = audioread("measured_IRs/IR_LMA_M2_right.wav");
LMA_M3_right = audioread("measured_IRs/IR_LMA_M3_right.wav");
LMA_M4_right = audioread("measured_IRs/IR_LMA_M4_right.wav");
% figure(1);
% subplot(4,2,1);plot(LMA_M1_left(200:300));title("LMA_M1_left",'interpreter','none');
% subplot(4,2,3);plot(LMA_M2_left(200:300));title("LMA_M2_left",'interpreter','none');
% subplot(4,2,5);plot(LMA_M3_left(200:300));title("LMA_M3_left",'interpreter','none');
% subplot(4,2,7);plot(LMA_M4_left(200:300));title("LMA_M4_left",'interpreter','none');
% subplot(4,2,2);plot(LMA_M1_right(200:300));title("LMA_M1_right",'interpreter','none');
% subplot(4,2,4);plot(LMA_M2_right(200:300));title("LMA_M2_right",'interpreter','none');
% subplot(4,2,6);plot(LMA_M3_right(200:300));title("LMA_M3_right",'interpreter','none');
% subplot(4,2,8);plot(LMA_M4_right(200:300));title("LMA_M4_right",'interpreter','none');
RIR_sources_left = [LMA_M1_left LMA_M2_left LMA_M3_left LMA_M4_left];
RIR_sources_right = [LMA_M1_right LMA_M2_right LMA_M3_right LMA_M4_right];
RIR_sources = cat(3, RIR_sources_left, RIR_sources_right);
RIR_sources = RIR_sources(1:3*fs_RIR,:,:); % truncate the RIRs to 1s. 
fprintf("====> RIRs constructed.\n")
mic = create_micsigs(speech_filename_1, speech_filename_2, noise_filename, ...
                     fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
                     bool_play_audio_micsigs, bool_plot_audio_micsigs, bool_noise);
mic_SIR_reference = create_micsigs_single_source(speech_filename_1, speech_filename_2, noise_filename, ...
                     fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
                     bool_play_audio_micsigs, bool_plot_audio_micsigs, bool_noise);

y=mic(:,1);
x1=mic_SIR_reference(:,1);
x2=y-x1;
ground_truth = compute_VAD(speech_filename_1,desired_len,fs_RIR,VAD_TD_threshold);
[SIR]=compute_SIR(y,x1,x2,ground_truth)

% estimate DOA using wideband MUSIC algorithm. 2 desired sources are hard coded in wideband MUSIC. 
[DOA_est,STFT_mic] = MUSIC_wideband(mic, fs_RIR, Q, dist_mic, c, bool_displayDOA, L, overlap_ratio, num_mic);
DOA_speech = DOA_est(2); % DOA of speech source 
DOA_noise  = DOA_est(1); % DOA of noise source (according to setup, noise is always on the right hand side)
%% time domain GSC using DAS BF, assume that there are 2 desired sources
speech_DAS_delayed = DAS_BF(mic, DOA_speech, num_mic, dist_mic, c, fs_RIR);
noise_DAS_delayed  = DAS_BF(mic, DOA_noise, num_mic, dist_mic, c, fs_RIR);
reference_DAS_delayed = DAS_BF(mic_SIR_reference, DOA_speech, num_mic, dist_mic, c, fs_RIR);


y=mean(speech_DAS_delayed,2);
x1=mic_SIR_reference(:,1);
x2=y-x1;
ground_truth = compute_VAD(speech_filename_1,desired_len,fs_RIR,VAD_TD_threshold);
[SIR]=compute_SIR(y,x1,x2,ground_truth)

[GSC_out,X] = GSC(speech_DAS_delayed, speech_filename_1, desired_len, fs_RIR, num_mic, bool_VAD_time_domain,VAD_TD_threshold);

% y=GSC_out;
% x1=mic_SIR_reference(:,1)*(max(GSC_out)/max(mic_SIR_reference(:,1)));
% x2=y-x1;
% ground_truth = compute_VAD(speech_filename_1,desired_len,fs_RIR,VAD_TD_threshold);
% [SIR]=compute_SIR(y,x1,x2,ground_truth)
W_save=zeros(L,num_mic-1)';
GSC_fd_output=GSC_fd(STFT_mic, RIR_sources,2,fs_RIR,overlap_ratio,mu, ...
  speech_filename_1, desired_len, VAD_TD_threshold, ...
  speech_percentage_threshold,W_save);


%% evaluation (DAS BF, GSC_td)
figure(2); % comparison between DAS BF of speech and noise
plot(mean(noise_DAS_delayed,2),'g');hold on;
plot(mean(speech_DAS_delayed,2),'r');hold on;
legend("DAS BF noise (averaged)", "DAS BF speech (averaged)");
title("Comparison between DAS BF speech, and DAS BF noise");
subtitle('measured LMA in lab','interpreter','none','fontsize',10);
figure(3); % comparison between mic signal, DAS BF, and GSC
plot(mean(mic,2),'b');hold on;
plot(mean(speech_DAS_delayed,2),'r');hold on;
plot(GSC_out,'g');hold on;
legend("mic signal (averaged)", "DAS BF (averaged)", "GSC");
title("comparison between mic signal, DAS BF, and GSC");
subtitle('measured LMA in lab','interpreter','none','fontsize',10);
if bool_play_audio_universal % whether to play audio
  fprintf('INFO: playing DAS_BF result. Press any key to continue.\n');soundsc(mean(speech_DAS_delayed,2),fs_RIR);pause;
  fprintf('INFO: playing GSC result. Press any key to continue.\n');soundsc(GSC_out,fs_RIR);pause;
end