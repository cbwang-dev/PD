function [EEG_all, envelope_all] = concat_trials(subject_dir, desired_SNR, ...
  desired_attended_speaker, desired_unattended_speaker)
  
  EEG_all_tensor = zeros(50*20, 16, 6);
  HRTF_flags = zeros(6,1);
  temp_i = 0;

  trial_names = dir(subject_dir);
  trial_names = {trial_names.name};
  for trial_name = trial_names
    temp_i = temp_i + 1;
    if strcmp(trial_name{1}(1), '.')
      continue;
    end % get rid of the hidden files
    temp_trial = load(strcat(subject_dir, string(trial_name)));
    if temp_trial.FileHeader.SNR == desired_SNR && ...
       temp_trial.AttendedTrack.SexOfSpeaker == desired_attended_speaker && ...
       temp_trial.UnattendedTrack.SexOfSpeaker == desired_unattended_speaker

      locus_attended = temp_trial.AttendedTrack.Locus;
      locus_unattended = temp_trial.UnattendedTrack.Locus;
      locus_combined = [locus_attended locus_unattended];
      switch locus_combined
      case 'LR'
        HRTF_flags(temp_i) = 1;
      case 'RL'
        HRTF_flags(temp_i) = 2;
      case 'FR'
        HRTF_flags(temp_i) = 3;
      case 'RF'
        HRTF_flags(temp_i) = 4;
      case 'FL'
        HRTF_flags(temp_i) = 5;
      case 'LF'
        HRTF_flags(temp_i) = 6;
      otherwise
        error('Locus combination not recognized');
      end
    end
  end
end