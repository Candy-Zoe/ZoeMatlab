%% ========================================================================
%  自动驾驶基础 - Autonomous Driving Basics
%  本脚本演示自动驾驶的核心概念和MATLAB实现
%  内容包括：传感器模型、目标检测、车道线检测、车辆运动学
%  ========================================================================
clear; clc; close all;

%% === 1. 传感器模型 ===
fprintf('=== 1. 传感器模型 ===\n');

% 模拟激光雷达 (LiDAR) 点云
rng(42);
num_points = 5000;
theta = rand(num_points, 1) * 2*pi;
phi = rand(num_points, 1) * pi/4 - pi/8;  % 垂直角度限制

% 模拟环境: 前方有障碍物 (墙壁和圆柱)
ranges = 30 * ones(num_points, 1);  % 默认最大距离

% 前方墙壁 (x = 20)
wall_mask = abs(theta) < pi/4;
ranges(wall_mask) = 20 ./ cos(theta(wall_mask));
ranges(ranges > 30) = 30;

% 右侧圆柱 (中心: 10, -5, 半径2)
for i = 1:num_points
    dx = ranges(i)*cos(phi(i))*cos(theta(i));
    dy = ranges(i)*cos(phi(i))*sin(theta(i));
    % 圆柱检测
    t = cos(theta(i))^2 + sin(theta(i))^2;
    a_coeff = t;
    b_coeff = -2*(10*cos(theta(i)) + (-5)*sin(theta(i)));
    c_coeff = 10^2 + (-5)^2 - 4;  % r^2 = 4
    disc = b_coeff^2 - 4*a_coeff*c_coeff;
    if disc >= 0
        r_cyl = (-b_coeff - sqrt(disc)) / (2*a_coeff);
        if r_cyl > 0 && r_cyl < ranges(i)
            ranges(i) = r_cyl;
        end
    end
end

% 转换为3D点云
x = ranges .* cos(phi) .* cos(theta);
y = ranges .* cos(phi) .* sin(theta);
z = ranges .* sin(phi);

% 添加噪声
x = x + 0.05*randn(num_points, 1);
y = y + 0.05*randn(num_points, 1);
z = z + 0.05*randn(num_points, 1);

fprintf('点云数量: %d\n', num_points);
fprintf('探测范围: %.1f m\n', max(ranges));

figure('Name', 'LiDAR点云', 'Position', [100 100 1000 500]);
subplot(1,2,1);
scatter(x, y, 5, ranges, 'filled');
colorbar;
hold on;
scatter(0, 0, 100, 'r', 's', 'filled');
xlabel('X (m)'); ylabel('Y (m)');
title('LiDAR俯视图');
axis equal;
grid on;

subplot(1,2,2);
scatter3(x, y, z, 3, ranges, 'filled');
hold on;
scatter3(0, 0, 0, 100, 'r', 's', 'filled');
xlabel('X'); ylabel('Y'); zlabel('Z');
title('LiDAR 3D点云');
view(45, 30);

%% === 2. 目标聚类与检测 ===
fprintf('\n=== 2. 目标聚类与检测 ===\n');

% 过滤近距离和远距离
valid = ranges > 1 & ranges < 25;
pts_2d = [x(valid), y(valid)];

% DBSCAN聚类
min_pts = 5;
eps_dist = 2;
[idx, ~] = dbscan_pts(pts_2d, eps_dist, min_pts);

num_clusters = max(idx);
fprintf('检测到 %d 个目标\n', num_clusters);

figure('Name', '目标检测', 'Position', [100 100 800 600]);
scatter(pts_2d(idx==0,1), pts_2d(idx==0,2), 5, [0.7 0.7 0.7], 'filled');
hold on;

colors = lines(num_clusters);
for k = 1:num_clusters
    cluster_pts = pts_2d(idx==k, :);
    scatter(cluster_pts(:,1), cluster_pts(:,2), 10, colors(k,:), 'filled');
    
    % 包围盒
    bbox_x = [min(cluster_pts(:,1)), max(cluster_pts(:,1))];
    bbox_y = [min(cluster_pts(:,2)), max(cluster_pts(:,2))];
    rectangle('Position', [bbox_x(1), bbox_y(1), ...
                bbox_x(2)-bbox_x(1), bbox_y(2)-bbox_y(1)], ...
              'EdgeColor', colors(k,:), 'LineWidth', 2);
    
    % 目标中心
    cx = mean(cluster_pts(:,1));
    cy = mean(cluster_pts(:,2));
    scatter(cx, cy, 200, colors(k,:), 'p', 'filled');
    
    dist_to_car = sqrt(cx^2 + cy^2);
    fprintf('  目标%d: 中心(%.1f, %.1f), 距离%.1fm\n', k, cx, cy, dist_to_car);
