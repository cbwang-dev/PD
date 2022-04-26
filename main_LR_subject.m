% subject specific linear regression.
% Using leave-one-out strategy

%% hyperparameters
clear;runme;

preproc_LR_dir = './data_phase_2/preprocessed_LR/';
subject_names = dir(preproc_LR_dir);
subject_names = {subject_names.name};
subject_num = 37; % fixed
use_regularization = true;
lambda = 0.4;
Q_type = 1;
evaluated_SNR = 100; % from now the SNR is not a variable.
sample_freq = 20;
lag_time = 250e-3; % should stay fixed regarding to paper
% window_len_time = 25;
window_len_time_LUT = [10,5,2,1];
verbose = false; % control whether the messages in train_test_split is displayed
flag_subject_specific = true; % control whether the subject specific train test split is used

% w = warning('query','last'); id = w.identifier; warning('off',id); % temprarily suppress 'nearlySingularMatrix' warning
fprintf("INFO: suppress warning nearlySingularMatrix\n");

% print the necessary information
Q_LUT = ["identity matrix (ridge regularizer)", "discrete derivative regularizer"];
fprintf("INFO: train and test subject specific: %d\n", flag_subject_specific);
fprintf("INFO: lambda value is %.2f\n", lambda);
fprintf("INFO: regularizer: %s.\n", Q_LUT(Q_type));

accuracy_list = [];

for window_len_time = window_len_time_LUT
  fprintf("INFO: window length: %d ms.\n", window_len_time);
  for subject_name = subject_names

    count_correct = 0;
    count_all     = 0;
    warning_count = 0;

    if strcmp(subject_name{1}(1), '.')
      continue;
    end % get rid of the hidden files

    for leave_one_index =1:size(dir(strcat(preproc_LR_dir,subject_name{1})),1)-3 % hard code .DS_Store into account

      [EEG_train, envelope_train, EEG_test, attended_envelope_test, unattended_envelope_test] = ...
      train_test_split_subject(preproc_LR_dir, evaluated_SNR, subject_name, leave_one_index, verbose);

      % load(strcat(preproc_LR_dir, subject_name{1}, '/trial-1.mat'));
      % EEG_train = trial.ProcessedEegData;
      % envelope_train = trial.ProcessedAttendedTrack;

      lastwarn('', '');

      % train
      if use_regularization
        d = LS_train_regularized(envelope_train, EEG_train, ...
                                lag_time, window_len_time, sample_freq, ...
                                lambda, Q_type);
      else
        d = LS_train_simple(envelope_train, EEG_train, ...
                            lag_time, window_len_time, sample_freq);
      end
      % plot(d);pause;
      [warnMsg, warnID] = lastwarn();
      if(~isempty(warnID))
        warning_count = warning_count + 1;
      end

      % test
      [prediction, corr1, corr2] = LS_test_simple(attended_envelope_test, unattended_envelope_test, EEG_test, ...
                                                  d, lag_time, window_len_time, sample_freq);
      count_correct = count_correct + prediction * 1;
      count_all     = count_all + 1;
    end

    accuracy = count_correct / count_all;
    fprintf(">OUT: accuracy of subject %s : %f\t", subject_name{1}, accuracy);
    fprintf("WARNING: %d\n", warning_count);
    accuracy_list = [accuracy_list accuracy];

  end

end

% accuracy_simpleLS_50ms = accuracy_list';
% save('variables_accuracy_simpleLS_50ms.mat', 'accuracy_simpleLS_50ms');
% boxplot(accuracy_simpleLS_50ms)

% accuracy_regularizedLS_lambda_01_50ms = accuracy_list';
% save('variables_accuracy_regularizedLS_lambda_01_50ms.mat', 'accuracy_regularizedLS_lambda_01_50ms');
% boxplot(accuracy_regularizedLS_lambda_01_50ms)

accuracy = accuracy_list';
name = strcat("variables_accuracy_regularizedLS_lambda_", num2str(lambda), "_windowlen_", num2str(window_len_time), "_Q_", num2str(Q_type), ".mat");
save(name, 'accuracy');
boxplot(accuracy);ylim([0 1]);

% boxplot([accuracy_simpleLS_50ms accuracy_regularizedLS_lambda_01_50ms]);ylim([0 1])
