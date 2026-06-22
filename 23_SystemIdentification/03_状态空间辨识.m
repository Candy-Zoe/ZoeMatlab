%% ========================================================================
%  状态空间模型辨识 - State-Space Model Identification
%  本脚本演示状态空间模型的辨识方法
%  内容包括：N4SID算法、子空间辨识、模型降阶、多变量系统
%  ========================================================================
clear; clc; close all;

%% === 1. 状态空间系统基础 ===
fprintf('=== 1. 状态空间系统 ===\n');

% 真实系统: 质量-弹簧-阻尼系统
% m*x'' + c*x' + k*x = F
% 状态: [x; x']
m = 2; c = 0.5; k = 10;
A = [0 1; -k/m -c/m];
B = [0; 1/m];
C = [1 0];
D = 0;

sys_true = ss(A, B, C, D);
Ts = 0.02;
sys_d = c2d(sys_true, Ts);

fprintf('连续系统矩阵:\n');
fprintf('A = \n'); disp(A);
fprintf('B = \n'); disp(B);
fprintf('C = \n'); disp(C);
fprintf('D = %.2f\n\n', D);

% 系统特征
eig_vals = eig(A);
omega_n = sqrt(k/m);
zeta = c / (2*sqrt(k*m));
fprintf('固有频率: %.2f rad/s\n', omega_n);
fprintf('阻尼比: %.4f\n', zeta);
fprintf('特征值: %.4f +/- %.4fi\n', real(eig_vals(1)), abs(imag(eig_vals(1))));

%% === 2. 生成辨识数据 ===
fprintf('\n=== 2. 生成辨识数据 ===\n');

N = 800;
t = (0:N-1)' * Ts;

% 输入: 扫频信号 (Chirp)
f0 = 0.1; f1 = 5;
u = sin(2*pi*(f0 + (f1-f0)*t/(2*t(end)))*t);

% 生成响应
x0 = [0; 0];
x_sim = zeros(N, 2);
y_clean = zeros(N, 1);
x_state = x0;

for k = 1:N
    y_clean(k) = C * x_state + D * u(k);
    x_state = A * x_state + B * u(k);
    x_sim(k,:) = x_state';
end

% 添加噪声
rng(42);
y = y_clean + 0.1*randn(N, 1);

fprintf('数据点数: %d\n', N);
fprintf('输入频率范围: %.1f - %.1f Hz\n', f0, f1);

figure('Name', '辨识数据', 'Position', [100 100 1000 500]);
subplot(3,1,1);
plot(t, u); xlabel('时间 (s)'); ylabel('力 F'); title('输入: Chirp信号');
subplot(3,1,2);
plot(t, y_clean, 'b', t, y, 'r', 'LineWidth', 0.8);
xlabel('时间 (s)'); ylabel('位移 x'); title('输出'); legend('真实','测量');
subplot(3,1,3);
plot(x_sim(:,1), x_sim(:,2), 'b', 'LineWidth', 0.8);
xlabel('位移'); ylabel('速度'); title('状态轨迹');

%% === 3. 子空间辨识 (N4SID原理) ===
fprintf('\n=== 3. 子空间辨识 ===\n');

% 简化N4SID: 通过Hankel矩阵的SVD辨识
n_order = 2;  % 系统阶数
future = 10;  % 未来步数
past = 10;    % 过去步数

% 构建Hankel矩阵
N_hankel = N - past - future + 1;

% 过去输入输出
U_p = zeros(past, N_hankel);
Y_p = zeros(past, N_hankel);
U_f = zeros(future, N_hankel);
Y_f = zeros(future, N_hankel);

for i = 1:N_hankel
    for j = 1:past
        U_p(j,i) = u(i+j-1);
        Y_p(j,i) = y(i+j-1);
    end
    for j = 1:future
        U_f(j,i) = u(i+past+j-1);
        Y_f(j,i) = y(i+past+j-1);
    end
end

% 组合
W_p = [U_p; Y_p];
W_f = [U_f; Y_f];

% 斜投影 (简化)
% Y_f / W_p 的SVD
R = Y_f * W_p' / (W_p * W_p');
Gamma = R;

% SVD分解
[U_svd, S_svd, V_svd] = svd(Gamma);

% 估计状态序列
S_half = sqrt(S_svd(1:n_order, 1:n_order));
Obs = U_svd(:, 1:n_order) * S_half;
X_est = S_half * V_svd(:, 1:n_order)';

fprintf('奇异值: ');
fprintf('%.4f ', diag(S_svd(1:5,1:5)));
fprintf('\n');
fprintf('系统阶数选择: %d\n', n_order);

% 从估计状态辨识系统矩阵
X1 = X_est(1:end-1, :);
X2 = X_est(2:end, :);
U_ident = u(past+1 : past+size(X1,1));
Y_ident = y(past+1 : past+size(X1,1));

% [X2; Y] = [A B; C D] * [X1; U]
Phi_ss = [X1, U_ident];
Theta_ss = [X2; Y_ident] / Phi_ss;

A_id = Theta_ss(1:n_order, 1:n_order);
B_id = Theta_ss(1:n_order, end);
C_id = Theta_ss(n_order+1:end-1, 1:n_order);
D_id = Theta_ss(n_order+1:end-1, end);

sys_id = ss(A_id, B_id, C_id, D_id, Ts);

fprintf('\n辨识的离散系统矩阵:\n');
fprintf('A_id = \n'); disp(A_id);
fprintf('B_id = \n'); disp(B_id);

%% === 4. 模型验证 ===
fprintf('\n=== 4. 模型验证 ===\n');

figure('Name', '模型比较', 'Position', [100 100 1000 600]);

% 脉冲响应
subplot(2,2,1);
impulse(sys_true, 'b', sys_id, 'r--');
legend('真实','辨识');
title('脉冲响应比较');
grid on;

% Bode图
subplot(2,2,2);
bode(sys_d, 'b', sys_id, 'r--');
legend('真实','辨识');
title('Bode图比较');

% 时间响应
subplot(2,2,3);
y_id = lsim(sys_id, u, t);
plot(t, y, 'b', 'LineWidth', 0.8); hold on;
plot(t, y_id, 'r--', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('输出');
title('时间响应比较');
legend('测量','辨识');

fit_pct = (1 - norm(y-y_id)/norm(y-mean(y))) * 100;
fprintf('总体拟合度: %.1f%%\n', fit_pct);

% 极点对比
subplot(2,2,4);
pzmap(sys_d, 'b', sys_id, 'r');
legend('真实','辨识');
title('极点比较');
grid on;

% 极点比较
eig_true_d = eig(sys_d.A);
eig_id = eig(sys_id.A);
fprintf('\n极点比较:\n');
fprintf('真实极点: %.4f +/- %.4fi\n', real(eig_true_d(1)), abs(imag(eig_true_d(1))));
fprintf('辨识极点: %.4f +/- %.4fi\n', real(eig_id(1)), abs(imag(eig_id(1))));

%% === 总结 ===
fprintf('\n=== 状态空间辨识总结 ===\n');
fprintf('1. 状态空间: 物理系统建模、矩阵形式\n');
fprintf('2. 子空间辨识: Hankel矩阵、SVD分解、N4SID\n');
fprintf('3. 模型验证: 脉冲响应、Bode图、极点比较\n');
