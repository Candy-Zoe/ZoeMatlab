%% 机器人动力学与控制 (Robot Dynamics & Control)
% 基础 MATLAB 即可
% 内容: 拉格朗日动力学, PID控制, 轨迹跟踪, 仿真
clear; clc; close all;

%% === 第一部分: 动力学方程 ===
fprintf('=== 机器人动力学与控制 ===\n\n');
fprintf('--- 第一部分: 拉格朗日动力学 ---\n\n');

fprintf('机器人动力学方程 (拉格朗日形式):\n');
fprintf('  M(q)*q_ddot + C(q,q_dot)*q_dot + g(q) = tau\n\n');
fprintf('  M(q):    惯性矩阵 (正定对称)\n');
fprintf('  C(q,q_dot): 科氏力/离心力\n');
fprintf('  g(q):    重力项\n');
fprintf('  tau:     关节力矩\n\n');

% 2-link 机械臂参数
m1 = 1.0; m2 = 0.8;    % 质量 (kg)
l1 = 1.0; l2 = 0.8;    % 长度 (m)
lc1 = l1/2; lc2 = l2/2; % 质心位置
g = 9.81;                % 重力加速度

fprintf('2-link 机械臂参数:\n');
fprintf('  连杆1: m1=%.1f kg, l1=%.1f m\n', m1, l1);
fprintf('  连杆2: m2=%.1f kg, l2=%.1f m\n', m2, l2);

%% === 第二部分: 动力学仿真 ===
fprintf('\n--- 第二部分: ODE 仿真 ---\n');

% 初始条件: [q1, q2, q1_dot, q2_dot]
x0 = [pi/4; pi/3; 0; 0];  % 初始角度和角速度
tspan = [0 5];

% 自由运动 (无控制, 只有重力)
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
[t, x] = ode45(@(t,x) robot_dynamics(t, x, m1, m2, l1, l2, lc1, lc2, g, [0;0]), tspan, x0, options);

figure('Name', '自由运动', 'Position', [100 100 900 400]);

