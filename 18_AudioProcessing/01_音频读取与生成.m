%% 音频读取与生成 (Audio Read & Generate)
% 本脚本演示音频数据的读取、生成和基本操作
% 基础 MATLAB 即可 (Audio Toolbox 可选)
% 内容: audioread, audiowrite, audioplayer, 合成音频
clear; clc; close all;

%% === 第一部分: 音频基础概念 ===
fprintf('=== 音频处理基础 ===\n\n');
fprintf('--- 第一部分: 音频基础概念 ---\n\n');

fprintf('数字音频基础:\n');
fprintf('  采样率 (Fs): 每秒采样次数 (Hz)\n');
fprintf('    - 电话: 8 kHz\n');
fprintf('    - FM广播: 22.05 kHz\n');
fprintf('    - CD: 44.1 kHz\n');
fprintf('    - 专业音频: 48/96/192 kHz\n\n');
fprintf('  量化位数 (bit depth):\n');
fprintf('    - 8 bit: 256 级\n');
fprintf('    - 16 bit: 65536 级 (CD 质量)\n');
fprintf('    - 24 bit: 专业录音\n\n');
fprintf('  声道数:\n');
fprintf('    - 单声道 (Mono): 1 通道\n');
fprintf('    - 立体声 (Stereo): 2 通道\n');
fprintf('    - 环绕声: 5.1/7.1 通道\n');

%% === 第二部分: 生成音频信号 ===
fprintf('\n--- 第二部分: 合成音频信号 ---\n');

Fs = 44100;          % 采样率 (CD质量)
duration = 3;        % 3秒
t = 0:1/Fs:duration-1/Fs;
N = length(t);

fprintf('生成参数: Fs=%d Hz, 时长=%d s, 样本数=%d\n', Fs, duration, N);

% 生成不同频率的纯音
figure('Name', '音频信号生成', 'Position', [100 100 1000 600]);

% 1. 正弦波 (A4 = 440 Hz)
f_A4 = 440;
tone_A4 = 0.5 * sin(2*pi*f_A4*t);

subplot(3,2,1);
plot(t(1:2000), tone_A4(1:2000), 'b', 'LineWidth', 0.5);
xlabel('时间 (s)'); ylabel('幅度');
title('A4 音 (440 Hz)'); grid on;

% 2. 和弦 (C大三和弦: C4, E4, G4)
f_C4 = 261.63; f_E4 = 329.63; f_G4 = 392.00;
chord = (sin(2*pi*f_C4*t) + sin(2*pi*f_E4*t) + sin(2*pi*f_G4*t)) / 3;

subplot(3,2,2);
plot(t(1:2000), chord(1:2000), 'r', 'LineWidth', 0.5);
xlabel('时间 (s)'); ylabel('幅度');
title('C大三和弦 (C4+E4+G4)'); grid on;

% 3. 带包络的音符 (ADSR)
attack = 0.05;  decay = 0.1;  sustain = 2.0;  release = 0.5;
env_attack = linspace(0, 1, round(attack*Fs));
env_decay = linspace(1, 0.7, round(decay*Fs));
env_sustain = ones(1, round(sustain*Fs)) * 0.7;
env_release = linspace(0.7, 0, round(release*Fs));
envelope = [env_attack, env_decay, env_sustain, env_release];
envelope = envelope(1:N);

note = 0.5 * sin(2*pi*f_A4*t) .* envelope;

subplot(3,2,3);
plot(t, envelope, 'k-', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('幅度');
title('ADSR 包络'); grid on;
text(attack/2, 0.5, 'Attack');
text(attack+decay/2, 0.8, 'Decay');
text(attack+decay+sustain/2, 0.3, 'Sustain');
text(attack+decay+sustain+release/2, 0.3, 'Release');

subplot(3,2,4);
plot(t, note, 'g', 'LineWidth', 0.5);
xlabel('时间 (s)'); ylabel('幅度');
title('带包络的 A4 音符'); grid on;

% 4. 音阶
fprintf('\n生成音阶...\n');
notes_freq = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25];
notes_name = {'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5'};
note_dur = 0.3;    % 每个音符时长
note_N = round(note_dur * Fs);

scale = zeros(1, 0);
for i = 1:length(notes_freq)
    t_note = 0:1/Fs:note_dur-1/Fs;
    env_note = exp(-2*t_note);  % 简单衰减包络
    note_sig = 0.5 * sin(2*pi*notes_freq(i)*t_note) .* env_note;
    scale = [scale, note_sig];
    fprintf('  %s: %.2f Hz\n', notes_name{i}, notes_freq(i));
end

subplot(3,2,5);
plot(scale, 'b', 'LineWidth', 0.3);
xlabel('样本'); ylabel('幅度');
title('C大调音阶'); grid on;

% 5. 白噪声
noise = 0.3 * randn(1, N);
subplot(3,2,6);
plot(t(1:2000), noise(1:2000), 'm', 'LineWidth', 0.3);
xlabel('时间 (s)'); ylabel('幅度');
title('白噪声'); grid on;

%% === 第三部分: 音频读写 ===
fprintf('\n--- 第三部分: 音频文件读写 ---\n');

try
    % 保存合成音频到文件
    filename = 'demo_audio.wav';
    audiowrite(filename, note', Fs);
    fprintf('已保存音频文件: %s\n', filename);
    
    % 读取音频文件
    [audio_data, read_Fs] = audioread(filename);
    fprintf('读取音频: %d 个样本, Fs=%d Hz\n', length(audio_data), read_Fs);
    fprintf('时长: %.2f 秒\n', length(audio_data)/read_Fs);
    
    % 播放音频
    player = audioplayer(audio_data, read_Fs);
    play(player);
    fprintf('正在播放音频...\n');
    pause(length(audio_data)/read_Fs + 0.5);
    stop(player);
    fprintf('播放完成\n');
    
    % 支持的格式
    fprintf('\n支持的音频格式:\n');
    fprintf('  WAV  - 无损, PCM编码\n');
    fprintf('  MP3  - 有损压缩\n');
    fprintf('  FLAC - 无损压缩\n');
    fprintf('  OGG  - 开源有损压缩\n');
    fprintf('  M4A  - AAC编码\n');
    
    % 清理
    delete(filename);
    
catch ME
    fprintf('音频读写演示: %s\n', ME.message);
    fprintf('audioread/audiowrite 需要支持的编解码器\n');
end

%% === 第四部分: 音频数据信息 ===
fprintf('\n--- 第四部分: 音频数据分析 ---\n');

% 分析合成音阶
figure('Name', '音阶频谱分析', 'Position', [100 100 800 400]);

% 对音阶做短时傅里叶变换 (语谱图)
window = hamming(2048);
noverlap = 1536;
nfft = 4096;

spectrogram(scale, window, noverlap, nfft, Fs, 'yaxis');
title('音阶语谱图');

fprintf('语谱图显示了每个音符的频率成分随时间的变化\n');
fprintf('  - 纵轴: 频率 (Hz)\n');
fprintf('  - 横轴: 时间 (s)\n');
fprintf('  - 颜色: 能量强度\n');

%% === 总结 ===
fprintf('\n=== 音频基础总结 ===\n');
fprintf('1. 采样率决定可表示的最高频率 (Nyquist: f_max = Fs/2)\n');
fprintf('2. 纯音 = sin(2*pi*f*t), 音乐 = 多个纯音的叠加\n');
fprintf('3. ADSR 包络模拟真实乐器的音色特征\n');
fprintf('4. audioread/audiowrite 处理常见音频格式\n');
fprintf('5. 语谱图是音频分析的重要可视化工具\n');
