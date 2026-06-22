%% 信道编码 (Channel Coding)
% 本脚本演示信道编码的基本概念和方法
% 需要 Communications Toolbox
% 内容: 汉明码, CRC, 卷积码, 编码/解码
clear; clc; close all;

%% === 第一部分: 汉明码 (Hamming Code) ===
fprintf('=== 信道编码演示 ===\n\n');
fprintf('--- 第一部分: 汉明码 ---\n');

try
    % 汉明码参数
    M = 4;            % 汉明码阶数
    N = 2^M - 1;      % 码字长度 = 15
    K = N - M;        % 信息位长度 = 11
    
    fprintf('汉明码参数:\n');
    fprintf('  阶数 M = %d\n', M);
    fprintf('  码字长度 N = %d\n', N);
    fprintf('  信息位 K = %d\n', K);
    fprintf('  校验位 = %d\n', M);
    fprintf('  编码效率 = %.2f\n', K/N);
    
    % 生成汉明码编码/解码矩阵
    [H, G] = hammgen(M);
    
    fprintf('\n生成矩阵 G (%dx%d):\n', size(G,1), size(G,2));
    disp(G);
    
    fprintf('校验矩阵 H (%dx%d):\n', size(H,1), size(H,2));
    disp(H);
    
    % 编码示例
    msg = randi([0 1], 1, K);       % 随机信息位
    fprintf('\n原始信息位 (%d bits):\n', K);
    disp(msg);
    
    code = encode(msg, N, K, 'hamming');
    fprintf('编码后码字 (%d bits):\n', N);
    disp(code);
    
    % 添加单个错误
    error_pos = randi(N);
    received = code;
    received(error_pos) = mod(received(error_pos) + 1, 2);
    fprintf('\n在第 %d 位引入错误:\n', error_pos);
    disp(received);
    
    % 解码并纠错
    decoded = decode(received, N, K, 'hamming');
    fprintf('解码后信息位:\n');
    disp(decoded);
    
    if isequal(msg, decoded)
        fprintf('汉明码成功纠正了单个错误!\n');
    else
        fprintf('解码有误\n');
    end
    
    % 批量测试纠错能力
    n_trials = 10000;
    errors_corrected = 0;
    for i = 1:n_trials
        msg_i = randi([0 1], 1, K);
        code_i = encode(msg_i, N, K, 'hamming');
        
        % 引入1个随机错误
        err_pos = randi(N);
        recv_i = code_i;
        recv_i(err_pos) = mod(recv_i(err_pos) + 1, 2);
        
        dec_i = decode(recv_i, N, K, 'hamming');
        if isequal(msg_i, dec_i)
            errors_corrected = errors_corrected + 1;
        end
    end
    fprintf('\n批量测试 (%d 次):\n', n_trials);
    fprintf('  单错误纠正成功率: %.2f%%\n', errors_corrected/n_trials*100);
    
catch ME
    fprintf('Communications Toolbox 未安装, 使用简化演示\n');
    fprintf('错误: %s\n', ME.message);
    
    % 简化汉明(7,4)码演示
    fprintf('\n--- 简化汉明(7,4)码演示 ---\n');
    G_simple = [1 0 0 0 1 1 0;
                0 1 0 0 1 0 1;
                0 0 1 0 0 1 1;
                0 0 0 1 1 1 1];
    H_simple = [1 1 0 1 1 0 0;
                1 0 1 1 0 1 0;
                0 1 1 1 0 0 1];
    
    msg = [1 0 1 1];
    code = mod(msg * G_simple, 2);
    fprintf('信息位: '); disp(msg);
    fprintf('编码后: ');  disp(code);
end

%% === 第二部分: CRC 校验 ===
fprintf('\n--- 第二部分: CRC 循环冗余校验 ---\n');

