% note:
% there are 37 subjects, each with 48 trials. When loaded one trial,
% it always displays as "trial" variable in the workspace. 
% For subject-specific option, 


function [EEG_train, envelope_train, EEG_test, attended_envelope_test, unattended_envelope_test] = ...
  train_test_split_subject(preproc_LR_dir, evaluated_SNR, subject_name, leave_one_index, verbose)
  
  if verbose
    fprintf("===== train test split start\n")
    fprintf("INFO: leave one index is %d\n", leave_one_index)
    % fprintf("INFO: evaluated SNR is %d\n", evaluated_SNR) % here this is not used
    fprintf("INFO: subject name is %s\n", subject_name{1})
  end

  trial_dir = strcat(preproc_LR_dir, subject_name{1});
  trial_names = dir(trial_dir);
  trial_names = {trial_names.name};
  
  EEG_train = [];
  envelope_train = [];
  EEG_test = [];
  attended_envelope_test = [];
  unattended_envelope_test = [];

  for trial_name = trial_names
    if verbose
      fprintf("INFO: Processing %s.\t", strcat(trial_dir, '/', trial_name{1})); 
    end
    if strcmp(trial_name{1}(1), '.')
      if verbose
        fprintf("Skipping because of invalid path.\n");
      end
        continue;
    end % get rid of the hidden files

    load(strcat(trial_dir, '/', trial_name{1}));

    % if trial.FileHeader.SNR ~= evaluated_SNR
    %   if verbose
    %     fprintf("Skipping because of undesired SNR.\n");
    %   end
    %   continue;
    % end

    if leave_one_index < 10 && trial_name{1}(8) == '.' && strcmp(trial_name{1}(7), num2str(leave_one_index))
      if verbose
        fprintf("as validation set.\n", strcat(trial_dir, '/', trial_name{1}));
      end
      EEG_test = [EEG_test; trial.ProcessedEegData];
      attended_envelope_test = [attended_envelope_test; trial.ProcessedAttendedTrack];
      unattended_envelope_test = [unattended_envelope_test; trial.ProcessedUnattendedTrack];
      continue
    elseif leave_one_index < 49 && strcmp(trial_name{1}(7:8), num2str(leave_one_index))
      if verbose
        fprintf("as validation set.\n");
      end
      EEG_test = [EEG_test; trial.ProcessedEegData];
      attended_envelope_test = [attended_envelope_test; trial.ProcessedAttendedTrack];
      unattended_envelope_test = [unattended_envelope_test; trial.ProcessedUnattendedTrack];
      continue
    end
    if verbose
      fprintf("as training set.\n");
    end
    EEG_train = [EEG_train; trial.ProcessedEegData];
    envelope_train = [envelope_train; trial.ProcessedAttendedTrack];
  end
  if verbose
    fprintf("INFO: size of training EEG (%d,%d)\n", size(EEG_train,1), size(EEG_train,2));
    fprintf("INFO: size of training envelope (%d,%d)\n", size(envelope_train,1), size(envelope_train,2));
    fprintf("INFO: size of testing EEG (%d,%d)\n", size(EEG_test,1), size(EEG_test,2));
    fprintf("INFO: size of testing envelope (%d,%d)\n", size(attended_envelope_test,1), size(attended_envelope_test,2));
    fprintf("===== train test split end\n")
  end
end
