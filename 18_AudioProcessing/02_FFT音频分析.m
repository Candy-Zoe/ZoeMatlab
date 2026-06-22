%% FFT 音频分析 (FFT Audio Analysis)
% 本脚本演示音频信号的频域分析方法
% 基础 MATLAB + Signal Processing Toolbox (可选)
% 内容: FFT, 功率谱, 频率检测, 谐波分析
clear; clc; close all;

%% === 第一部分: FFT 基础 ===
fprintf('=== FFT 音频分析 ===\n\n');
fprintf('--- 第一部分: FFT 基础 ---\n');

Fs = 8000;              % 采样率
N = 8192;               % 样本数
t = (0:N-1)/Fs;

% 合成信号: 440Hz + 880Hz + 1320Hz (基频+谐波)
f1 = 440; f2 = 880; f3 = 1320;
signal = 1.0*sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t) + 0.25*sin(2*pi*f3*t);
noise = 0.1*randn(1, N);
signal_noisy = signal + noise;

fprintf('信号成分: %d Hz (A=1.0) + %d Hz (A=0.5) + %d Hz (A=0.25)\n', f1, f2, f3);

% FFT 分析
Y = fft(signal_noisy);
P2 = abs(Y/N);           % 双侧频谱
P1 = P2(1:N/2+1);        % 单侧频谱
P1(2:end-1) = 2*P1(2:end-1);
f_axis = Fs*(0:N/2)/N;

figure('Name', 'FFT 频谱分析', 'Position', [100 100 1000 500]);

subplot(2,2,1);
plot(t(1:500), signal_noisy(1:500), 'b', 'LineWidth', 0.5);
xlabel('时间 (s)'); ylabel('幅度');
title('时域信号 (含噪声)'); grid on;

subplot(2,2,2);
stem(f_axis(1:300), P1(1:300), 'LineWidth', 1, 'MarkerSize', 3);
xlabel('频率 (Hz)'); ylabel('幅度');
title('FFT 单侧幅度谱'); grid on;

% 标记峰值频率
[pks, locs] = findpeaks(P1(1:300), 'MinPeakHeight', 0.1);
for i = 1:length(locs)
    fprintf('  检测到频率: %.1f Hz, 幅度: %.2f\n', f_axis(locs(i)), pks(i));
end

% 对数频谱
subplot(2,2,3);
plot(f_axis(1:1000), 20*log10(P1(1:1000)), 'b', 'LineWidth', 1);
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title('对数频谱 (dB)'); grid on;

% 功率谱密度
subplot(2,2,4);
try
    periodogram(signal_noisy, [], N, Fs);
    title('功率谱密度 (Periodogram)');
catch
    PSD = P1.^2;
    plot(f_axis(1:1000), 10*log10(PSD(1:1000)), 'b', 'LineWidth', 1);
    xlabel('频率 (Hz)'); ylabel('功率 (dB)');
    title('功率谱密度'); grid on;
end

%% === 第二部分: 频率分辨率 ===
fprintf('\n--- 第二部分: 频率分辨率 ---\n');

fprintf('频率分辨率: df = Fs / N\n');
fprintf('  N = 1024 时, df = %.1f Hz\n', Fs/1024);
fprintf('  N = 4096 时, df = %.1f Hz\n', Fs/4096);
fprintf('  N = 8192 时, df = %.1f Hz\n', Fs/8192);
fprintf('  N = 16384 时, df = %.1f Hz\n', Fs/16384);

% 不同 FFT 长度对比
figure('Name', '频率分辨率对比', 'Position', [100 100 800 400]);

N_vals = [256, 1024, 4096, 16384];
f_close1 = 440; f_close2 = 460;
signal_close = sin(2*pi*f_close1*t) + sin(2*pi*f_close2*t);

for i = 1:length(N_vals)
    subplot(2, 2, i);
    N_i = N_vals(i);
    Y_i = fft(signal_close(1:min(N_i, length(signal_close))));
    P_i = abs(Y_i(1:N_i/2+1)) / N_i;
    f_i = Fs*(0:N_i/2)/N_i;
    
    plot(f_i(1:min(200, length(f_i))), P_i(1:min(200, length(P_i))), 'b', 'LineWidth', 1);
    xlabel('频率 (Hz)'); ylabel('幅度');
    title(sprintf('N = %d (df = %.1f Hz)', N_i, Fs/N_i));
    grid on; xlim([400 500]);
end
sgtitle('440 Hz 和 460 Hz 的频率分辨率对比');

%% === 第三部分: 谐波分析 ===
fprintf('\n--- 第三部分: 谐波分析 ---\n');

% 模拟不同乐器的音色 (不同谐波分布)
f0 = 220;  % 基频 A3
harmonics_count = 10;

