function d = LS_train_regularized(attended_envelope, train_EEG, ...
  lag_time, window_len_time, sample_freq, ...
  lambda, Q_type)
  % Q_type: 1 for identity matrix (ridge regularization), 2 for discrete derivative regularizer.

  window_len_samples = sample_freq * window_len_time;
  lag_samples    = sample_freq * lag_time;
  C = size(train_EEG,2);
  
  M = zeros(lag_samples*C , (window_len_samples-lag_samples+1));
  for t = 1:window_len_samples-lag_samples+1
    m = train_EEG(t:t+lag_samples-1,:);
    m = m(:); % size (window_len_samples*C,1)
    M(:,t) = m;
  end
  
  R = M * M'; % R must be a square matrix
  r = M * attended_envelope(1:window_len_samples-lag_samples+1);

  num_coefficients = size(R, 1);
  if Q_type == 1
    Q = eye(num_coefficients);
  elseif Q_type == 2 % equation 11
    Q = diag( 2*ones(1,num_coefficients  ),  0) + ...
        diag(-1*ones(1,num_coefficients-1),  1) + ...
        diag(-1*ones(1,num_coefficients-1), -1);
    Q(1,1) = 1;
    Q(num_coefficients, num_coefficients) = 1;
  else
    error('Q_type must be 1 or 2');
  end
  
  z = mean(diag(R));  % equation 10
  R = R + lambda*z*Q; % equation 10
  d = R \ r; % 320 1 == 5*64
end