%% 01_模拟调制.m — 模拟信号调制
%  涵盖: ammod, fmmod, pmmod, 调制信号可视化
%  需要 Communications Toolbox

clear; clc; close all;

%% ===== 1. 生成消息信号 =====
fprintf('===== 1. 消息信号与载波 =====\n');

Fs = 10000;     % 采样率
Fc = 500;       % 载波频率
Fm = 10;        % 消息频率
t = (0:1/Fs:0.1-1/Fs)';

% 消息信号: 正弦 + 方波
msg = sin(2*pi*Fm*t) + 0.5*sin(2*pi*3*Fm*t);

% 载波
carrier = cos(2*pi*Fc*t);

figure('Name', '消息与载波', 'Position', [100 100 800 400]);
subplot(2, 1, 1);
plot(t*1000, msg, 'b-', 'LineWidth', 1);
title('消息信号 (基带)');
xlabel('时间 (ms)'); ylabel('幅值');
grid on;

subplot(2, 1, 2);
plot(t*1000, carrier, 'r-', 'LineWidth', 0.5);
title(sprintf('载波 (%.0f Hz)', Fc));
xlabel('时间 (ms)'); ylabel('幅值');
grid on;

%% ===== 2. 调幅 (AM) =====
fprintf('\n===== 2. 幅度调制 (AM) =====\n');

try
    % ammod
    Ka = 0.8;  % 调制指数
    am_signal = ammod(msg, Fc, Fs, 0, Ka);
    
    % 包络检波
    am_env = abs(hilbert(am_signal));
    
    figure('Name', 'AM 调制', 'Position', [200 200 800 500]);
    subplot(3, 1, 1);
    plot(t*1000, am_signal, 'b-', 'LineWidth', 0.5);
    title('AM 调制信号'); grid on;
    
    subplot(3, 1, 2);
    plot(t*1000, am_signal, 'b-', 'LineWidth', 0.3); hold on;
    plot(t*1000, am_env, 'r-', 'LineWidth', 1.5);
    plot(t*1000, -am_env, 'r-', 'LineWidth', 1.5);
    hold off;
    title('AM 信号 + 包络'); grid on;
    
    subplot(3, 1, 3);
    plot(t*1000, am_env - Ka, 'g-', 'LineWidth', 1); hold on;
    plot(t*1000, msg, 'b--', 'LineWidth', 1);
    hold off;
    title('解调: 包络检波恢复消息'); grid on;
    legend('解调信号', '原始消息');
    
    fprintf('AM 调制指数: %.1f\n', Ka);
    
catch ME
    fprintf('ammod 不可用: %s\n', ME.message);
    % 手动实现 AM
    am_signal = (1 + Ka*msg) .* carrier;
    figure; plot(t*1000, am_signal); title('AM (手动实现)'); grid on;
end

%% ===== 3. 调频 (FM) =====
fprintf('\n===== 3. 频率调制 (FM) =====\n');

try
    Kf = 200;  % 频率偏移
    fm_signal = fmmod(msg, Fc, Fs, Kf);
    
    figure('Name', 'FM 调制', 'Position', [300 300 800 400]);
    subplot(2, 1, 1);
    plot(t*1000, fm_signal, 'b-', 'LineWidth', 0.5);
    title('FM 调制信号'); grid on;
    
    subplot(2, 1, 2);
    % 瞬时频率
    inst_freq = Fc + Kf * msg;
    plot(t*1000, inst_freq, 'r-', 'LineWidth', 1);
    title('瞬时频率变化');
    xlabel('时间 (ms)'); ylabel('频率 (Hz)');
    grid on;
    
    fprintf('FM 频率偏移: %.0f Hz\n', Kf);
    
catch ME
    fprintf('fmmod 不可用: %s\n', ME.message);
    % 手动实现
    phase = 2*pi*Fc*t + Kf*cumsum(msg)/Fs;
    fm_signal = cos(phase);
    figure; plot(t*1000, fm_signal); title('FM (手动实现)'); grid on;
end

%% ===== 4. 调相 (PM) =====
fprintf('\n===== 4. 相位调制 (PM) =====\n');

try
    Kp = pi/2;  % 相位偏移
    pm_signal = pmmod(msg, Fc, Fs, Kp);
    
    figure('Name', 'PM 调制', 'Position', [100 100 800 300]);
    plot(t*1000, pm_signal, 'g-', 'LineWidth', 0.5);
    title('PM 调制信号');
    xlabel('时间 (ms)'); ylabel('幅值');
    grid on;
    
    fprintf('PM 相位偏移: %.2f rad\n', Kp);
    
catch ME
    fprintf('pmmod 不可用: %s\n', ME.message);
    phase = 2*pi*Fc*t + Kp*msg;
    pm_signal = cos(phase);
    figure; plot(t*1000, pm_signal); title('PM (手动实现)'); grid on;
end

%% ===== 5. 调制对比 =====
fprintf('\n===== 5. 调制方式对比 =====\n');

fprintf('模拟调制方式对比:\n');
fprintf('  AM: 信息编码在幅值中，简单易实现，抗噪性差\n');
fprintf('  FM: 信息编码在频率中，抗噪性好，带宽大\n');
fprintf('  PM: 信息编码在相位中，与FM类似\n');
fprintf('  FM 广播: 88-108 MHz\n');
fprintf('  AM 广播: 530-1600 kHz\n');

fprintf('\n===== 模拟调制模块完成! =====\n');
