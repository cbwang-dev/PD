%% preparation
clear;
project_parameters; % load parameters in project_parameters.m
%% generate mic signal (head mount case)
mic = create_micsigs_head_mount(speech_filename_1, fs_RIR, HMIR_dir, HMIR_mic_name, IR_length, desired_len);
% notations of mic array:
% 1) size is                         [441000 6 4]
% 2) second dimension: azimuth angle [+30 +60 +90 -30 -60 -90]
% 3) third dimension: mic number     [L1 L2 R1 R2]
%% several sound experiments
% soundsc([mic(:,1,1),mic(:,1,3)],fs_RIR); fprintf("====> listening to s+30: [L1 R1].\n"); pause;
% soundsc([mic(:,4,1),mic(:,4,3)],fs_RIR); fprintf("====> listening to s-30: [L1 R1].\n"); pause;
% soundsc([mic(:,2,1),mic(:,2,3)],fs_RIR); fprintf("====> listening to s+60: [L1 R1].\n"); pause;
% soundsc([mic(:,5,1),mic(:,5,3)],fs_RIR); fprintf("====> listening to s-60: [L1 R1].\n"); pause;
% soundsc([mic(:,3,1),mic(:,3,3)],fs_RIR); fprintf("====> listening to s+90: [L1 R1].\n"); pause;
% soundsc([mic(:,6,1),mic(:,6,3)],fs_RIR); fprintf("====> listening to s-90: [L1 R1].\n"); pause;
