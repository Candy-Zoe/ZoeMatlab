%% 目标检测与跟踪 (Object Detection & Tracking)
% 本脚本演示目标检测和运动跟踪方法
% 需要 Computer Vision Toolbox
% 内容: 模板匹配, 运动检测, 光流, 背景减除
clear; clc; close all;

%% === 第一部分: 模板匹配 ===
fprintf('=== 目标检测与跟踪 ===\n\n');
fprintf('--- 第一部分: 模板匹配 ---\n');

% 创建测试图像和模板
img = rand(200, 300) * 0.1;
% 在图像中放置一个目标
target = ones(30, 40) * 0.8;
img(80:109, 120:159) = target;
img = img + 0.05*randn(size(img));

% 使用归一化互相关 (NCC) 模板匹配
template = target;
correlation = normxcorr2(template, img);
[maxVal, maxIdx] = max(correlation(:));
[peakRow, peakCol] = ind2sub(size(correlation), maxIdx);

% 计算目标位置
y = peakRow - size(template, 1);
x = peakCol - size(template, 2);

fprintf('模板匹配结果:\n');
fprintf('  最大相关值: %.4f\n', maxVal);
fprintf('  目标位置: (%d, %d)\n', x, y);
fprintf('  实际位置: (120, 80)\n');

figure('Name', '模板匹配', 'Position', [100 100 900 350]);
subplot(1,3,1);
imshow(img, []); title('搜索图像');
hold on;
rectangle('Position', [x, y, size(template,2), size(template,1)], ...
    'EdgeColor', 'r', 'LineWidth', 2);

subplot(1,3,2);
imshow(template, []); title('模板');

subplot(1,3,3);
imshow(correlation, []); title('相关图');
hold on;
plot(peakCol, peakRow, 'r+', 'MarkerSize', 15, 'LineWidth', 3);

%% === 第二部分: 运动检测 (帧差法) ===
fprintf('\n--- 第二部分: 运动检测 (帧差法) ---\n');

% 模拟连续帧
N_frames = 10;
frame_size = [100, 150];

fprintf('帧差法运动检测:\n');
fprintf('  原理: |Frame(n) - Frame(n-1)| > 阈值\n');
fprintf('  优点: 简单快速\n');
fprintf('  缺点: 只能检测边缘, 不能获取完整目标\n\n');

figure('Name', '帧差法运动检测', 'Position', [100 100 900 500]);

% 创建模拟场景
bg = zeros(frame_size);
bg(20:80, :) = 0.3;    % 背景

positions = 10:12:130;
for f = 1:min(N_frames, length(positions))
    frame = bg + 0.02*randn(frame_size);
    % 移动的目标
    x_pos = positions(f);
    if x_pos + 15 <= frame_size(2)
        frame(40:55, x_pos:x_pos+14) = 0.9;
    end
    
    subplot(2, 5, f);
    imshow(frame, []);
    title(sprintf('帧 %d', f));
    
    if f > 1
        % 帧差
        diff_frame = abs(frame - prev_frame);
        motion = diff_frame > 0.3;
        
        subplot(2, 5, f+5);
        imshow(motion);
        title(sprintf('运动区域 %d', f));
    end
    prev_frame = frame;
end

%% === 第三部分: 光流法 ===
fprintf('\n--- 第三部分: 光流法 (Optical Flow) ---\n');

fprintf('光流法计算每个像素的运动向量:\n');
fprintf('  Lucas-Kanade: 局部窗口内最小化误差\n');
fprintf('  Horn-Schunck: 全局平滑约束\n\n');

% 创建两帧图像 (物体向右移动)
img1 = zeros(100, 150);
img1(30:70, 30:60) = 1;    % 方块
img1(20:25, 80:130) = 0.7; % 线条
img1 = img1 + 0.02*randn(size(img1));

img2 = zeros(100, 150);
img2(30:70, 35:65) = 1;    % 方块右移5像素
img2(20:25, 82:132) = 0.7; % 线条右移2像素
img2 = img2 + 0.02*randn(size(img2));

try
    % Lucas-Kanade 光流
    flow = opticalFlowLK(img1, img2);
    
    figure('Name', '光流', 'Position', [100 100 800 350]);
    subplot(1,2,1);
    imshow(img1, []); title('帧 1');
    hold on;
    quiver(1:10:150, 1:10:100, flow.Vx(1:10:end,1:10:end)', ...
        -flow.Vy(1:10:end,1:10:end)', 0.5, 'Color', 'y');
    
    subplot(1,2,2);
    imshow(sqrt(flow.Vx.^2 + flow.Vy.^2), []);
    title('光流幅度图');
    colormap(hot);
    
catch ME
    fprintf('光流计算需要 CV Toolbox: %s\n', ME.message);
    
    % 简化: 块匹配运动估计
    fprintf('使用块匹配运动估计...\n');
    
    block_size = 10;
    search_range = 15;
    figure; imshow(img1, []); title('帧差显示');
    hold on;
    for y = 1:block_size:100-block_size
        for x = 1:block_size:150-block_size
            block = img1(y:y+block_size-1, x:x+block_size-1);
            if sum(block(:)) > block_size  % 有内容的块
                best_match = inf; best_dx = 0; best_dy = 0;
                for dy = -search_range:search_range
                    for dx = -search_range:search_range
                        ny = y+dy; nx = x+dx;
                        if ny >= 1 && ny+block_size-1 <= 100 && nx >= 1 && nx+block_size-1 <= 150
                            target_block = img2(ny:ny+block_size-1, nx:nx+block_size-1);
                            err = sum(abs(block(:) - target_block(:)));
                            if err < best_match
                                best_match = err;
                                best_dx = dx; best_dy = dy;
                            end
                        end
                    end
                end
                quiver(x+block_size/2, y+block_size/2, best_dx, best_dy, ...
                    0.5, 'Color', 'y', 'LineWidth', 0.8);
            end
        end
    end
    title('块匹配运动向量');
end

%% === 第四部分: 背景减除 ===
fprintf('\n--- 第四部分: 背景减除 ---\n\n');

fprintf('背景减除方法:\n');
fprintf('  1. 帧差法: 相邻帧相减, 简单但不完整\n');
fprintf('  2. 均值背景: 多帧平均作为背景\n');
fprintf('  3. 高斯混合模型 (GMM): 自适应背景建模\n');
fprintf('  4. 中值滤波背景: 像素级中值作为背景\n');

% 简单背景建模演示
N_bg = 20;
bg_model = zeros(100, 150);

for i = 1:N_bg
    bg_model = bg_model + bg + 0.02*randn(size(bg));
end
bg_model = bg_model / N_bg;

% 前景提取
test_frame = bg + 0.02*randn(size(bg));
test_frame(40:55, 60:75) = 0.9;  % 前景目标

foreground = abs(test_frame - bg_model) > 0.15;

figure('Name', '背景减除', 'Position', [100 100 900 250]);
subplot(1,3,1); imshow(test_frame, []); title('当前帧');
subplot(1,3,2); imshow(bg_model, []); title('背景模型');
subplot(1,3,3); imshow(foreground); title('前景掩码');

%% === 总结 ===
fprintf('\n=== 目标检测与跟踪总结 ===\n');
fprintf('1. 模板匹配: 简单但计算量大, 适合已知目标\n');
fprintf('2. 帧差法: 快速运动检测, 实现简单\n');
fprintf('3. 光流法: 像素级运动估计, 精度高\n');
fprintf('4. 背景减除: 适合固定摄像头的目标检测\n');
