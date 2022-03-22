desired_len = 10;
VAD_TD_threshold = 0.5;
[speech,fs_RIR] = audioread("Audio_File/part1_track1_dry.wav");
speech = speech(1:desired_len*fs_RIR);
VAD = abs(speech(:,1))>std(speech(:,1))*VAD_TD_threshold; 

subplot(2,1,1);plot(speech);subplot(2,1,2);plot(VAD)