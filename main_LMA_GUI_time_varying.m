%% preparation
clear;
project_parameters; % load parameters in project_parameters.m
VAD_TD_threshold=1e-3;
speech_percentage_threshold=0.9;
mu= 0.1;
fprintf('====> parameters registered.\n')
% generate mic signal (regular case)
% The sceario is set to GUI_setup/w2_p3.mat. Load the file using mySA_GUI
% before executing this block. 

time_varying_mic = time_varying_scenario(...
    computed_RIRs_LUT, bool_time_varying_reverb, ...
    speech_filename_1, speech_filename_2, noise_filename, ...
    fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
    bool_play_audio_micsigs, bool_plot_audio_micsigs, true);
mic_reference = time_varying_scenario_reference(...
    computed_RIRs_LUT, bool_time_varying_reverb, ...
    speech_filename_1, speech_filename_2, noise_filename, ...
    fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
    bool_play_audio_micsigs, bool_plot_audio_micsigs, false);

window_len = time_varying_time_window_length * fs_RIR;
window_num = floor(size(time_varying_mic,1)/window_len); % assume no overlap between wondows, can be adapted later...
DOA_all = zeros(2,window_num); % store all DOA estimation results, both for speech source and noise source. 
GSC_out_all = [];
FAS_td_all = [];
GSC_fd_all = [];
speech_DAS_delayed_all = [];
W_save=zeros(L,num_mic-1);
W_save_another=zeros(L,num_mic-1);
w_GSC_fd = zeros(num_mic-1, L);
SIR_init = zeros(window_num,1);
SIR_DAS = zeros(window_num,1);
SIR_GSC = zeros(window_num,1);
for index_window = 1:window_num % assume no overlap between wondows, can be adapted later...
  % NOTE THAT EVERYTHING IS BASED ON NO OVERLAP BETWEEN SAMPLES!!! ESPECIALLY VAD!!!
  mic = time_varying_mic( (index_window-1)*window_len+1 : index_window*window_len ,:);
  mic_ref_temp = mic_reference( (index_window-1)*window_len+1 : index_window*window_len ,:);
  
  temp=rem(index_window,window_num/5);
  if temp == 0
    temp = window_num/5;
  end
  speech_period = [(temp-1)*window_len+1 : temp*window_len];

  y_init=mic(:,1);
  x1_init=mic_ref_temp(:,1);
  x2_init=y_init-x1_init;
  speech_temp = audioread(speech_filename_1);
  speech_temp = speech_temp(speech_period);
  VAD = abs(speech_temp(:,1))>std(speech_temp(:,1))*VAD_TD_threshold; 
  SIR_init(index_window)=compute_SIR(y_init,x1_init,x2_init,VAD);

  % estimate DOA using wideband MUSIC algorithm. 2 desired sources are hard coded in wideband MUSIC. 
  [DOA_est,STFT_mic] = MUSIC_wideband(mic, fs_RIR, Q, dist_mic, c, bool_displayDOA, L, overlap_ratio, num_mic); 
  % according to setup, speech is always on the left hand side -> speech DOA > 90!!!
  DOA_speech = DOA_est(2); DOA_all(1,index_window)=DOA_speech; % DOA of speech source 
  DOA_noise  = DOA_est(1); DOA_all(2,index_window)=DOA_noise;  % DOA of noise source (according to setup, noise is always on the right hand side)
  %% time domain GSC using DAS BF, assume that there are 2 desired sources
  speech_DAS_delayed = DAS_BF(mic, DOA_speech, num_mic, dist_mic, c, fs_RIR);
  speech_DAS_delayed_all = [speech_DAS_delayed_all; speech_DAS_delayed]; %#ok<AGROW> 
  noise_DAS_delayed  = DAS_BF(mic, DOA_noise, num_mic, dist_mic, c, fs_RIR);
  
