function [AADEEG] = eegread(EEG_in, strtevent, stpevent)
% EEGREAD - Read EEG data between start and stop events
%   Usage: AADEEG = eeagread(EEG_in, dataset);
%
%   eegread(EEG_in) extracts the raw EEG data stored in 
%   EEG_in, between audio start and audio stop events by default.
%
%   eegread(EEG_in, strtevent, stpevent) extracts the raw EEG data stored in 
%   EEG_in, between strtevent and stpevent event IDs.
%
    if(nargin<2)
       strtevent = 33027; % Start of the experiment recording
       stpevent = 33024; % End of the experiment recording        
    end
    channels = 1:24;
    
%    NOTE: The attention switch event IDs are different from those above
%           Refer to documentation for the event IDs.

    cue_events = EEG_in.event;
    valuetofind = strtevent;
    audiostart = find(arrayfun(@(s) ismember(valuetofind, s.type), cue_events));

    valuetofind = stpevent;
    audiostop = find(arrayfun(@(s) ismember(valuetofind, s.type), cue_events));

    % Extract the start and stop triggers of the session
    locs(1) = EEG_in.event(audiostart).latency;
    locs(2) = EEG_in.event(audiostop).latency;
    
  % Extract EEG data of the AAD session using the trigger event locations.
    AADEEG = EEG_in.data(channels,locs(1):locs(2)); % Truncate EEG
end