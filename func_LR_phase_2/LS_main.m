function result = LS_main(train_EEG, train_envelope, valid_EEG, valid_envelope, ...
        lagtime, windowlength_time, sample_freq, ...
        b_visu)
  %% train
  L=windowlength_time*sample_freq;
  for k=1:size(train_EEG,1)-L+1
    m = eeg_train(k:k+L-1,:);
    m = m(:);
    M(k,:) = m;
  end

  R = M'*M;
  r = M'*train_envelope(1:k); 
  d(:,i) = R\r;

  %% test
  for k=1:size(valid_EEG,1)-L+1
    m = eeg_test(k:k+L-1,:);
    m = m(:);
    M_test(k,:) = m;
  end
  env_hat = M_test*d(:,i);
end