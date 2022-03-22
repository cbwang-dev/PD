function [GSC_out,W_save] = GSC_time_varying(delayed_sequence, concentrating_speech_filename, ...
  speech_period, fs_RIR, num_mic, bool_VAD, VAD_TD_threshold, W_init)
fprintf("====> start time domain GSC\n")

%% changeable parameters
blocking_matrix = [ones(1,num_mic-1); diag(-ones(1,num_mic-1))]; % Griffiths Jim blocking matrix
mu=0.1; % stepsize
L=1024; % filter length
delta = L/2; % delay

%% VAD
speech = audioread(concentrating_speech_filename);
speech = speech(speech_period);
VAD = abs(speech(:,1))>std(speech(:,1))*VAD_TD_threshold; 

%% prepare for necessary data of adaptive filtering
% product of delayed mic signals and blocking matrix, aka noise reference, denoted in x_{1...M-1} in week3.pdf
X = delayed_sequence * blocking_matrix; % [220500 4]
% the sound of mean(X,2) should contain the interference speech
% soundsc(mean(X,2),fs_RIR);pause;

% Starting NLMS filtering
averaged_sequence=mean(delayed_sequence,2);
% soundsc(averaged_sequence,fs_RIR);pause;
d=[zeros(delta,1);averaged_sequence]; % [220500+512 1] denoted in d in week3.pdf

W=W_init; % weight initialization [1024 4]
GSC_out=zeros(length(d),1); % outputs
% adaptive filter should only be updated when no speech is present to avoid signal cancellation!
% That is why we use VAD
for i=L:length(X(:,1))
frob_norm=norm(X(i-L+1:i,:),'fro');  
t = trace(W'*X(i-L+1:i,:)); % calculating noise samples [4 1024] * [1024 4] result [1024 1024] trace [1 1]
%         GSC_out(i)=d(i)-t; % subtracting noise samples from delay and sum beamformer audio
GSC_out(i)=d(i)-t;
%         W=W+(mu/(frob_norm^2))*X(i-L+1:i,:)*GSC_out(i); % weight updates
W=W+(1-VAD(i))*(mu/(frob_norm^2))*X(i-L+1:i,:)*GSC_out(i); % weight updates with VAD modification
end

% d=d(delta+1:end);
GSC_out=GSC_out(delta+1:end);

%% SNR calculations
signal_power_in=var(averaged_sequence(VAD==1));
noise_power_in=var(averaged_sequence(VAD==0));
SNR_in_GSC=10*log10((signal_power_in-noise_power_in)/noise_power_in);
fprintf('INFO: SNR of FAS BF is\t%f\n',SNR_in_GSC); 
signal_power_GSC=var(GSC_out(VAD==1));
noise_power_GSC=var(GSC_out(VAD==0));    % Calculate noise power only where noise is active (speech is not active)
SNR_out_GSC=10*log10((signal_power_GSC-noise_power_GSC)/noise_power_GSC);
fprintf('INFO: SNR of GSC is \t%f\n',SNR_out_GSC);      
W_save = W;
fprintf("====> finish time domain GSC\n")
end