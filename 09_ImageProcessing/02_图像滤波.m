%% 02_图像滤波.m — 空间域滤波
%  涵盖: imfilter, 均值/中值/高斯滤波, 锐化
%  需要 Image Processing Toolbox

clear; clc; close all;

%% ===== 1. 创建带噪声的测试图像 =====
fprintf('===== 1. 创建带噪声图像 =====\n');

% 创建合成图像: 几何图形
img_clean = zeros(256, 256, 'uint8');
img_clean(50:200, 80:170) = 200;       % 矩形
theta = linspace(0, 2*pi, 100);
cx = 128; cy = 128; r = 60;
for i = 1:length(theta)
    x = round(cx + r * cos(theta(i)));
    y = round(cy + r * sin(theta(i)));
    if x >= 1 && x <= 256 && y >= 1 && y <= 256
        img_clean(y, x) = 255;
    end
end

% 添加高斯噪声
rng(42);
img_gauss = imnoise(img_clean, 'gaussian', 0, 0.01);

% 添加椒盐噪声
img_salt = imnoise(img_clean, 'salt & pepper', 0.05);

figure('Name', '噪声图像', 'Position', [100 100 900 300]);
subplot(1, 3, 1); imshow(img_clean); title('原始图像');
subplot(1, 3, 2); imshow(img_gauss); title('高斯噪声');
subplot(1, 3, 3); imshow(img_salt); title('椒盐噪声');

%% ===== 2. 均值滤波 =====
fprintf('\n===== 2. 均值滤波 =====\n');

% fspecial 创建均值核
h_avg3 = fspecial('average', 3);
h_avg5 = fspecial('average', 5);

img_avg3 = imfilter(img_gauss, h_avg3, 'replicate');
img_avg5 = imfilter(img_gauss, h_avg5, 'replicate');

figure('Name', '均值滤波', 'Position', [100 100 900 400]);
subplot(2, 2, 1); imshow(img_gauss); title('高斯噪声图像');
subplot(2, 2, 2); imshow(img_avg3); title('3x3 均值滤波');
subplot(2, 2, 3); imshow(img_avg5); title('5x5 均值滤波');
subplot(2, 2, 4); imshow(img_clean); title('原始图像 (参考)');

fprintf('3x3 均值核:\n'); disp(h_avg3);

%% ===== 3. 高斯滤波 =====
fprintf('\n===== 3. 高斯滤波 =====\n');

% fspecial 创建高斯核
h_gauss3 = fspecial('gaussian', [3 3], 1.0);
h_gauss5 = fspecial('gaussian', [5 5], 1.5);

img_gf3 = imfilter(img_gauss, h_gauss3, 'replicate');
img_gf5 = imfilter(img_gauss, h_gauss5, 'replicate');

figure('Name', '高斯滤波', 'Position', [200 200 900 400]);
subplot(2, 2, 1); imshow(img_gauss); title('高斯噪声图像');
subplot(2, 2, 2); imshow(img_gf3); title('3x3 高斯 (\sigma=1.0)');
subplot(2, 2, 3); imshow(img_gf5); title('5x5 高斯 (\sigma=1.5)');
subplot(2, 2, 4); imshow(img_clean); title('原始图像 (参考)');

fprintf('5x5 高斯核 (\sigma=1.5):\n');
fprintf('%.4f  ', h_gauss5);
fprintf('\n');

%% ===== 4. 中值滤波 (适合椒盐噪声) =====
fprintf('\n===== 4. 中值滤波 =====\n');

% medfilt2: 中值滤波
img_med3 = medfilt2(img_salt, [3 3]);
img_med5 = medfilt2(img_salt, [5 5]);

figure('Name', '中值滤波', 'Position', [300 300 900 400]);
subplot(2, 2, 1); imshow(img_salt); title('椒盐噪声图像');
subplot(2, 2, 2); imshow(img_med3); title('3x3 中值滤波');
subplot(2, 2, 3); imshow(img_med5); title('5x5 中值滤波');
subplot(2, 2, 4); imshow(img_clean); title('原始图像 (参考)');

