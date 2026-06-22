%% =========================================================================
%  卷积与相关
%  学习目标：掌握卷积运算、自相关、互相关
%% =========================================================================

clear; clc; close all;

%% 1. 一维卷积 (conv)
disp('--- 一维卷积 ---');

% 基本卷积
a = [1, 2, 3];
b = [4, 5];
c = conv(a, b);
fprintf('a = [%s]\n', num2str(a));
fprintf('b = [%s]\n', num2str(b));
fprintf('conv(a,b) = [%s]\n', num2str(c));
fprintf('长度: %d + %d - 1 = %d\n', length(a), length(b), length(c));

% 卷积模式
c_full = conv(a, b, 'full');
c_same = conv(a, b, 'same');
c_valid = conv(a, b, 'valid');
fprintf('full:  [%s] (长度 %d)\n', num2str(c_full), length(c_full));
fprintf('same:  [%s] (长度 %d)\n', num2str(c_same), length(c_same));
fprintf('valid: [%s] (长度 %d)\n', num2str(c_valid), length(c_valid));

%% 2. 卷积的可视化
disp('--- 卷积可视化 ---');

% 用卷积实现移动平均滤波
fs = 100;
t = 0:1/fs:1;
sig = sin(2*pi*5*t) + 0.5*randn(size(t));

% 不同窗长的移动平均
figure('Name', '移动平均卷积', 'Position', [100, 100, 800, 500]);

subplot(3,1,1);
plot(t, sig, 'LineWidth', 0.5);
title('原始信号 (5Hz + 噪声)');
xlabel('时间 (s)'); ylabel('幅值');

for k = 1:2
    window_len = [5, 20];
    h = ones(1, window_len(k)) / window_len(k);
    sig_smooth = conv(sig, h, 'same');
    
    subplot(3,1,k+1);
    plot(t, sig, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.3); hold on;
    plot(t, sig_smooth, 'r-', 'LineWidth', 1.5);
    title(sprintf('移动平均滤波 (窗长=%d)', window_len(k)));
    xlabel('时间 (s)'); ylabel('幅值');
    legend('原始', '平滑后');
    hold off;
end

%% 3. 自相关 (autocorrelation)
disp('--- 自相关 ---');

% 周期信号的自相关可以检测周期
fs2 = 1000;
N = 2000;
t2 = (0:N-1)/fs2;

% 含噪周期信号
sig_periodic = sin(2*pi*100*t2) + 0.8*randn(size(t2));

% 自相关
[acf, lags] = xcorr(sig_periodic, 'coeff');

figure('Name', '自相关', 'Position', [100, 100, 800, 400]);

subplot(1,2,1);
plot(t2, sig_periodic, 'LineWidth', 0.5);
title('含噪周期信号 (100Hz)');
xlabel('时间 (s)'); ylabel('幅值');

subplot(1,2,2);
plot(lags/fs2, acf, 'LineWidth', 1);
title('自相关函数');
xlabel('时延 (s)'); ylabel('相关系数');
grid on;

% 找到第一个峰值（排除零时延）
acf_pos = acf(lags > 0);
lags_pos = lags(lags > 0);
[~, peak_idx] = findpeaks(acf_pos, 'MinPeakDistance', 5, 'NPeaks', 1);
if ~isempty(peak_idx)
    period = lags_pos(peak_idx(1))/fs2;
    fprintf('检测到的周期: %.4f s (频率 %.1f Hz)\n', period, 1/period);
end

%% 4. 互相关 (cross-correlation)
disp('--- 互相关 ---');

% 两个信号之间的时延检测
fs3 = 1000;
t3 = 0:1/fs3:0.5;
delay_samples = 50;                    % 信号2比信号1延迟50个采样点

sig1 = sin(2*pi*20*t3);
sig2 = [zeros(1, delay_samples), sig1(1:end-delay_samples)];
sig2 = sig2 + 0.2*randn(size(sig2));

% 互相关
[ccf, lags_cc] = xcorr(sig1, sig2, 'coeff');

figure('Name', '互相关', 'Position', [100, 100, 800, 300]);

subplot(1,2,1);
plot(t3, sig1, 'b-', 'LineWidth', 1); hold on;
plot(t3, sig2, 'r-', 'LineWidth', 0.8);
title('两个信号');
xlabel('时间 (s)'); ylabel('幅值');
legend('信号1', '信号2 (延迟50ms)');
hold off;

subplot(1,2,2);
plot(lags_cc/fs3*1000, ccf, 'LineWidth', 1);
title('互相关函数');
xlabel('时延 (ms)'); ylabel('相关系数');
grid on;

% 找到最大相关对应的时延
[max_cc, max_idx] = max(ccf);
detected_delay = lags_cc(max_idx) / fs3 * 1000;
fprintf('理论延迟: %.1f ms\n', delay_samples/fs3*1000);
fprintf('检测延迟: %.1f ms\n', detected_delay);
hold on;
plot(detected_delay, max_cc, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
hold off;

disp('=== 脚本执行完毕 ===');
