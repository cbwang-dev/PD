clear;
preproc_CNN_dir = './data_phase_2/preprocessed_CNN_test_sub_1_37/';

EEG_SNR_100 = [];
env_1_SNR_100 = [];
env_2_SNR_100 = [];
EEG_SNR_4 = [];
env_1_SNR_4 = [];
env_2_SNR_4 = [];

subject_names = dir(preproc_CNN_dir); 
subject_names = subject_names(4:end); % include DS_Store
subject_names = {subject_names.name};
for subject_name =subject_names
  subject_name = subject_name{1}; % convert union to string
  subject_dir = strcat(preproc_CNN_dir, subject_name, '/');
  trial_names = dir(subject_dir);
  trial_names = trial_names(3:end); % include . and ..
  trial_names = {trial_names.name};
  for trial_name = trial_names
    trial_name = trial_name{1}; % convert union to string
    trial_dir = strcat(subject_dir, trial_name);
    fprintf("INFO: Loading %s\t ", trial_dir);
    load(trial_dir);
    SNR = trial.FileHeader.SNR;
    fprintf("SNR %d\n", SNR);
    if SNR == 100
      EEG_SNR_100 = [EEG_SNR_100; trial.ProcessedEegData];
      env_1_SNR_100 = [env_1_SNR_100; trial.Processedtrack1];
      env_2_SNR_100 = [env_2_SNR_100; trial.Processedtrack2];
    elseif SNR == 4
      EEG_SNR_4 = [EEG_SNR_4; trial.ProcessedEegData];
      env_1_SNR_4 = [env_1_SNR_4; trial.Processedtrack1];
      env_2_SNR_4 = [env_2_SNR_4; trial.Processedtrack2];
    end
  end
end

% fprintf("INFO: size of EEG_SNR_100: (%d,%d)\n", size(EEG_SNR_100,1), size(EEG_SNR_100,2));
% fprintf("INFO: size of env_1_SNR_100: (%d,%d)\n", size(env_1_SNR_100,1), size(env_1_SNR_100,2));
% fprintf("INFO: size of env_2_SNR_100: (%d,%d)\n", size(env_2_SNR_100,1), size(env_2_SNR_100,2));
% fprintf("INFO: size of EEG_SNR_4: (%d,%d)\n", size(EEG_SNR_4,1), size(EEG_SNR_4,2));
% fprintf("INFO: size of env_1_SNR_4: (%d,%d)\n", size(env_1_SNR_4,1), size(env_1_SNR_4,2));
% fprintf("INFO: size of env_2_SNR_4: (%d,%d)\n", size(env_2_SNR_4,1), size(env_2_SNR_4,2));

length_one_trial = 3500;

trials_SNR_100 = size(EEG_SNR_100,1)/length_one_trial;
EEG_SNR_100_reshaped = reshape(EEG_SNR_100, [trials_SNR_100, length_one_trial, size(EEG_SNR_100,2)]);
env_1_SNR_100 = reshape(env_1_SNR_100, [trials_SNR_100, length_one_trial, size(env_1_SNR_100,2)]);
env_2_SNR_100 = reshape(env_2_SNR_100, [trials_SNR_100, length_one_trial, size(env_2_SNR_100,2)]);

trials_SNR_4 = size(EEG_SNR_4,1)/length_one_trial;
EEG_SNR_4_reshaped = reshape(EEG_SNR_4, [trials_SNR_4, length_one_trial, size(EEG_SNR_4,2)]);
env_1_SNR_4 = reshape(env_1_SNR_4, [trials_SNR_4, length_one_trial, size(env_1_SNR_4,2)]);
env_2_SNR_4 = reshape(env_2_SNR_4, [trials_SNR_4, length_one_trial, size(env_2_SNR_4,2)]);

% fprintf("INFO: size of EEG_SNR_100_reshaped: (%d,%d,%d)\n", size(EEG_SNR_100_reshaped,1), size(EEG_SNR_100_reshaped,2), size(EEG_SNR_100_reshaped,3));
% fprintf("INFO: size of env_1_SNR_100: (%d,%d)\n", size(env_1_SNR_100,1), size(env_1_SNR_100,2)));
% fprintf("INFO: size of env_2_SNR_100: (%d,%d)\n", size(env_2_SNR_100,1), size(env_2_SNR_100,2)));
% fprintf("INFO: size of EEG_SNR_4_reshaped: (%d,%d,%d)\n", size(EEG_SNR_4_reshaped,1), size(EEG_SNR_4_reshaped,2), size(EEG_SNR_4_reshaped,3));
% fprintf("INFO: size of env_1_SNR_4: (%d,%d)\n", size(env_1_SNR_4,1), size(env_1_SNR_4,2)));
% fprintf("INFO: size of env_2_SNR_4: (%d,%d)\n", size(env_2_SNR_4,1), size(env_2_SNR_4,2)));

% save("dataset_CNN_test_1_37_SNR_100.mat","EEG_SNR_100_reshaped","env_1_SNR_100","env_2_SNR_100");
% save("dataset_CNN_test_1_37_SNR_4.mat","EEG_SNR_4_reshaped","env_1_SNR_4","env_2_SNR_4");

save("dataset_CNN_test_1_37_SNR_100.mat","EEG_SNR_100_reshaped","env_1_SNR_100","env_2_SNR_100");
save("dataset_CNN_test_1_37_SNR_100.mat","EEG_SNR_4_reshaped","env_1_SNR_4","env_2_SNR_4");

fprintf("double check: size of EEG_SNR_100: (%d,%d)\n", size(EEG_SNR_100,1), size(EEG_SNR_100,2));
fprintf("double check: size of EEG_SNR_100_reshaped: (%d,%d,%d)\n", size(EEG_SNR_100_reshaped,1), size(EEG_SNR_100_reshaped,2), size(EEG_SNR_100_reshaped,3));
fprintf("double check: size of EEG_SNR_100_test_set: (%d,%d,%d)\n", size(EEG_SNR_100_test_set,1), size(EEG_SNR_100_test_set,2), size(EEG_SNR_100_test_set,3));
fprintf("double check: size of EEG_SNR_100_train_set: (%d,%d,%d)\n\n", size(EEG_SNR_100_train_set,1), size(EEG_SNR_100_train_set,2), size(EEG_SNR_100_train_set,3));
