function [mic_DAS_delayed, mic_DAS_averaged] = FAS_BF(input_BF, steer_angle, num_mic, dist_mic, c, fs_RIR)
    TDOA=(dist_mic*sind(steer_angle-90)) / c * fs_RIR; 
end