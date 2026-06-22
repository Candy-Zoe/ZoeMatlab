%% 语音处理 (Speech Processing)
% 本脚本演示语音信号处理的基本方法
% 基础 MATLAB + Signal Processing Toolbox (可选)
% 内容: 语音特征提取, MFCC, 端点检测, 语音合成基础
clear; clc; close all;

%% === 第一部分: 语音信号特性 ===
fprintf('=== 语音处理 ===\n\n');
fprintf('--- 第一部分: 语音信号特性 ---\n\n');

fprintf('语音信号特点:\n');
fprintf('  频率范围: 80 Hz - 8000 Hz (人声)\n');
fprintf('  基频 (F0): 男 85-180 Hz, 女 165-255 Hz\n');
fprintf('  采样率: 8 kHz (电话) / 16 kHz (语音识别)\n');
fprintf('  短时平稳: 约 20-30 ms 内可视为平稳信号\n\n');

fprintf('语音的三要素:\n');
fprintf('  1. 音调 (Pitch) - 由基频决定\n');
fprintf('  2. 响度 (Loudness) - 由幅度决定\n');
fprintf('  3. 音色 (Timbre) - 由频谱包络决定\n');

% 生成模拟语音信号 (元音 /a/ 的简化模型)
Fs = 16000;
dur = 0.5;   % 0.5秒
t = 0:1/Fs:dur-1/Fs;
N = length(t);

% 声源: 脉冲串 (模拟声带振动)
F0 = 150;     % 基频 150 Hz
source = zeros(1, N);
period = round(Fs/F0);
source(1:period:N) = 1;

% 声道滤波器 (简化的共振峰模型)
% 元音 /a/ 的前两个共振峰: F1=730 Hz, F2=1090 Hz
F1 = 730; F2 = 1090;
BW1 = 60; BW2 = 90;

try
    % 使用二阶共振峰滤波器
    [b1, a1] = butter(2, [F1-BW1 F1+BW1]/(Fs/2), 'bandpass');
    [b2, a2] = butter(2, [F2-BW2 F2+BW2]/(Fs/2), 'bandpass');
    
    vowel_a = filter(b1, a1, source) + 0.7*filter(b2, a2, source);
catch
    % 简化版: 直接叠加共振峰
    vowel_a = sin(2*pi*F1*t) + 0.7*sin(2*pi*F2*t);
    vowel_a = vowel_a .* source;
end

% 添加自然衰减
envelope = exp(-2*t/dur);
vowel_a = vowel_a .* envelope * 2;

figure('Name', '语音信号特征', 'Position', [100 100 1000 600]);

subplot(3,2,1);
plot(t, vowel_a, 'b', 'LineWidth', 0.3);
xlabel('时间 (s)'); ylabel('幅度');
title('合成元音 /a/ 波形'); grid on;

subplot(3,2,2);
% 放大显示脉冲结构
plot(t(1:500), vowel_a(1:500), 'b', 'LineWidth', 0.8);
xlabel('时间 (s)'); ylabel('幅度');
title('脉冲串结构 (F0 = 150 Hz)'); grid on;

%% === 第二部分: 语谱图分析 ===
fprintf('\n--- 第二部分: 语谱图分析 ---\n');

% 语谱图
subplot(3,2,3);
window_len = round(0.025 * Fs);  % 25ms 窗长
hop_len = round(0.010 * Fs);     % 10ms 帧移
window = hamming(window_len);
spectrogram(vowel_a, window, window_len-hop_len, 512, Fs, 'yaxis');
title('语谱图 (元音 /a/)');

% 共振峰标注
hold on;
yline(F1, 'r--', 'LineWidth', 1);
yline(F2, 'r--', 'LineWidth', 1);
text(0.05, F1+100, sprintf('F1=%d Hz', F1), 'Color', 'r', 'FontSize', 9);
text(0.05, F2+100, sprintf('F2=%d Hz', F2), 'Color', 'r', 'FontSize', 9);

% 不同元音的共振峰
fprintf('\n常见元音共振峰 (成人男性):\n');
fprintf('%-6s | F1 (Hz) | F2 (Hz) | 特征\n', '元音');
fprintf('-------|---------|---------|-----------\n');
vowels = {
    '/a/',  730,  1090, '开口大, 舌位低';
    '/e/',  530,  1840, '半开, 前元音';
    '/i/',  270,  2290, '闭口, 前元音';
    '/o/',  570,  840,  '圆唇, 后元音';
    '/u/',  300,  870,  '闭口圆唇, 后元音';
};
for i = 1:size(vowels, 1)
    fprintf('%-6s | %5d   | %5d   | %s\n', vowels{i,:});
end

% F1-F2 元音图
subplot(3,2,4);
F1_vals = [vowels{:,2}];
F2_vals = [vowels{:,3}];
plot(F2_vals, F1_vals, 'ko', 'MarkerSize', 12, 'LineWidth', 2); hold on;
for i = 1:length(F1_vals)
    text(F2_vals(i)+30, F1_vals(i)+30, vowels{i,1}, 'FontSize', 12);
end
xlabel('F2 (Hz)'); ylabel('F1 (Hz)');
title('F1-F2 元音图');
grid on;
xlim([600 2500]); ylim([200 900]);
set(gca, 'XDir', 'reverse');

