%% 图像特征检测 (Image Feature Detection)
% 本脚本演示计算机视觉中的图像特征检测方法
% 需要 Computer Vision Toolbox
% 内容: 角点检测, 特征点匹配, Harris, SURF
clear; clc; close all;

%% === 第一部分: 角点检测 ===
fprintf('=== 图像特征检测 ===\n\n');
fprintf('--- 第一部分: 角点检测 ---\n');

try
    % 创建测试图像 (棋盘格)
    img_size = 256;
    img = zeros(img_size);
    block = 32;
    for i = 1:block:img_size
        for j = 1:block:img_size
            if mod(floor(i/block) + floor(j/block), 2) == 0
                img(i:min(i+block-1,end), j:min(j+block-1,end)) = 1;
            end
        end
    end
    
    % Harris 角点检测
    corners = corner(img, 'Method', 'Harris', 'Sensitivity', 0.04);
    fprintf('Harris 角点检测: 发现 %d 个角点\n', size(corners, 1));
    
    % Harris-Minimum Eigenvalue
    corners2 = corner(img, 'Method', 'MinimumEigenvalue');
    fprintf('最小特征值法: 发现 %d 个角点\n', size(corners2, 1));
    
    figure('Name', '角点检测', 'Position', [100 100 800 400]);
    subplot(1,2,1);
    imshow(img, []);
    hold on;
    plot(corners(:,1), corners(:,2), 'y+', 'MarkerSize', 8, 'LineWidth', 2);
    title(sprintf('Harris 角点 (%d 个)', size(corners, 1)));
    
    subplot(1,2,2);
    imshow(img, []);
    hold on;
    plot(corners2(:,1), corners2(:,2), 'r*', 'MarkerSize', 8, 'LineWidth', 1.5);
    title(sprintf('最小特征值法 (%d 个)', size(corners2, 1)));
    
catch ME
    fprintf('Computer Vision Toolbox 不可用: %s\n', ME.message);
    fprintf('使用基础方法演示角点检测...\n');
    
    % 简化版: 手动 Harris 角点响应
    img_size = 128;
    img = zeros(img_size);
    block = 16;
    for i = 1:block:img_size
        for j = 1:block:img_size
            if mod(floor(i/block) + floor(j/block), 2) == 0
                img(i:min(i+block-1,end), j:min(j+block-1,end)) = 1;
            end
        end
    end
    
    % 计算梯度
    Ix = imfilter(img, [-1 0 1], 'replicate');
    Iy = imfilter(img, [-1; 0; 1], 'replicate');
    
    % Harris 响应 (简化)
    Ixx = imfilter(Ix.^2, ones(5)/25);
    Iyy = imfilter(Iy.^2, ones(5)/25);
    Ixy = imfilter(Ix.*Iy, ones(5)/25);
    
    R = Ixx.*Iyy - Ixy.^2 - 0.04*(Ixx + Iyy).^2;
    
    figure;
    subplot(1,2,1); imshow(img); title('棋盘格图像');
    subplot(1,2,2); imagesc(R); colormap(hot); title('Harris 响应');
end

%% === 第二部分: SURF 特征点 ===
fprintf('\n--- 第二部分: SURF 特征点 ---\n\n');

try
    % 创建测试图像
    img_test = zeros(200, 300);
    % 画一些几何图形
    img_test(20:80, 20:80) = 1;           % 方块
    img_test(100:160, 120:220) = 0.8;     % 矩形
    img_test(30:170, 250:252) = 0.6;      % 线条
    
    % 添加噪声使特征更丰富
    img_test = img_test + 0.05*randn(size(img_test));
    
    % SURF 特征检测
    points = detectSURFFeatures(img_test);
    fprintf('SURF 特征点: %d 个\n', points.Count);
    
    % 提取特征描述符
    [features, validPoints] = extractFeatures(img_test, points);
    fprintf('有效特征描述符: %d 个, 维度: %d\n', size(features, 1), size(features, 2));
    
    figure('Name', 'SURF 特征', 'Position', [100 100 800 300]);
    subplot(1,2,1);
    imshow(img_test, []);
    hold on;
    plot(points);
    title(sprintf('SURF 特征点 (%d 个)', points.Count));
    
    subplot(1,2,2);
    imshow(img_test, []);
    hold on;
    plot(points.selectStrongest(10));
    title('前10个最强 SURF 特征');
    
