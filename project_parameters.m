%% Tunable parameters
% general parameters
dist_mic=0.05; % in meter. 0.05 -> GUI mic array;
desired_len = 10;        % desired length of audio crop, in seconds
% scenarios
RIR_GUI_LMA = 7; % from 1 to 10, not for time varying scenario
bool_time_varying_reverb = false; % true for time varying scenario with reverberation
VAD_TD_threshold = 1e-3; % threshold for VAD in time domain. % when using part1_track1_dry.wav, set to 0.5. speech1 1e-3.
% STFT 
L = 1024;                % time window width.                        FOR STFT.  
overlap_ratio = 0.5;    % overlap ratio of time window in STFT.      FOR STFT. 
% For L and overlap ratio: if the result of inverse STFT is wished to be equal to the original signal
% rem(desired_len*fs_RIR-(1-overlap_ratio)*L, overlap_ratio*L) == 0
% in other words, no remaining time samples after the sliding window operation in STFT. 
time_varying_time_window_length = 2; % in seconds. In time varying setup (week 4). The VAD in GSC should be changed too!!!
%% UNtunable parameters
c=340; % light speed, 340 m/s

%% hard coded: RIR loading
computed_RIRs_LUT = {...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_1_T60_0_63_133.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_2_T60_0_47_113.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_3_T60_0_50_108.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_4_T60_0_30_141.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_5_T60_0_59_106.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_1_T60_1_63_133.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_2_T60_1_47_113.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_3_T60_1_50_108.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_4_T60_1_30_141.mat" ...
    "computed_RIRs_phase_1/Computed_RIRs_week_4_setup_5_T60_1_59_106.mat" ...
    }; %#ok<*CLARRSTR> 
load(computed_RIRs_LUT{RIR_GUI_LMA});
% load Computed_RIRs.mat; % used only before week 4 or for test reasons. 
num_mic=size(m_pos, 1); % number of microphones *computed*, created in mySA_GUI. 
Q=size(RIR_sources,3);  % number of signal sources, created in mySA_GUI. 
%% hard coded: directories for load and store

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters for create_micsigs
audio_file_dir    = 'Audio_File/';
% speech1 part1_track1_dry part1_track2_dry whitenoise_signal_1
% Babble_noise1
speech_filename_1 = strcat(audio_file_dir, 'speech1.wav'); % represent a1 in GUI. preferably speech. 
speech_filename_2 = strcat(audio_file_dir, 'whitenoise_signal_1.wav'); % preferably noise. 
noise_filename    = strcat(audio_file_dir, 'Babble_noise1.wav');
bool_noise        = false; % choose whether to add spatially uncorrelated white microphone noise into the evaluation
                       % if true, this option will generate SNR. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters for create_micsigs_head_mount
HMIR_dir = {'Head_mounted_IRs/s30/', 'Head_mounted_IRs/s60/', 'Head_mounted_IRs/s90/', ...
            'Head_mounted_IRs/s-30/', 'Head_mounted_IRs/s-60/', 'Head_mounted_IRs/s-90/'};
HMIR_mic_name = {'HMIR_L1.wav', 'HMIR_L2.wav', 'HMIR_R1.wav', 'HMIR_R2.wav'};
IR_length = 40000; % truncation of HMIR. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bool_play_audio_universal = false;
bool_play_audio_micsigs = false; % choose whether to play audio (before filtered and after filtered by RIR)
bool_plot_audio_micsigs = false; % choose whether to plot audio after filtered by RIR

%% parameters for MUSIC
bool_displayDOA = 1;

%% parameters for DAS_BF
bool_displayDiffSNR = 0;

%% parameters for GSC (time domain)
bool_VAD_time_domain = 1; % choose whether to use VAD information to update the adaptive filtering parameters. 
VAD_TD_threshold = 0.5; % threshold for VAD in time domain. % when using part1_track1_dry.wav, set to 0.5. speech1 1e-3. 
stepsize_time_domain = 0.1;

%% parameters for GSC_fd
mu=0.1;
speech_percentage_threshold = 0.1;
bool_VAD_frequency_domain = 1; % choose whether to use VAD information to update the adaptive filtering parameters. 
bool_displayInformation_GSC_fd = 0;
bool_test_use_DAS_BF = 0; % used in VAD_STFT.m

%% Path Configurations
addpath('./func_metrics/')
addpath('./func_preproc/')