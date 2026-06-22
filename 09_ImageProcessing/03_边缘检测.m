%% 03_边缘检测.m — 图像边缘检测
%  涵盖: edge (Sobel/Canny/Prewitt), Hough 变换, bwboundaries
%  需要 Image Processing Toolbox

clear; clc; close all;

%% ===== 1. 创建测试图像 =====
fprintf('===== 1. 创建测试图像 =====\n');

% 创建包含多种边缘特征的图像
img = zeros(256, 256, 'uint8');

% 矩形
img(40:120, 30:100) = 180;

% 圆形
theta = linspace(0, 2*pi, 200);
cx = 180; cy = 80; r = 40;
for i = 1:length(theta)
    for dr = -1:1
        x = round(cx + (r+dr) * cos(theta(i)));
        y = round(cy + (r+dr) * sin(theta(i)));
        if x >= 1 && x <= 256 && y >= 1 && y <= 256
            img(y, x) = 220;
        end
    end
end
img(cy-r+5:cy+r-5, cx-r+5:cx+r-5) = 150;

% 三角形
tri_x = [60, 100, 140]; tri_y = [230, 160, 230];
mask = roipoly(img, tri_x, tri_y);
img(mask) = 200;

% 对角线
for i = 1:256
    j = min(max(round(i * 0.5 + 50), 1), 256);
    img(max(j-2,1):min(j+2,256), i) = 240;
end

% 添加少量噪声
rng(42);
img_noisy = imnoise(img, 'gaussian', 0, 0.002);

figure('Name', '测试图像', 'Position', [100 100 600 300]);
subplot(1, 2, 1); imshow(img); title('原始图像');
subplot(1, 2, 2); imshow(img_noisy); title('带噪声图像');

%% ===== 2. Sobel 边缘检测 =====
fprintf('\n===== 2. Sobel 边缘检测 =====\n');

% edge 函数 + Sobel 方法
bw_sobel = edge(img_noisy, 'sobel');

% 带阈值的 Sobel
bw_sobel_low = edge(img_noisy, 'sobel', 0.05);
bw_sobel_high = edge(img_noisy, 'sobel', 0.3);

figure('Name', 'Sobel 边缘检测', 'Position', [100 100 900 400]);
subplot(2, 2, 1); imshow(img_noisy); title('原始图像');
subplot(2, 2, 2); imshow(bw_sobel); title('Sobel (自动阈值)');
subplot(2, 2, 3); imshow(bw_sobel_low); title('Sobel (低阈值=0.05)');
subplot(2, 2, 4); imshow(bw_sobel_high); title('Sobel (高阈值=0.3)');

fprintf('低阈值检测到更多细节，高阈值只保留强边缘\n');

%% ===== 3. Canny 边缘检测 =====
fprintf('\n===== 3. Canny 边缘检测 =====\n');

% Canny 方法: 最优边缘检测器
bw_canny = edge(img_noisy, 'canny');

% 不同阈值的 Canny
bw_canny1 = edge(img_noisy, 'canny', [0.05, 0.15]);
bw_canny2 = edge(img_noisy, 'canny', [0.1, 0.3]);

figure('Name', 'Canny 边缘检测', 'Position', [200 200 900 400]);
subplot(2, 2, 1); imshow(img_noisy); title('原始图像');
subplot(2, 2, 2); imshow(bw_canny); title('Canny (自动阈值)');
subplot(2, 2, 3); imshow(bw_canny1); title('Canny [0.05, 0.15]');
subplot(2, 2, 4); imshow(bw_canny2); title('Canny [0.1, 0.3]');

fprintf('Canny 边缘检测特点:\n');
fprintf('- 使用高斯平滑预处理\n');
fprintf('- 计算梯度幅值和方向\n');
fprintf('- 非极大值抑制\n');
fprintf('- 双阈值连接\n');

%% ===== 4. Prewitt 和 Roberts 边缘检测 =====
fprintf('\n===== 4. 其他边缘检测方法 =====\n');

bw_prewitt = edge(img_noisy, 'prewitt');
bw_roberts = edge(img_noisy, 'roberts');
bw_log = edge(img_noisy, 'log');  % Laplacian of Gaussian

