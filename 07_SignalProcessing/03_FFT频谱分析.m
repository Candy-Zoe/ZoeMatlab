%% =========================================================================
%  FFT 频谱分析
%  学习目标：掌握快速傅里叶变换与频谱分析
%% =========================================================================

clear; clc; close all;

%% 1. 基本 FFT
disp('--- 基本 FFT ---');

fs = 1000;                             % 采样率
N = 1024;                              % 采样点数（2的幂次，FFT 效率最高）
t = (0:N-1)/fs;

% 信号：50Hz + 120Hz
sig = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t);

% FFT
Y = fft(sig);
P2 = abs(Y/N);                        % 双边谱
P1 = P2(1:N/2+1);                     % 单边谱
P1(2:end-1) = 2*P1(2:end-1);          % 补偿负频能量
f = fs*(0:(N/2))/N;                    % 频率轴

figure('Name', 'FFT 频谱', 'Position', [100, 100, 700, 500]);

subplot(2,1,1);
plot(t, sig, 'LineWidth', 0.5);
title('时域信号');
xlabel('时间 (s)'); ylabel('幅值');
xlim([0, 0.05]);

subplot(2,1,2);
stem(f, P1, 'filled', 'MarkerSize', 3);
title('FFT 单边幅值谱');
xlabel('频率 (Hz)'); ylabel('|P(f)|');
xlim([0, 200]);

% 标注峰值
[peaks_val, peaks_idx] = findpeaks(P1, 'MinPeakHeight', 0.3);
for k = 1:length(peaks_idx)
    fprintf('峰值: %d Hz, 幅值 = %.2f\n', round(f(peaks_idx(k))), peaks_val(k));
end

%% 2. 功率谱密度 (PSD)
disp('--- 功率谱密度 ---');

% 带噪声的信号
rng(42);
sig_noise = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.3*randn(size(t));

% periodogram 方法
[pxx, f_psd] = periodogram(sig_noise, [], N, fs);

figure('Name', '功率谱密度', 'Position', [100, 100, 700, 300]);
plot(f_psd, 10*log10(pxx), 'LineWidth', 1.5);
title('功率谱密度 (Periodogram)');
xlabel('频率 (Hz)'); ylabel('PSD (dB/Hz)');
grid on;
xlim([0, 250]);

%% 3. 频谱图 (Spectrogram)
disp('--- 频谱图 ---');

% 时变信号：频率随时间变化
N_long = 4096;
t_long = (0:N_long-1)/fs;
sig_chirp = chirp(t_long, 20, t_long(end), 300);  % 线性扫频 20→300 Hz

figure('Name', '频谱图', 'Position', [100, 100, 700, 500]);

subplot(2,1,1);
plot(t_long, sig_chirp, 'LineWidth', 0.3);
title('Chirp 信号（频率随时间变化）');
xlabel('时间 (s)'); ylabel('幅值');

subplot(2,1,2);
spectrogram(sig_chirp, 256, 200, 256, fs, 'yaxis');
title('频谱图 (Spectrogram)');

%% 4. FFT 的相位信息
disp('--- 相位信息 ---');

sig_phase = 2*sin(2*pi*50*t + pi/4);   % 幅值2, 相位45°
Y_p = fft(sig_phase);
phase = angle(Y_p(1:N/2+1)) * 180/pi;  % 转为角度

figure('Name', 'FFT 相位', 'Position', [100, 100, 700, 300]);
P1_phase = 2*abs(Y_p(1:N/2+1))/N;
subplot(1,2,1);
stem(f, P1_phase, 'filled', 'MarkerSize', 3);
title('幅值谱');
xlabel('Hz'); ylabel('幅值');
xlim([0, 100]);

subplot(1,2,2);
% 只显示幅值较大处的相位
mask = P1_phase > 0.1;
stem(f(mask), phase(mask), 'filled', 'MarkerSize', 5);
title('相位谱（仅显著分量）');
xlabel('Hz'); ylabel('相位 (°)');
xlim([0, 100]);

fprintf('50Hz 处相位: %.1f° (理论值: 45°)\n', phase(f==50));

disp('=== 脚本执行完毕 ===');
