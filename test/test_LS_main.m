load ./data_phase_2/preprocessed_LR/001/trial-1.mat
train_EEG = trial.ProcessedEegData;
gt_env = trial.ProcessedAttendedTrack;

sample_freq = 20;
lag_time = 250e-3;
windowlength_time = 50;

% train
d = LS_train_simple(gt_env, train_EEG, ...
lag_time, windowlength_time, sample_freq);

% test
subject_str = '003/';
mat_names = dir(strcat("./data_phase_2/preprocessed_LR/", subject_str));
count_correct = 0;
count_all     = 0;
mat_names = {mat_names.name};
for name = mat_names
  if strcmp(name{1}(1), '.')
    continue;
  end % get rid of the hidden files
  load(strcat("./data_phase_2/preprocessed_LR/", subject_str, name));
  test_EEG = trial.ProcessedEegData;
  attended_env = trial.ProcessedAttendedTrack;
  unattended_env = trial.ProcessedUnattendedTrack;
  [prediction, corr1, corr2] = LS_test_simple(attended_env, unattended_env, test_EEG, d,...
      lag_time, windowlength_time, sample_freq);
  count_correct = count_correct + prediction * 1;
  count_all     = count_all + 1;
end

ratio = count_correct / count_all