%% 机器人运动学基础 (Robot Kinematics)
% 需要 Robotics System Toolbox (基础概念可用 MATLAB 实现)
% 内容: 齐次变换, 正运动学, DH参数, 工作空间
clear; clc; close all;

%% === 第一部分: 齐次变换矩阵 ===
fprintf('=== 机器人运动学基础 ===\n\n');
fprintf('--- 第一部分: 齐次变换矩阵 ---\n\n');

fprintf('齐次变换矩阵 (4x4):\n');
fprintf('  T = [R  p]\n');
fprintf('      [0  1]\n');
fprintf('  R: 3x3 旋转矩阵\n');
fprintf('  p: 3x1 平移向量\n\n');

% 基本旋转矩阵
Rx = @(theta) [1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];
Ry = @(theta) [cos(theta) 0 sin(theta) 0; 0 1 0 0; -sin(theta) 0 cos(theta) 0; 0 0 0 1];
Rz = @(theta) [cos(theta) -sin(theta) 0 0; sin(theta) cos(theta) 0 0; 0 0 1 0; 0 0 0 1];

% 平移变换
Trans = @(dx,dy,dz) [1 0 0 dx; 0 1 0 dy; 0 0 1 dz; 0 0 0 1];

% 示例: 绕Z轴旋转45度, 然后平移(1,0,0)
T1 = Rz(pi/4) * Trans(1, 0, 0);
fprintf('变换矩阵 (Rz(45°) * Tx(1)):\n');
disp(T1);

% 可视化坐标系
figure('Name', '坐标系变换', 'Position', [100 100 700 500]);
ax = axes;
hold on; grid on;
view(3);

% 世界坐标系
quiver3(0,0,0, 1,0,0, 'r', 'LineWidth', 2);
quiver3(0,0,0, 0,1,0, 'g', 'LineWidth', 2);
quiver3(0,0,0, 0,0,1, 'b', 'LineWidth', 2);

% 变换后的坐标系
p_origin = T1 * [0;0;0;1];
x_axis = T1 * [1;0;0;0]; y_axis = T1 * [0;1;0;0]; z_axis = T1 * [0;0;1;0];
quiver3(p_origin(1),p_origin(2),p_origin(3), x_axis(1),x_axis(2),x_axis(3), 'r--', 'LineWidth', 2);
quiver3(p_origin(1),p_origin(2),p_origin(3), y_axis(1),y_axis(2),y_axis(3), 'g--', 'LineWidth', 2);
quiver3(p_origin(1),p_origin(2),p_origin(3), z_axis(1),z_axis(2),z_axis(3), 'b--', 'LineWidth', 2);

xlabel('X'); ylabel('Y'); zlabel('Z');
title('坐标系变换可视化');
legend('X_w','Y_w','Z_w','X_t','Y_t','Z_t');
axis equal; xlim([-1 2]); ylim([-1 2]); zlim([-1 2]);

%% === 第二部分: DH 参数 ===
fprintf('\n--- 第二部分: DH (Denavit-Hartenberg) 参数 ---\n\n');

fprintf('DH 参数描述相邻关节之间的变换:\n');
fprintf('  theta_i: 绕 z_{i-1} 轴的旋转角\n');
fprintf('  d_i:     沿 z_{i-1} 轴的距离\n');
fprintf('  a_i:     沿 x_i 轴的距离 (连杆长度)\n');
fprintf('  alpha_i: 绕 x_i 轴的扭转角\n\n');

% 2-link 平面机械臂
fprintf('2-link 平面机械臂 DH 参数:\n');
fprintf('%-5s | %-8s | %-5s | %-5s | %-8s\n', '关节', 'theta', 'd', 'a', 'alpha');
fprintf('------|----------|-------|-------|---------\n');
fprintf('  1   | theta_1  |   0   |  L1   |    0\n');
fprintf('  2   | theta_2  |   0   |  L2   |    0\n');

L1 = 1.0; L2 = 0.8;

% 正运动学
theta1_vals = linspace(-pi, pi, 50);
theta2_vals = linspace(-pi, pi, 50);
[T1_all, T2_all] = meshgrid(theta1_vals, theta2_vals);

end_x = zeros(size(T1_all));
end_y = zeros(size(T1_all));

for i = 1:size(T1_all,1)
    for j = 1:size(T1_all,2)
        t1 = T1_all(i,j);
        t2 = T2_all(i,j);
        end_x(i,j) = L1*cos(t1) + L2*cos(t1+t2);
        end_y(i,j) = L1*sin(t1) + L2*sin(t1+t2);
    end
end

figure('Name', '机械臂工作空间', 'Position', [100 100 700 500]);
plot(end_x(:), end_y(:), 'b.', 'MarkerSize', 1);
hold on;
% 画最大/最小半径
theta_c = linspace(0, 2*pi, 100);
plot((L1+L2)*cos(theta_c), (L1+L2)*sin(theta_c), 'r--', 'LineWidth', 1);
plot(abs(L1-L2)*cos(theta_c), abs(L1-L2)*sin(theta_c), 'g--', 'LineWidth', 1);
xlabel('X (m)'); ylabel('Y (m)');
title('2-Link 平面机械臂工作空间');
legend('可达位置', '最大半径', '最小半径', 'Location', 'best');
axis equal; grid on;

%% === 第三部分: 正运动学可视化 ===
fprintf('\n--- 第三部分: 正运动学演示 ---\n');

figure('Name', '机械臂运动', 'Position', [100 100 600 500]);

% 演示几个姿态
configs = [0 0; pi/4 -pi/4; pi/2 pi/3; -pi/3 pi/2; pi/6 -pi/2];

for c = 1:size(configs, 1)
    t1 = configs(c, 1);
    t2 = configs(c, 2);
    
    % 关节位置
    p0 = [0; 0];
    p1 = [L1*cos(t1); L1*sin(t1)];
    p2 = p1 + [L2*cos(t1+t2); L2*sin(t1+t2)];
    
    subplot(2, 3, c);
    plot([p0(1) p1(1)], [p0(2) p1(2)], 'bo-', 'LineWidth', 3, 'MarkerSize', 8); hold on;
    plot([p1(1) p2(1)], [p1(2) p2(2)], 'ro-', 'LineWidth', 3, 'MarkerSize', 8);
    plot(p0(1), p0(2), 'ks', 'MarkerSize', 12, 'MarkerFaceColor', 'k');
    
    title(sprintf('\\theta_1=%.0f°, \\theta_2=%.0f°', t1*180/pi, t2*180/pi));
    xlabel('X (m)'); ylabel('Y (m)');
    axis equal; grid on;
    xlim([-2.5 2.5]); ylim([-2.5 2.5]);
end

fprintf('各构型的末端位置:\n');
for c = 1:size(configs, 1)
    t1 = configs(c, 1); t2 = configs(c, 2);
    px = L1*cos(t1) + L2*cos(t1+t2);
    py = L1*sin(t1) + L2*sin(t1+t2);
    fprintf('  [%6.1f°, %6.1f°] → (%.3f, %.3f)\n', t1*180/pi, t2*180/pi, px, py);
end

%% === 总结 ===
fprintf('\n=== 运动学总结 ===\n');
fprintf('1. 齐次变换矩阵统一表示旋转和平移\n');
fprintf('2. DH 参数是描述机械臂的标准方法\n');
fprintf('3. 正运动学: 关节角 → 末端位置\n');
fprintf('4. 逆运动学: 末端位置 → 关节角 (可能多解)\n');
fprintf('5. 工作空间是机械臂可达的所有点的集合\n');
