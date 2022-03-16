function mic = create_micsigs_head_mount(speech_filename_1, fs_RIR, HMIR_dir, HMIR_mic_name, IR_length, desired_len)
    % sidenote: only one single sound source and no noise source is implemented. 
    fprintf("====> start creating mic signals (head mount case)\n")
    
    if fs_RIR ~= 44100
        disp('Sampling frequency of the RIRs is wrong')
        exit
    end % sample frequency is always 44100!!!

    [source_1, fs_source_1] = audioread(speech_filename_1); % for first audio file
    source_1 = resample(source_1,fs_RIR,fs_source_1);
    source_1 = source_1(1:desired_len*fs_RIR); % truncation of speech signal

    RIR_sources = create_rirs_head_mount(HMIR_dir, HMIR_mic_name, IR_length);
    num_dirs = size(RIR_sources, 2);
    num_mics = size(RIR_sources, 3);
    if num_dirs ~= 6 || num_mics ~= 4
        disp('RIR dimension for head mount is wrong!')
        exit
    end % RIR sources always has the dimension of (:, 6, 4)!!!
    mic = zeros(length(source_1), num_dirs, num_mics);
    for index_dir = 1:num_dirs
        for index_mics = 1:num_mics
            mic(:, index_dir, index_mics) = fftfilt(RIR_sources(:, index_dir, index_mics), source_1);
        end
    end 
end