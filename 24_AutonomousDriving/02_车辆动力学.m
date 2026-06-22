%% ========================================================================
%  车辆动力学与运动学 - Vehicle Dynamics & Kinematics
%  本脚本演示车辆动力学模型和运动规划
%  内容包括：自行车模型、Ackermann转向、轨迹跟踪、稳定性分析
%  ========================================================================
clear; clc; close all;

%% === 1. 自行车模型 (Bicycle Model) ===
fprintf('=== 1. 自行车模型 ===\n');

% 车辆参数
L = 2.7;       % 轴距 (m)
Lr = 1.35;     % 后轴到质心 (m)
Lf = L - Lr;   % 前轴到质心 (m)
m_car = 1500;   % 质量 (kg)
Iz = 2500;     % 转动惯量 (kg*m^2)

% 轮胎刚度
Cf = 80000;    % 前轮侧偏刚度 (N/rad)
Cr = 80000;    % 后轮侧偏刚度 (N/rad)

fprintf('车辆参数:\n');
fprintf('  轴距: %.2f m\n', L);
fprintf('  质量: %.0f kg\n', m_car);
fprintf('  前轮刚度: %.0f N/rad\n', Cf);
fprintf('  后轮刚度: %.0f N/rad\n', Cr);

%% === 2. 运动学仿真 ===
fprintf('\n=== 2. 运动学仿真 ===\n');

% 状态: [x, y, theta]
% 输入: [v, delta] (速度, 前轮转角)
dt = 0.05;
T_sim = 10;
N_sim = round(T_sim/dt);

% 运动学自行车模型
x_state = zeros(N_sim, 3);
x_state(1,:) = [0, 0, 0];  % 初始状态

