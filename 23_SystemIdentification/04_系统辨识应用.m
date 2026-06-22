%% ========================================================================
%  系统辨识应用 - System Identification Applications
%  本脚本演示系统辨识在工程中的实际应用
%  内容包括：非线性辨识、闭环辨识、在线辨识、模型预测控制
%  ========================================================================
clear; clc; close all;

%% === 1. 非线性系统辨识 ===
fprintf('=== 1. 非线性系统辨识 ===\n');

% 非线性系统: Duffing振子
% x'' + 0.1*x' + x + 0.5*x^3 = F(t)
Ts = 0.01;
N = 2000;
t = (0:N-1)' * Ts;

% 输入
u = 0.5*sin(2*pi*2*t) + 0.3*sin(2*pi*5*t);

% 仿真Duffing振子
x = zeros(N, 2);
x(1,:) = [0, 0];
delta = 0.1; alpha = 1; beta = 0.5;

for k = 1:N-1
    dx = x(k,2);
    ddx = -delta*x(k,2) - alpha*x(k,1) - beta*x(k,1)^3 + u(k);
    x(k+1,1) = x(k,1) + Ts*dx;
    x(k+1,2) = x(k,2) + Ts*ddx;
end

y = x(:,1);
rng(42);
y_noisy = y + 0.02*randn(N, 1);

fprintf('非线性系统: Duffing振子\n');
fprintf('参数: delta=%.1f, alpha=%.1f, beta=%.1f\n', delta, alpha, beta);

figure('Name', '非线性系统', 'Position', [100 100 1000 600]);
subplot(2,2,1);
plot(t, y, 'b', 'LineWidth', 1);
xlabel('时间 (s)'); ylabel('位移'); title('Duffing振子响应');

subplot(2,2,2);
plot(y, x(:,2), 'b', 'LineWidth', 0.5);
xlabel('位移'); ylabel('速度'); title('相空间轨迹');

% 线性ARX辨识 (比较基线)
na = 4; nb = 4; nk = 1;
n_reg = N - max(na, nb+nk-1);
Phi_lin = zeros(n_reg, na+nb);
for i = 1:n_reg
    idx = i + max(na, nb+nk-1);
    for j = 1:na
        Phi_lin(i,j) = -y_noisy(idx-j);
    end
    for j = 1:nb
        Phi_lin(i,na+j) = u(idx-nk-j+1);
    end
end
Y_reg = y_noisy(max(na,nb+nk-1)+1:N);
theta_lin = (Phi_lin'*Phi_lin) \ (Phi_lin'*Y_reg);
y_lin = Phi_lin * theta_lin;
fit_lin = (1 - norm(Y_reg-y_lin)/norm(Y_reg-mean(Y_reg))) * 100;

% 非线性NARX辨识 (包含y^3项)
Phi_nl = [Phi_lin, Y_reg.^3];
theta_nl = (Phi_nl'*Phi_nl) \ (Phi_nl'*Y_reg);
y_nl = Phi_nl * theta_nl;
fit_nl = (1 - norm(Y_reg-y_nl)/norm(Y_reg-mean(Y_reg))) * 100;

fprintf('\n线性ARX拟合度: %.1f%%\n', fit_lin);
fprintf('非线性NARX拟合度: %.1f%%\n', fit_nl);

subplot(2,2,3);
plot(Y_reg, 'b', 'LineWidth', 0.8); hold on;
plot(y_lin, 'r--', 'LineWidth', 1);
plot(y_nl, 'g--', 'LineWidth', 1);
xlabel('样本'); ylabel('输出');
title(sprintf('拟合比较 (线性:%.1f%%, 非线性:%.1f%%)', fit_lin, fit_nl));
legend('真实','线性ARX','NARX+y^3');

subplot(2,2,4);
scatter(Y_reg - y_lin, Y_reg - y_nl, 5, 'filled');
xlabel('线性残差'); ylabel('非线性残差');
title('残差比较');
grid on;

%% === 2. 闭环辨识 ===
fprintf('\n=== 2. 闭环辨识 ===\n');

% 被控对象: G(s) = 1/(s+1)^2
plant = tf(1, [1 2 1]);
plant_d = c2d(plant, 0.1);

% PI控制器: C(s) = 2 + 1/s
controller = pid(2, 1);
controller_d = c2d(controller, 0.1);

% 闭环系统
cl_sys = feedback(plant_d * controller_d, 1);

N_cl = 500;
t_cl = (0:N_cl-1)' * 0.1;
r = sign(sin(2*pi*0.05*t_cl));  % 参考信号

% 闭环仿真
y_cl = lsim(cl_sys, r, t_cl);
y_cl = y_cl + 0.05*randn(N_cl, 1);

fprintf('闭环系统辨识:\n');
fprintf('被控对象: G(s) = 1/(s+1)^2\n');
fprintf('控制器: PI (Kp=2, Ki=1)\n');

figure('Name', '闭环辨识', 'Position', [100 100 1000 500]);
subplot(2,1,1);
plot(t_cl, r, 'k--', t_cl, y_cl, 'b');
xlabel('时间 (s)'); ylabel('输出');
title('闭环响应 (参考 vs 输出)');
legend('参考','输出');

% 直接用闭环数据辨识 (直接法)
na_cl = 3; nb_cl = 3; nk_cl = 1;
n_reg_cl = N_cl - max(na_cl, nb_cl+nk_cl-1);
Phi_cl = zeros(n_reg_cl, na_cl+nb_cl);
for i = 1:n_reg_cl
    idx = i + max(na_cl, nb_cl+nk_cl-1);
    for j = 1:na_cl
        Phi_cl(i,j) = -y_cl(idx-j);
    end
    for j = 1:nb_cl
        Phi_cl(i,na_cl+j) = r(idx-nk_cl-j+1);
    end
