%% 04_形态学与颜色.m — 形态学操作与颜色空间
%  涵盖: 膨胀/腐蚀/开闭运算, RGB/HSV/灰度转换
%  需要 Image Processing Toolbox

clear; clc; close all;

%% ===== 1. 形态学基础: 膨胀与腐蚀 =====
fprintf('===== 1. 膨胀与腐蚀 =====\n');

% 创建二值图像
bw = zeros(200, 200, 'logical');
bw(60:140, 60:140) = true;     % 正方形
% 添加一些小噪声点
rng(42);
noise_idx = randperm(200*200, 200);
bw(noise_idx) = true;
bw(60:140, 60:140) = true;  % 确保正方形完整

% 结构元素
se_disk3 = strel('disk', 3);
se_disk5 = strel('disk', 5);
se_square = strel('square', 5);

% 膨胀 (扩大前景)
bw_dilate3 = imdilate(bw, se_disk3);
bw_dilate5 = imdilate(bw, se_disk5);

% 腐蚀 (缩小前景)
bw_erode3 = imerode(bw, se_disk3);
bw_erode5 = imerode(bw, se_disk5);

figure('Name', '膨胀与腐蚀', 'Position', [100 100 800 500]);
subplot(2, 3, 1); imshow(bw); title('原始二值图像');
subplot(2, 3, 2); imshow(bw_dilate3); title('膨胀 (disk r=3)');
subplot(2, 3, 3); imshow(bw_dilate5); title('膨胀 (disk r=5)');
subplot(2, 3, 4); imshow(bw_erode3); title('腐蚀 (disk r=3)');
subplot(2, 3, 5); imshow(bw_erode5); title('腐蚀 (disk r=5)');
subplot(2, 3, 6); imshow(bw); title('参考: 原始');

fprintf('膨胀: 扩大白色区域，填充小空洞\n');
fprintf('腐蚀: 缩小白色区域，去除小突起\n');

%% ===== 2. 开运算与闭运算 =====
fprintf('\n===== 2. 开运算与闭运算 =====\n');

% 创建有噪声的图像
img_obj = zeros(200, 200, 'logical');
img_obj(50:150, 50:150) = true;
% 添加小的噪声点（前景噪声）
img_obj(20, 20) = true; img_obj(180, 30) = true;
img_obj(10, 180) = true; img_obj(190, 190) = true;
% 添加内部小空洞
img_obj(80, 80) = false; img_obj(120, 120) = false;

se = strel('disk', 5);

% 开运算: 先腐蚀后膨胀 (去除小噪声)
bw_open = imopen(img_obj, se);

% 闭运算: 先膨胀后腐蚀 (填充小空洞)
bw_close = imclose(img_obj, se);

% 开+闭组合
bw_open_close = imclose(imopen(img_obj, se), se);

figure('Name', '开运算与闭运算', 'Position', [200 200 800 400]);
subplot(2, 2, 1); imshow(img_obj); title('含噪声和空洞的图像');
subplot(2, 2, 2); imshow(bw_open); title('开运算 (去除小噪声)');
subplot(2, 2, 3); imshow(bw_close); title('闭运算 (填充小空洞)');
subplot(2, 2, 4); imshow(bw_open_close); title('开运算 + 闭运算');

fprintf('开运算 = 先腐蚀后膨胀: 去除小的前景噪声\n');
fprintf('闭运算 = 先膨胀后腐蚀: 填充小的背景空洞\n');

%% ===== 3. 形态学高级操作 =====
fprintf('\n===== 3. 形态学高级操作 =====\n');

% 形态学梯度 (边缘)
bw_grad = imdilate(img_obj, se) - imerode(img_obj, se);

% Top-hat 变换 (提取比周围亮的小区域)
bw_tophat = imtophat(img_obj, se);

% Bottom-hat 变换 (提取比周围暗的小区域)
bw_bottomhat = imbothat(img_obj, se);

% 骨架化
bw_skel = bwmorph(bw, 'skel', Inf);

% 边界提取
bw_boundary = bw - imerode(bw, strel('disk', 1));

figure('Name', '形态学高级操作', 'Position', [300 300 800 500]);
subplot(2, 3, 1); imshow(bw_grad); title('形态学梯度');
subplot(2, 3, 2); imshow(bw_tophat); title('Top-hat 变换');
subplot(2, 3, 3); imshow(bw_bottomhat); title('Bottom-hat 变换');
subplot(2, 3, 4); imshow(bw_skel); title('骨架化 (skel)');
subplot(2, 3, 5); imshow(bw_boundary); title('边界提取');
subplot(2, 3, 6); imshow(bw); title('参考: 原始');

%% ===== 4. 区域属性分析 =====
fprintf('\n===== 4. 区域属性分析 =====\n');

% 创建多个对象
img_objects = zeros(300, 400, 'logical');
img_objects(20:80, 20:120) = true;     % 矩形
theta_t = linspace(0, 2*pi, 100);
for i = 1:length(theta_t)
    x = round(280 + 50*cos(theta_t(i)));
    y = round(60 + 50*sin(theta_t(i)));
    if x >= 1 && x <= 400 && y >= 1 && y <= 300
        img_objects(y, x) = true;
    end
