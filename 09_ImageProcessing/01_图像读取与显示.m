%% 01_图像读取与显示.m — 图像 I/O 基础
%  涵盖: imread, imshow, imwrite, 图像信息, 灰度/RGB 转换
%  需要 Image Processing Toolbox

clear; clc; close all;

%% ===== 1. 创建示例图像 =====
% 由于可能没有外部图像文件，先创建合成图像用于演示

fprintf('===== 1. 创建示例图像 =====\n');

% 创建 RGB 彩色图像 (200x300x3)
img_rgb = zeros(200, 300, 3, 'uint8');
img_rgb(1:100, 1:150, 1) = 255;       % 左上: 红色
img_rgb(1:100, 151:300, 2) = 255;     % 右上: 绿色
img_rgb(101:200, 1:150, 3) = 255;     % 左下: 蓝色
img_rgb(101:200, 151:300, :) = 200;   % 右下: 灰色

figure('Name', '图像读取与显示', 'Position', [100 100 1000 700]);

subplot(2, 3, 1);
imshow(img_rgb);
title('合成 RGB 图像');

% 图像基本信息
[rows, cols, channels] = size(img_rgb);
fprintf('图像尺寸: %d x %d x %d\n', rows, cols, channels);
fprintf('数据类型: %s\n', class(img_rgb));
fprintf('数据范围: [%d, %d]\n', min(img_rgb(:)), max(img_rgb(:)));

%% ===== 2. 灰度转换 =====
fprintf('\n===== 2. 灰度转换 =====\n');

% rgb2gray: RGB -> 灰度
img_gray = rgb2gray(img_rgb);

subplot(2, 3, 2);
imshow(img_gray);
title('灰度图像');

fprintf('灰度图尺寸: %d x %d\n', size(img_gray, 1), size(img_gray, 2));
fprintf('灰度范围: [%d, %d]\n', min(img_gray(:)), max(img_gray(:)));

% 灰度直方图
subplot(2, 3, 3);
imhist(img_gray, 256);
title('灰度直方图');
xlabel('灰度值'); ylabel('像素数');

%% ===== 3. 颜色空间转换 =====
fprintf('\n===== 3. 颜色空间转换 =====\n');

% 创建渐变图像用于颜色空间演示
[X, Y] = meshgrid(linspace(0, 1, 300), linspace(0, 1, 200));
img_gradient = cat(3, X, Y, fliplr(X));  % RGB 渐变

% RGB -> HSV
img_hsv = rgb2hsv(im2double(img_gradient));

subplot(2, 3, 4);
imshow(img_gradient);
title('RGB 渐变图像');

subplot(2, 3, 5);
imshow(img_hsv(:,:,1), []);  % 色相通道
title('HSV - 色相 (H)');
colormap('hsv'); colorbar;

subplot(2, 3, 6);
imshow(img_hsv(:,:,2), []);  % 饱和度通道
title('HSV - 饱和度 (S)');
colormap('gray'); colorbar;

% HSV 各通道说明
fprintf('HSV 色相范围: [%.2f, %.2f]\n', min(img_hsv(:,:,1)(:)), max(img_hsv(:,:,1)(:)));
fprintf('HSV 饱和度范围: [%.2f, %.2f]\n', min(img_hsv(:,:,2)(:)), max(img_hsv(:,:,2)(:)));
fprintf('HSV 明度范围: [%.2f, %.2f]\n', min(img_hsv(:,:,3)(:)), max(img_hsv(:,:,3)(:)));

%% ===== 4. 图像保存与读取 =====
fprintf('\n===== 4. 图像保存与读取 =====\n');

% 保存为不同格式
temp_dir = tempdir;
fpath_png = fullfile(temp_dir, 'test_image.png');
fpath_jpg = fullfile(temp_dir, 'test_image.jpg');
fpath_bmp = fullfile(temp_dir, 'test_image.bmp');

% 写入
imwrite(img_rgb, fpath_png);
imwrite(img_rgb, fpath_jpg, 'Quality', 90);
imwrite(img_rgb, fpath_bmp);

% 获取文件信息
info_png = dir(fpath_png);
info_jpg = dir(fpath_jpg);
info_bmp = dir(fpath_bmp);

fprintf('PNG 文件大小: %d bytes\n', info_png.bytes);
fprintf('JPG 文件大小: %d bytes (压缩)\n', info_jpg.bytes);
fprintf('BMP 文件大小: %d bytes (无压缩)\n', info_bmp.bytes);

% 读回
img_read = imread(fpath_png);
fprintf('\n读回 PNG 图像: %d x %d x %d, 类型: %s\n', ...
    size(img_read, 1), size(img_read, 2), size(img_read, 3), class(img_read));

% 验证一致性
if isequal(img_rgb, img_read)
    fprintf('PNG 无损保存验证通过!\n');
end

% 清理临时文件
delete(fpath_png, fpath_jpg, fpath_bmp);

%% ===== 5. 图像数据类型转换 =====
fprintf('\n===== 5. 数据类型转换 =====\n');

% uint8 -> double (归一化到 [0, 1])
img_double = im2double(img_rgb);
fprintf('uint8 -> double: 范围 [%.1f, %.1f]\n', min(img_double(:)), max(img_double(:)));

% double -> uint8
img_uint8 = im2uint8(img_double);
fprintf('double -> uint8: 范围 [%d, %d]\n', min(img_uint8(:)), max(img_uint8(:)));

% im2bw: 灰度图 -> 二值图 (阈值化)
threshold = 0.5;
img_bw = im2bw(img_gray, threshold);

figure('Name', '数据类型与二值化', 'Position', [200 200 800 300]);
subplot(1, 3, 1); imshow(img_gray); title('原始灰度图');
subplot(1, 3, 2); imshow(img_bw); title(sprintf('二值图 (阈值=%.1f)', threshold));
subplot(1, 3, 3); imshow(~img_bw); title('反转二值图');

%% ===== 6. 图像缩放与旋转 =====
fprintf('\n===== 6. 图像缩放与旋转 =====\n');

figure('Name', '图像变换', 'Position', [300 300 900 400]);

% 缩放
subplot(2, 3, 1); imshow(img_rgb); title('原图 (200x300)');

img_half = imresize(img_rgb, 0.5);
subplot(2, 3, 2); imshow(img_half); title(sprintf('缩小 50%% (%dx%d)', size(img_half,1), size(img_half,2)));

img_double_size = imresize(img_rgb, [400 600], 'bilinear');
subplot(2, 3, 3); imshow(img_double_size); title('放大到 400x600 (双线性)');

% 旋转
img_rot90 = imrotate(img_rgb, 90);
subplot(2, 3, 4); imshow(img_rot90); title('旋转 90°');

img_rot45 = imrotate(img_rgb, 45, 'crop');
subplot(2, 3, 5); imshow(img_rot45); title('旋转 45° (裁剪)');

% 翻转
img_flip_lr = fliplr(img_rgb);
subplot(2, 3, 6); imshow(img_flip_lr); title('水平翻转');

fprintf('缩放 50%%: %d x %d\n', size(img_half, 1), size(img_half, 2));
fprintf('旋转 90°: %d x %d\n', size(img_rot90, 1), size(img_rot90, 2));

fprintf('\n===== 图像读取与显示模块完成! =====\n');