% 钢琴: 偶数谐波较弱
amp_piano = zeros(1, harmonics_count);
for h = 1:harmonics_count
    amp_piano(h) = 1/h;
    if mod(h, 2) == 0
        amp_piano(h) = amp_piano(h) * 0.5;
    end
end

% 小号: 奇数谐波突出
amp_trumpet = zeros(1, harmonics_count);
for h = 1:harmonics_count
    amp_trumpet(h) = 1/sqrt(h);
    if mod(h, 2) == 1
        amp_trumpet(h) = amp_trumpet(h) * 1.5;
    end
end
amp_trumpet = amp_trumpet / max(amp_trumpet);

% 合成信号
piano = zeros(1, N);
trumpet = zeros(1, N);
for h = 1:harmonics_count
    piano = piano + amp_piano(h) * sin(2*pi*h*f0*t);
    trumpet = trumpet + amp_trumpet(h) * sin(2*pi*h*f0*t);
end

figure('Name', '谐波分析: 不同音色', 'Position', [100 100 1000 500]);

% 钢琴
subplot(2,2,1);
plot(t(1:200), piano(1:200), 'b', 'LineWidth', 0.8);
xlabel('时间 (s)'); ylabel('幅度');
title('钢琴波形 (A3)'); grid on;

subplot(2,2,2);
bar(1:harmonics_count, amp_piano/max(amp_piano), 'FaceColor', [0.3 0.6 0.9]);
xlabel('谐波序号'); ylabel('相对幅度');
title('钢琴谐波分布'); grid on;

% 小号
subplot(2,2,3);
plot(t(1:200), trumpet(1:200), 'r', 'LineWidth', 0.8);
xlabel('时间 (s)'); ylabel('幅度');
title('小号波形 (A3)'); grid on;

subplot(2,2,4);
bar(1:harmonics_count, amp_trumpet/max(amp_trumpet), 'FaceColor', [0.9 0.4 0.3]);
xlabel('谐波序号'); ylabel('相对幅度');
title('小号谐波分布'); grid on;

sgtitle('不同乐器的谐波结构决定音色', 'FontSize', 13);

fprintf('音色由谐波结构决定:\n');
fprintf('  - 基频决定音高\n');
fprintf('  - 谐波的相对强度决定音色\n');
fprintf('  - 不同乐器有独特的谐波分布特征\n');

%% === 第四部分: 音高检测 ===
fprintf('\n--- 第四部分: 音高检测 ---\n');

% 使用自相关函数检测基频
Fs_detect = 16000;
t_detect = 0:1/Fs_detect:0.5;
f_test = 330;  % E4
test_signal = sin(2*pi*f_test*t_detect) + 0.3*sin(2*pi*2*f_test*t_detect);
test_signal = test_signal + 0.1*randn(size(test_signal));

% 自相关法
[acf, lags] = xcorr(test_signal, 'coeff');
acf_half = acf(length(acf)/2+1:end);
lags_half = lags(length(lags)/2+1:end);

% 找到第一个峰值 (排除零点)
min_lag = round(Fs_detect/1000);  % 最高频率1kHz
[~, peak_idx] = findpeaks(acf_half(min_lag:end), 'NPeaks', 1);
detected_lag = lags_half(min_lag + peak_idx - 1);
detected_freq = Fs_detect / detected_lag;

fprintf('测试信号频率: %d Hz\n', f_test);
fprintf('自相关检测频率: %.1f Hz\n', detected_freq);
fprintf('误差: %.1f%%\n', abs(detected_freq - f_test)/f_test*100);

figure('Name', '音高检测', 'Position', [100 100 800 300]);
subplot(1,2,1);
plot(t_detect(1:500), test_signal(1:500), 'LineWidth', 0.5);
xlabel('时间 (s)'); ylabel('幅度');
title(sprintf('测试信号: %d Hz', f_test)); grid on;

subplot(1,2,2);
plot(lags_half/Fs_detect*1000, acf_half, 'b', 'LineWidth', 1);
xlabel('滞后时间 (ms)'); ylabel('自相关系数');
title('自相关函数'); grid on;
hold on;
plot(detected_lag/Fs_detect*1000, acf_half(detected_lag+1), 'ro', 'MarkerSize', 10);
legend('自相关', sprintf('峰值: %.1f Hz', detected_freq));

%% === 总结 ===
fprintf('\n=== FFT 音频分析总结 ===\n');
fprintf('1. FFT 将时域信号转换为频域表示\n');
fprintf('2. 频率分辨率 df = Fs/N, 增加 N 可提高分辨率\n');
fprintf('3. 谐波结构是区分不同乐器音色的关键\n');
fprintf('4. 自相关函数可用于基频 (音高) 检测\n');
fprintf('5. 对数频谱 (dB) 更适合观察宽动态范围的信号\n');
