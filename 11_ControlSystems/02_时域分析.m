%% 02_时域分析.m — 时域响应分析
%  涵盖: step, impulse, lsim, 阶跃响应指标
%  需要 Control System Toolbox

clear; clc; close all;

%% ===== 1. 阶跃响应 =====
fprintf('===== 1. 阶跃响应 =====\n');

s = tf('s');

% 不同阻尼的二阶系统
wn = 5;
zeta_vals = [0.1, 0.3, 0.5, 0.707, 1.0, 2.0];
colors = ['r', 'm', 'b', 'g', 'c', 'k'];
labels = {'\zeta=0.1', '\zeta=0.3', '\zeta=0.5', '\zeta=0.707', '\zeta=1.0', '\zeta=2.0'};

figure('Name', '阶跃响应对比', 'Position', [100 100 700 500]);
hold on;
for i = 1:length(zeta_vals)
    sys = tf(wn^2, [1 2*zeta_vals(i)*wn wn^2]);
    step(sys, 'Color', colors(i), 'LineWidth', 1.5);
end
hold off;
title('二阶系统阶跃响应 (不同阻尼比)');
xlabel('时间 (s)'); ylabel('幅值');
legend(labels, 'Location', 'best');
grid on;

%% ===== 2. 阶跃响应指标 =====
fprintf('\n===== 2. 阶跃响应指标 =====\n');

% 欠阻尼系统
zeta = 0.3;
sys = tf(wn^2, [1 2*zeta*wn wn^2]);
info = stepinfo(sys);

fprintf('系统参数: wn = %.2f, \zeta = %.2f\n', wn, zeta);
fprintf('上升时间 (RiseTime):     %.4f s\n', info.RiseTime);
fprintf('峰值时间 (PeakTime):     %.4f s\n', info.PeakTime);
fprintf('超调量 (Overshoot):      %.2f%%\n', info.Overshoot);
fprintf('调节时间 (SettlingTime): %.4f s\n', info.SettlingTime);
fprintf('稳态值 (SteadyStateValue): %.4f\n', info.SteadyStateValue);

% 可视化标注
figure('Name', '阶跃响应指标', 'Position', [200 200 700 500]);
step(sys);
title(sprintf('阶跃响应 (\zeta=%.2f, wn=%.1f)', zeta, wn));
grid on;

% 在图上标注
hold on;
% 稳态值
yline(info.SteadyStateValue, 'k--', '稳态值');
% 超调
peak_val = info.SteadyStateValue * (1 + info.Overshoot/100);
plot(info.PeakTime, peak_val, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(info.PeakTime + 0.1, peak_val, sprintf('超调 %.1f%%', info.Overshoot), ...
    'FontSize', 10, 'Color', 'r');
hold off;

%% ===== 3. 脉冲响应 =====
fprintf('\n===== 3. 脉冲响应 =====\n');

figure('Name', '脉冲响应', 'Position', [300 300 700 500]);
hold on;
for i = 1:length(zeta_vals)
    sys = tf(wn^2, [1 2*zeta_vals(i)*wn wn^2]);
    impulse(sys, 'Color', colors(i), 'LineWidth', 1.5);
end
hold off;
title('二阶系统脉冲响应');
xlabel('时间 (s)'); ylabel('幅值');
legend(labels, 'Location', 'best');
grid on;

%% ===== 4. 任意输入响应 (lsim) =====
fprintf('\n===== 4. 任意输入响应 (lsim) =====\n');

% 系统
sys_plant = tf(10, [1 3 2]);  % G(s) = 10/(s^2+3s+2)

% 输入信号
t = 0:0.01:10;

% 4a: 正弦输入
u_sin = sin(2 * pi * 0.5 * t);  % 0.5 Hz 正弦
[y_sin, t_sin] = lsim(sys_plant, u_sin, t);

figure('Name', '正弦输入响应', 'Position', [100 100 700 400]);
subplot(2, 1, 1);
plot(t, u_sin, 'b-', 'LineWidth', 1);
title('输入: 0.5 Hz 正弦波');
ylabel('幅值'); grid on;
subplot(2, 1, 2);
plot(t_sin, y_sin, 'r-', 'LineWidth', 1.5);
title('系统输出');
xlabel('时间 (s)'); ylabel('幅值'); grid on;

% 4b: 方波输入
u_square = square(2 * pi * 0.2 * t);  % 0.2 Hz 方波
[y_square, t_sq] = lsim(sys_plant, u_square, t);

figure('Name', '方波输入响应', 'Position', [200 200 700 400]);
subplot(2, 1, 1);
plot(t, u_square, 'b-', 'LineWidth', 1);
title('输入: 0.2 Hz 方波');
ylabel('幅值'); grid on;
subplot(2, 1, 2);
plot(t_sq, y_square, 'r-', 'LineWidth', 1.5);
title('系统输出');
xlabel('时间 (s)'); ylabel('幅值'); grid on;

% 4c: 斜坡输入
u_ramp = t;
[y_ramp, t_ramp] = lsim(sys_plant, u_ramp, t);

fprintf('正弦输入 -> 稳态幅值: %.4f\n', y_sin(end));
fprintf('方波输入 -> 稳态值: %.4f\n', y_square(end));
fprintf('斜坡输入 -> t=10s 时输出: %.4f\n', y_ramp(end));

%% ===== 5. 稳定性分析 =====
fprintf('\n===== 5. 稳定性分析 =====\n');

% 稳定系统
G_stable = tf(10, [1 3 2]);
% 不稳定系统 (有右半平面极点)
G_unstable = tf(10, [1 -1 -2]);  % 极点 s=2, s=-1
% 临界稳定
G_marginal = tf(10, [1 0 4]);    % 极点 s=±2i

fprintf('稳定系统极点: ');
disp(pole(G_stable)');
fprintf('不稳定系统极点: ');
disp(pole(G_unstable)');
fprintf('临界稳定系统极点: ');
disp(pole(G_marginal)');

figure('Name', '稳定性对比', 'Position', [300 300 900 300]);
subplot(1, 3, 1);
step(G_stable, 5); title('稳定系统'); grid on;
subplot(1, 3, 2);
step(G_unstable, 5); title('不稳定系统'); grid on;
subplot(1, 3, 3);
step(G_marginal, 5); title('临界稳定 (持续振荡)'); grid on;

% isstable 检查
fprintf('\nisstable 检查:\n');
fprintf('G_stable:   %d\n', isstable(G_stable));
fprintf('G_unstable: %d\n', isstable(G_unstable));
fprintf('G_marginal: %d\n', isstable(G_marginal));

fprintf('\n===== 时域分析模块完成! =====\n');
