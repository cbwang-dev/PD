function [LR_result,LS_weight_updated] = LR_simple(S_a, S_u, M, LS_weight_init, lag_time, windowlength_time)
% LR_simple: compute linear regression result
% S_a: unattended track
% S_u: attended track
% M: EEG signals, (time_samples, number_channels)
% LS_weight_init: initial weight
% lag_time: time lag in seconds
% windowlength_time: window length in seconds

lagtime = 250e-3; % 
sample_freq = 20;
windowlength_time = 10; % choose windowlength in time
windowlength = windowlength_time*sample_freq; %transform windowlength into samples
c = 64; % number of channels
N_l = sample_freq*lagtime; %N_l

for t = 1:length(S_a,1)
  m = M(t:t+N_l-1, :);
  R = m * m';
  r_ms = m * S_a(t);
  d = R\r_ms;
end


