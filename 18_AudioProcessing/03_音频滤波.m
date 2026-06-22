%% 音频滤波 (Audio Filtering)
% 本脚本演示音频信号的各种滤波方法
% 需要 Signal Processing Toolbox (基础方法可替代)
% 内容: 低通/高通/带通滤波, 均衡器, 降噪
clear; clc; close all;

%% === 第一部分: 滤波器类型 ===
fprintf('=== 音频滤波 ===\n\n');
fprintf('--- 第一部分: 音频滤波器类型 ---\n\n');

fprintf('常用音频滤波器:\n');
fprintf('  低通 (Low-pass):   保留低频, 去除高频噪声\n');
fprintf('  高通 (High-pass):  去除低频噪声 (如风声)\n');
fprintf('  带通 (Band-pass):  保留特定频段 (如人声 300-3400 Hz)\n');
fprintf('  带阻 (Notch):      去除特定频率 (如 50/60 Hz 电源噪声)\n');
fprintf('  均衡器 (EQ):       调节多个频段的增益\n');

Fs = 16000;
N = 16000;
t = (0:N-1)/Fs;

% 测试信号: 多频率混合 + 噪声
f_sig = 500;
signal = sin(2*pi*f_sig*t) + 0.5*sin(2*pi*2000*t) + 0.3*sin(2*pi*5000*t);
noise = 0.2*randn(1, N);
test_signal = signal + noise;

fprintf('\n测试信号: %d Hz + 2000 Hz + 5000 Hz + 噪声\n', f_sig);

try
    %% === 第二部分: 设计并应用滤波器 ===
    fprintf('\n--- 第二部分: 滤波器设计与应用 ---\n');
    
    figure('Name', '音频滤波器', 'Position', [100 100 1000 700]);
    
    % 1. 低通滤波器 (Butterworth)
    fc_lp = 1000;   % 截止频率 1000 Hz
    [b_lp, a_lp] = butter(4, fc_lp/(Fs/2), 'low');
    y_lp = filter(b_lp, a_lp, test_signal);
    
    subplot(3,2,1);
    plot(t(1:500), test_signal(1:500), 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5); hold on;
    plot(t(1:500), y_lp(1:500), 'b', 'LineWidth', 1);
    xlabel('时间 (s)'); ylabel('幅度');
    title(sprintf('低通滤波 (fc = %d Hz)', fc_lp)); grid on;
    legend('原始', '滤波后');
    
    % 2. 高通滤波器
    fc_hp = 1500;
    [b_hp, a_hp] = butter(4, fc_hp/(Fs/2), 'high');
    y_hp = filter(b_hp, a_hp, test_signal);
    
    subplot(3,2,2);
    plot(t(1:500), y_hp(1:500), 'r', 'LineWidth', 0.8);
    xlabel('时间 (s)'); ylabel('幅度');
    title(sprintf('高通滤波 (fc = %d Hz)', fc_hp)); grid on;
    
    % 3. 带通滤波器
    fc_bp = [400 600];
    [b_bp, a_bp] = butter(4, fc_bp/(Fs/2), 'bandpass');
    y_bp = filter(b_bp, a_bp, test_signal);
    
    subplot(3,2,3);
    plot(t(1:500), y_bp(1:500), 'g', 'LineWidth', 0.8);
    xlabel('时间 (s)'); ylabel('幅度');
    title(sprintf('带通滤波 (%d-%d Hz)', fc_bp(1), fc_bp(2))); grid on;
    
    % 4. 带阻滤波器 (去除50Hz电源噪声)
    fc_bs = [48 52];
    [b_bs, a_bs] = butter(2, fc_bs/(Fs/2), 'stop');
    
    % 添加50Hz电源噪声
    power_noise = 0.5*sin(2*pi*50*t);
    signal_50hz = sin(2*pi*200*t) + power_noise;
    y_bs = filter(b_bs, a_bs, signal_50hz);
    
    subplot(3,2,4);
    plot(t(1:500), signal_50hz(1:500), 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5); hold on;
    plot(t(1:500), y_bs(1:500), 'm', 'LineWidth', 1);
    xlabel('时间 (s)'); ylabel('幅度');
    title('带阻滤波 (去除 50 Hz 噪声)'); grid on;
    legend('含50Hz噪声', '滤波后');
    
    % 5. 频谱对比
    subplot(3,2,5);
    f_axis = Fs*(0:N/2)/N;
    Y_orig = abs(fft(test_signal))/N;
    Y_lp = abs(fft(y_lp))/N;
    Y_hp = abs(fft(y_hp))/N;
    
    plot(f_axis(1:500), Y_orig(1:500), 'k', 'LineWidth', 0.8); hold on;
    plot(f_axis(1:500), Y_lp(1:500), 'b', 'LineWidth', 1.5);
    plot(f_axis(1:500), Y_hp(1:500), 'r', 'LineWidth', 1.5);
    xlabel('频率 (Hz)'); ylabel('幅度');
    title('频谱对比'); grid on;
    legend('原始', '低通', '高通');
    
    % 6. 滤波器频率响应
    subplot(3,2,6);
    [H_lp, w_lp] = freqz(b_lp, a_lp, 512, Fs);
    [H_hp, w_hp] = freqz(b_hp, a_hp, 512, Fs);
    [H_bp, w_bp] = freqz(b_bp, a_bp, 512, Fs);
    
    plot(w_lp, 20*log10(abs(H_lp)), 'b', 'LineWidth', 1.5); hold on;
    plot(w_hp, 20*log10(abs(H_hp)), 'r', 'LineWidth', 1.5);
    plot(w_bp, 20*log10(abs(H_bp)), 'g', 'LineWidth', 1.5);
    xlabel('频率 (Hz)'); ylabel('增益 (dB)');
    title('滤波器频率响应'); grid on;
    legend('低通', '高通', '带通');
    ylim([-60 5]);
    
    fprintf('滤波器参数:\n');
    fprintf('  低通: 4阶 Butterworth, fc = %d Hz\n', fc_lp);
    fprintf('  高通: 4阶 Butterworth, fc = %d Hz\n', fc_hp);
    fprintf('  带通: 4阶 Butterworth, fc = [%d, %d] Hz\n', fc_bp(1), fc_bp(2));
    
