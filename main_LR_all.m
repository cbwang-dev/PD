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
window_len_time_LUT = [50];
verbose = false; % control whether the messages in train_test_split is displayed
flag_subject_specific = true; % control whether the subject specific train test split is used
% leave_one_index_list = floor(rand(1,8)*40); % the index of the subject to be left out for test
leave_one_index_list = [25,26,27,28,29];
% 40 is set because some subjects don't have specific trials.
flag_use_presplitted_data = false;
experiment_times = 5;
presplitted_data_dir = "variables_main_LR_all.mat";

% print the necessary information
Q_LUT = ["identity matrix (ridge regularizer)", "discrete derivative regularizer"];
fprintf("INFO: train and test subject specific: %d\n", flag_subject_specific);

fprintf("INFO: lambda value is %.2f\n", lambda);
fprintf("INFO: regularizer: %s.\n", Q_LUT(Q_type));

for window_len_time = window_len_time_LUT
  fprintf("INFO: window length time: %d\n", window_len_time);
  count_all_subjects=zeros(1,37);
  count_correct_subjects = zeros(1,37);

  for repete =1:experiment_times
    tic
    EEG_train_all = [];
    envelope_train_all = [];
    EEG_test_all = [];
    attended_envelope_all = [];
    unattended_envelope_all = [];
    
    % leave_one_index_list = [randperm(32,8)]; % the index of the subject to be left out for test
    % 40 is set because some subjects don't have specific trials.
    if ~flag_use_presplitted_data
      for subject_name = subject_names
        fprintf("experiment %d: Processing subject: %s\n", repete, subject_name{1});
        count_correct = 0;
        count_all     = 0;
        warning_count = 0;

        if strcmp(subject_name{1}(1), '.')
          continue;
        end % get rid of the hidden files

        [EEG_train, envelope_train, EEG_test, attended_envelope_test, unattended_envelope_test] = ...
        train_test_split_all(preproc_LR_dir, evaluated_SNR, subject_name, leave_one_index_list, verbose);

        EEG_train_all = [EEG_train_all; EEG_train];
        envelope_train_all = [envelope_train_all; envelope_train];
        EEG_test = reshape(EEG_test, ...
                          [length(EEG_test)/1000,...
                          1000, ...
                          size(EEG_test,2)]);
        EEG_test_all = [EEG_test_all; EEG_test];
        attended_envelope_test = reshape(attended_envelope_test, ...
                                        [length(attended_envelope_test)/1000, ...
                                        1000, ...
                                        size(attended_envelope_test,2)]);
        attended_envelope_all = [attended_envelope_all; attended_envelope_test];
        unattended_envelope_test = reshape(unattended_envelope_test, ...
                                          [length(unattended_envelope_test)/1000,...
                                          1000, ...
                                          size(unattended_envelope_test,2)]);
        unattended_envelope_all = [unattended_envelope_all; unattended_envelope_test];
      end
      fprintf("size of EEG_train_all: (%d,%d)\n", size(EEG_train_all,1), size(EEG_train_all,2));
      fprintf("size of envelope_train_all: (%d,%d)\n", size(envelope_train_all,1), size(envelope_train_all,2));
      fprintf("size of EEG_test_all: (%d,%d,%d)\n", size(EEG_test_all,1), size(EEG_test_all,2), size(EEG_test_all,3));
      fprintf("size of attended_envelope_all: (%d,%d)\n", size(attended_envelope_all,1), size(attended_envelope_all,2));
      fprintf("size of unattended_envelope_all: (%d,%d)\n\n", size(unattended_envelope_all,1), size(unattended_envelope_all,2));
      % save("variables_main_LR_all.mat", "EEG_train_all", "envelope_train_all", "EEG_test_all", "attended_envelope_all", "unattended_envelope_all");
      fprintf("INFO: save variables_main_LR_all.mat\n");
    else
      fprintf("INFO: load variables_main_LR_all.mat\n");
      load(presplitted_data_dir);
    end

    lastwarn('', '');

    % train
    if use_regularization
      d = LS_train_regularized(envelope_train_all, EEG_train_all, ...
                              lag_time, window_len_time, sample_freq, ...
                              lambda, Q_type);
    else
      d = LS_train_simple(envelope_train, EEG_train, ...
                          lag_time, window_len_time, sample_freq);
    end
    [warnMsg, warnID] = lastwarn();
    if(~isempty(warnID))
      warning_count = warning_count + 1;
    end

    % test
    % keep in mind that length(EEG_test_all) = length(leave_one_index_list) * number of subjects
    all_tests = size(EEG_test_all,1);
    num_tests_in_one_subject = length(leave_one_index_list);
    num_subjects = all_tests / num_tests_in_one_subject;

    for i = 1:num_subjects
      count_correct = 0;
      count_all = 0;
      for j =1:num_tests_in_one_subject
        index = (i-1)*num_tests_in_one_subject+j;
        % fprintf("testing subject %d, test %d, index %d ", i, j, index);
        attended_envelope_test = attended_envelope_all(index,:)';
        unattended_envelope_test = unattended_envelope_all(index,:)';
        EEG_test = squeeze(EEG_test_all(index,:,:));

        [prediction, corr1, corr2] = LS_test_simple(attended_envelope_test, unattended_envelope_test, EEG_test, ...
                                                    d, lag_time, window_len_time, sample_freq);
        count_correct_subjects(i) = count_correct_subjects(i) + prediction * 1;
        count_all_subjects(i)     = count_all_subjects(i) + 1;
        % fprintf("prediction is %d\n", prediction);
      end
    end
    toc
  end

  accuracy_list_new = count_correct_subjects ./ count_all_subjects;

  name = strcat("variables_accuracy_grandtotal_regularizedLS_lambda_", num2str(lambda), "_windowlen_", num2str(window_len_time),"_Q_", num2str(Q_type), ".mat");
  save(name, 'accuracy_list_new');
  fprintf("INFO: save variables_accuracy_grandtotal_regularizedLS_lambda_%s_windowlen_%s_Q_%s_SNR_%s.mat\n", ...
            num2str(lambda), num2str(window_len_time), num2str(Q_type), num2str(evaluated_SNR));
  figure;boxplot(accuracy_list_new);pause;close all;
end

% boxplot(accuracy_list_new)