%   reference_delayed = DAS_BF(mic_ref_temp, DOA_speech, num_mic, dist_mic, c, fs_RIR);
%   y_DAS=mean(speech_DAS_delayed,2);
%   x1_DAS=mic_ref_temp(:,1);
%   x2_DAS=y_DAS-x1_DAS;
%   SIR_DAS(index_window)=compute_SIR(y_DAS,x1_DAS,x2_DAS,VAD);

  [GSC_out,W_save] = GSC_time_varying(speech_DAS_delayed, speech_filename_1, speech_period, fs_RIR, num_mic, bool_VAD_time_domain, VAD_TD_threshold, W_save);
  % RLS can be used too. 
  GSC_out_all = [GSC_out_all; GSC_out];

%   y_GSC=GSC_out;
%   x1_GSC = mic_ref_temp(:,1);
%   x2_GSC=y_GSC-x1_GSC;
%   SIR_GSC(index_window)=compute_SIR(y_GSC,x1_GSC,x2_GSC,VAD);
    [GSC_fd_output,w_GSC_fd] = GSC_fd_time_varying(STFT_mic, RIR_sources, 2, fs_RIR, overlap_ratio, mu, ...
                                      speech_filename_1, speech_period, VAD_TD_threshold, ...
                                      speech_percentage_threshold, w_GSC_fd);
    load variables_GSC_fd.mat
FAS_td_all=[FAS_td_all; FAS_td_output];
GSC_fd_all=[GSC_fd_all;GSC_fd_output];
end

save("variables_GSC_out_all.mat",'GSC_out_all','speech_DAS_delayed_all','time_varying_mic','DOA_all','SIR_GSC',"SIR_DAS",'SIR_init');

figure;
subplot(3,1,1)
plot(time_varying_mic(:,1));hold on;plot(mean(speech_DAS_delayed_all,2));hold on;plot(GSC_out_all) % reasonable result. 
ylim([-2e-3 2e-3]);xlim([0 length(GSC_out_all)]);
legend('mic','DAS BF','GSC time domain');
title("Result time varying scenario with GSC time domain");
subtitle(sprintf('left: %s; right: %s',speech_filename_1,speech_filename_2),'interpreter','none')
subplot(3,1,2)
plot(DOA_all(1,:)); hold on; plot(DOA_all(2,:));
ylim([0 180])
legend('speech DOA','noise DOA');
title("DOA estimation, time-varying scenario");
subtitle(sprintf("speech length: %.1f s, window size: %.1f s, reverb: %d, VAD thres: %.3f", desired_len, time_varying_time_window_length, bool_time_varying_reverb, VAD_TD_threshold));
subplot(3,1,3)
plot(time_varying_mic(:,1));hold on;plot(FAS_td_all);hold on;plot(GSC_fd_all);
ylim([-2e-3 2e-3]);xlim([0 length(GSC_out_all)]);
legend('mic','FAS BF','GSC frequency domain');
title("Result time varying scenario with GSC frequency domain");

%% evaluation (DAS BF, GSC_td)
% figure(1); % comparison between DAS BF of speech and noise
% plot(mean(noise_DAS_delayed,2),'g');hold on;
% plot(mean(speech_DAS_delayed,2),'r');hold on;
% legend("DAS BF noise (averaged)", "DAS BF speech (averaged)");
% title("Comparison between DAS BF speech, and DAS BF noise");
% subtitle(computed_RIRs_LUT{RIR_GUI_LMA},'interpreter','none','fontsize',10);
% figure(2); % comparison between mic signal, DAS BF, and GSC
% plot(mean(mic,2),'b');hold on;
% plot(mean(speech_DAS_delayed,2),'r');hold on;
% plot(GSC_out,'g');hold on;
% legend("mic signal (averaged)", "DAS BF (averaged)", "GSC");
% title("comparison between mic signal, DAS BF, and GSC");
% subtitle(computed_RIRs_LUT{RIR_GUI_LMA},'interpreter','none','fontsize',10);
% if bool_play_audio_universal % whether to play audio
%   fprintf('INFO: playing DAS_BF result. Press any key to continue.\n');soundsc(mean(speech_DAS_delayed,2),fs_RIR);pause;
%   fprintf('INFO: playing GSC result. Press any key to continue.\n');soundsc(GSC_out,fs_RIR);pause;
% end
