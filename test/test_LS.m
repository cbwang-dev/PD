% clear
load("env_data.mat")
load("EEG.mat")


for i=1:37
  eeg =[];
  env = [];
  for j=1:numel(EEG{i,1}.trial)
    SNR=EEG{i,1}.trial{j,1}.FileHeader.SNR;
    AttendedSpeaker=string(EEG{i,1}.trial{j,1}.AttendedTrack.SexOfSpeaker);
    UnattendedSpeaker=string(EEG{i,1}.trial{j,1}.UnattendedTrack.SexOfSpeaker);
    if SNR==100 && AttendedSpeaker=='M' && UnattendedSpeaker=='F'
      eeg = cat(1,eeg,EEG{i,1}.trial{j,1}.eegprepro.reg);
      env_attend_name = {EEG{i,1}.trial{j,1}.AttendedTrack.Envelope};
      env_unattend_name = {EEG{i,1}.trial{j,1}.UnattendedTrack.Envelope};

      num_attend(j)  = sscanf(sprintf('%s', env_attend_name{:}),'envelope_track_%d.wav');
      num_unattend(j) = sscanf(sprintf('%s', env_unattend_name{:}),'envelope_track_%d.wav');

      env = cat(1,env,env_reg(:,num_attend(j)));
    end
  end

  num_attend(num_attend==0)=[];
  num_unattend(num_unattend==0)=[];


  if ~isempty(eeg)
      eeg_train = eeg(1:5000,:);
      env_train = env(1:5000,:);
      eeg_test = eeg(5001:end,:);
      env_test = env(5001:end,:);

      %% train
      L=6;
      for k=1:size(eeg_train,1)-L+1
          m = eeg_train(k:k+L-1,:);
          m = m(:);
          M(k,:) = m;
      end
      R = M'*M;
      r = M'*env_train(1:k); 
      d(:,i) = R\r;

      %% test
      for k=1:size(eeg_test,1)-L+1
          m = eeg_test(k:k+L-1,:);
          m = m(:);
          M_test(k,:) = m;
      end
      env_hat = M_test*d(:,i);

      a = corr(env_hat,env_reg(1:k,num_attend(end)), 'type', 'Spearman');
      b = corr(env_hat,env_reg(1:k,num_unattend(end)), 'type', 'Spearman');   
      c(i)= a> b;
  end
end

accuracy = sum(c)/numel(c);