catch ME
    fprintf('SURF 需要 Computer Vision Toolbox: %s\n', ME.message);
    
    figure; text(0.5, 0.5, 'SURF 特征检测\n需要 CV Toolbox', ...
        'HorizontalAlignment', 'center', 'FontSize', 14);
    axis off;
end

%% === 第三部分: 特征匹配 ===
fprintf('\n--- 第三部分: 特征匹配 ---\n\n');

try
    % 创建两个相关图像 (旋转+平移)
    img1 = zeros(200, 200);
    img1(30:80, 30:80) = 1;
    img1(100:150, 100:170) = 0.8;
    img1(50:60, 130:180) = 0.6;
    img1 = img1 + 0.03*randn(size(img1));
    
    % 平移版本
    img2 = zeros(200, 200);
    img2(50:100, 50:100) = 1;
    img2(120:170, 120:190) = 0.8;
    img2(70:80, 150:200) = 0.6;
    img2 = img2 + 0.03*randn(size(img2));
    
    % 检测特征
    pts1 = detectSURFFeatures(img1);
    pts2 = detectSURFFeatures(img2);
    
    [feat1, vp1] = extractFeatures(img1, pts1);
    [feat2, vp2] = extractFeatures(img2, pts2);
    
    % 匹配特征
    idxPairs = matchFeatures(feat1, feat2);
    matchedPts1 = vp1(idxPairs(:,1));
    matchedPts2 = vp2(idxPairs(:,2));
    
    fprintf('图像1特征: %d, 图像2特征: %d\n', pts1.Count, pts2.Count);
    fprintf('匹配对数: %d\n', size(idxPairs, 1));
    
    figure('Name', '特征匹配', 'Position', [100 100 900 350]);
    showMatchedFeatures(img1, img2, matchedPts1, matchedPts2, 'montage');
    title(sprintf('SURF 特征匹配 (%d 对)', size(idxPairs, 1)));
    
catch ME
    fprintf('特征匹配出错: %s\n', ME.message);
end

%% === 第四部分: Hough 变换 ===
fprintf('\n--- 第四部分: Hough 直线检测 ---\n');

try
    % 创建含直线的图像
    img_line = zeros(200, 200);
    % 画几条线
    for x = 30:170
        y = round(0.5*x + 20);
        if y > 0 && y <= 200
            img_line(y-1:y+1, x) = 1;
        end
    end
    for y = 50:150
        img_line(y, 140:142) = 1;
    end
    for x = 60:140
        img_line(160:162, x) = 1;
    end
    
    img_line = img_line + 0.05*randn(size(img_line));
    
    % Hough 变换
    [H, theta, rho] = hough(img_line);
    P = houghpeaks(H, 5, 'Threshold', 0.3*max(H(:)));
    lines = houghlines(img_line, theta, rho, P, 'FillGap', 10, 'MinLength', 30);
    
    fprintf('Hough 变换检测到 %d 条直线\n', length(lines));
    
    figure('Name', 'Hough 直线检测', 'Position', [100 100 800 350]);
    subplot(1,2,1);
    imshow(H, [], 'XData', theta, 'YData', rho, 'InitialMagnification', 'fit');
    xlabel('\theta (度)'); ylabel('\rho');
    title('Hough 变换累加器');
    hold on;
    plot(theta(P(:,2)), rho(P(:,1)), 'r*', 'MarkerSize', 8);
    
    subplot(1,2,2);
    imshow(img_line, []);
    hold on;
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
        plot(xy(1,1), xy(1,2), 'rx', 'MarkerSize', 8);
        plot(xy(2,1), xy(2,2), 'rx', 'MarkerSize', 8);
    end
    title(sprintf('检测到的直线 (%d 条)', length(lines)));
    
catch ME
    fprintf('Hough 变换出错: %s\n', ME.message);
end

%% === 总结 ===
fprintf('\n=== 图像特征检测总结 ===\n');
fprintf('1. Harris 角点: 检测图像中的角点特征\n');
fprintf('2. SURF: 尺度不变特征, 适合匹配和跟踪\n');
fprintf('3. 特征匹配: 在不同图像中找到对应点\n');
fprintf('4. Hough 变换: 检测直线、圆等几何结构\n');
fprintf('5. 这些方法是 SLAM、拼接、三维重建的基础\n');
