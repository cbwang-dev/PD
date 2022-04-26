clear;
preproc_CNN_dir = './data_phase_2/preprocessed_CNN/';

EEG_SNR_100 = [];
env_attended_SNR_100 = [];
env_unattended_SNR_100 = [];
EEG_SNR_4 = [];
env_attended_SNR_4 = [];
env_unattended_SNR_4 = [];

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
    fprintf("INFO: Loading %s\t| ", trial_dir);
    load(trial_dir);
    SNR = trial.FileHeader.SNR;
    Locus_AttendedTrack = trial.AttendedTrack.Locus;
    SexOfSpeaker = trial.AttendedTrack.SexOfSpeaker;
    fprintf("SNR %d\tLocus %s\tSexOfSpeaker %s\n", SNR, Locus_AttendedTrack, SexOfSpeaker);
    if SNR == 100
      EEG_SNR_100 = [EEG_SNR_100; trial.ProcessedEegData];
      env_attended_SNR_100 = [env_attended_SNR_100; trial.ProcessedAttendedTrack];
      env_unattended_SNR_100 = [env_unattended_SNR_100; trial.ProcessedUnattendedTrack];
    elseif SNR == 4
      EEG_SNR_4 = [EEG_SNR_4; trial.ProcessedEegData];
      env_attended_SNR_4 = [env_attended_SNR_4; trial.ProcessedAttendedTrack];
      env_unattended_SNR_4 = [env_unattended_SNR_4; trial.ProcessedUnattendedTrack];
    end
  end
end

% fprintf("INFO: size of EEG_SNR_100: (%d,%d)\n", size(EEG_SNR_100,1), size(EEG_SNR_100,2));
% fprintf("INFO: size of env_attended_SNR_100: (%d,%d)\n", size(env_attended_SNR_100,1), size(env_attended_SNR_100,2));
% fprintf("INFO: size of env_unattended_SNR_100: (%d,%d)\n", size(env_unattended_SNR_100,1), size(env_unattended_SNR_100,2));
% fprintf("INFO: size of EEG_SNR_4: (%d,%d)\n", size(EEG_SNR_4,1), size(EEG_SNR_4,2));
% fprintf("INFO: size of env_attended_SNR_4: (%d,%d)\n", size(env_attended_SNR_4,1), size(env_attended_SNR_4,2));
% fprintf("INFO: size of env_unattended_SNR_4: (%d,%d)\n", size(env_unattended_SNR_4,1), size(env_unattended_SNR_4,2));

length_one_trial = 3500;

trials_SNR_100 = size(EEG_SNR_100,1)/length_one_trial;
EEG_SNR_100_reshaped = reshape(EEG_SNR_100, [trials_SNR_100, length_one_trial, size(EEG_SNR_100,2)]);
env_attended_SNR_100 = reshape(env_attended_SNR_100, [trials_SNR_100, length_one_trial, size(env_attended_SNR_100,2)]);
env_unattended_SNR_100 = reshape(env_unattended_SNR_100, [trials_SNR_100, length_one_trial, size(env_unattended_SNR_100,2)]);

trials_SNR_4 = size(EEG_SNR_4,1)/length_one_trial;
EEG_SNR_4_reshaped = reshape(EEG_SNR_4, [trials_SNR_4, length_one_trial, size(EEG_SNR_4,2)]);
env_attended_SNR_4 = reshape(env_attended_SNR_4, [trials_SNR_4, length_one_trial, size(env_attended_SNR_4,2)]);
env_unattended_SNR_4 = reshape(env_unattended_SNR_4, [trials_SNR_4, length_one_trial, size(env_unattended_SNR_4,2)]);

% fprintf("INFO: size of EEG_SNR_100_reshaped: (%d,%d,%d)\n", size(EEG_SNR_100_reshaped,1), size(EEG_SNR_100_reshaped,2), size(EEG_SNR_100_reshaped,3));
% fprintf("INFO: size of env_attended_SNR_100: (%d,%d)\n", size(env_attended_SNR_100,1), size(env_attended_SNR_100,2)));
% fprintf("INFO: size of env_unattended_SNR_100: (%d,%d)\n", size(env_unattended_SNR_100,1), size(env_unattended_SNR_100,2)));
% fprintf("INFO: size of EEG_SNR_4_reshaped: (%d,%d,%d)\n", size(EEG_SNR_4_reshaped,1), size(EEG_SNR_4_reshaped,2), size(EEG_SNR_4_reshaped,3));
% fprintf("INFO: size of env_attended_SNR_4: (%d,%d)\n", size(env_attended_SNR_4,1), size(env_attended_SNR_4,2)));
% fprintf("INFO: size of env_unattended_SNR_4: (%d,%d)\n", size(env_unattended_SNR_4,1), size(env_unattended_SNR_4,2)));

