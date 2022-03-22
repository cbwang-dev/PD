function [mic_DAS_delayed] = DAS_BF(input_BF, steer_angle, num_mic, dist_mic, c, fs_RIR)
    fprintf('====> start DAS_BF for angle %f\n', steer_angle)
    TDOA=(dist_mic*sind(steer_angle-90)) / c * fs_RIR;
    mic_DAS_delayed=zeros(size(input_BF,1),size(input_BF,2));
    % delay in samples. mic5.delay=4*TDOA, mic1.delay=0.
    for i=1:num_mic
        mic_DAS_delayed(:,i)=delayseq(input_BF(:,i),-(i-1)*TDOA); % checked for correctness
    end % this delayed time is time-domain steer vector, can be used in FAS_BF
    fprintf('====> end DAS_BF for angle %f\n', steer_angle)
%     figure;
%     subplot(5,2,1);plot(input_BF(155532:155700,1));title('mic1');xlim([1 168]);
%     subplot(5,2,3);plot(input_BF(155532:155700,2));title('mic2');xlim([1 168]);
%     subplot(5,2,5);plot(input_BF(155532:155700,3));title('mic3');xlim([1 168]);
%     subplot(5,2,7);plot(input_BF(155532:155700,4));title('mic4');xlim([1 168]);
%     subplot(5,2,9);plot(input_BF(155532:155700,5));title('mic5');xlim([1 168]);
%     subplot(5,2,2);plot(mic_DAS_delayed(155532:155700,1));title('mic1 DAS BF out');xlim([1 168]);
%     subplot(5,2,4);plot(mic_DAS_delayed(155532:155700,2));title('mic2 DAS BF out');xlim([1 168]);
%     subplot(5,2,6);plot(mic_DAS_delayed(155532:155700,3));title('mic3 DAS BF out');xlim([1 168]);
%     subplot(5,2,8);plot(mic_DAS_delayed(155532:155700,4));title('mic4 DAS BF out');xlim([1 168]);
%     subplot(5,2,10);plot(mic_DAS_delayed(155532:155700,5));title('mic5 DAS BF out');xlim([1 168]);
end