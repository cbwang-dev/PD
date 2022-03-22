function [prediction, corr1, corr2] = LS_test_simple(attended_envelope, unattended_envelope, test_EEG, d,...
    lag_time, window_len_time, sample_freq)

  window_len_samples = sample_freq * window_len_time;
  lag_samples    = sample_freq * lag_time;
  C = size(test_EEG,2);

  M = zeros(lag_samples*C , (window_len_samples-lag_samples+1));
  for t = 1:window_len_samples-lag_samples+1
    m = test_EEG(t:t+lag_samples-1,:);
    m = m(:); % size (window_len_samples*C,1)
    M(:,t) = m;
  end
  
  envelope_hat = M' * d;
  attended_envelope = attended_envelope(1:window_len_samples-lag_samples+1);
  unattended_envelope = unattended_envelope(1:window_len_samples-lag_samples+1);

  corr1 = corr(attended_envelope, envelope_hat, 'type', 'Spearman');
  corr2 = corr(unattended_envelope, envelope_hat, 'type', 'Spearman');
  if corr1 > corr2
    prediction = true;
  else
    prediction = false;
  end
end

