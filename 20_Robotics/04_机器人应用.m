%% 机器人应用 (Robotics Applications)
% 基础 MATLAB 即可
% 内容: ROS简介, 移动机器人, 传感器, 应用综述
clear; clc; close all;

%% === 第一部分: ROS 简介 ===
fprintf('=== 机器人应用 ===\n\n');
fprintf('--- 第一部分: ROS (机器人操作系统) ---\n\n');

fprintf('ROS (Robot Operating System):\n');
fprintf('  - 开源机器人中间件框架\n');
fprintf('  - 提供通信、工具、库和约定\n');
fprintf('  - MATLAB 通过 ROS Toolbox 支持 ROS\n\n');

fprintf('ROS 核心概念:\n');
fprintf('  Node:     独立执行单元\n');
fprintf('  Topic:    发布/订阅消息通道\n');
fprintf('  Service:  请求/响应通信\n');
fprintf('  Action:   长时间运行任务\n');
fprintf('  Message:  结构化数据\n');
fprintf('  Bag:      录制/回放数据\n\n');

fprintf('MATLAB ROS 接口:\n');
fprintf('  rosinit             - 初始化 ROS 节点\n');
fprintf('  rospublisher        - 创建发布器\n');
fprintf('  rossubscriber       - 创建订阅器\n');
fprintf('  rostopic list       - 列出话题\n');
fprintf('  rosmsg list         - 列出消息类型\n');

%% === 第二部分: 移动机器人导航 ===
fprintf('\n--- 第二部分: 移动机器人导航 ---\n\n');

fprintf('移动机器人类型:\n');
fprintf('  差速驱动: 两个独立驱动轮 (简单, 常见)\n');
fprintf('  全向移动: 麦克纳姆轮 (灵活, 复杂)\n');
fprintf('  阿克曼转向: 类似汽车 (高速, 稳定)\n\n');

% 差速驱动运动学
fprintf('差速驱动运动学:\n');
fprintf('  v = (v_r + v_l) / 2  (线速度)\n');
fprintf('  w = (v_r - v_l) / L  (角速度)\n');
fprintf('  L: 轮距\n\n');

% 模拟差速驱动机器人
L = 0.5;   % 轮距 0.5m
dt = 0.05; % 时间步长

% 机器人状态: [x, y, theta]
state = [0; 0; 0];
trajectory = state';

% 简单导航: 前进 → 转弯 → 前进
v_r = zeros(1, 200); v_l = zeros(1, 200);
v_r(1:60) = 1;   v_l(1:60) = 1;     % 前进
v_r(61:100) = 0.5; v_l(61:100) = -0.5; % 左转
v_r(101:200) = 1; v_l(101:200) = 1;  % 前进

for i = 1:length(v_r)
    v = (v_r(i) + v_l(i)) / 2;
    w = (v_r(i) - v_l(i)) / L;
    
    state(1) = state(1) + v*cos(state(3))*dt;
    state(2) = state(2) + v*sin(state(3))*dt;
    state(3) = state(3) + w*dt;
    trajectory = [trajectory; state'];
end

figure('Name', '差速驱动机器人', 'Position', [100 100 600 500]);
plot(trajectory(:,1), trajectory(:,2), 'b-', 'LineWidth', 2); hold on;
plot(trajectory(1,1), trajectory(1,2), 'go', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
plot(trajectory(end,1), trajectory(end,2), 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r');

% 画机器人方向
for i = 1:20:length(trajectory,1)
    quiver(trajectory(i,1), trajectory(i,2), ...
        0.2*cos(trajectory(i,3)), 0.2*sin(trajectory(i,3)), ...
        0, 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
end

xlabel('X (m)'); ylabel('Y (m)');
title('差速驱动机器人轨迹');
legend('轨迹', '起点', '终点');
axis equal; grid on;

%% === 第三部分: 传感器 ===
fprintf('\n--- 第三部分: 机器人传感器 ---\n\n');

sensors = {
    '激光雷达 (LiDAR)', '距离测量', '2D/3D点云, 高精度';
    '相机',             '视觉',     'RGB/深度, 丰富信息';
    'IMU',              '惯性测量', '加速度+角速度, 高频';
    'GPS',              '全局定位', '室外定位, 精度有限';
    '编码器',           '里程计',   '轮速测量, 累积误差';
    '超声波',           '近距检测', '低成本, 短距离';
    '力/力矩传感器',    '力反馈',   '柔顺控制, 安全';
};

fprintf('%-20s | %-8s | %s\n', '传感器', '功能', '特点');
fprintf('---------------------|----------|------------------\n');
for i = 1:size(sensors, 1)
    fprintf('%-20s | %-8s | %s\n', sensors{i,:});
end

% 模拟激光雷达扫描
figure('Name', '激光雷达扫描', 'Position', [100 100 600 400]);

angles = linspace(0, 2*pi, 360);
% 模拟房间墙壁
ranges = 5 + 0.3*sin(3*angles) + 0.1*randn(size(angles));
% 添加障碍物
ranges(abs(angles - pi/4) < 0.2) = 2 + 0.1*randn(sum(abs(angles-pi/4)<0.2));
ranges(abs(angles - pi) < 0.15) = 3 + 0.1*randn(sum(abs(angles-pi)<0.15));

polarplot(angles, ranges, 'b.', 'MarkerSize', 2);
hold on;
polarplot(0, 0, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
title('2D 激光雷达扫描');

%% === 第四部分: 机器人应用综述 ===
fprintf('\n--- 第四部分: 机器人应用 ---\n\n');

apps = {
    '工业制造',   '焊接, 喷涂, 装配, 搬运';
    '物流仓储',   '分拣, 搬运, AGV导航';
    '医疗手术',   '达芬奇手术机器人, 康复';
    '农业',       '采摘, 播种, 喷洒, 监测';
    '家庭服务',   '扫地, 陪伴, 护理';
    '探索',       '深海, 太空, 核辐射环境';
    '教育科研',   '编程教学, 算法验证';
};

fprintf('机器人主要应用领域:\n');
fprintf('%-10s | %s\n', '领域', '典型应用');
fprintf('-----------|-------------------------------\n');
for i = 1:size(apps, 1)
    fprintf('%-10s | %s\n', apps{i,:});
end

fprintf('\n=== 机器人应用总结 ===\n');
fprintf('1. ROS 提供标准化的机器人软件框架\n');
fprintf('2. 差速驱动是最常见的移动机器人底盘\n');
fprintf('3. 多传感器融合提高定位和感知精度\n');
fprintf('4. 机器人在各行业的应用持续扩展\n');