catch ME
    fprintf('滤波器设计出错: %s\n', ME.message);
    fprintf('需要 Signal Processing Toolbox\n');
end

%% === 第三部分: 音频均衡器 ===
fprintf('\n--- 第三部分: 简易均衡器 ---\n');

eq_bands = {
    '超低音',  20,  80,   '增强低音/鼓声';
    '低音',    80,  250,  '温暖感/丰满感';
    '中低音',  250, 500,  '人声基频区域';
    '中音',    500, 2000, '人声清晰度';
    '中高音',  2000, 4000, '明亮度/锐利度';
    '高音',    4000, 8000, '齿音/细节';
    '超高音',  8000, 20000, '空气感/空间感';
};

fprintf('%-8s | %-12s | %s\n', '频段', '频率范围', '特征');
fprintf('---------|--------------|----------------\n');
for i = 1:size(eq_bands, 1)
    fprintf('%-8s | %d - %d Hz  | %s\n', eq_bands{i,:});
end

% 简易均衡器可视化
figure('Name', '均衡器设置', 'Position', [100 100 700 400]);
gains = [3, 2, 0, 2, 4, 3, 1];  % dB增益
bar(1:7, gains, 'FaceColor', [0.3 0.7 0.9]);
set(gca, 'XTickLabel', {'超低音', '低音', '中低音', '中音', '中高音', '高音', '超高音'});
ylabel('增益 (dB)');
title('均衡器设置示例');
grid on;
ylim([-6 8]);
yline(0, 'k-', 'LineWidth', 1);

%% === 总结 ===
fprintf('\n=== 音频滤波总结 ===\n');
fprintf('1. 低通滤波保留低频, 去除高频噪声和齿音\n');
fprintf('2. 高通滤波去除低频噪声 (如风声、机械振动)\n');
fprintf('3. 带通滤波提取特定频段信息\n');
fprintf('4. 均衡器通过调节多个频段增益改变音色\n');
fprintf('5. Butterworth 滤波器在通带内响应平坦, 适合音频处理\n');
