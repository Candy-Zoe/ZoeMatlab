%% 03_自相关与谱分析.m — 时间序列频域分析
%  涵盖: autocorr, parcorr, periodogram
%  部分功能需要 Econometrics Toolbox

clear; clc; close all;

%% ===== 1. 自相关函数 (ACF) =====
fprintf('===== 1. 自相关函数 (ACF) =====\n');

rng(42);
N = 500;

% 白噪声
white_noise = randn(N, 1);

% AR(1) 过程: y(t) = 0.8*y(t-1) + e(t)
ar1 = zeros(N, 1);
for i = 2:N
    ar1(i) = 0.8 * ar1(i-1) + randn();
end

% AR(2) 过程: y(t) = 1.2*y(t-1) - 0.5*y(t-2) + e(t)
ar2 = zeros(N, 1);
for i = 3:N
    ar2(i) = 1.2*ar2(i-1) - 0.5*ar2(i-2) + randn();
end

% 含季节性的过程
seasonal_ts = zeros(N, 1);
for i = 1:N
    seasonal_ts(i) = 3*sin(2*pi*i/12) + 0.5*randn();
end

figure('Name', '自相关函数', 'Position', [100 100 800 700]);

subplot(4, 2, 1); plot(white_noise, 'LineWidth', 0.8); title('白噪声'); grid on;
subplot(4, 2, 2); autocorr(white_noise); title('ACF: 白噪声');

subplot(4, 2, 3); plot(ar1, 'LineWidth', 0.8); title('AR(1) 过程'); grid on;
subplot(4, 2, 4); autocorr(ar1); title('ACF: AR(1) (指数衰减)');

subplot(4, 2, 5); plot(ar2, 'LineWidth', 0.8); title('AR(2) 过程'); grid on;
subplot(4, 2, 6); autocorr(ar2); title('ACF: AR(2) (振荡衰减)');

subplot(4, 2, 7); plot(seasonal_ts, 'LineWidth', 0.8); title('季节过程'); grid on;
subplot(4, 2, 8); autocorr(seasonal_ts); title('ACF: 季节性 (周期峰值)');

fprintf('白噪声 ACF: 仅在 lag=0 处显著\n');
fprintf('AR(1) ACF: 指数衰减\n');
fprintf('季节性 ACF: 在周期倍数处有峰值\n');

%% ===== 2. 偏自相关函数 (PACF) =====
fprintf('\n===== 2. 偏自相关函数 (PACF) =====\n');

figure('Name', '偏自相关', 'Position', [200 200 800 500]);
subplot(2, 2, 1); parcorr(ar1); title('PACF: AR(1) (lag=1 后截断)');
subplot(2, 2, 2); parcorr(ar2); title('PACF: AR(2) (lag=2 后截断)');
subplot(2, 2, 3); autocorr(ar1, 'NumLags', 30); title('ACF: AR(1)');
subplot(2, 2, 4); parcorr(ar1, 'NumLags', 30); title('PACF: AR(1)');

fprintf('PACF 用于确定 AR 模型阶数\n');
fprintf('AR(p): PACF 在 lag=p 后截断\n');

%% ===== 3. 周期图 (Periodogram) =====
fprintf('\n===== 3. 周期图 =====\n');

Fs = 1000;  % 采样率 1000 Hz
t = (0:N-1)/Fs;

% 多频率信号
signal = 2*sin(2*pi*50*t) + 1.5*sin(2*pi*120*t) + 0.5*sin(2*pi*300*t) + randn(1,N);

figure('Name', '周期图', 'Position', [300 300 800 400]);
subplot(1, 2, 1);
plot(t*1000, signal, 'LineWidth', 0.5);
title('时域信号');
xlabel('时间 (ms)'); ylabel('幅值');
grid on;

subplot(1, 2, 2);
periodogram(signal, [], [], Fs);
title('功率谱密度 (Periodogram)');

fprintf('周期图检测到频率: 50 Hz, 120 Hz, 300 Hz\n');

%% ===== 4. FFT 频谱分析 =====
fprintf('\n===== 4. FFT 频谱分析 =====\n');

% FFT
Y = fft(signal);
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(N/2))/N;

[peaks_val, peaks_idx] = findpeaks(P1, 'MinPeakHeight', 0.5);

figure('Name', 'FFT 频谱', 'Position', [100 100 700 400]);
stem(f, P1, 'filled', 'MarkerSize', 3);
hold on;
for i = 1:length(peaks_idx)
    plot(f(peaks_idx(i)), peaks_val(i), 'r*', 'MarkerSize', 15);
    text(f(peaks_idx(i))+10, peaks_val(i), sprintf('%.0f Hz', f(peaks_idx(i))), ...
        'FontSize', 10, 'Color', 'r');
end
hold off;
xlabel('频率 (Hz)'); ylabel('幅值');
title('FFT 幅度谱');
grid on;
xlim([0 500]);

fprintf('FFT 检测到的频率:\n');
for i = 1:length(peaks_idx)
    fprintf('  %.0f Hz (幅值: %.2f)\n', f(peaks_idx(i)), peaks_val(i));
end

fprintf('\n===== 自相关与谱分析模块完成! =====\n');