%% === 第三部分: MFCC 特征提取 ===
fprintf('\n--- 第三部分: MFCC 特征 ---\n\n');

fprintf('MFCC (梅尔频率倒谱系数):\n');
fprintf('  - 模拟人耳频率感知特性\n');
fprintf('  - 语音识别中最常用的特征\n');
fprintf('  - 通常提取 13 个 MFCC 系数\n\n');

fprintf('MFCC 计算步骤:\n');
fprintf('  1. 预加重: y[n] = x[n] - 0.97*x[n-1]\n');
fprintf('  2. 分帧: 25ms 窗长, 10ms 帧移\n');
fprintf('  3. 加窗: 汉明窗\n');
fprintf('  4. FFT: 计算短时频谱\n');
fprintf('  5. 梅尔滤波器组: 映射到梅尔频率尺度\n');
fprintf('  6. 取对数能量\n');
fprintf('  7. DCT: 得到 MFCC 系数\n');

% 梅尔频率 vs 线性频率
subplot(3,2,5);
f_linear = linspace(0, 8000, 500);
f_mel = 2595 * log10(1 + f_linear/700);
plot(f_linear, f_mel, 'b', 'LineWidth', 2);
xlabel('频率 (Hz)'); ylabel('梅尔频率 (Mel)');
title('梅尔频率尺度');
grid on;

% 梅尔滤波器组
subplot(3,2,6);
n_filters = 26;
n_fft = 512;
f_max = Fs/2;
mel_min = 0;
mel_max = 2595*log10(1+f_max/700);
mel_points = linspace(mel_min, mel_max, n_filters+2);
f_points = 700*(10.^(mel_points/2595) - 1);

filter_bank = zeros(n_filters, n_fft/2+1);
for i = 1:n_filters
    f_left = f_points(i);
    f_center = f_points(i+1);
    f_right = f_points(i+2);
    
    for j = 1:n_fft/2+1
        f_j = (j-1)*Fs/n_fft;
        if f_j >= f_left && f_j <= f_center
            filter_bank(i,j) = (f_j - f_left)/(f_center - f_left);
        elseif f_j > f_center && f_j <= f_right
            filter_bank(i,j) = (f_right - f_j)/(f_right - f_center);
        end
    end
end

f_axis = (0:n_fft/2)*Fs/n_fft;
plot(f_axis(1:200), filter_bank(:,1:200)', 'LineWidth', 0.8);
xlabel('频率 (Hz)'); ylabel('增益');
title('梅尔滤波器组');
grid on;

%% === 第四部分: 端点检测 ===
fprintf('\n--- 第四部分: 端点检测 (VAD) ---\n\n');

fprintf('语音端点检测 (Voice Activity Detection):\n');
fprintf('  - 区分语音段和静音段\n');
fprintf('  - 方法1: 短时能量阈值\n');
fprintf('  - 方法2: 过零率分析\n');
fprintf('  - 方法3: 能量 + 过零率组合\n\n');

% 模拟含静音的语音信号
silence = zeros(1, round(0.3*Fs));
speech_part = vowel_a * 3;
full_signal = [silence, speech_part, silence, speech_part, silence];
t_full = (0:length(full_signal)-1)/Fs;

% 短时能量
frame_len = round(0.02*Fs);
n_frames = floor(length(full_signal)/frame_len);
energy = zeros(1, n_frames);
for i = 1:n_frames
    frame = full_signal((i-1)*frame_len+1:i*frame_len);
    energy(i) = sum(frame.^2)/frame_len;
end

% 过零率
zcr = zeros(1, n_frames);
for i = 1:n_frames
    frame = full_signal((i-1)*frame_len+1:i*frame_len);
    zcr(i) = sum(abs(diff(sign(frame)))) / (2*frame_len);
end

fprintf('检测到 %d 个语音帧 (共 %d 帧)\n', sum(energy > 0.01), n_frames);

figure('Name', '端点检测', 'Position', [100 100 800 400]);
subplot(3,1,1);
plot(t_full, full_signal, 'b', 'LineWidth', 0.3);
xlabel('时间 (s)'); ylabel('幅度');
title('含静音的语音信号'); grid on;

subplot(3,1,2);
frame_time = (0:n_frames-1)*frame_len/Fs;
plot(frame_time, energy, 'r', 'LineWidth', 1);
yline(0.01, 'k--', '阈值');
xlabel('时间 (s)'); ylabel('能量');
title('短时能量'); grid on;

subplot(3,1,3);
plot(frame_time, zcr, 'g', 'LineWidth', 1);
xlabel('时间 (s)'); ylabel('过零率');
title('过零率'); grid on;

%% === 总结 ===
fprintf('\n=== 语音处理总结 ===\n');
fprintf('1. 语音由声带振动(源)经声道(滤波器)产生\n');
fprintf('2. 共振峰 (F1, F2) 决定元音音质\n');
fprintf('3. MFCC 是语音识别的标准特征\n');
fprintf('4. 语谱图展示语音频率随时间的变化\n');
fprintf('5. 端点检测用于定位语音段的起止位置\n');
