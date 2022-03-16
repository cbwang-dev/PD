function mic = create_micsigs(speech_filename_1, speech_filename_2, noise_filename, ...
    fs_RIR, RIR_sources, RIR_noise, desired_len, num_mic, Q, ...
    bool_play_audio, bool_plot_audio, bool_noise)
    fprintf("====> start creating mic signals\n")
    %% sanity check
    % before calling this function, make sure that `load('Computed_RIRs.mat')` is done. 
    % this is assured in project_parameters.m
    if fs_RIR ~= 44100
        disp('Sampling frequency of the RIRs is wrong')
        exit
    end
    
    %% load target audios
    [source_1, fs_source_1] = audioread(speech_filename_1); % for first audio file
    [source_2, fs_source_2] = audioread(speech_filename_2); % for second audio file
    
    %% set desired length of recorded microphone signals
    source_1 = source_1(1:desired_len*fs_source_1); 
    source_2 = source_2(1:desired_len*fs_source_2); 
    
    %% play the cropped audios
    if bool_play_audio
        fprintf("INFO: playing 1st oringinal audio file (%d seconds)...\n", desired_len)
        soundsc(source_1,fs_source_1);pause;
        fprintf("INFO: playing 2nd oringinal audio file (%d seconds)...\n", desired_len)
        soundsc(source_2,fs_source_2);pause;
    end
    
    %% resample
    source_1 = resample(source_1,fs_RIR,fs_source_1);
    source_2 = resample(source_2,fs_RIR,fs_source_2)*0.5;

    %% filtered by room impulse response
    signal = [];
    for i=1:num_mic
        temp_1 = fftfilt(RIR_sources(:,i,1),source_1);
        temp_2 = fftfilt(RIR_sources(:,i,2),source_2);
        temp = temp_1 + temp_2;
        signal = [signal temp];
    end

    if bool_noise
        noise = wgn(size(signal,1),size(signal,2),10*log10(0.1*var(signal(:,1))));
        mic = signal + noise;
        power_signal=var(signal);
        power_noise =var(noise);
        SNR=10*log10(power_signal/power_noise);
        fprintf("DATA: SNR of originally created mic signal is %.2f.\n", SNR)
    else
        mic = signal;
    end
    
    %% visualization and presentation
    % play the microphone signals that are recorded by the microphone array 
    if bool_play_audio
        fprintf("INFO: playing filtered (received) audio in 1st mic (%d seconds)...\n", desired_len)
        soundsc(mic(:,1), fs_RIR);pause;
        fprintf("INFO: playing filtered (received) audio in 2nd mic (%d seconds)...\n", desired_len)
        soundsc(mic(:,2), fs_RIR);pause;
    end
    
    % visualize the microphone signal
    if bool_plot_audio
        figure;
        plot(mic(:,1),'r')
        hold on
        plot(mic(:,2),'g')
    end
    fprintf("====> finished creating mic signals\n\n")
end