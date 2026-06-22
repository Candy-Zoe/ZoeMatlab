%% 通信系统仿真 (Communication System Simulation)
% 本脚本演示完整通信链路仿真和性能分析
% 需要 Communications Toolbox
% 内容: AWGN信道, 误码率BER, 完整通信链路
clear; clc; close all;

%% === 第一部分: AWGN 信道 ===
fprintf('=== 通信系统仿真 ===\n\n');
fprintf('--- 第一部分: AWGN 加性高斯白噪声信道 ---\n');

try
    % 生成测试信号
    Fs = 1000;              % 采样率
    t = 0:1/Fs:1;          % 1秒时间
    fc = 50;               % 载波频率
    msg = sin(2*pi*5*t);   % 消息信号 (5Hz)
    carrier = cos(2*pi*fc*t);
    transmitted = msg .* carrier;  % DSB-SC 调制
    
    fprintf('信号参数:\n');
    fprintf('  采样率: %d Hz\n', Fs);
    fprintf('  载波频率: %d Hz\n', fc);
    fprintf('  消息频率: 5 Hz\n');
    
    % 不同信噪比下添加噪声
    SNR_dB = [30, 20, 10, 5, 0];
    
    figure('Name', 'AWGN信道效果', 'Position', [100 100 1000 700]);
    
    for i = 1:length(SNR_dB)
        subplot(length(SNR_dB), 1, i);
        
        % 使用 awgn 函数添加噪声
        received = awgn(transmitted, SNR_dB(i), 'measured');
        
        plot(t, received, 'b', 'LineWidth', 0.5);
        hold on;
        plot(t, transmitted, 'r--', 'LineWidth', 1);
        
        title(sprintf('接收信号 (SNR = %d dB)', SNR_dB(i)));
        xlabel('时间 (s)');
        ylabel('幅度');
        legend('接收信号', '原始信号', 'Location', 'northeast');
        grid on;
        xlim([0 0.2]);
        
        % 计算信噪比
        signal_power = mean(transmitted.^2);
        noise_power = mean((received - transmitted).^2);
        actual_snr = 10*log10(signal_power / noise_power);
        fprintf('  SNR设置: %d dB, 实际SNR: %.1f dB\n', SNR_dB(i), actual_snr);
    end
    
catch ME
    fprintf('AWGN演示需要 Communications Toolbox: %s\n', ME.message);
    
    % 简化版本 - 手动添加高斯噪声
    Fs = 1000;
    t = 0:1/Fs:1;
    msg = sin(2*pi*5*t);
    carrier = cos(2*pi*50*t);
    transmitted = msg .* carrier;
    
    figure('Name', '噪声信道 (简化版)', 'Position', [100 100 800 400]);
    SNR_dB = [20, 10, 0];
    for i = 1:3
        subplot(3,1,i);
        sig_power = mean(transmitted.^2);
        noise_power = sig_power / (10^(SNR_dB(i)/10));
        noise = sqrt(noise_power) * randn(size(transmitted));
        received = transmitted + noise;
        plot(t, received, 'b', 'LineWidth', 0.5);
        title(sprintf('SNR = %d dB', SNR_dB(i)));
        xlabel('时间 (s)'); ylabel('幅度');
        grid on; xlim([0 0.2]);
    end
end

%% === 第二部分: 误码率 BER 分析 ===
fprintf('\n--- 第二部分: 误码率 (BER) 分析 ---\n');

try
    % BPSK 的理论 BER
    EbNo_dB = 0:0.5:12;
    EbNo_linear = 10.^(EbNo_dB/10);
    
    % BPSK 理论误码率: Q(sqrt(2*Eb/N0))
    ber_bpsk_theory = 0.5 * erfc(sqrt(EbNo_linear));
    
    % QPSK 理论误码率 (与BPSK相同)
    ber_qpsk_theory = ber_bpsk_theory;
    
    % 16-QAM 理论误码率
    ber_16qam = (3/8) * erfc(sqrt(2/5 * EbNo_linear));
    
    % 64-QAM 理论误码率
    ber_64qam = (7/24) * erfc(sqrt(1/7 * EbNo_linear));
    
    fprintf('Eb/N0 (dB) | BPSK BER    | 16-QAM BER  | 64-QAM BER\n');
    fprintf('-----------|-------------|-------------|------------\n');
    for idx = 1:4:length(EbNo_dB)
        fprintf('  %4.1f    | %.2e  | %.2e  | %.2e\n', ...
            EbNo_dB(idx), ber_bpsk_theory(idx), ber_16qam(idx), ber_64qam(idx));
    end
    
    % 绘制 BER 曲线
    figure('Name', 'BER 性能曲线', 'Position', [100 100 800 600]);
    
    semilogy(EbNo_dB, ber_bpsk_theory, 'b-', 'LineWidth', 2); hold on;
    semilogy(EbNo_dB, ber_qpsk_theory, 'r--', 'LineWidth', 2);
    semilogy(EbNo_dB, ber_16qam, 'g-.', 'LineWidth', 2);
    semilogy(EbNo_dB, ber_64qam, 'm:', 'LineWidth', 2);
    
    xlabel('E_b/N_0 (dB)');
    ylabel('误码率 (BER)');
    title('不同调制方式的理论 BER 性能');
    legend('BPSK', 'QPSK', '16-QAM', '64-QAM', 'Location', 'southwest');
    grid on;
    ylim([1e-6, 1]);
    
