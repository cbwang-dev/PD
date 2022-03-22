%%% Script to compute the signal-to-interference ratio for two sources (one
%%% target source and one interfering source). The script takes into
%%% account possible switches between which source is the target and which
%%% one is the interference. The script assumes there is access to each
%%% source's contribution in the beamformer output.

%%%REQUIRED INPUTS:
% y: actual output signal of the beamformer (Nx1 vector where N is the number of time samples)

% x1: beamformer output attributed to source 1 (Nx1 vector)

% x2: beamformer output attributed to source 2 (Nx1 vector)

% ground_truth: Nx1 vector with zeros and ones indicating for each time sample which source is the target(1=x1, 0=x2).



function [SIR]=compute_SIR(y,x1,x2,ground_truth)

if sqrt(sum((y-x1-x2).^2))/sqrt(sum(y.^2))>0.01 %%%Sanity check (check whether y=x1+x2 based on RMSE of residual)
    disp('!!!!!!Something is wrong, y should be the sum of x1 and x2!!!!!')  
    disp('SIR can not be computed')  
    SIR=NaN;
elseif sum(ground_truth)+sum(1-ground_truth)~=length(ground_truth)
    disp('!!!!!!ground_truth vector is not binary!!!!!!')
    disp('SIR can not be computed')  
    SIR=NaN;
else
    SIR=10*log10(var(x1.*ground_truth+x2.*(1-ground_truth))/var(x2.*ground_truth+x1.*(1-ground_truth)));
end