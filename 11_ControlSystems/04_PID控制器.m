%% 04_PID控制器.m — PID 设计与仿真
%  涵盖: pid, pidtune, 闭环控制仿真, 参数调节
%  需要 Control System Toolbox

clear; clc; close all;

%% ===== 1. 被控对象 =====
fprintf('===== 1. 被控对象 =====\n');

s = tf('s');

% 电机模型: G(s) = K / (s*(tau*s + 1))
K_motor = 5;
tau = 0.5;
G_plant = K_motor / (s * (tau * s + 1));

fprintf('被控对象 (直流电机):\n');
disp(G_plant);

% 开环响应
figure('Name', '开环响应', 'Position', [100 100 600 400]);
step(G_plant, 5);
title('被控对象开环阶跃响应 (积分型 -> 持续增长)');
xlabel('时间 (s)'); ylabel('输出');
grid on;

%% ===== 2. P 控制器 =====
fprintf('\n===== 2. 比例 (P) 控制 =====\n');

Kp_vals = [2, 5, 10, 20];
figure('Name', 'P 控制', 'Position', [200 200 700 500]);
hold on;
for i = 1:length(Kp_vals)
    C_p = pid(Kp_vals(i));
    G_cl = feedback(C_p * G_plant, 1);
    step(G_cl, 'LineWidth', 1.5);
    info = stepinfo(G_cl);
    fprintf('Kp=%d: 稳态误差≈%.3f, 超调=%.1f%%\n', ...
        Kp_vals(i), 1 - info.SteadyStateValue, info.Overshoot);
end
hold off;
title('P 控制: 不同 Kp 的阶跃响应');
xlabel('时间 (s)'); ylabel('输出');
legend(arrayfun(@(k) sprintf('Kp=%d', k), Kp_vals, 'UniformOutput', false), ...
    'Location', 'best');
grid on;
yline(1, 'k--', '参考值');

fprintf('P 控制: 增大 Kp 加快响应但增加超调，无法消除稳态误差\n');

%% ===== 3. PI 控制器 =====
fprintf('\n===== 3. 比例-积分 (PI) 控制 =====\n');

% PI: C(s) = Kp + Ki/s
Kp = 5;
Ki_vals = [1, 5, 10, 20];

figure('Name', 'PI 控制', 'Position', [300 300 700 500]);
hold on;
for i = 1:length(Ki_vals)
    C_pi = pid(Kp, Ki_vals(i));
    G_cl = feedback(C_pi * G_plant, 1);
    step(G_cl, 'LineWidth', 1.5);
    info = stepinfo(G_cl);
    fprintf('Kp=%d, Ki=%d: 超调=%.1f%%, 调节时间=%.2fs\n', ...
        Kp, Ki_vals(i), info.Overshoot, info.SettlingTime);
end
hold off;
title('PI 控制: 不同 Ki 的阶跃响应 (Kp=5)');
xlabel('时间 (s)'); ylabel('输出');
legend(arrayfun(@(k) sprintf('Ki=%d', k), Ki_vals, 'UniformOutput', false), ...
    'Location', 'best');
grid on;
yline(1, 'k--', '参考值');

fprintf('PI 控制: 积分项消除稳态误差，但增加超调和调节时间\n');

%% ===== 4. PID 控制器 =====
fprintf('\n===== 4. PID 控制 =====\n');

% PID: C(s) = Kp + Ki/s + Kd*s
Kp = 10; Ki = 5; Kd_vals = [0.1, 0.5, 1.0, 2.0];

figure('Name', 'PID 控制', 'Position', [100 100 700 500]);
hold on;
for i = 1:length(Kd_vals)
    C_pid = pid(Kp, Ki, Kd_vals(i));
    G_cl = feedback(C_pid * G_plant, 1);
    step(G_cl, 'LineWidth', 1.5);
    info = stepinfo(G_cl);
    fprintf('Kd=%.1f: 超调=%.1f%%, 调节时间=%.2fs, 上升时间=%.3fs\n', ...
        Kd_vals(i), info.Overshoot, info.SettlingTime, info.RiseTime);
