%% 相机标定与三维重建 (Camera Calibration & 3D Reconstruction)
% 需要 Computer Vision Toolbox
% 内容: 相机参数, 标定板, 畸变校正, 立体视觉
clear; clc; close all;

%% === 第一部分: 相机模型 ===
fprintf('=== 相机标定与三维重建 ===\n\n');
fprintf('--- 第一部分: 相机模型 ---\n\n');

fprintf('针孔相机模型:\n');
fprintf('  世界坐标 → 相机坐标 → 图像坐标\n\n');
fprintf('  内参矩阵 K:\n');
fprintf('    [fx  0  cx]\n');
fprintf('    [0  fy  cy]\n');
fprintf('    [0   0   1]\n\n');
fprintf('  fx, fy: 焦距 (像素)\n');
fprintf('  cx, cy: 光心坐标 (像素)\n\n');

fprintf('外参 (Extrinsic):\n');
fprintf('  [R | t]: 旋转矩阵 + 平移向量\n');
fprintf('  描述世界坐标系到相机坐标系的变换\n\n');

fprintf('畸变参数:\n');
fprintf('  径向畸变: k1, k2, k3\n');
fprintf('  切向畸变: p1, p2\n');
fprintf('  桶形畸变: k < 0 (广角镜头)\n');
fprintf('  枕形畸变: k > 0 (长焦镜头)\n');

% 可视化畸变
figure('Name', '镜头畸变', 'Position', [100 100 900 300]);

% 无畸变网格
subplot(1,3,1);
hold on; grid on;
for i = -5:5
    plot([-5 5], [i i], 'b-');
    plot([i i], [-5 5], 'b-');
end
title('无畸变'); axis equal; xlim([-6 6]); ylim([-6 6]);

% 桶形畸变
subplot(1,3,2);
k_barrel = -0.05;
hold on; grid on;
for i = -5:5
    x = linspace(-5, 5, 100);
    y = i * ones(size(x));
    r = sqrt(x.^2 + y.^2);
    x_d = x .* (1 + k_barrel*r.^2);
    y_d = y .* (1 + k_barrel*r.^2);
    plot(x_d, y_d, 'r-');
end
for j = -5:5
    y = linspace(-5, 5, 100);
    x = j * ones(size(y));
    r = sqrt(x.^2 + y.^2);
    x_d = x .* (1 + k_barrel*r.^2);
    y_d = y .* (1 + k_barrel*r.^2);
    plot(x_d, y_d, 'r-');
end
title('桶形畸变 (k<0)'); axis equal; xlim([-6 6]); ylim([-6 6]);

% 枕形畸变
subplot(1,3,3);
k_pincushion = 0.03;
hold on; grid on;
for i = -5:5
    x = linspace(-5, 5, 100);
    y = i * ones(size(x));
    r = sqrt(x.^2 + y.^2);
    x_d = x .* (1 + k_pincushion*r.^2);
    y_d = y .* (1 + k_pincushion*r.^2);
    plot(x_d, y_d, 'g-');
end
for j = -5:5
    y = linspace(-5, 5, 100);
    x = j * ones(size(y));
    r = sqrt(x.^2 + y.^2);
    x_d = x .* (1 + k_pincushion*r.^2);
    y_d = y .* (1 + k_pincushion*r.^2);
    plot(x_d, y_d, 'g-');
end
title('枕形畸变 (k>0)'); axis equal; xlim([-6 6]); ylim([-6 6]);

%% === 第二部分: 相机标定流程 ===
fprintf('\n--- 第二部分: 相机标定流程 ---\n\n');

fprintf('MATLAB 相机标定步骤:\n');
fprintf('  1. 准备标定板 (棋盘格或圆点阵列)\n');
fprintf('  2. 从多个角度拍摄标定板图像 (15-20张)\n');
fprintf('  3. 使用 Camera Calibrator App 或代码:\n');
fprintf('     - detectCheckerboardPoints 检测角点\n');
fprintf('     - generateCheckerboardPoints 生成世界坐标\n');
fprintf('     - estimateCameraParameters 估计参数\n');
fprintf('  4. 评估标定质量 (重投影误差)\n');
fprintf('  5. 应用标定结果校正畸变\n\n');

try
    % 模拟标定板检测
    img_size = [300, 400];
    checker_size = 50;
    rows = floor(img_size(1)/checker_size);
    cols = floor(img_size(2)/checker_size);
    
    board = zeros(img_size);
    for i = 1:rows
        for j = 1:cols
            if mod(i+j, 2) == 0
                board((i-1)*checker_size+1:i*checker_size, ...
                      (j-1)*checker_size+1:j*checker_size) = 1;
            end
        end
    end
    
    % 检测角点
    [points, boardSize] = detectCheckerboardPoints(board);
    worldPoints = generateCheckerboardPoints(boardSize, checker_size);
    
    fprintf('标定板尺寸: %dx%d\n', boardSize(1), boardSize(2));
    fprintf('检测到角点: %d 个\n', size(points, 1));
    
    figure('Name', '标定板检测', 'Position', [100 100 600 300]);
    subplot(1,2,1); imshow(board); title('模拟棋盘格');
    subplot(1,2,2); imshow(board); hold on;
    plot(points(:,1), points(:,2), 'g+', 'MarkerSize', 8, 'LineWidth', 2);
    title(sprintf('检测到的角点 (%d个)', size(points,1)));
    
catch ME
    fprintf('标定演示: %s\n', ME.message);
end

%% === 第三部分: 立体视觉 ===
fprintf('\n--- 第三部分: 立体视觉与深度估计 ---\n\n');

fprintf('立体视觉原理:\n');
fprintf('  两个相机从不同角度观察同一场景\n');
fprintf('  通过视差 (disparity) 计算深度\n\n');
fprintf('  depth = f * B / disparity\n');
fprintf('  f: 焦距, B: 基线距离\n\n');

% 模拟深度图
[X, Y] = meshgrid(1:100, 1:80);
depth_map = zeros(80, 100);
% 前景物体
depth_map(20:50, 30:60) = 2;    % 近距离
depth_map(25:45, 35:55) = 1;    % 更近
% 背景
depth_map(depth_map == 0) = 5;  % 远距离

figure('Name', '深度图', 'Position', [100 100 600 250]);
subplot(1,2,1);
imagesc(depth_map); colormap(jet); colorbar;
title('深度图 (值越小越近)');
xlabel('x'); ylabel('y');

subplot(1,2,2);
surf(X(1:5:end,1:5:end), Y(1:5:end,1:5:end), depth_map(1:5:end,1:5:end));
xlabel('x'); ylabel('y'); zlabel('深度');
title('3D 深度可视化');
view(45, 30); colormap(jet);

%% === 总结 ===
fprintf('\n=== 相机标定总结 ===\n');
fprintf('1. 相机内参描述投影几何, 外参描述相机位姿\n');
fprintf('2. 镜头畸变通过标定参数校正\n');
fprintf('3. 棋盘格是最常用的标定目标\n');
fprintf('4. 立体视觉通过视差计算深度信息\n');
