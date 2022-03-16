function RIR_sources = create_rirs_head_mount(HMIR_dir, HMIR_mic_name, IR_length)
    RIR_sources = zeros(IR_length, length(HMIR_dir), length(HMIR_mic_name));
    for index_dir = 1:length(HMIR_dir)
        for index_mic = 1:length(HMIR_mic_name)
            str_dir = char(HMIR_dir(index_dir));
            str_name = char(HMIR_mic_name(index_mic));
            str_IR = [str_dir str_name];
            [IR,fs] = audioread(str_IR);
            IR = IR(1:IR_length);
            RIR_sources(:, index_dir, index_mic) = IR;
        end
    end
end