figure('Name', '多种边缘检测方法对比', 'Position', [300 300 800 500]);
subplot(2, 3, 1); imshow(img_noisy); title('原始图像');
subplot(2, 3, 2); imshow(bw_sobel); title('Sobel');
subplot(2, 3, 3); imshow(bw_canny); title('Canny');
subplot(2, 3, 4); imshow(bw_prewitt); title('Prewitt');
subplot(2, 3, 5); imshow(bw_roberts); title('Roberts');
subplot(2, 3, 6); imshow(bw_log); title('LoG');

%% ===== 5. Hough 变换 (直线检测) =====
fprintf('\n===== 5. Hough 变换检测直线 =====\n');

% 创建包含明显直线的图像
img_lines = zeros(300, 400, 'uint8');

% 画几条直线
for x = 50:350
    y = round(0.5 * x + 50);
    if y >= 1 && y <= 300
        img_lines(max(y-1,1):min(y+1,300), x) = 255;
    end
end
for y = 30:270
    x = round(0.3 * y + 100);
    if x >= 1 && x <= 400
        img_lines(y, max(x-1,1):min(x+1,400)) = 255;
    end
end
% 水平线
img_lines(200, 80:320) = 255;

% 边缘检测 + Hough 变换
bw_edges = edge(img_lines, 'canny');
[H, theta_h, rho] = hough(bw_edges);

% Hough 变换可视化
figure('Name', 'Hough 变换', 'Position', [100 100 900 400]);
subplot(1, 3, 1); imshow(img_lines); title('含直线的图像');
subplot(1, 3, 2); imshow(bw_edges); title('Canny 边缘');
subplot(1, 3, 3);
imshow(imadjust(mat2gray(H)), 'XData', theta_h, 'YData', rho, 'InitialMagnification', 'fit');
xlabel('\theta (度)'); ylabel('\rho (像素)');
title('Hough 变换参数空间');
axis on; axis normal;
hold on;

% 检测峰值
P = houghpeaks(H, 5, 'threshold', ceil(0.3 * max(H(:))));
plot(theta_h(P(:,2)), rho(P(:,1)), 'r+', 'MarkerSize', 10, 'LineWidth', 2);

% 提取直线
lines = houghlines(bw_edges, theta_h, rho, P, 'FillGap', 20, 'MinLength', 30);

figure('Name', 'Hough 直线检测', 'Position', [200 200 700 400]);
imshow(img_lines); hold on;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'r');
    plot(xy(1,1), xy(1,2), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot(xy(2,1), xy(2,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
end
hold off;
title(sprintf('检测到 %d 条直线', length(lines)));

fprintf('检测到 %d 条直线\n', length(lines));

%% ===== 6. 边界跟踪 (bwboundaries) =====
fprintf('\n===== 6. 边界跟踪 bwboundaries =====\n');

% 创建二值图像（多个对象）
img_multi = zeros(300, 400, 'uint8');
img_multi(30:100, 30:120) = 255;    % 矩形
theta2 = linspace(0, 2*pi, 100);
cx2 = 250; cy2 = 80; r2 = 50;
for i = 1:length(theta2)
    x = round(cx2 + r2*cos(theta2(i)));
    y = round(cy2 + r2*sin(theta2(i)));
    if x >= 1 && x <= 400 && y >= 1 && y <= 300
        img_multi(y, x) = 255;
    end
end
img_multi(cy2-r2+3:cy2+r2-3, cx2-r2+3:cx2+r2-3) = 255;
% 三角形
mask2 = roipoly(img_multi, [150 200 250], [250 170 250]);
img_multi(mask2) = 255;

% 二值化
bw = img_multi > 128;

% 边界跟踪
[B, L] = bwboundaries(bw, 'noholes');

figure('Name', '边界跟踪', 'Position', [300 300 700 400]);
imshow(label2rgb(L, 'jet', 'w'));
hold on;
colors = ['r', 'g', 'b', 'm', 'c', 'y'];
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), colors(mod(k-1,6)+1), 'LineWidth', 2);
    % 标注对象编号
    text(mean(boundary(:,2)), mean(boundary(:,1)), ...
        sprintf('对象 %d', k), 'FontSize', 12, 'Color', 'w', ...
        'BackgroundColor', 'k', 'HorizontalAlignment', 'center');
end
hold off;
title(sprintf('检测到 %d 个对象边界', length(B)));

fprintf('检测到 %d 个独立对象\n', length(B));
for k = 1:length(B)
    fprintf('对象 %d 边界点数: %d\n', k, size(B{k}, 1));
end

fprintf('\n===== 边缘检测模块完成! =====\n');
