%% =========================================================================
%  滤波
%  学习目标：掌握 FIR/IIR 滤波器设计与信号滤波
%  需要: Signal Processing Toolbox
%% =========================================================================

clear; clc; close all;

%% 1. 生成测试信号
disp('--- 测试信号 ---');

fs = 1000;
t = 0:1/fs:1-1/fs;

% 混合信号：50Hz + 120Hz + 噪声
sig = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.3*randn(size(t));

fprintf('信号长度: %d 点\n', length(sig));
fprintf('采样率: %d Hz\n', fs);

%% 2. FIR 低通滤波器
disp('--- FIR 低通滤波器 ---');

% 设计 FIR 低通滤波器（截止频率 80Hz）
fc = 80;
order = 50;
b_fir = fir1(order, fc/(fs/2));       % 归一化截止频率

% 频率响应
[H_fir, f_fir] = freqz(b_fir, 1, 512, fs);

figure('Name', 'FIR 滤波器', 'Position', [100, 100, 800, 600]);

subplot(3,1,1);
plot(f_fir, 20*log10(abs(H_fir)), 'LineWidth', 2);
title('FIR 低通滤波器频率响应');
xlabel('频率 (Hz)'); ylabel('幅值 (dB)');
grid on;
xline(fc, 'r--', 'LineWidth', 1.5);
text(fc+10, -10, sprintf('截止 %dHz', fc));

% 滤波
sig_fir = filter(b_fir, 1, sig);

subplot(3,1,2);
plot(t, sig, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5); hold on;
plot(t, sig_fir, 'r-', 'LineWidth', 1.5);
title('FIR 滤波前后对比');
xlabel('时间 (s)'); ylabel('幅值');
legend('原始信号', '滤波后');
xlim([0, 0.1]);
hold off;

%% 3. IIR 滤波器 (Butterworth)
disp('--- IIR Butterworth 滤波器 ---');

% 设计 4 阶 Butterworth 低通滤波器
order_iir = 4;
[b_iir, a_iir] = butter(order_iir, fc/(fs/2));

[H_iir, f_iir] = freqz(b_iir, a_iir, 512, fs);

% 滤波
sig_iir = filter(b_iir, a_iir, sig);

subplot(3,1,3);
plot(t, sig, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5); hold on;
plot(t, sig_iir, 'b-', 'LineWidth', 1.5);
title('Butterworth IIR 滤波');
xlabel('时间 (s)'); ylabel('幅值');
legend('原始信号', 'IIR 滤波后');
xlim([0, 0.1]);
hold off;

%% 4. 带通滤波器
disp('--- 带通滤波器 ---');

% 提取 100-150 Hz 分量
f_low = 100; f_high = 150;
[b_bp, a_bp] = butter(4, [f_low f_high]/(fs/2), 'bandpass');

sig_bp = filter(b_bp, a_bp, sig);

figure('Name', '带通滤波', 'Position', [100, 100, 700, 400]);
subplot(2,1,1);
plot(t, sig, 'Color', [0.7 0.7 0.7]); hold on;
plot(t, sig_bp, 'r-', 'LineWidth', 1.5);
title('带通滤波 100-150 Hz');
xlabel('时间 (s)'); ylabel('幅值');
legend('原始', '带通滤波后');
xlim([0, 0.1]);
hold off;

subplot(2,1,2);
plot(f_fir, 20*log10(abs(freqz(b_bp, a_bp, 512, fs))), 'b-', 'LineWidth', 2);
hold on;
[H_bp, f_bp] = freqz(b_bp, a_bp, 512, fs);
plot(f_bp, 20*log10(abs(H_bp)), 'b-', 'LineWidth', 2);
title('带通滤波器频率响应');
xlabel('频率 (Hz)'); ylabel('幅值 (dB)');
grid on;
hold off;

%% 5. filtfilt（零相位滤波）
disp('--- 零相位滤波 filtfilt ---');

% filter 会引入相位延迟，filtfilt 不会
sig_filtfilt = filtfilt(b_iir, a_iir, sig);

figure('Name', '相位对比', 'Position', [100, 100, 700, 300]);
subplot(1,2,1);
plot(t, sin(2*pi*50*t), 'k-', 'LineWidth', 2); hold on;
plot(t, sig_iir, 'r-', 'LineWidth', 1.5);
title('filter (有相位延迟)');
legend('理想50Hz', '滤波后');
xlim([0, 0.1]);
hold off;

subplot(1,2,2);
plot(t, sin(2*pi*50*t), 'k-', 'LineWidth', 2); hold on;
plot(t, sig_filtfilt, 'b-', 'LineWidth', 1.5);
title('filtfilt (零相位)');
legend('理想50Hz', '零相位滤波');
xlim([0, 0.1]);
hold off;

disp('=== 脚本执行完毕 ===');