try
    % CRC 编码
    msg = randi([0 1], 1, 8);   % 8位信息
    fprintf('原始数据 (8 bits):\n');
    disp(msg);
    
    % 使用 CRC 生成多项式
    % CRC-8: x^8 + x^2 + x + 1
    gen_poly = [1 0 0 0 0 0 1 1 1];  % CRC-8 多项式系数
    
    % CRC 编码 (手动实现)
    msg_padded = [msg, zeros(1, length(gen_poly)-1)];
    
    % 多项式除法 (模2运算)
    crc_remainder = msg_padded;
    for i = 1:length(msg)
        if crc_remainder(i) == 1
            crc_remainder(i:i+length(gen_poly)-1) = ...
                mod(crc_remainder(i:i+length(gen_poly)-1) + gen_poly, 2);
        end
    end
    crc_bits = crc_remainder(length(msg)+1:end);
    
    fprintf('CRC 校验位 (%d bits):\n', length(crc_bits));
    disp(crc_bits);
    
    % CRC 编码数据
    coded_data = [msg, crc_bits];
    fprintf('CRC 编码数据 (%d bits):\n', length(coded_data));
    disp(coded_data);
    
    % 验证 CRC (无错误)
    check = coded_data;
    for i = 1:length(msg)
        if check(i) == 1
            check(i:i+length(gen_poly)-1) = ...
                mod(check(i:i+length(gen_poly)-1) + gen_poly, 2);
        end
    end
    remainder_no_err = check(length(msg)+1:end);
    fprintf('无错误时 CRC 校验余数: ');
    disp(remainder_no_err);
    if all(remainder_no_err == 0)
        fprintf('CRC 校验通过!\n');
    end
    
    % 引入错误后验证
    error_data = coded_data;
    error_data(3) = mod(error_data(3) + 1, 2);
    error_data(7) = mod(error_data(7) + 1, 2);
    
    check2 = error_data;
    for i = 1:length(msg)
        if check2(i) == 1
            check2(i:i+length(gen_poly)-1) = ...
                mod(check2(i:i+length(gen_poly)-1) + gen_poly, 2);
        end
    end
    remainder_err = check2(length(msg)+1:end);
    fprintf('\n引入2个错误后 CRC 校验余数: ');
    disp(remainder_err);
    if any(remainder_err ~= 0)
        fprintf('CRC 检测到错误!\n');
    end
    
catch ME
    fprintf('CRC 演示出错: %s\n', ME.message);
end

%% === 第三部分: 线性分组码 ===
fprintf('\n--- 第三部分: 线性分组码 ---\n');

try
    % (7,4) 汉明码的编码效率分析
    N = 7; K = 4;
    rates = [1/3, 1/2, 2/3, 3/4, 4/5, 5/6];
    
    fprintf('常见编码率与纠错能力:\n');
    fprintf('  编码率  |  开销  |  典型应用\n');
    fprintf('  --------|--------|------------------\n');
    fprintf('  1/3     |  3x    |  深空通信\n');
    fprintf('  1/2     |  2x    |  卫星通信\n');
    fprintf('  2/3     |  1.5x  |  数字电视\n');
    fprintf('  3/4     |  1.33x |  Wi-Fi\n');
    fprintf('  5/6     |  1.2x  |  高速链路\n');
    
    % 编码效率与冗余度的关系
    figure('Name', '编码效率与冗余度', 'Position', [100 100 800 400]);
    
    k_vals = 4:20;
    n_vals_1 = k_vals + 3;   % 3个校验位
    n_vals_2 = k_vals + 5;   % 5个校验位
    n_vals_3 = 2 * k_vals;   % 编码率1/2
    
    subplot(1,2,1);
    plot(k_vals, k_vals./n_vals_1, '-o', 'LineWidth', 2); hold on;
    plot(k_vals, k_vals./n_vals_2, '-s', 'LineWidth', 2);
    plot(k_vals, k_vals./n_vals_3, '-^', 'LineWidth', 2);
    xlabel('信息位长度 K');
    ylabel('编码效率 (K/N)');
    title('编码效率 vs 信息位长度');
    legend('N=K+3', 'N=K+5', 'N=2K', 'Location', 'southeast');
    grid on;
    ylim([0 1.1]);
    
    subplot(1,2,2);
    redundancy = [3, 5, 7, 10];
    max_errors = floor((redundancy - 1) / 2);  % 最大纠错数 (近似)
    bar(redundancy, max_errors, 'FaceColor', [0.2 0.6 0.8]);
    xlabel('校验位数');
    ylabel('最大可纠正错误数');
    title('冗余度 vs 纠错能力');
    grid on;
    
catch ME
    fprintf('线性分组码演示出错: %s\n', ME.message);