end
hold off;
title('PID 控制: 不同 Kd 的阶跃响应 (Kp=10, Ki=5)');
xlabel('时间 (s)'); ylabel('输出');
legend(arrayfun(@(k) sprintf('Kd=%.1f', k), Kd_vals, 'UniformOutput', false), ...
    'Location', 'best');
grid on;
yline(1, 'k--', '参考值');

fprintf('PID 控制: 微分项减小超调、改善稳定性\n');

%% ===== 5. pidtune 自动调参 =====
fprintf('\n===== 5. pidtune 自动调参 =====\n');

try
    % 自动设计 PI 控制器
    [C_pi_auto, info_pi] = pidtune(G_plant, 'PI');
    fprintf('自动调参 PI:\n');
    disp(C_pi_auto);
    
    % 自动设计 PID 控制器
    [C_pid_auto, info_pid] = pidtune(G_plant, 'PID');
    fprintf('自动调参 PID:\n');
    disp(C_pid_auto);
    
    % 对比
    figure('Name', '自动调参结果', 'Position', [200 200 700 500]);
    step(feedback(C_pi_auto * G_plant, 1), 'LineWidth', 1.5); hold on;
    step(feedback(C_pid_auto * G_plant, 1), 'LineWidth', 1.5);
    hold off;
    title('pidtune 自动调参对比');
    legend('PI', 'PID', 'Location', 'best');
    grid on;
    yline(1, 'k--', '参考值');
    
catch ME
    fprintf('pidtune 不可用: %s\n', ME.message);
end

%% ===== 6. PID 参数调节过程可视化 =====
fprintf('\n===== 6. Ziegler-Nichols 调参法 =====\n');

% Z-N 方法: 先找临界增益 Kcr 和临界周期 Tcr
% 使用 P 控制器，逐渐增大 Kp 直到系统等幅振荡

G_test = K_motor / (s * (tau*s + 1));

% 通过根轨迹找临界增益
figure('Name', 'Z-N 调参', 'Position', [300 300 700 500]);

% 理论计算: 闭环特征方程 s*(tau*s+1) + Kp*K = 0
% tau*s^2 + s + Kp*K = 0, 临界阻尼时 s = ±jw
% => w = sqrt(Kp*K/tau), 且 Re(s)=0 => Kp = 无穷 (对于纯积分系统)
% 改用带延迟的模型

% 使用一阶+延迟模型: G(s) = K*e^(-Ls) / (T*s + 1)
% Z-N 参数: Kp = 1.2*T/(K*L), Ti = 2*L, Td = 0.5*L
K_zn = 5; T_zn = 1; L_zn = 0.2;  % 模型参数

G_fopdt = tf(K_zn, [T_zn 1], 'InputDelay', L_zn);

Kp_zn = 1.2 * T_zn / (K_zn * L_zn);
Ti_zn = 2 * L_zn;
Ki_zn = Kp_zn / Ti_zn;
Td_zn = 0.5 * L_zn;
Kd_zn = Kp_zn * Td_zn;

fprintf('FOPDT 模型: K=%.1f, T=%.1f, L=%.1f\n', K_zn, T_zn, L_zn);
fprintf('Z-N 调参结果:\n');
fprintf('  Kp = %.3f\n', Kp_zn);
fprintf('  Ki = %.3f (Ti = %.3f)\n', Ki_zn, Ti_zn);
fprintf('  Kd = %.3f (Td = %.3f)\n', Kd_zn, Td_zn);

C_zn = pid(Kp_zn, Ki_zn, Kd_zn, 0.01);  % 0.01s 滤波
G_cl_zn = feedback(C_zn * G_fopdt, 1);

step(G_cl_zn, 5, 'LineWidth', 2);
title('Ziegler-Nichols PID 调参');
xlabel('时间 (s)'); ylabel('输出');
grid on;
yline(1, 'k--', '参考值');

info_zn = stepinfo(G_cl_zn);
fprintf('\n闭环性能:\n');
fprintf('  超调量: %.1f%%\n', info_zn.Overshoot);
fprintf('  调节时间: %.3f s\n', info_zn.SettlingTime);
fprintf('  上升时间: %.3f s\n', info_zn.RiseTime);

fprintf('\n===== PID 控制器模块完成! =====\n');