subplot(2,2,1);
plot(t, x(:,1)*180/pi, 'b', 'LineWidth', 1.5); hold on;
plot(t, x(:,2)*180/pi, 'r', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('角度 (°)');
title('关节角度 (自由摆动)');
legend('\\theta_1', '\\theta_2'); grid on;

subplot(2,2,2);
plot(t, x(:,3)*180/pi, 'b', 'LineWidth', 1.5); hold on;
plot(t, x(:,4)*180/pi, 'r', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('角速度 (°/s)');
title('关节角速度');
legend('\\dot{\\theta}_1', '\\dot{\\theta}_2'); grid on;

% 动画帧
subplot(2,2,[3 4]);
n_frames = 30;
frame_idx = round(linspace(1, size(x,1), n_frames));
for i = 1:n_frames
    q = x(frame_idx(i), :);
    p0 = [0, 0];
    p1 = [l1*sin(q(1)), -l1*cos(q(1))];
    p2 = p1 + [l2*sin(q(1)+q(2)), -l2*cos(q(1)+q(2))];
    
    plot([p0(1) p1(1)], [p0(2) p1(2)], 'b-', 'LineWidth', 3); hold on;
    plot([p1(1) p2(1)], [p1(2) p2(2)], 'r-', 'LineWidth', 3);
    plot(p1(1), p1(2), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
    plot(p2(1), p2(2), 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'g');
end
xlabel('X (m)'); ylabel('Y (m)');
title('运动轨迹'); axis equal; grid on;

%% === 第三部分: PID 控制 ===
fprintf('\n--- 第三部分: PID 轨迹跟踪控制 ---\n');

% 目标: 从初始位置运动到目标位置
q_desired = [0; 0];  % 目标角度
Kp = 50; Ki = 10; Kd = 20;  % PID 增益

fprintf('PID 参数: Kp=%g, Ki=%g, Kd=%g\n', Kp, Ki, Kd);

x0_ctrl = [pi/4; pi/3; 0; 0];
tspan_ctrl = [0 3];

% 带 PID 控制的仿真
integral_err = [0; 0];
[t_ctrl, x_ctrl] = ode45(@(t,x) robot_pid(t, x, m1, m2, l1, l2, lc1, lc2, g, ...
    q_desired, Kp, Ki, Kd), tspan_ctrl, [x0_ctrl; 0; 0], options);

figure('Name', 'PID 控制', 'Position', [100 100 800 400]);

subplot(1,2,1);
plot(t_ctrl, x_ctrl(:,1)*180/pi, 'b', 'LineWidth', 1.5); hold on;
plot(t_ctrl, x_ctrl(:,2)*180/pi, 'r', 'LineWidth', 1.5);
yline(q_desired(1)*180/pi, 'b--');
yline(q_desired(2)*180/pi, 'r--');
xlabel('时间 (s)'); ylabel('角度 (°)');
title('PID 轨迹跟踪');
legend('\\theta_1', '\\theta_2', '目标1', '目标2'); grid on;

subplot(1,2,2);
error1 = abs(x_ctrl(:,1)*180/pi - q_desired(1)*180/pi);
error2 = abs(x_ctrl(:,2)*180/pi - q_desired(2)*180/pi);
plot(t_ctrl, error1, 'b', 'LineWidth', 1.5); hold on;
plot(t_ctrl, error2, 'r', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('误差 (°)');
title('跟踪误差'); legend('\\theta_1', '\\theta_2'); grid on;

fprintf('稳态误差: theta1=%.4f°, theta2=%.4f°\n', error1(end), error2(end));

%% === 总结 ===
fprintf('\n=== 动力学与控制总结 ===\n');
fprintf('1. 拉格朗日方程提供系统化的建模方法\n');
fprintf('2. 惯性和科氏力导致耦合非线性动力学\n');
fprintf('3. PID 控制简单有效, 广泛用于工业机器人\n');
fprintf('4. 计算力矩控制可以补偿动力学耦合\n');

%% === 辅助函数 ===
function dx = robot_dynamics(~, x, m1, m2, l1, l2, lc1, lc2, g, tau)
    q = x(1:2); qd = x(3:4);
    
    M = [m1*lc1^2 + m2*(l1^2+lc2^2+2*l1*lc2*cos(q(2))) + m2*lc2^2, ...
         m2*(lc2^2+l1*lc2*cos(q(2))); ...
         m2*(lc2^2+l1*lc2*cos(q(2))), m2*lc2^2];
    
    h = -m2*l1*lc2*sin(q(2));
    C = [h*qd(2), h*(qd(1)+qd(2)); -h*qd(1), 0];
    
    G = [(m1*lc1+m2*l1)*g*sin(q(1)) + m2*lc2*g*sin(q(1)+q(2)); ...
         m2*lc2*g*sin(q(1)+q(2))];
    
    qdd = M \ (tau - C*qd - G);
    dx = [qd; qdd];
end

function dx = robot_pid(~, x, m1, m2, l1, l2, lc1, lc2, g, q_des, Kp, Ki, Kd)
    q = x(1:2); qd = x(3:4); int_err = x(5:6);
    
    err = q_des - q;
    tau = Kp*err + Ki*int_err - Kd*qd;
    
    M = [m1*lc1^2+m2*(l1^2+lc2^2+2*l1*lc2*cos(q(2)))+m2*lc2^2, ...
         m2*(lc2^2+l1*lc2*cos(q(2))); ...
         m2*(lc2^2+l1*lc2*cos(q(2))), m2*lc2^2];
    h = -m2*l1*lc2*sin(q(2));
    C = [h*qd(2), h*(qd(1)+qd(2)); -h*qd(1), 0];
    G = [(m1*lc1+m2*l1)*g*sin(q(1))+m2*lc2*g*sin(q(1)+q(2)); ...
         m2*lc2*g*sin(q(1)+q(2))];
    
    qdd = M \ (tau - C*qd - G);
    dx = [qd; qdd; err];
end
