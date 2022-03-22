% subject specific linear regression.

clear;runme;
preproc_LR_dir = './data_phase_2/preprocessed_LR/';
subject_names = dir(preproc_LR_dir);
subject_names = {subject_names.name};

use_regularization = true;
lambda = 0.2;
Q_type = 2;
evaluated_SNR = 100;



accuracy_list = [];

for subject_name = subject_names

  if strcmp(subject_name{1}(1), '.')
    continue;
  end % get rid of the hidden files

  [EEG_train, envelope_train, EEG_test, envelope_test] = train_test_split(evaluated_SNR, ...
    subject_names, preproc_LR_dir);

  load(strcat(preproc_LR_dir, subject_name{1}, '/trial-1.mat'));
  train_EEG = trial.ProcessedEegData;
  gt_env = trial.ProcessedAttendedTrack;

  sample_freq = 20;
  lag_time = 250e-3;
  window_len_time = 50;

  % train
  if use_regularization
    d = LS_train_regularized(gt_env, train_EEG, ...
      lag_time, window_len_time, sample_freq, ...
      lambda, Q_type);
  else
    d = LS_train_simple(gt_env, train_EEG, ...
      lag_time, window_len_time, sample_freq);
  end

  % test
  subject_str = strcat(subject_name{1}, '/');
  trial_names = dir(strcat(preproc_LR_dir, subject_str));
  count_correct = 0;
  count_all     = 0;
  trial_names = {trial_names.name};

  for trial_name = trial_names
    if strcmp(trial_name{1}(1), '.')
      continue;
    end % get rid of the hidden files
    load(strcat(preproc_LR_dir, subject_str, string(trial_name)));
    test_EEG = trial.ProcessedEegData;
    attended_env = trial.ProcessedAttendedTrack;
    unattended_env = trial.ProcessedUnattendedTrack;
    [prediction, corr1, corr2] = LS_test_simple(attended_env, unattended_env, test_EEG, d,...
        lag_time, window_len_time, sample_freq);
    count_correct = count_correct + prediction * 1;
    count_all     = count_all + 1;
  end

  accuracy = count_correct / count_all;
  fprintf("Accuracy of subject %s : %f\n", subject_name{1}, accuracy);
  accuracy_list = [accuracy_list accuracy];
end




% accuracy_simpleLS_50ms = accuracy_list';
% save('variables_accuracy_simpleLS_50ms.mat', 'accuracy_simpleLS_50ms');
% boxplot(accuracy_simpleLS_50ms)

% accuracy_regularizedLS_lambda_01_50ms = accuracy_list';
% save('variables_accuracy_regularizedLS_lambda_01_50ms.mat', 'accuracy_regularizedLS_lambda_01_50ms');
% boxplot(accuracy_regularizedLS_lambda_01_50ms)

accuracy_regularizedLS_lambda_02_50ms = accuracy_list';
save('variables_accuracy_regularizedLS_lambda_02_50ms.mat', 'accuracy_regularizedLS_lambda_02_50ms');
boxplot(accuracy_regularizedLS_lambda_02_50ms)

% boxplot([accuracy_simpleLS_50ms accuracy_regularizedLS_lambda_01_50ms]);ylim([0 1])