end
img_objects(60-47:60+47, 280-47:280+47) = img_objects(60-47:60+47, 280-47:280+47) | ...
    (sqrt((((60-47:60+47)'-60).^2) + (((280-47:280+47)-280).^2)) <= 50);
% 三角形
mask_t = roipoly(zeros(300,400), [150 200 250], [250 180 250]);
img_objects = img_objects | mask_t;

% 标记连通区域
[L, num] = bwlabel(img_objects);
stats = regionprops(L, 'Area', 'Perimeter', 'Centroid', 'BoundingBox', ...
    'Eccentricity', 'Solidity');

figure('Name', '区域属性', 'Position', [100 100 700 400]);
imshow(label2rgb(L, 'jet', 'w')); hold on;
for k = 1:num
    c = stats(k).Centroid;
    text(c(1), c(2), sprintf('对象 %d\n面积: %d\n周长: %.1f', ...
        k, stats(k).Area, stats(k).Perimeter), ...
        'FontSize', 9, 'HorizontalAlignment', 'center', ...
        'BackgroundColor', 'w', 'EdgeColor', 'k');
    % 画边界框
    bb = stats(k).BoundingBox;
    rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 1.5);
end
hold off;
title(sprintf('共 %d 个对象', num));

fprintf('区域属性统计:\n');
for k = 1:num
    fprintf('  对象 %d: 面积=%d, 周长=%.1f, 离心率=%.3f, 实心度=%.3f\n', ...
        k, stats(k).Area, stats(k).Perimeter, ...
        stats(k).Eccentricity, stats(k).Solidity);
end

%% ===== 5. RGB 颜色空间 =====
fprintf('\n===== 5. RGB 颜色空间 =====\n');

% 创建 RGB 彩色测试图像
img_color = zeros(200, 300, 3, 'uint8');
% 渐变色
for i = 1:300
    img_color(1:66, i, 1) = uint8(i * 255 / 300);    % R 渐变
    img_color(67:133, i, 2) = uint8(i * 255 / 300);   % G 渐变
    img_color(134:200, i, 3) = uint8(i * 255 / 300);  % B 渐变
end

figure('Name', 'RGB 通道分离', 'Position', [200 200 900 500]);
subplot(2, 3, 1); imshow(img_color); title('RGB 合成图');

% 分离通道
R = img_color(:,:,1);
G = img_color(:,:,2);
B = img_color(:,:,3);

subplot(2, 3, 2); imshow(R); title('R 通道');
subplot(2, 3, 3); imshow(G); title('G 通道');
subplot(2, 3, 4); imshow(B); title('B 通道');

% 通道叠加显示
img_r_only = cat(3, R, zeros(size(R)), zeros(size(R)));
img_g_only = cat(3, zeros(size(G)), G, zeros(size(G)));
img_b_only = cat(3, zeros(size(B)), zeros(size(B)), B);

subplot(2, 3, 5); imshow(img_r_only); title('仅 R 分量');
subplot(2, 3, 6); imshow(img_g_only); title('仅 G 分量');

%% ===== 6. HSV 颜色空间 =====
fprintf('\n===== 6. HSV 颜色空间 =====\n');

% 创建 HSV 色轮
N = 300;
[X, Y] = meshgrid(linspace(-1, 1, N), linspace(-1, 1, N));
R_c = sqrt(X.^2 + Y.^2);
Theta_c = atan2(Y, X);

% 在圆内创建 HSV 色轮
H = (Theta_c + pi) / (2 * pi);    % 色相: 角度
S = R_c;                           % 饱和度: 半径
V = ones(size(H));                 % 明度: 全1
V(R_c > 1) = 0; S(R_c > 1) = 0;

hsv_wheel = cat(3, H, S, V);
rgb_wheel = hsv2rgb(hsv_wheel);

figure('Name', 'HSV 色轮', 'Position', [300 300 500 500]);
imshow(rgb_wheel);
title('HSV 色轮 (色相=角度, 饱和度=半径)');

% HSV 颜色分割示例
figure('Name', 'HSV 颜色分割', 'Position', [200 200 900 300]);

% 创建颜色丰富的图像
img_hsv_test = zeros(200, 300, 3);
for i = 1:300
    for j = 1:200
        img_hsv_test(j, i, :) = [i/300, j/200, 0.9];
    end
end
img_rgb_test = hsv2rgb(img_hsv_test);

% 提取红色区域 (H 接近 0 或 1)
hsv_img = rgb2hsv(img_rgb_test);
mask_red = (hsv_img(:,:,1) < 0.1 | hsv_img(:,:,1) > 0.9) & hsv_img(:,:,2) > 0.5;

% 提取绿色区域
mask_green = (hsv_img(:,:,1) > 0.25 & hsv_img(:,:,1) < 0.42) & hsv_img(:,:,2) > 0.5;

subplot(1, 3, 1); imshow(img_rgb_test); title('HSV 渐变图像');
subplot(1, 3, 2); imshow(mask_red); title('红色区域提取');
subplot(1, 3, 3); imshow(mask_green); title('绿色区域提取');

fprintf('HSV 颜色分割: 通过色相(H)范围提取特定颜色\n');
fprintf('红色: H < 0.1 或 H > 0.9\n');
fprintf('绿色: 0.25 < H < 0.42\n');
fprintf('蓝色: 0.55 < H < 0.72\n');

fprintf('\n===== 形态学与颜色模块完成! =====\n');