% save("dataset_CNN_SNR_100.mat","EEG_SNR_100_reshaped","env_attended_SNR_100","env_unattended_SNR_100");
% save("dataset_CNN_SNR_4.mat","EEG_SNR_4_reshaped","env_attended_SNR_4","env_unattended_SNR_4");

percentage_test_set = 0.2;

num_test_set_SNR_100 = floor(trials_SNR_100 * percentage_test_set);

index_test_set_SNR_100 = randperm(trials_SNR_100, num_test_set_SNR_100);
EEG_SNR_100_test_set = EEG_SNR_100_reshaped(index_test_set_SNR_100,:,:);
env_attended_SNR_100_test_set = env_attended_SNR_100(index_test_set_SNR_100,:);
env_unattended_SNR_100_test_set = env_unattended_SNR_100(index_test_set_SNR_100,:);

index_train_set_SNR_100 = setdiff(1:trials_SNR_100, index_test_set_SNR_100);
EEG_SNR_100_train_set = EEG_SNR_100_reshaped(index_train_set_SNR_100,:,:);
env_attended_SNR_100_train_set = env_attended_SNR_100(index_train_set_SNR_100,:);
env_unattended_SNR_100_train_set = env_unattended_SNR_100(index_train_set_SNR_100,:);

save("dataset_CNN_SNR_100.mat","EEG_SNR_100_test_set","env_attended_SNR_100_test_set","env_unattended_SNR_100_test_set",...
                               "EEG_SNR_100_train_set","env_attended_SNR_100_train_set","env_unattended_SNR_100_train_set");

num_test_set_SNR_4 = floor(trials_SNR_4 * percentage_test_set);

index_test_set_SNR_4 = randperm(trials_SNR_4, num_test_set_SNR_4);
EEG_SNR_4_test_set = EEG_SNR_4_reshaped(index_test_set_SNR_4,:,:);
env_attended_SNR_4_test_set = env_attended_SNR_4(index_test_set_SNR_4,:);
env_unattended_SNR_4_test_set = env_unattended_SNR_4(index_test_set_SNR_4,:);

index_train_set_SNR_4 = setdiff(1:trials_SNR_4, index_test_set_SNR_4);
EEG_SNR_4_train_set = EEG_SNR_4_reshaped(index_train_set_SNR_4,:,:);
env_attended_SNR_4_train_set = env_attended_SNR_4(index_train_set_SNR_4,:);
env_unattended_SNR_4_train_set = env_unattended_SNR_4(index_train_set_SNR_4,:);

save("dataset_CNN_SNR_4.mat","EEG_SNR_4_test_set","env_attended_SNR_4_test_set","env_unattended_SNR_4_test_set",...
                             "EEG_SNR_4_train_set","env_attended_SNR_4_train_set","env_unattended_SNR_4_train_set");

fprintf("double check: size of EEG_SNR_100: (%d,%d)\n", size(EEG_SNR_100,1), size(EEG_SNR_100,2));
fprintf("double check: size of EEG_SNR_100_reshaped: (%d,%d,%d)\n", size(EEG_SNR_100_reshaped,1), size(EEG_SNR_100_reshaped,2), size(EEG_SNR_100_reshaped,3));
fprintf("double check: size of EEG_SNR_100_test_set: (%d,%d,%d)\n", size(EEG_SNR_100_test_set,1), size(EEG_SNR_100_test_set,2), size(EEG_SNR_100_test_set,3));
fprintf("double check: size of EEG_SNR_100_train_set: (%d,%d,%d)\n\n", size(EEG_SNR_100_train_set,1), size(EEG_SNR_100_train_set,2), size(EEG_SNR_100_train_set,3));