end
Y_reg_cl = y_cl(max(na_cl,nb_cl+nk_cl-1)+1:N_cl);
theta_cl = (Phi_cl'*Phi_cl) \ (Phi_cl'*Y_reg_cl);

num_cl = theta_cl(na_cl+1:end)';
den_cl = [1 -theta_cl(1:na_cl)'];
sys_cl = tf(num_cl, den_cl, 0.1);

subplot(2,1,2);
step(plant_d, 'b', sys_cl, 'r--');
legend('真实对象','闭环辨识(直接法)');
title('闭环辨识结果');
grid on;

fprintf('注意: 直接法闭环辨识得到的是"闭环等效模型"\n');
fprintf('需要间接法或双步法才能得到真实对象模型\n');

%% === 3. 在线辨识 (递推最小二乘) ===
fprintf('\n=== 3. 在线辨识 (RLS) ===\n');

% 时变系统: 参数随时间变化
N_online = 1000;
t_ol = (0:N_online-1)' * 0.1;
u_ol = sin(2*pi*0.3*t_ol) + 0.5*sin(2*pi*t_ol);

% 时变参数
a1_true = -0.5 * ones(N_online, 1);
a1_true(500:end) = -0.8;  % 参数突变
b1_true = 0.3 * ones(N_online, 1);
b1_true(500:end) = 0.5;

% 生成数据
y_ol = zeros(N_online, 1);
for k = 2:N_online
    y_ol(k) = -a1_true(k)*y_ol(k-1) + b1_true(k)*u_ol(k-1) + 0.05*randn;
end

% 递推最小二乘 (RLS)
forget_factor = 0.98;
theta_rls = zeros(N_online-1, 2);
P = 100 * eye(2);

for k = 2:N_online
    phi_k = [-y_ol(k-1); u_ol(k-1)];
    K = P * phi_k / (forget_factor + phi_k' * P * phi_k);
    theta_k = theta_rls(k-2,:) ' + K * (y_ol(k) - phi_k' * theta_rls(k-2,:)');
    theta_rls(k-1,:) = theta_k';
    P = (eye(2) - K * phi_k') * P / forget_factor;
end

figure('Name', '在线辨识', 'Position', [100 100 1000 500]);
subplot(2,1,1);
plot(t_ol(2:end), a1_true(2:end), 'b--', 'LineWidth', 2); hold on;
plot(t_ol(2:end), theta_rls(:,1), 'r', 'LineWidth', 1);
xlabel('时间 (s)'); ylabel('参数 a1');
title('参数a1在线跟踪');
legend('真实','RLS估计');
xline(50, 'k:', '参数突变');
grid on;

subplot(2,1,2);
plot(t_ol(2:end), b1_true(2:end), 'b--', 'LineWidth', 2); hold on;
plot(t_ol(2:end), theta_rls(:,2), 'r', 'LineWidth', 1);
xlabel('时间 (s)'); ylabel('参数 b1');
title('参数b1在线跟踪');
legend('真实','RLS估计');
xline(50, 'k:', '参数突变');
grid on;

fprintf('遗忘因子: %.2f\n', forget_factor);
fprintf('RLS可以跟踪时变参数\n');

%% === 4. 模型预测控制 (MPC概念) ===
fprintf('\n=== 4. 模型预测控制概念 ===\n');

% 使用辨识模型进行简单预测控制
sys_mpc = tf([0.5], [1 -0.7 0.3], 0.1);

% MPC参数
Np = 20;  % 预测步长
Nu = 5;   % 控制步长
r_mpc = 1;  % 目标值

% 简单MPC: 求解最优控制序列
% 构建预测矩阵
[b_mp, a_mp] = tfdata(sys_mpc, 'v');
na_m = length(a_mp) - 1;

% 阶跃响应系数
[y_step, ~] = step(sys_mpc, (0:Np)*0.1);
S = y_step(2:end);

% 构建动态矩阵
G = zeros(Np, Nu);
for i = 1:Np
    for j = 1:min(i, Nu)
        G(i,j) = S(i-j+1);
    end
end

% 当前输出
y0 = 0;
E = r_mpc*ones(Np,1) - y0 - S*y0;  % 误差

% 求解 (无约束)
Q = eye(Np);
R = 0.01 * eye(Nu);
delta_u = (G'*Q*G + R) \ (G'*Q*E);

% 预测输出
y_pred = y0 + S*y0 + G*delta_u;

figure('Name', 'MPC概念');
subplot(2,1,1);
stairs(0:Nu-1, delta_u, 'b-o', 'LineWidth', 1.5);
xlabel('控制步'); ylabel('控制增量');
title('最优控制序列');
grid on;

subplot(2,1,2);
plot(0:Np, [y0; y_pred], 'r-o', 'LineWidth', 1.5); hold on;
yline(r_mpc, 'k--', '目标');
xlabel('预测步'); ylabel('输出');
title(sprintf('预测输出 (目标=%.1f)', r_mpc));
grid on;

fprintf('预测步长: %d, 控制步长: %d\n', Np, Nu);
fprintf('MPC第一步控制增量: %.4f\n', delta_u(1));

%% === 总结 ===
fprintf('\n=== 系统辨识应用总结 ===\n');
fprintf('1. 非线性辨识: NARX模型、Hammerstein/Wiener模型\n');
fprintf('2. 闭环辨识: 直接法、间接法、双步法\n');
fprintf('3. 在线辨识: RLS递推最小二乘、遗忘因子\n');
fprintf('4. 预测控制: MPC利用辨识模型进行优化控制\n');
fprintf('\n推荐工具箱: System Identification Toolbox\n');