end

scatter(0, 0, 150, 'r', 's', 'filled');
xlabel('X (m)'); ylabel('Y (m)');
title('目标聚类与包围盒');
axis equal;
grid on;

%% === 3. 车道线检测 ===
fprintf('\n=== 3. 车道线检测 ===\n');

% 模拟俯视图中的车道线
img_size = [200, 400];
road_img = ones(img_size) * 100;  % 灰色路面

% 左车道线 (弯曲)
t_lane = linspace(0, 1, 200);
left_x = 50 + 30*t_lane.^2;
left_y = linspace(img_size(1), 1, 200);
for i = 1:length(left_x)
    x_idx = round(left_x(i));
    y_idx = round(left_y(i));
    if x_idx > 0 && x_idx <= img_size(2) && y_idx > 0 && y_idx <= img_size(1)
        road_img(max(1,y_idx-1):min(img_size(1),y_idx+1), ...
                 max(1,x_idx-1):min(img_size(2),x_idx+1)) = 255;
    end
end

% 右车道线
right_x = 150 - 20*t_lane.^2;
for i = 1:length(right_x)
    x_idx = round(right_x(i));
    y_idx = round(left_y(i));
    if x_idx > 0 && x_idx <= img_size(2) && y_idx > 0 && y_idx <= img_size(1)
        road_img(max(1,y_idx-1):min(img_size(1),y_idx+1), ...
                 max(1,x_idx-1):min(img_size(2),x_idx+1)) = 255;
    end
end

% 添加噪声
road_img = road_img + 10*randn(size(road_img));

% Hough变换检测直线
figure('Name', '车道线检测', 'Position', [100 100 1000 500]);
subplot(1,2,1);
imshow(road_img, []);
title('模拟车道俯视图');

% 边缘检测
edges = edge(road_img, 'Canny', [0.1 0.3]);
subplot(1,2,2);
imshow(edges);
hold on;

% Hough变换
[H, theta_h, rho_h] = hough(edges);
P = houghpeaks(H, 6, 'threshold', ceil(0.3*max(H(:))));
lines_h = houghlines(edges, theta_h, rho_h, P, 'FillGap', 20, 'MinLength', 30);

for k = 1:length(lines_h)
    xy = [lines_h(k).point1; lines_h(k).point2];
    plot(xy(:,1), xy(:,2), 'r-', 'LineWidth', 2);
    plot(xy(1,1), xy(1,2), 'go', 'MarkerSize', 6);
    plot(xy(2,1), xy(2,2), 'go', 'MarkerSize', 6);
end
title(sprintf('检测到 %d 条线段', length(lines_h)));

fprintf('检测到 %d 条线段\n', length(lines_h));

%% === 总结 ===
fprintf('\n=== 自动驾驶基础总结 ===\n');
fprintf('1. 传感器: LiDAR点云、毫米波雷达、摄像头\n');
fprintf('2. 目标检测: DBSCAN聚类、包围盒、距离估计\n');
fprintf('3. 车道线: 边缘检测、Hough变换、曲线拟合\n');
fprintf('\n推荐工具箱: Automated Driving Toolbox, Lidar Toolbox\n');

%% === 辅助函数 ===
function [idx, numClust] = dbscan_pts(X, eps_val, minPts)
    n = size(X, 1);
    idx = zeros(n, 1);
    clusterId = 0;
    
    for i = 1:n
        if idx(i) ~= 0
            continue;
        end
        
        % 邻域搜索
        D = pdist2(X(i,:), X);
        neighbors = find(D <= eps_val);
        
        if length(neighbors) < minPts
            idx(i) = -1;  % 噪声
            continue;
        end
        
        clusterId = clusterId + 1;
        idx(i) = clusterId;
        
        seedSet = neighbors(neighbors ~= i);
        while ~isempty(seedSet)
            q = seedSet(1);
            seedSet(1) = [];
            
            if idx(q) == -1
                idx(q) = clusterId;
            end
            
            if idx(q) ~= 0
                continue;
            end
            
            idx(q) = clusterId;
            
            D_q = pdist2(X(q,:), X);
            neighbors_q = find(D_q <= eps_val);
            
            if length(neighbors_q) >= minPts
                seedSet = union(seedSet, neighbors_q);
            end
        end
    end
    
    numClust = clusterId;
end
