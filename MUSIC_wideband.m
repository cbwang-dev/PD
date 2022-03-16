function [DOA_est,S] = MUSIC_wideband(mic, fs_RIR, Q, dist_mic, c, bool_displayDOA, L, overlap_ratio, num_mic)
    fprintf("====> start MUSIC algorithm\n")
    %% Compute a (subsampled) short-time Fourier transform
    overlap_length_rounded = round(L*overlap_ratio); 
    % round the length, possibly resulting into 'input mic signal length != output mic signal length', so it is better
    % to 1) make L*overlap_ratio ann integer and 2) no remainder after the sliding window operation. This is important
    % for synchronization scenario in phase 3 assignment. This is further noted in project_parameters.m

    %% get an array of [M,n_F,n_T] -> [5,fs_RIR,fs_RIR*desired_len]
    % M the number of microphones, (5) can be 4
    % n_F the number of frequency bins (1024, check F1) and 
    % n_T the number of time samples (452, check T1).
    S = [];
    F1=0;
    for i=1:num_mic
        [temp,F1] = stft(mic(:,i),fs_RIR,'Window',sqrt(hann(L)),'OverlapLength',overlap_length_rounded);
        S = cat(3,S,temp);
    end
    S = permute(S, [3,1,2]);


    %% start MUSIC main
    p_omega=S;
    theta = 0:0.5:180; % search angles
    num_mic = size(mic,2);
    num_freq = size(S,2);
    p_music = zeros(num_freq/2-1,length(theta));

    for index_freq=2:num_freq/2 % frequency index 2:512
        p_omega_temp=squeeze(p_omega(:,index_freq,:));
        Rx=cov(p_omega_temp');           % Data covariance matrix
        [eigenVec,~] = eig(Rx);          % Find the eigenvalues and eigenvectors of R 
        E = eigenVec(:,1:num_mic-Q);     % Estimate noise subspace 
                                         % Note that eigenvalues sorted ascending on columns of "eigenVal")
        % Peak search     
        g = exp(-1i*2*pi*dist_mic*(0:num_mic-1)'*cosd(theta(:).')/(c/(F1(L+1-index_freq)))); % [5 361]
        for k=1:length(theta) % DOA candidate index
            p_music(index_freq-1,k) = 1/(g(:,k)'*(E*E')*g(:,k)); 
        end
    end

    p_music_geo_avg=zeros(1,size(p_music,2));

    p_music=log(p_music);
    for i=1:size(p_omega,2)/2-1
        p_music_geo_avg=p_music_geo_avg+p_music(i,:);
    end
    p_music_geo_avg=(1/(size(p_omega,2)/2-1))*p_music_geo_avg;
    p_music_geo_avg=exp(p_music_geo_avg);
    figure;plot(theta,real(p_music_geo_avg));

    %% save DOA_est
    [peaks,locs]=findpeaks(real(p_music_geo_avg));
    [~,locs_index]=sort(peaks);
    DOA_est=zeros(1,2); % here we assume that only 2 sources. Additional sources may apply.
    for i=1:Q
        DOA_est(i)=theta(locs(locs_index(end-(i-1)))+1);
    end
    if bool_displayDOA
        fprintf("RESULT: estimated DOA is %.1f and %.1f.\n", DOA_est(1), DOA_est(2))
    end
    save("variables_MUSIC.mat", 'theta','p_music_geo_avg')
    save('DOA_est.mat','DOA_est'); % for the purpose of drawing the line in GUI. DO NOT COMMENT OUT.
    DOA_est = sort(DOA_est); % in order to make sure DOA_est is in ascending order
    fprintf("====> finished MUSIC algorithm\n\n")
end