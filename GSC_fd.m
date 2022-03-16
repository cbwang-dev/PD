function [GSC_fd_output,w_GSC_fd_save] = GSC_fd(STFT_mics, RIR_sources, desired_DOA, fs_RIR, overlap_ratio, mu, ...
                                  concentrating_speech_filename, desired_len, VAD_TD_threshold, ...
                                  speech_percentage_threshold, w_GSC_fd_old)
    % desired DOA is index, not real value. For example, 1 or 2 in this assignment.
    fprintf("====> start frequency domain GSC\n")
    %% constructing FAS BF coefficients
    num_mics=size(STFT_mics,1); 
    num_freq=size(STFT_mics,2); 
    num_DOAs=size(RIR_sources,3); 
    num_frames=size(STFT_mics,3);
    L = num_freq; 
    overlap_length_rounded = round(L*overlap_ratio);

    h     = zeros(num_freq,num_mics,num_DOAs); 
    w_fas = zeros(num_freq,num_mics,num_DOAs); 
    for index_DOA = 1:num_DOAs
        a1 = fft(RIR_sources(:,1,index_DOA),num_freq); % choose 1 or 5 not impact on the result (low amplitude)
        for index_mic = 1:num_mics
            a = fft(RIR_sources(:,index_mic,index_DOA),num_freq);
            h(:,index_mic,index_DOA) = a ./ a1; % normalize w.r.t first mic 
        end
    end 
    for index_DOA = 1:num_DOAs
        for index_freq = 1:num_freq
            temp_h = h(index_freq,:,index_DOA).';
            w_fas(index_freq,:,index_DOA) = temp_h./(temp_h'*temp_h);
        end
    end % However, there is some problems (mainly robotic sound) in FAS BF. Now step ahead. 

    %% obtain FAS BF result, saved in STFT_FAS_BF_single
    STFT_FAS_BF_single = zeros(num_freq, num_frames);
    for index_frame=1:num_frames % same operation iterating over time frame
        temp_w_fas = squeeze(w_fas(num_freq/2,:,desired_DOA));
        STFT_FAS_BF_single(num_freq/2,index_frame) = conj(temp_w_fas) * squeeze(STFT_mics(:,num_freq/2,index_frame)); 
        temp_w_fas = squeeze(w_fas(num_freq,:,desired_DOA));
        STFT_FAS_BF_single(num_freq,index_frame) = conj(temp_w_fas) * squeeze(STFT_mics(:,num_freq,index_frame)); 
        for index_freq = 1:num_freq/2-1
            STFT_FAS_BF_single(index_freq,index_frame) = conj(temp_w_fas) * squeeze(STFT_mics(:,index_freq,index_frame)); 
            STFT_FAS_BF_single(end-index_freq,index_frame) = conj(STFT_FAS_BF_single(index_freq,index_frame));
        end
    end
    %% change VAD time domain to STFT domain
    VAD = compute_VAD(concentrating_speech_filename,desired_len,fs_RIR,VAD_TD_threshold);
    VAD_STFT_out = VAD_STFT(VAD, STFT_mics, speech_percentage_threshold);
    %% adaptive filtering process
    GSC_fd_out = zeros(num_freq,num_frames); % [1024 429]
    t = zeros(num_freq,num_frames);
%     w_GSC_fd = zeros(num_mics-1, num_freq); % [4 1024] initialize outside any loop, checked
    w_GSC_fd = w_GSC_fd_old;

    tic
    for index_frame = 1:num_frames % outer loop, time frame
        for index_freq = 1:num_freq % inner loop, frequency bin 
            temp_h = squeeze(h(index_freq,:,desired_DOA)).'; % [5 1]
            % blocking_matrix = null(conj(temp_h)','r');
            blocking_matrix = null(temp_h.','r'); % [5 4]
            % checked: blocking_matrix.' * temp_h == 0
            blocked_S = squeeze(STFT_mics(:,index_freq,index_frame)).' * conj(blocking_matrix); % [1 4] conjugate
            t = blocked_S * conj(w_GSC_fd(:,index_freq)); % [1 1]
            GSC_fd_out(index_freq,index_frame) = STFT_FAS_BF_single(index_freq,index_frame) - t;
            frob_norm=norm(blocked_S,'fro'); 
            w_GSC_fd(:,index_freq) = w_GSC_fd(:,index_freq) + (1-VAD_STFT_out(index_frame)) * ...
                                     ( mu/(frob_norm^2) * blocked_S * conj(GSC_fd_out(index_freq,index_frame)) ).';
        end
        if rem(index_frame,100) == 0
            fprintf("INFO: processed frame index: %d of %d \n",index_frame, num_frames);
        end
    end
    toc

    % Give final STFT result to the synthesis filter bank. 
    % COMMENT OUT second and third line after completion. 2nd and 3rd line is for debugging!!!
    result_STFT=GSC_fd_out;
    w_GSC_fd_save = w_GSC_fd;
%     result_STFT=STFT_FAS_BF_single; % check whether the FAS BF result is reasonable (output in time domain is real)

    %% switch to time domain
    % use 'ConjugateSymmetric',true to avoid the imaginary part of the result
    FAS_td_output = istft(STFT_FAS_BF_single,fs_RIR,'Window',sqrt(hann(L)),'OverlapLength',overlap_length_rounded,'ConjugateSymmetric',true);
    GSC_fd_output = istft(result_STFT,fs_RIR,'Window',sqrt(hann(L)),'OverlapLength',overlap_length_rounded,'ConjugateSymmetric',true);
    save("variables_GSC_fd.mat",'w_fas','h','GSC_fd_output','FAS_td_output')
    fprintf("INFO: stored essential intermediate variables in variables_GSC_fd.mat\n")
    fprintf("====> finish frequency domain GSC\n")
end