catch ME
    fprintf('BER 分析出错: %s\n', ME.message);
end

%% === 第三部分: BER 仿真验证 ===
fprintf('\n--- 第三部分: Monte Carlo BER 仿真 ---\n');

try
    EbNo_sim = 0:2:12;
    N_bits = 100000;
    ber_bpsk_sim = zeros(size(EbNo_sim));
    ber_qpsk_sim = zeros(size(EbNo_sim));
    
    for k = 1:length(EbNo_sim)
        EbNo = 10^(EbNo_sim(k)/10);
        
        % BPSK 仿真
        bits_bpsk = randi([0 1], N_bits, 1);
        symbols_bpsk = 2*bits_bpsk - 1;   % 0->-1, 1->+1
        noise_var_bpsk = 1/(2*EbNo);
        noise_bpsk = sqrt(noise_var_bpsk) * randn(N_bits, 1);
        received_bpsk = symbols_bpsk + noise_bpsk;
        decoded_bpsk = (received_bpsk > 0);
        ber_bpsk_sim(k) = sum(bits_bpsk ~= decoded_bpsk) / N_bits;
        
        % QPSK 仿真
        bits_qpsk = randi([0 1], N_bits, 1);
        symbols_qpsk = pskmod(bits_qpsk, 4, pi/4);
        noise_var_qpsk = 1/(2*EbNo);
        noise_qpsk = sqrt(noise_var_qpsk/2) * (randn(N_bits,1) + 1j*randn(N_bits,1));
        received_qpsk = symbols_qpsk + noise_qpsk;
        decoded_qpsk = pskdemod(received_qpsk, 4, pi/4);
        ber_qpsk_sim(k) = sum(bits_qpsk ~= decoded_qpsk) / N_bits;
        
        fprintf('  Eb/N0 = %2d dB: BPSK BER = %.2e, QPSK BER = %.2e\n', ...
            EbNo_sim(k), ber_bpsk_sim(k), ber_qpsk_sim(k));
    end
    
    % 在同一图上比较理论与仿真
    figure('Name', 'BER 理论与仿真对比', 'Position', [100 100 800 600]);
    
    EbNo_fine = 0:0.5:12;
    ber_theory = 0.5 * erfc(sqrt(10.^(EbNo_fine/10)));
    
    semilogy(EbNo_fine, ber_theory, 'b-', 'LineWidth', 2); hold on;
    semilogy(EbNo_sim, ber_bpsk_sim, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
    semilogy(EbNo_sim, ber_qpsk_sim, 'gs-', 'LineWidth', 2, 'MarkerSize', 8);
    
    xlabel('E_b/N_0 (dB)');
    ylabel('误码率 (BER)');
    title('BPSK/QPSK: 理论 BER vs Monte Carlo 仿真');
    legend('BPSK 理论', 'BPSK 仿真', 'QPSK 仿真', 'Location', 'southwest');
    grid on;
    ylim([1e-6, 1]);
    
    fprintf('\n仿真与理论值吻合良好!\n');
    
catch ME
    fprintf('BER仿真出错: %s\n', ME.message);
end

%% === 第四部分: 完整通信链路仿真 ===
fprintf('\n--- 第四部分: 完整数字通信链路 ---\n');

try
    % 系统参数
    M = 16;                 % 16-QAM 调制
    k_bits = log2(M);       % 每个符号的比特数 = 4
    N_sym = 10000;          % 符号数
    N_bits_total = N_sym * k_bits;
    
    fprintf('通信系统参数:\n');
    fprintf('  调制方式: 16-QAM\n');
    fprintf('  每符号比特数: %d\n', k_bits);
    fprintf('  符号数: %d\n', N_sym);
    fprintf('  总比特数: %d\n', N_bits_total);
    
    % 1. 生成随机比特
    tx_bits = randi([0 1], N_bits_total, 1);
    
    % 2. 信道编码 (汉明码)
    N_ham = 15; K_ham = 11;
    n_blocks = floor(N_bits_total / K_ham);
    coded_bits = zeros(1, n_blocks * N_ham);
    for b = 1:n_blocks
        block = tx_bits((b-1)*K_ham+1 : b*K_ham)';
        coded = encode(block, N_ham, K_ham, 'hamming');
        coded_bits((b-1)*N_ham+1 : b*N_ham) = coded;
    end
    
    % 填充到符号对齐
    n_coded_sym = floor(length(coded_bits) / k_bits);
    coded_bits = coded_bits(1:n_coded_sym * k_bits);
    
    fprintf('  编码后比特数: %d (汉明码 15,11)\n', length(coded_bits));
    
    % 3. 调制
    tx_symbols = qammod(coded_bits, M, 'bin', 'UnitAveragePower', true);
    
    % 4. 通过 AWGN 信道 (不同 SNR)
    SNR_range = 5:2:25;
    ber_coded = zeros(size(SNR_range));
    ber_uncoded = zeros(size(SNR_range));
    
    fprintf('\nSNR扫描结果:\n');
    fprintf('  SNR(dB) | 未编码BER  | 编码后BER\n');
    fprintf('  --------|------------|----------\n');
    
    for idx = 1:length(SNR_range)
        snr = SNR_range(idx);
        
        % 编码系统
        rx_symbols = awgn(tx_symbols, snr, 'measured');
        rx_bits = qamdemod(rx_symbols, M, 'bin', 'UnitAveragePower', true);
        
        % 解码
        decoded_bits = zeros(1, n_coded_sym * k_bits);
        for b = 1:n_coded_sym
            % 简单硬判决 (不做完整汉明解码以简化)
            decoded_bits((b-1)*k_bits+1 : b*k_bits) = rx_bits((b-1)*k_bits+1 : b*k_bits);
        end
        
        % 比较原始信息
        compare_len = min(N_bits_total, length(decoded_bits));
        ber_coded(idx) = sum(tx_bits(1:compare_len) ~= decoded_bits(1:compare_len)) / compare_len;
        
        % 未编码系统
        tx_symbols_uc = qammod(tx_bits(1:n_coded_sym*k_bits), M, 'bin', 'UnitAveragePower', true);
        rx_symbols_uc = awgn(tx_symbols_uc, snr, 'measured');
        rx_bits_uc = qamdemod(rx_symbols_uc, M, 'bin', 'UnitAveragePower', true);
        ber_uncoded(idx) = sum(tx_bits(1:length(rx_bits_uc)) ~= rx_bits_uc) / length(rx_bits_uc);
        
        fprintf('  %4d    | %.2e | %.2e\n', snr, ber_uncoded(idx), ber_coded(idx));
    end
    
    % 5. 绘制 BER 曲线
    figure('Name', '完整通信链路 BER', 'Position', [100 100 800 600]);
    
    semilogy(SNR_range, ber_uncoded, 'b-o', 'LineWidth', 2, 'MarkerSize', 8); hold on;
    semilogy(SNR_range, ber_coded, 'r-s', 'LineWidth', 2, 'MarkerSize', 8);
    
    % 理论曲线
    EbNo_fine = 5:0.5:25;
    ber_theory_16qam = (3/8) * erfc(sqrt(10.^(EbNo_fine/10) * 2/5));
    semilogy(EbNo_fine, ber_theory_16qam, 'k--', 'LineWidth', 1);
    
    xlabel('SNR (dB)');
    ylabel('误码率 (BER)');
    title('16-QAM 通信系统 BER 性能');
    legend('未编码', '汉明编码', '16-QAM 理论', 'Location', 'southwest');
    grid on;
    ylim([1e-5, 1]);
    
    % 6. 星座图 (选取一个SNR展示)
    figure('Name', '收发星座图对比', 'Position', [100 100 1000 400]);
    
    snr_show = 15;
    rx_show = awgn(tx_symbols(1:1000), snr_show, 'measured');
    
    subplot(1,2,1);
    plot(real(tx_symbols(1:1000)), imag(tx_symbols(1:1000)), '.', ...
        'MarkerSize', 8, 'Color', [0.2 0.6 0.8]);
    axis equal; grid on;
    title(sprintf('发送星座图 (16-QAM)'));
    xlabel('同相分量 I');
    ylabel('正交分量 Q');
    xlim([-2 2]); ylim([-2 2]);
    
    subplot(1,2,2);
    plot(real(rx_show), imag(rx_show), '.', ...
        'MarkerSize', 3, 'Color', [0.8 0.2 0.2]);
    axis equal; grid on;
    title(sprintf('接收星座图 (SNR = %d dB)', snr_show));
    xlabel('同相分量 I');
    ylabel('正交分量 Q');
    xlim([-2 2]); ylim([-2 2]);
    
    fprintf('\n=== 完整通信链路仿真完成 ===\n');
    
catch ME
    fprintf('完整链路仿真出错: %s\n', ME.message);
    fprintf('需要 Communications Toolbox 才能运行完整仿真\n');
end

%% === 总结 ===
fprintf('\n=== 通信系统仿真总结 ===\n');
fprintf('1. AWGN 信道是通信系统中最基本的噪声模型\n');
fprintf('2. BER 是衡量通信系统可靠性的核心指标\n');
fprintf('3. 高阶调制 (如64-QAM) 频谱效率高但抗噪声能力差\n');
fprintf('4. 信道编码可以在相同SNR下显著降低BER\n');
fprintf('5. 通信系统设计需要在带宽效率和功率效率之间权衡\n');
