%% 02_数字调制.m — 数字调制与星座图
%  涵盖: pskmod, qammod, 星座图可视化
%  需要 Communications Toolbox

clear; clc; close all;

%% ===== 1. BPSK 调制 =====
fprintf('===== 1. BPSK (二进制相移键控) =====\n');

rng(42);
N_bits = 1000;
bits = randi([0 1], N_bits, 1);

% BPSK: 0 -> +1, 1 -> -1
bpsk_symbols = 2*bits - 1;

figure('Name', 'BPSK', 'Position', [100 100 700 400]);
subplot(1, 2, 1);
stem(1:20, bits(1:20), 'filled', 'MarkerSize', 5);
title('二进制数据 (前20位)');
xlabel('位序号'); ylabel('位值');
ylim([-0.5 1.5]); grid on;

subplot(1, 2, 2);
scatter(real(bpsk_symbols(1:50)), imag(bpsk_symbols(1:50)), 30, 'filled');
title('BPSK 星座图');
xlabel('实部'); ylabel('虚部');
axis equal; grid on;
xlim([-2 2]); ylim([-2 2]);

%% ===== 2. QPSK / PSK 调制 =====
fprintf('\n===== 2. PSK 调制 =====\n');

M_psk = 4;  % QPSK
bits_qpsk = randi([0 1], N_bits, 1);
symbols_qpsk = pskmod(bits_qpsk, M_psk, pi/4);

figure('Name', 'PSK 星座图', 'Position', [200 200 800 300]);

% QPSK
subplot(1, 2, 1);
scatter(real(symbols_qpsk), imag(symbols_qpsk), 10, 'b', 'filled');
title('QPSK 星座图 (M=4)');
xlabel('实部'); ylabel('虚部');
axis equal; grid on; xlim([-2 2]); ylim([-2 2]);
hold on;
theta_q = pi/4 + (0:3)*2*pi/4;
plot(cos(theta_q), sin(theta_q), 'r+', 'MarkerSize', 15, 'LineWidth', 2);
hold off;

% 8-PSK
M8 = 8;
symbols_8psk = pskmod(randi([0 1], N_bits, 1), M8, pi/8);
subplot(1, 2, 2);
scatter(real(symbols_8psk), imag(symbols_8psk), 10, 'g', 'filled');
title('8-PSK 星座图 (M=8)');
xlabel('实部'); ylabel('虚部');
axis equal; grid on; xlim([-2 2]); ylim([-2 2]);

fprintf('QPSK: 每个符号传输 2 bits\n');
fprintf('8-PSK: 每个符号传输 3 bits\n');

%% ===== 3. QAM 调制 =====
fprintf('\n===== 3. QAM 调制 =====\n');

figure('Name', 'QAM 星座图', 'Position', [300 300 900 300]);

for idx = 1:3
    M = 2^(2*idx);  % 4, 16, 64
    bits_qam = randi([0 1], N_bits * log2(M), 1);
    symbols_qam = qammod(bits_qam, M, 'UnitAveragePower', true);
    
    subplot(1, 3, idx);
    scatter(real(symbols_qam), imag(symbols_qam), 5, 'filled', 'MarkerFaceAlpha', 0.3);
    title(sprintf('%d-QAM 星座图', M));
    xlabel('实部'); ylabel('虚部');
    axis equal; grid on;
    fprintf('%d-QAM: 每个符号 %d bits, 星座点数 %d\n', M, log2(M), M);
end

%% ===== 4. AWGN 信道下的星座图 =====
fprintf('\n===== 4. AWGN 信道影响 =====\n');

M = 16;
bits_tx = randi([0 1], N_bits * 4, 1);
symbols_tx = qammod(bits_tx, M, 'UnitAveragePower', true);

SNR_dB = [20, 15, 10, 5];

figure('Name', 'AWGN 对星座图的影响', 'Position', [100 100 800 600]);
for i = 1:length(SNR_dB)
    % 加噪声
    snr_linear = 10^(SNR_dB(i)/10);
    noise_power = 1 / snr_linear;
    noise = sqrt(noise_power/2) * (randn(size(symbols_tx)) + 1j*randn(size(symbols_tx)));
    symbols_rx = symbols_tx + noise;
    
    subplot(2, 2, i);
    scatter(real(symbols_rx), imag(symbols_rx), 3, 'filled', 'MarkerFaceAlpha', 0.3);
    hold on;
    % 理想星座点
    ideal = qammod(0:M-1, M, 'UnitAveragePower', true);
    plot(real(ideal), imag(ideal), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    hold off;
    title(sprintf('16-QAM @ SNR = %d dB', SNR_dB(i)));
    xlabel('实部'); ylabel('虚部');
    axis equal; grid on;
    xlim([-2 2]); ylim([-2 2]);
end

fprintf('SNR 越高，星座图越清晰，误码率越低\n');

%% ===== 5. 调制方式对比 =====
fprintf('\n===== 5. 调制效率对比 =====\n');

fprintf('调制方式   | bits/符号 | 带宽效率 | 抗噪性\n');
fprintf('-----------|-----------|----------|--------\n');
fprintf('BPSK       |     1     |   低     |  最好\n');
fprintf('QPSK       |     2     |   中     |  好\n');
fprintf('8-PSK      |     3     |   较高   |  中\n');
fprintf('16-QAM     |     4     |   高     |  中\n');
fprintf('64-QAM     |     6     |   很高   |  差\n');
fprintf('256-QAM    |     8     |   极高   |  最差\n');

fprintf('\n===== 数字调制模块完成! =====\n');
