%% ========================================================================
%  系统辨识基础 - System Identification Basics
%  本脚本演示系统辨识的基本概念和MATLAB实现
%  内容包括：iddata对象、信号分析、简单模型辨识、模型验证
%  ========================================================================
clear; clc; close all;

%% === 1. 创建实验数据 ===
fprintf('=== 1. 创建实验数据 ===\n');

% 真实系统: 二阶传递函数
% G(s) = 5 / (s^2 + 2*s + 5)
Ts = 0.05;  % 采样时间
N = 500;    % 数据点数
t = (0:N-1)' * Ts;

% 输入信号: 多频正弦叠加 (PRBS更好, 这里简化)
u = 2*sin(2*pi*0.5*t) + sin(2*pi*2*t) + 0.5*sin(2*pi*5*t);

% 真实系统响应 (使用lsim)
sys_true = tf(5, [1 2 5]);
sys_d = c2d(sys_true, Ts);
y_clean = lsim(sys_d, u, t);

% 添加测量噪声
rng(42);
noise_level = 0.3;
y = y_clean + noise_level * randn(N, 1);

fprintf('采样时间: %.3f s\n', Ts);
fprintf('数据点数: %d\n', N);
fprintf('信噪比: ~%.1f dB\n', 10*log10(var(y_clean)/var(y-y_clean)));

% 可视化输入输出
figure('Name', '实验数据', 'Position', [100 100 1000 600]);
subplot(2,1,1);
plot(t, u, 'b', 'LineWidth', 1);
xlabel('时间 (s)');
ylabel('输入 u');
title('输入信号');
grid on;

subplot(2,1,2);
plot(t, y_clean, 'b', 'LineWidth', 1.5); hold on;
plot(t, y, 'r-', 'LineWidth', 0.5);
xlabel('时间 (s)');
ylabel('输出 y');
title('输出信号 (蓝=无噪声, 红=有噪声)');
legend('真实输出','测量输出');
grid on;

%% === 2. 数据分析与预处理 ===
fprintf('\n=== 2. 数据分析 ===\n');

% 自相关分析
figure('Name', '信号分析', 'Position', [100 100 1000 500]);
subplot(2,2,1);
autocorr(y, 30);
title('输出自相关');

% 互相关
subplot(2,2,2);
crosscorr(u, y, 30);
title('输入-输出互相关');

% 频谱分析
subplot(2,2,3);
periodogram(y, [], [], 1/Ts);
title('输出功率谱密度');

% 相干性分析
subplot(2,2,4);
mscohere(u, y, hamming(128), 64, 128, 1/Ts);
title('输入-输出相干性');

% 数据划分
fprintf('\n数据划分:\n');
N_train = round(0.7 * N);
u_train = u(1:N_train);
y_train = y(1:N_train);
t_train = t(1:N_train);
u_test = u(N_train+1:end);
y_test = y(N_train+1:end);
t_test = t(N_train+1:end);

fprintf('训练集: %d 点 (%.1f s)\n', N_train, N_train*Ts);
fprintf('测试集: %d 点 (%.1f s)\n', N-N_train, (N-N_train)*Ts);

%% === 3. 简单模型辨识 ===
fprintf('\n=== 3. 模型辨识 ===\n');

% 方法1: 最小二乘法辨识ARX模型
% y(k) = a1*y(k-1) + a2*y(k-2) + b1*u(k-1) + b2*u(k-2)
na = 2;  % y的阶数
nb = 2;  % u的阶数
nk = 1;  % 延迟

% 构建回归矩阵
N_reg = N_train - max(na, nb+nk-1);
Phi = zeros(N_reg, na+nb);
for i = 1:N_reg
    idx = i + max(na, nb+nk-1);
    for j = 1:na
        Phi(i, j) = -y_train(idx-j);
    end
    for j = 1:nb
        Phi(i, na+j) = u_train(idx-nk-j+1);
    end
end

Y_reg = y_train(max(na, nb+nk-1)+1 : N_train);

% 最小二乘求解
theta = (Phi' * Phi) \ (Phi' * Y_reg);

fprintf('ARX模型参数 (最小二乘):\n');
fprintf('  a1 = %.4f\n', theta(1));
fprintf('  a2 = %.4f\n', theta(2));
fprintf('  b1 = %.4f\n', theta(3));
fprintf('  b2 = %.4f\n', theta(4));

% 构建辨识模型
num_id = [theta(3) theta(4)];
den_id = [1 -theta(1) -theta(2)];
sys_id = tf(num_id, den_id, Ts);

% 模型比较
figure('Name', '模型验证', 'Position', [100 100 1000 600]);

% 阶跃响应比较
subplot(2,2,1);
step(sys_true, 'b', 'LineWidth', 2); hold on;
step(sys_id, 'r--', 'LineWidth', 2);
legend('真实系统','辨识模型');
title('阶跃响应比较');
grid on;

% Bode图比较
subplot(2,2,2);
bode(sys_true, 'b', sys_id, 'r--');
legend('真实系统','辨识模型');
title('Bode图比较');

% 拟合度 (训练集)
y_fit_train = lsim(sys_id, u_train, t_train);
fit_train = (1 - norm(y_train - y_fit_train) / norm(y_train - mean(y_train))) * 100;
fprintf('\n训练集拟合度: %.1f%%\n', fit_train);

% 预测 (测试集)
subplot(2,2,3);
y_pred = lsim(sys_id, u_test, t_test);
plot(t_test, y_test, 'b', 'LineWidth', 1); hold on;
plot(t_test, y_pred, 'r--', 'LineWidth', 1.5);
xlabel('时间 (s)');
ylabel('输出');
title('测试集预测');
legend('真实','预测');

fit_test = (1 - norm(y_test - y_pred) / norm(y_test - mean(y_test))) * 100;
fprintf('测试集拟合度: %.1f%%\n', fit_test);

% 残差分析
subplot(2,2,4);
residual = y_test - y_pred;
stem(1:length(residual), residual, 'filled');
xlabel('样本');
ylabel('残差');
title(sprintf('预测残差 (RMSE=%.4f)', sqrt(mean(residual.^2))));
grid on;

%% === 总结 ===
fprintf('\n=== 系统辨识基础总结 ===\n');
fprintf('1. 实验设计: 输入信号设计、数据采集、信噪比\n');
fprintf('2. 数据分析: 自相关、互相关、频谱、相干性\n');
fprintf('3. 模型辨识: ARX模型、最小二乘法\n');
fprintf('4. 模型验证: 阶跃响应、Bode图、拟合度、残差\n');
