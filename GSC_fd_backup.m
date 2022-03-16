function [GSC_fd_output] = GSC_fd(S, fs_RIR, L, overlap_ratio, Q, dist_mic, c, TEST_DOA, mu,...
                                  bool_test_use_DAS_BF, mic_DAS_delayed)
    overlap_length_rounded = round(L*overlap_ratio);
    num_mic   = size(S,1);
    num_freq  = size(S,2);
    num_frame = size(S,3);
    fprintf("====> start frequency domain GSC\n")
    
    %% generate steering vector (LUT), size is the same as RIR_sources (or not) [: num_mic num_src]
    % h     is the steering vector   according to assignment
    % a     is the DFT of RIRs       according to assignment
    % w_fas is the weights of FAS BF according to assignment
    load Computed_RIRs.mat % RIR_sources: time domain, [22050 5 2] 
%     RIR_sources = RIR_sources(1:1000,:,:); % crop the zeros
    num_DOA   = size(RIR_sources,3);
    num_freq = L; 
    h     = zeros(num_freq,num_mic,num_DOA); % confirmed from TA's mail
    w_fas = zeros(num_freq,num_mic,num_DOA); % confirmed from TA's mail
    
    % for index_DOA = 1:num_DOA
    %     a1 = fft(RIR_sources(:,1,index_DOA),num_freq); 
    %     for index_mic = 1:num_mic
    %         a = fft(RIR_sources(:,index_mic,index_DOA),num_freq);
    %         h(:,index_mic,index_DOA) = a ./ a1; % normalize w.r.t first mic 
    %         temp_h = h(:,index_mic,index_DOA);
    %         w_fas(:,index_mic,index_DOA) = temp_h/(ctranspose(temp_h)*temp_h); % H superscript -> conjugate transpose
    %     end
    % end 
    
    for index_DOA = 1:num_DOA
        a1 = fft(RIR_sources(:,1,index_DOA),num_freq); 
        for index_freq = 1:num_freq
            a = fft(RIR_sources(index_freq,:,index_DOA),num_freq);
            h(index_freq,:,index_DOA) = a ./ a1; % normalize w.r.t first mic
            temp_h = h(index_freq,:,index_DOA).';
            w_fas(index_freq,:,index_DOA) = temp_h/(ctranspose(temp_h)*temp_h);
        end
    end
            
    %% steer the STFT result (filter and sum), resulting two variables:
    % 1) steered_STFT_1_mic [num_freq num_frame]
    % 2) steered_STFT_5_mic [num_mic num_freq num_frame] the same as S
    steered_STFT_5_mic = zeros(size(S));
    steered_STFT_1_mic = zeros(num_freq, num_frame);
    for index_frame=1:num_frame % same operation iterating over time frame
        for index_freq = 1:num_freq
            temp_w_fas = squeeze(w_fas(index_freq,:,TEST_DOA)).';
            steered_STFT_1_mic(index_freq,index_frame) = temp_w_fas' * squeeze(S(:,index_freq,index_frame)); 
        end
    end
    
    
    %% adaptive filtering process
    GSC_fd_out = zeros(num_freq,num_frame); % [1024 429]
    t = zeros(num_freq,num_frame);
    w_GSC_fd = zeros(num_mic-1, num_freq); % [4 1024] initialize outside any loop, checked
    for index_frame = 1:num_frame % outer loop, time frame
        for index_freq = 1:num_freq % inner loop, frequency bin
            temp_h = squeeze(h(index_freq,:,TEST_DOA)).'; % [5 1]
            blocking_matrix = null(conj(temp_h)','r');
            % disp((blocking_matrix.'*temp_h).') % display whether the mult result is [0 0 0 0]
            blocked_S = squeeze(S(:,:,index_frame)).'*(blocking_matrix); % [1024 4]
            t(index_freq,index_frame) = trace(blocked_S*w_GSC_fd); % [1 1]
            GSC_fd_out(index_freq,index_frame) = steered_STFT_1_mic(index_freq,index_frame)-t(index_freq,index_frame);
            frob_norm=norm(blocked_S,'fro'); 
            w_GSC_fd=w_GSC_fd+((mu/(frob_norm^2))*blocked_S*GSC_fd_out(index_freq,index_frame)).';
        end
        if rem(index_frame,100) == 0
            fprintf("INFO: processed frame index: %d of %d ",index_frame, num_frame);
        end
    end
    
    processed_S = steered_STFT_1_mic; 
    % choose which signal to pass into synthesis filter
    % if want to evaluate the FAS BF result, choose steered_STFT_1_mic
    % if want to evaluate the GSC fd result, choose GSC_fd_out
    
    %% synthesis filter bank
    synthesis_result = istft(processed_S,fs_RIR,'Window',sqrt(hann(L)),'OverlapLength',overlap_length_rounded);
    GSC_fd_output = synthesis_result;
    fprintf("====> finish frequency domain GSC\n\n")
    
    %% for debugging purposes, save intermediate variables
    save("variables_GSC_fd.mat", "synthesis_result", 'w_fas','h');
end