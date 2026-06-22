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

%% 5. 窗函数与频谱泄露
fprintf('\n--- 窗函数与频谱泄露 ---\n');

% 非整数周期截断导致泄露
N_win = 256;
t_win = (0:N_win-1)/fs;
f_sig = 53.5;  % 非频率分辨率整数倍 → 泄露
sig_leak = sin(2*pi*f_sig*t_win);

% 不同窗函数
windows = {'矩形窗', '汉宁窗', '汉明窗', 'Blackman窗'};
win_funcs = {@(N)ones(N,1), @hann, @hamming, @blackman};

figure('Name', '窗函数与泄露', 'Position', [100, 100, 1000, 600]);
subplot(2,2,1);
for w = 1:4
    win = win_funcs{w}(N_win);
    sig_windowed = sig_leak .* win;
    Y_w = fft(sig_windowed, 1024);
    P_w = 2*abs(Y_w(1:513)) / sum(win);
    f_w = fs*(0:512)/1024;
    plot(f_w, 20*log10(P_w + 1e-10), 'LineWidth', 1, 'DisplayName', windows{w}); hold on;
end
xlabel('频率 (Hz)'); ylabel('幅值 (dB)');
title('不同窗函数的频谱泄露对比');
legend('Location', 'best');
xlim([30, 80]);
grid on;

% 窗函数时域形状
subplot(2,2,2);
for w = 1:4
    win = win_funcs{w}(N_win);
    plot(1:N_win, win, 'LineWidth', 1.5, 'DisplayName', windows{w}); hold on;
end
xlabel('样本'); ylabel('幅值');
title('窗函数时域形状');
legend('Location', 'best');
grid on;

% 主瓣宽度 vs 旁瓣衰减
subplot(2,2,3);
mainlobe = [2, 4, 4, 6];  % 主瓣宽度 (频率箱数)
sidelobe = [-13, -31, -43, -58];  % 旁瓣衰减 (dB)
bar(1:4, sidelobe, 'FaceColor', [0.3 0.5 0.8]);
set(gca, 'XTickLabel', windows);
ylabel('第一旁瓣衰减 (dB)');
title('窗函数性能: 旁瓣衰减');
grid on;

subplot(2,2,4);
bar(1:4, mainlobe, 'FaceColor', [0.8 0.4 0.3]);
set(gca, 'XTickLabel', windows);
ylabel('主瓣宽度 (箱数)');
title('窗函数性能: 频率分辨率');
grid on;

%% 6. 零填充与频率分辨率
fprintf('\n--- 零填充 ---\n');

N_orig = 64;
t_orig = (0:N_orig-1)/fs;
sig_short = sin(2*pi*100*t_orig) + 0.5*sin(2*pi*110*t_orig);

% 不同FFT点数
nfft_vals = [64, 128, 256, 1024];

figure('Name', '零填充效果', 'Position', [100, 100, 800, 400]);
for i = 1:length(nfft_vals)
    Y_zp = fft(sig_short, nfft_vals(i));
    P_zp = 2*abs(Y_zp(1:nfft_vals(i)/2+1)) / N_orig;
    f_zp = fs*(0:nfft_vals(i)/2) / nfft_vals(i);
    
    subplot(2, 2, i);
    stem(f_zp, P_zp, 'filled', 'MarkerSize', 2);
    title(sprintf('N_{FFT} = %d', nfft_vals(i)));
    xlabel('Hz'); ylabel('幅值');
    xlim([80, 140]);
    grid on;
end
fprintf('零填充提高频率显示的精细度，但不提高实际分辨率\n');
fprintf('实际分辨率仅由原始数据长度决定: Δf = fs/N = %.1f Hz\n', fs/N_orig);

%% === 总结 ===
fprintf('\n=== FFT频谱分析总结 ===\n');
fprintf('1. 基本FFT: 幅值谱、相位谱、峰值检测\n');
fprintf('2. 功率谱: periodogram、Welch方法\n');
fprintf('3. 频谱图: STFT短时傅里叶、chirp信号\n');
fprintf('4. 窗函数: 减少频谱泄露、主瓣/旁瓣权衡\n');
fprintf('5. 零填充: 提高显示精度，不提高实际分辨率\n');
