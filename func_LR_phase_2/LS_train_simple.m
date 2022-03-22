function d = LS_train_simple(attended_envelope, train_EEG, ...
  lag_time, window_len_time, sample_freq)

  window_len_samples = sample_freq * window_len_time;
  lag_samples    = sample_freq * lag_time;
  C = size(train_EEG,2);
  
  M = zeros(lag_samples*C , (window_len_samples-lag_samples+1));
  for t = 1:window_len_samples-lag_samples+1
    m = train_EEG(t:t+lag_samples-1,:);
    m = m(:); % size (window_len_samples*C,1)
    M(:,t) = m;
  end
  
  R = M * M';
  r = M * attended_envelope(1:window_len_samples-lag_samples+1);
  d = R \ r; % 320 1 == 5*64
end