% 对比: 均值 vs 中值 对椒盐噪声
img_avg_salt = imfilter(img_salt, fspecial('average', 3), 'replicate');
figure('Name', '均值 vs 中值 (椒盐噪声)', 'Position', [100 100 600 300]);
subplot(1, 2, 1); imshow(img_avg_salt); title('均值滤波 (椒盐噪声)');
subplot(1, 2, 2); imshow(img_med3); title('中值滤波 (椒盐噪声)');
fprintf('中值滤波对椒盐噪声效果明显优于均值滤波\n');

%% ===== 5. 图像锐化 =====
fprintf('\n===== 5. 图像锐化 =====\n');

% 拉普拉斯锐化核
h_lap = fspecial('laplacian', 0.2);
img_lap = imfilter(img_clean, h_lap, 'replicate');
img_sharp = img_clean - im2uint8(im2double(img_lap));  % 原图 - 拉普拉斯

% Unsharp Masking (非锐化掩模)
h_gblur = fspecial('gaussian', [5 5], 2);
img_blurred = imfilter(img_clean, h_gblur, 'replicate');
img_unsharp = im2uint8(im2double(img_clean) + 1.5 * (im2double(img_clean) - im2double(img_blurred)));

figure('Name', '图像锐化', 'Position', [200 200 800 500]);
subplot(2, 2, 1); imshow(img_clean); title('原始图像');
subplot(2, 2, 2); imshow(img_blurred); title('高斯模糊');
subplot(2, 2, 3); imshow(img_sharp); title('拉普拉斯锐化');
subplot(2, 2, 4); imshow(img_unsharp); title('Unsharp Masking');

fprintf('拉普拉斯核:\n'); disp(h_lap);

%% ===== 6. 自定义滤波器 =====
fprintf('\n===== 6. 自定义滤波器 =====\n');

% Sobel 边缘检测核 (水平/垂直)
h_sobel_x = [-1 0 1; -2 0 2; -1 0 1];
h_sobel_y = [-1 -2 -1; 0 0 0; 1 2 1];

img_sx = imfilter(img_clean, double(h_sobel_x), 'replicate');
img_sy = imfilter(img_clean, double(h_sobel_y), 'replicate');
img_sobel = uint8(sqrt(double(img_sx).^2 + double(img_sy).^2));

figure('Name', 'Sobel 滤波器', 'Position', [300 300 900 300]);
subplot(1, 3, 1); imshow(img_sx, []); title('Sobel X (水平边缘)');
subplot(1, 3, 2); imshow(img_sy, []); title('Sobel Y (垂直边缘)');
subplot(1, 3, 3); imshow(img_sobel); title('Sobel 梯度幅值');

fprintf('水平 Sobel 核:\n'); disp(h_sobel_x);
fprintf('垂直 Sobel 核:\n'); disp(h_sobel_y);

%% ===== 7. 滤波效果定量对比 =====
fprintf('\n===== 7. 滤波效果定量对比 =====\n');

% 计算 PSNR (峰值信噪比)
psnr_gauss = psnr(img_gauss, img_clean);
psnr_avg3 = psnr(img_avg3, img_clean);
psnr_gf5 = psnr(img_gf5, img_clean);

fprintf('高斯噪声图像 PSNR: %.2f dB\n', psnr_gauss);
fprintf('3x3 均值滤波 PSNR: %.2f dB\n', psnr_avg3);
fprintf('5x5 高斯滤波 PSNR: %.2f dB\n', psnr_gf5);

% SSIM (结构相似性)
ssim_gauss = ssim(img_gauss, img_clean);
ssim_avg3 = ssim(img_avg3, img_clean);
ssim_gf5 = ssim(img_gf5, img_clean);

fprintf('\n高斯噪声图像 SSIM: %.4f\n', ssim_gauss);
fprintf('3x3 均值滤波 SSIM: %.4f\n', ssim_avg3);
fprintf('5x5 高斯滤波 SSIM: %.4f\n', ssim_gf5);

fprintf('\n===== 图像滤波模块完成! =====\n');
