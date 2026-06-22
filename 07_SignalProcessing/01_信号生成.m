%% =========================================================================
%  信号生成
%  学习目标：掌握各类基本信号的生成方法
%  需要: Signal Processing Toolbox（部分功能基础 MATLAB 即可）
%% =========================================================================

clear; clc; close all;

%% 1. 正弦信号
disp('--- 正弦信号 ---');

fs = 1000;                             % 采样率 1000 Hz
t = 0:1/fs:1-1/fs;                    % 1秒时长

f1 = 50;                               % 50 Hz
sig_sin = sin(2*pi*f1*t);

figure('Name', '基本信号', 'Position', [100, 100, 900, 600]);

subplot(3,2,1);
plot(t, sig_sin, 'LineWidth', 1);
title('正弦信号 f = 50 Hz');
xlabel('时间 (s)'); ylabel('幅值');
xlim([0, 0.1]);

%% 2. 复合信号（多频叠加）
disp('--- 复合信号 ---');

f2 = 120; f3 = 200;
sig_composite = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t) + 0.3*sin(2*pi*f3*t);

subplot(3,2,2);
plot(t, sig_composite, 'LineWidth', 0.5);
title('复合信号 50+120+200 Hz');
xlabel('时间 (s)'); ylabel('幅值');
xlim([0, 0.05]);

%% 3. 方波与锯齿波（需要 Signal Processing Toolbox）
disp('--- 方波与锯齿波 ---');

% 方波
sig_square = square(2*pi*5*t);         % 5 Hz 方波

subplot(3,2,3);
plot(t, sig_square, 'LineWidth', 1);
title('方波 5 Hz');
xlabel('时间 (s)'); ylabel('幅值');
xlim([0, 0.5]);
ylim([-1.5, 1.5]);

% 锯齿波
sig_sawtooth = sawtooth(2*pi*5*t);     % 5 Hz 锯齿波

subplot(3,2,4);
plot(t, sig_sawtooth, 'LineWidth', 1);
title('锯齿波 5 Hz');
xlabel('时间 (s)'); ylabel('幅值');
xlim([0, 0.5]);
ylim([-1.5, 1.5]);

%% 4. 脉冲信号
disp('--- 脉冲信号 ---');

% 单位脉冲（Dirac delta 近似）
N = 100;
n = -N/2:N/2-1;
delta = zeros(size(n));
delta(n == 0) = 1;

subplot(3,2,5);
stem(n, delta, 'filled', 'MarkerSize', 4);
title('单位脉冲 δ(n)');
xlabel('n'); ylabel('幅值');
xlim([-10, 10]);

% 阶跃信号
step = ones(size(n));
step(n < 0) = 0;

subplot(3,2,6);
stem(n, step, 'filled', 'MarkerSize', 4);
title('单位阶跃 u(n)');
xlabel('n'); ylabel('幅值');
xlim([-10, 10]);

%% 5. 带噪声的信号
disp('--- 噪声信号 ---');

rng(42);
fs2 = 1000;
t2 = 0:1/fs2:0.5-1/fs2;
clean = sin(2*pi*50*t2);              % 50Hz 纯净信号
noise = 0.5*randn(size(t2));           % 高斯白噪声
noisy = clean + noise;

figure('Name', '噪声信号', 'Position', [100, 100, 800, 300]);

subplot(1,2,1);
plot(t2, noisy, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5); hold on;
plot(t2, clean, 'r-', 'LineWidth', 2);
title('信号 + 噪声');
xlabel('时间 (s)'); ylabel('幅值');
legend('含噪信号', '原始信号');
hold off;

subplot(1,2,2);
% 信噪比
snr_val = snr(clean, noise);
fprintf('信噪比 SNR = %.1f dB\n', snr_val);
% 不同 SNR 对比
for snr_db = [0, 10, 20, 30]
    noise_level = rms(clean) / (10^(snr_db/20));
    sig_snr = clean + noise_level*randn(size(clean));
    plot(t2, sig_snr + snr_db*2, 'LineWidth', 0.5); hold on;
end
title('不同 SNR 的信号');
xlabel('时间 (s)');
legend('0dB', '10dB', '20dB', '30dB');
hold off;

disp('=== 脚本执行完毕 ===');
