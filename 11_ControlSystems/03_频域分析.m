%% 03_频域分析.m — 频域响应与稳定性
%  涵盖: bode, nyquist, nichols, margin
%  需要 Control System Toolbox

clear; clc; close all;

%% ===== 1. Bode 图 =====
fprintf('===== 1. Bode 图 =====\n');

s = tf('s');

% 创建系统
G1 = 100 / (s * (s + 1) * (s + 10));  % 三阶系统
G2 = 50 * (s + 2) / (s * (s + 5) * (s + 20));

figure('Name', 'Bode 图', 'Position', [100 100 800 500]);
bode(G1, G2);
legend('G1 = 100/(s(s+1)(s+10))', 'G2 = 50(s+2)/(s(s+5)(s+20))', 'Location', 'best');
grid on;

% 获取 Bode 数据
[mag1, phase1, w1] = bode(G1);
fprintf('G1 Bode 图数据 (前5个频率点):\n');
for i = 1:min(5, length(w1))
    fprintf('  w=%.2f rad/s: 幅值=%.2f dB, 相位=%.1f°\n', ...
        w1(i), 20*log10(mag1(i)), phase1(i));
end

%% ===== 2. 增益/相位裕度 =====
fprintf('\n===== 2. 增益裕度与相位裕度 =====\n');

% margin 函数
[Gm, Pm, Wgm, Wpm] = margin(G1);

fprintf('G1 稳定性裕度:\n');
fprintf('  增益裕度: %.2f dB (w=%.2f rad/s)\n', 20*log10(Gm), Wgm);
fprintf('  相位裕度: %.2f° (w=%.2f rad/s)\n', Pm, Wpm);

if Gm > 1 && Pm > 0
    fprintf('  -> 系统稳定\n');
else
    fprintf('  -> 系统不稳定或裕度不足\n');
end

figure('Name', 'Bode 图 + 裕度标注', 'Position', [200 200 700 500]);
margin(G1);
title('G1 Bode 图 (增益/相位裕度)');

% 多系统裕度对比
fprintf('\n多系统裕度对比:\n');
K_vals = [10, 50, 100, 200];
for i = 1:length(K_vals)
    sys_i = K_vals(i) / (s * (s+1) * (s+10));
    [Gm_i, Pm_i, ~, ~] = margin(sys_i);
    fprintf('  K=%d: GM=%.1f dB, PM=%.1f°\n', K_vals(i), 20*log10(Gm_i), Pm_i);
end

%% ===== 3. Nyquist 图 =====
fprintf('\n===== 3. Nyquist 图 =====\n');

figure('Name', 'Nyquist 图', 'Position', [300 300 600 500]);
nyquist(G1);
title('G1 Nyquist 图');
grid on;

% 放大临界点附近
figure('Name', 'Nyquist 图 (放大)', 'Position', [100 100 600 500]);
nyquist(G1);
hold on;
% 标记 -1+0j 点
plot(-1, 0, 'rx', 'MarkerSize', 15, 'LineWidth', 3);
text(-1.3, 0.2, '(-1, 0j) 临界点', 'FontSize', 11, 'Color', 'r');
hold off;
title('Nyquist 图 (Nyquist 稳定性判据)');
grid on;

fprintf('Nyquist 判据: 围绕 (-1, 0j) 的圈数 = 开环右半平面极点数 - 闭环右半平面极点数\n');

%% ===== 4. Nichols 图 =====
fprintf('\n===== 4. Nichols 图 =====\n');

figure('Name', 'Nichols 图', 'Position', [200 200 700 500]);
nichols(G1);
ngrid;
title('G1 Nichols 图');

%% ===== 5. 频率响应特性 =====
fprintf('\n===== 5. 频率响应特性 =====\n');

% 带宽 (bandwidth)
% 闭环系统
G_cl = feedback(G1, 1);
[mag_cl, ~, w_cl] = bode(G_cl);
mag_cl = squeeze(mag_cl);
w_cl = squeeze(w_cl);

% 找到 -3dB 频率
dc_gain = mag_cl(1);
bw_idx = find(mag_cl < dc_gain / sqrt(2), 1);
if ~isempty(bw_idx)
    bandwidth = w_cl(bw_idx);
    fprintf('闭环系统带宽: %.2f rad/s\n', bandwidth);
end

% 谐振峰值
[peak_mag, peak_idx] = max(mag_cl);
peak_freq = w_cl(peak_idx);
fprintf('谐振峰值: %.2f (%.1f dB) @ %.2f rad/s\n', ...
    peak_mag, 20*log10(peak_mag), peak_freq);

figure('Name', '闭环频率响应', 'Position', [300 300 700 400]);
bode(G_cl);
title('闭环系统 Bode 图');
grid on;

%% ===== 6. 根轨迹 =====
fprintf('\n===== 6. 根轨迹 (rlocus) =====\n');

G_plant = 1 / (s * (s + 2) * (s + 5));

figure('Name', '根轨迹', 'Position', [100 100 600 500]);
rlocus(G_plant);
title('根轨迹: G(s) = K / (s(s+2)(s+5))');
grid on;

% 找到使系统临界稳定的增益
[K_cr, poles_cr] = rlocfind(G_plant);
if ~isempty(K_cr)
    fprintf('临界稳定增益 K: %.4f\n', K_cr);
    fprintf('对应极点: '); disp(poles_cr');
end

% 不同 K 值的闭环响应
figure('Name', '不同增益的阶跃响应', 'Position', [200 200 700 500]);
K_values = [5, 20, 50, 70];
hold on;
for K = K_values
    sys_cl = feedback(K * G_plant, 1);
    step(sys_cl, 10, 'LineWidth', 1.5);
end
hold off;
title('不同增益 K 的闭环阶跃响应');
legend(arrayfun(@(k) sprintf('K=%d', k), K_values, 'UniformOutput', false), ...
    'Location', 'best');
grid on;

fprintf('\n===== 频域分析模块完成! =====\n');