% 输入: 恒定速度 + 正弦转向
v_input = 10 * ones(N_sim, 1);  % 10 m/s
delta_input = 0.1 * sin(2*pi*0.3*(0:N_sim-1)'*dt);  % 转向角

for k = 1:N_sim-1
    x_k = x_state(k, 1);
    y_k = x_state(k, 2);
    th_k = x_state(k, 3);
    v_k = v_input(k);
    d_k = delta_input(k);
    
    % 运动学方程
    x_state(k+1, 1) = x_k + v_k * cos(th_k) * dt;
    x_state(k+1, 2) = y_k + v_k * sin(th_k) * dt;
    x_state(k+1, 3) = th_k + v_k / L * tan(d_k) * dt;
end

fprintf('仿真时间: %.1f s\n', T_sim);
fprintf('最终位置: (%.1f, %.1f)\n', x_state(end,1), x_state(end,2));

figure('Name', '运动学仿真', 'Position', [100 100 1000 600]);
subplot(2,2,1);
plot(x_state(:,1), x_state(:,2), 'b', 'LineWidth', 2); hold on;
scatter(x_state(1,1), x_state(1,2), 100, 'g', 'filled');
scatter(x_state(end,1), x_state(end,2), 100, 'r', 'filled');
xlabel('X (m)'); ylabel('Y (m)');
title('车辆轨迹');
axis equal;
grid on;

subplot(2,2,2);
t_sim = (0:N_sim-1)'*dt;
plot(t_sim, delta_input*180/pi, 'b', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('转向角 (度)');
title('前轮转角输入');
grid on;

subplot(2,2,3);
plot(t_sim, x_state(:,3)*180/pi, 'r', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('航向角 (度)');
title('航向角变化');
grid on;

subplot(2,2,4);
% 绘制车辆位置动画帧
frames = round(linspace(1, N_sim, 8));
colors = jet(length(frames));
for i = 1:length(frames)
    k = frames(i);
    xk = x_state(k,1); yk = x_state(k,2); thk = x_state(k,3);
    % 车辆轮廓
    car_x = [cos(thk) -sin(thk); sin(thk) cos(thk)] * [L/2 L/2 -L/2 -L/2 L/2; 0.8 -0.8 -0.8 0.8 0.8];
    plot(xk+car_x(1,:), yk+car_x(2,:), '-', 'Color', colors(i,:), 'LineWidth', 1.5);
    hold on;
end
xlabel('X (m)'); ylabel('Y (m)');
title('车辆位姿序列');
axis equal;
grid on;

%% === 3. 动力学模型 (线性二自由度) ===
fprintf('\n=== 3. 线性二自由度模型 ===\n');

% 状态: [beta, r] (侧偏角, 横摆角速度)
% 线性化模型: x' = A*x + B*delta
v0 = 20;  % 纵向速度 (m/s)

A_lat = [-(Cf+Cr)/(m_car*v0),       -(Cf*Lf-Cr*Lr)/(m_car*v0)-v0;
         -(Cf*Lf-Cr*Lr)/(Iz*v0),    -(Cf*Lf^2+Cr*Lr^2)/(Iz*v0)];
B_lat = [Cf/m_car; Cf*Lf/Iz];

fprintf('纵向速度: %.0f m/s (%.0f km/h)\n', v0, v0*3.6);
fprintf('系统矩阵A:\n'); disp(A_lat);

% 稳定性分析
eig_vals = eig(A_lat);
fprintf('特征值: %.4f +/- %.4fi\n', real(eig_vals(1)), abs(imag(eig_vals(1))));
fprintf('系统稳定: %s\n', bool2str(all(real(eig_vals) < 0)));

% 转向角阶跃响应
figure('Name', '动力学分析', 'Position', [100 100 1000 600]);
sys_lat = ss(A_lat, B_lat, eye(2), [0 0]);

subplot(2,2,1);
step(sys_lat);
title('侧偏角和横摆角速度阶跃响应');
grid on;

% 不同速度下的极点
subplot(2,2,2);
velocities = 5:5:60;
for vi = velocities
    A_v = [-(Cf+Cr)/(m_car*vi), -(Cf*Lf-Cr*Lr)/(m_car*vi)-vi;
           -(Cf*Lf-Cr*Lr)/(Iz*vi), -(Cf*Lf^2+Cr*Lr^2)/(Iz*vi)];
    ev = eig(A_v);
    plot(real(ev), imag(ev), 'bx', 'MarkerSize', 10, 'LineWidth', 2);
    hold on;
end
xlabel('实部'); ylabel('虚部');
title('不同速度下的极点');
xline(0, 'r--');
grid on;

% 转向灵敏度 (不足转向/过度转向)
subplot(2,2,3);
K_us = m_car/L * (Lf/Cr - Lr/Cf);  % 稳定性因子
v_range = 5:0.5:60;
gain_yaw = v_range ./ (L + K_us * v_range.^2);
plot(v_range, gain_yaw, 'b-', 'LineWidth', 2); hold on;
plot(v_range, v_range/L, 'r--', 'LineWidth', 1.5);
xlabel('速度 (m/s)'); ylabel('横摆增益 (rad/s / rad)');
title('横摆角速度增益');
legend('实际','中性转向');
grid on;

if K_us > 0
    fprintf('转向特性: 不足转向 (K=%.4f)\n', K_us);
elseif K_us < 0
    fprintf('转向特性: 过度转向 (K=%.4f)\n', K_us);
else
    fprintf('转向特性: 中性转向\n');
end

% 临界速度
if K_us < 0
    v_crit = sqrt(-L/K_us);
    fprintf('临界速度: %.1f m/s (%.0f km/h)\n', v_crit, v_crit*3.6);
    subplot(2,2,3);
    xline(v_crit, 'k--', sprintf('临界%.0f km/h', v_crit*3.6));
end

%% === 4. 纯追踪路径跟踪 ===
fprintf('\n=== 4. 纯追踪控制 ===\n');

% 参考路径: S形曲线
s = linspace(0, 100, 500);
ref_x = s;
ref_y = 10 * sin(s * 2*pi / 50);

% 纯追踪控制器
ld = 5;  % 前视距离
x_pp = [0, 0, 0];  % [x, y, theta]
v_pp = 8;  % 速度

N_pp = 2000;
dt_pp = 0.05;
pos_hist = zeros(N_pp, 3);
pos_hist(1,:) = x_pp;

for k = 1:N_pp-1
    % 找最近参考点
    dists = sqrt((ref_x - x_pp(1)).^2 + (ref_y - x_pp(2)).^2);
    [~, closest] = min(dists);
    
    % 找前视点
    lookahead = closest;
    while lookahead < length(ref_x) && dists(lookahead) < ld
        lookahead = lookahead + 1;
    end
    
    % 前视点
    gx = ref_x(min(lookahead, end));
    gy = ref_y(min(lookahead, end));
    
    % 计算转向角
    alpha = atan2(gy - x_pp(2), gx - x_pp(1)) - x_pp(3);
    delta_pp = atan2(2*L*sin(alpha), ld);
    
    % 更新位姿
    x_pp(1) = x_pp(1) + v_pp*cos(x_pp(3))*dt_pp;
    x_pp(2) = x_pp(2) + v_pp*sin(x_pp(3))*dt_pp;
    x_pp(3) = x_pp(3) + v_pp/L*tan(delta_pp)*dt_pp;
    
    pos_hist(k+1,:) = x_pp;
    
    if x_pp(1) > 100
        pos_hist = pos_hist(1:k+1, :);
        break;
    end
end

subplot(2,2,4);
plot(ref_x, ref_y, 'r--', 'LineWidth', 2); hold on;
plot(pos_hist(:,1), pos_hist(:,2), 'b-', 'LineWidth', 1.5);
xlabel('X (m)'); ylabel('Y (m)');
title('纯追踪路径跟踪');
legend('参考路径','实际轨迹');
axis equal;
grid on;

fprintf('纯追踪完成, 行驶距离: %.1f m\n', pos_hist(end,1));

%% === 辅助函数 ===
function s = bool2str(b)
    if b; s = '是'; else; s = '否'; end
end

%% === 总结 ===
fprintf('\n=== 车辆动力学总结 ===\n');
fprintf('1. 自行车模型: 运动学/动力学简化模型\n');
fprintf('2. 线性二自由度: 侧偏角、横摆角速度分析\n');
fprintf('3. 稳定性: 不足/过度转向、临界速度\n');
fprintf('4. 路径跟踪: 纯追踪控制器\n');
