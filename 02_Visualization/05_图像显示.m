%% =========================================================================
%  图像显示与基本处理
%  学习目标：掌握图像的读取、显示、基本操作
%  注意：部分功能需要 Image Processing Toolbox
%% =========================================================================

clear; clc; close all;

%% 1. 创建测试图像（无需外部文件）
disp('--- 创建测试图像 ---');

% 创建灰度渐变图像
img_gray = uint8(repmat(0:255, 256, 1));
figure('Name', '灰度渐变图像');
imshow(img_gray);
title('灰度渐变 (256x256)');

% 创建 RGB 彩色图像
R = zeros(200, 300, 'uint8');
G = zeros(200, 300, 'uint8');
B = zeros(200, 300, 'uint8');
R(1:100, 1:150) = 255;          % 左上红色
G(1:100, 151:300) = 255;        % 右上绿色
B(101:200, 1:150) = 255;        % 左下蓝色
R(101:200, 151:300) = 255;      % 右下黄色
G(101:200, 151:300) = 255;
img_rgb = cat(3, R, G, B);

figure('Name', 'RGB 色块图像');
imshow(img_rgb);
title('RGB 色块图像');

%% 2. 图像基本信息
disp('--- 图像基本信息 ---');

fprintf('灰度图大小: [%s]\n', num2str(size(img_gray)));
fprintf('灰度图类型: %s\n', class(img_gray));
fprintf('RGB 图大小: [%s]\n', num2str(size(img_rgb)));
fprintf('RGB 图类型: %s\n', class(img_rgb));

% 读取外部图像示例（需要图像文件存在）
% img = imread('cameraman.tif');      % MATLAB 内置测试图像
% imshow(img);

%% 3. 灰度图像处理
disp('--- 灰度图像处理 ---');

% 使用内置测试图像（无需文件）
img = im2uint8(mat2gray(peaks(256)));   % 将 peaks 转为灰度图像

figure('Name', '灰度图像处理', 'Position', [100, 100, 1000, 300]);

subplot(1,3,1);
imshow(img);
title('原始灰度图');

subplot(1,3,2);
img_inv = imcomplement(img);        % 反色
imshow(img_inv);
title('反色 (imcomplement)');

subplot(1,3,3);
img_eq = histeq(img);               % 直方图均衡化
imshow(img_eq);
title('直方图均衡化 (histeq)');

%% 4. 图像直方图
disp('--- 图像直方图 ---');

figure('Name', '图像直方图', 'Position', [100, 100, 800, 300]);

subplot(1,2,1);
imshow(img);
title('原图');

subplot(1,2,2);
imhist(img);
title('灰度直方图');

%% 5. RGB 通道分离与合并
disp('--- RGB 通道分离 ---');

figure('Name', 'RGB 通道', 'Position', [100, 100, 1000, 300]);

% 生成渐变 RGB 图像
[X, Y] = meshgrid(1:300, 1:200);
img_color = uint8(cat(3, X/300*255, Y/200*255, 128*ones(200,300)));

subplot(1,4,1);
imshow(img_color);
title('原始 RGB');

R_ch = img_color(:,:,1);
G_ch = img_color(:,:,2);
B_ch = img_color(:,:,3);

subplot(1,4,2);
imshow(R_ch);
title('R 通道');

subplot(1,4,3);
imshow(G_ch);
title('G 通道');

subplot(1,4,4);
imshow(B_ch);
title('B 通道');

%% 6. 图像缩放与旋转
disp('--- 图像缩放与旋转 ---');

% 创建测试图像
img_test = uint8(cat(3, ...
    repmat(linspace(0,255,200)', 1, 300), ...
    repmat(linspace(0,255,300), 200, 1), ...
    128*ones(200,300)));

figure('Name', '缩放与旋转', 'Position', [100, 100, 900, 400]);

subplot(2,2,1);
imshow(img_test);
title('原图 (200x300)');

subplot(2,2,2);
img_resize = imresize(img_test, 0.5);     % 缩小50%
imshow(img_resize);
title('缩小50% (imresize)');

subplot(2,2,3);
img_rot = imrotate(img_test, 45);         % 旋转45度
imshow(img_rot);
title('旋转45° (imrotate)');

subplot(2,2,4);
img_flip = flip(img_test, 2);             % 水平翻转
imshow(img_flip);
title('水平翻转 (flip)');

%% 7. 图像保存示例
disp('--- 图像保存 ---');
disp('常用保存方法:');
disp('  imwrite(img, ''output.png'')       - 保存为 PNG');
disp('  imwrite(img, ''output.jpg'', ''Quality'', 90)');
disp('     - 保存为 JPEG 并设置质量');
disp('  imwrite(img, ''output.tif'')       - 保存为 TIFF');

% 示例（取消注释以执行）
% imwrite(img, 'test_output.png');
% fprintf('图像已保存到 test_output.png\n');

%% 8. colormap 色彩映射
disp('--- colormap ---');

figure('Name', 'colormap 对比', 'Position', [100, 100, 1000, 250]);
Z = peaks(100);

subplot(1,4,1);
imagesc(Z); colormap(jet); colorbar; title('jet');
subplot(1,4,2);
imagesc(Z); colormap(hot); colorbar; title('hot');
subplot(1,4,3);
imagesc(Z); colormap(cool); colorbar; title('cool');
subplot(1,4,4);
imagesc(Z); colormap(parula); colorbar; title('parula');

disp('=== 脚本执行完毕 ===');