end

%% === 第四部分: 卷积码概念 ===
fprintf('\n--- 第四部分: 卷积码 ---\n');

try
    % 卷积码参数
    K_conv = 1;     % 每次输入比特数
    N_conv = 2;     % 每次输出比特数  
    M_conv = 2;     % 约束长度-1 (记忆单元数)
    
    trellis = poly2trellis(M_conv + 1, [7 5]);  % 生成多项式 [111, 101]
    
    fprintf('卷积码参数:\n');
    fprintf('  输入比特数 K = %d\n', K_conv);
    fprintf('  输出比特数 N = %d\n', N_conv);
    fprintf('  约束长度 = %d\n', M_conv + 1);
    fprintf('  编码率 = %d/%d = %.2f\n', K_conv, N_conv, K_conv/N_conv);
    
    % 编码
    msg_bits = randi([0 1], 1, 20);
    fprintf('\n原始信息 (%d bits):\n', length(msg_bits));
    disp(msg_bits);
    
    % 使用 convenc 编码
    coded = convenc(msg_bits, trellis);
    fprintf('卷积编码输出 (%d bits):\n', length(coded));
    disp(coded);
    fprintf('编码后长度: %d (原长度 x %d)\n', length(coded), N_conv/K_conv);
    
    % 添加噪声
    noisy = coded;
    n_errors = 3;
    error_positions = randperm(length(coded), n_errors);
    noisy(error_positions) = mod(noisy(error_positions) + 1, 2);
    
    % Viterbi 解码
    decoded = vitdec(noisy, trellis, 32, 'trunc', 'hard');
    fprintf('\nViterbi 解码结果 (%d bits):\n', length(decoded));
    disp(decoded);
    
    % 比较
    msg_compare = msg_bits(1:length(decoded));
    bit_errors = sum(msg_compare ~= decoded);
    fprintf('误码数: %d / %d\n', bit_errors, length(msg_compare));
    
    % 不同噪声水平下的性能
    figure('Name', '卷积码性能', 'Position', [100 100 800 400]);
    
    error_counts = zeros(1, 8);
    n_flip = 0:7;
    n_sim = 500;
    
    for e = 1:length(n_flip)
        correct = 0;
        for sim = 1:n_sim
            msg_s = randi([0 1], 1, 50);
            code_s = convenc(msg_s, trellis);
            noisy_s = code_s;
            if n_flip(e) > 0
                pos = randperm(length(noisy_s), min(n_flip(e), length(noisy_s)));
                noisy_s(pos) = mod(noisy_s(pos) + 1, 2);
            end
            dec_s = vitdec(noisy_s, trellis, 32, 'trunc', 'hard');
            if sum(msg_s(1:length(dec_s)) ~= dec_s) == 0
                correct = correct + 1;
            end
        end
        error_counts(e) = n_sim - correct;
    end
    
    bar(n_flip, error_counts/n_sim*100, 'FaceColor', [0.8 0.2 0.2]);
    xlabel('码字中的错误比特数');
    ylabel('帧错误率 (%)');
    title('卷积码 + Viterbi 解码的纠错性能');
    grid on;
    fprintf('\n卷积码能有效纠正少量随机错误\n');
    
catch ME
    fprintf('卷积码需要 Communications Toolbox\n');
    fprintf('错误: %s\n', ME.message);
    
    % 简化说明
    fprintf('\n卷积码基本原理:\n');
    fprintf('  - 编码器具有记忆性, 输出取决于当前和之前的输入\n');
    fprintf('  - 常用 Viterbi 算法进行最大似然解码\n');
    fprintf('  - 广泛应用于卫星通信、移动通信等领域\n');
end

%% === 总结 ===
fprintf('\n=== 信道编码总结 ===\n');
fprintf('1. 汉明码: 能纠正单个错误, 编码效率高\n');
fprintf('2. CRC: 检错能力强, 广泛用于数据链路层\n');
fprintf('3. 卷积码: 具有记忆性, Viterbi解码, 适合连续传输\n');
fprintf('4. 编码率越低, 冗余越多, 纠错能力越强, 但效率越低\n');
fprintf('5. 实际系统通常组合使用多种编码 (如外码CRC + 内码卷积码)\n');
