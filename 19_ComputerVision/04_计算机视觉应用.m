%% 计算机视觉应用 (Computer Vision Applications)
% 需要 Computer Vision Toolbox
% 内容: 图像拼接, 目标检测, OCR, 视觉应用综述
clear; clc; close all;

%% === 第一部分: 图像拼接 ===
fprintf('=== 计算机视觉应用 ===\n\n');
fprintf('--- 第一部分: 图像拼接 (全景图) ---\n\n');

fprintf('图像拼接步骤:\n');
fprintf('  1. 特征检测 (SURF/SIFT)\n');
fprintf('  2. 特征匹配\n');
fprintf('  3. 估计单应性矩阵 (Homography)\n');
fprintf('  4. 图像变换与融合\n\n');

try
    % 创建两张重叠的图像
    img1 = zeros(200, 300);
    img1(20:80, 20:80) = 1;
    img1(100:180, 50:150) = 0.7;
    img1(30:50, 200:280) = 0.5;
    img1 = img1 + 0.03*randn(size(img1));
    
    img2 = zeros(200, 300);
    img2(20:80, 120:180) = 1;
    img2(100:180, 150:250) = 0.7;
    img2(30:50, 200:280) = 0.5;
    img2(120:160, 50:100) = 0.6;
    img2 = img2 + 0.03*randn(size(img2));
    
    % 检测和匹配特征
    pts1 = detectSURFFeatures(img1);
    pts2 = detectSURFFeatures(img2);
    [f1, vp1] = extractFeatures(img1, pts1);
    [f2, vp2] = extractFeatures(img2, pts2);
    idxPairs = matchFeatures(f1, f2);
    
    % 估计几何变换
    matchedPts1 = vp1(idxPairs(:,1));
    matchedPts2 = vp2(idxPairs(:,2));
    [tform, inlierIdx] = estimateGeometricTransform2D(...
        matchedPts1, matchedPts2, 'projective');
    
    fprintf('匹配点: %d, 内点: %d\n', size(idxPairs,1), sum(inlierIdx));
    
    figure('Name', '图像拼接', 'Position', [100 100 800 350]);
    subplot(1,2,1); imshow(img1, []); title('图像 1');
    subplot(1,2,2); imshow(img2, []); title('图像 2');
    
catch ME
    fprintf('图像拼接需要 CV Toolbox: %s\n', ME.message);
end

%% === 第二部分: 深度学习目标检测 ===
fprintf('\n--- 第二部分: 目标检测概述 ---\n\n');

methods = {
    'R-CNN',        '2014', '区域提议 + CNN',           '高精度, 速度慢';
    'Fast R-CNN',   '2015', '共享卷积特征',             '速度提升';
    'Faster R-CNN', '2015', '区域提议网络 (RPN)',       '实时候选';
    'SSD',          '2016', '多尺度特征图',             '速度快';
    'YOLO',         '2016', '单次回归',                 '实时检测';
    'YOLOv3',       '2018', '多尺度预测',               '精度+速度';
    'RetinaNet',    '2017', 'Focal Loss',               '解决类别不平衡';
};

fprintf('目标检测方法发展:\n');
fprintf('%-14s | 年份 | %-20s | %s\n', '方法', '核心思想', '特点');
fprintf('---------------|------|----------------------|-------------\n');
for i = 1:size(methods, 1)
    fprintf('%-14s | %s  | %-20s | %s\n', methods{i,:});
end

fprintf('\nMATLAB 中的目标检测:\n');
fprintf('  - trainObjectDetector: 训练自定义检测器\n');
fprintf('  - yolov4ObjectDetector: YOLO v4\n');
fprintf('  - fasterRCNNObjectDetector: Faster R-CNN\n');
fprintf('  - detect: 执行目标检测\n');

%% === 第三部分: OCR 文字识别 ===
fprintf('\n--- 第三部分: OCR 文字识别 ---\n\n');

fprintf('OCR (光学字符识别) 流程:\n');
fprintf('  1. 图像预处理: 灰度化, 二值化, 去噪\n');
fprintf('  2. 文字区域检测: 连通区域分析\n');
fprintf('  3. 字符分割: 将文字行分割为单个字符\n');
fprintf('  4. 字符识别: 模板匹配或深度学习\n');
fprintf('  5. 后处理: 语言模型纠错\n\n');

try
    % 创建含文字的图像
    img_text = ones(100, 300);
    % 模拟文字行
    img_text(10:30, 20:280) = 0;
    img_text(40:60, 20:200) = 0;
    img_text(70:90, 20:250) = 0;
    
    % 二值化
    bw = img_text < 0.5;
    
    % 连通区域分析
    CC = bwconncomp(bw);
    stats = regionprops(CC, 'BoundingBox', 'Area');
    
    fprintf('检测到 %d 个文字区域\n', CC.NumObjects);
    
    figure('Name', 'OCR 流程', 'Position', [100 100 800 300]);
    subplot(1,3,1); imshow(img_text); title('输入图像');
    subplot(1,3,2); imshow(bw); title('二值化');
    subplot(1,3,3); imshow(img_text); hold on;
    for i = 1:CC.NumObjects
        bb = stats(i).BoundingBox;
        rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 1);
    end
    title('文字区域检测');
    
catch ME
    fprintf('OCR 演示: %s\n', ME.message);
end

fprintf('\nMATLAB OCR 函数:\n');
fprintf('  ocr()            - 文字识别\n');
fprintf('  ocrText          - OCR 结果对象\n');
fprintf('  insertObjectAnnotation - 标注检测结果\n');

%% === 第四部分: 计算机视觉应用总结 ===
fprintf('\n--- 第四部分: CV 应用领域 ---\n\n');

apps = {
    '自动驾驶',     '车道检测, 目标识别, 深度估计';
    '医学影像',     'CT/MRI分割, 病变检测, 细胞计数';
    '安防监控',     '人脸识别, 行为分析, 异常检测';
    '工业检测',     '缺陷检测, 尺寸测量, 分拣';
    'AR/VR',        '手势识别, SLAM, 场景理解';
    '遥感',         '地物分类, 变化检测, 目标检测';
    '机器人',       '导航, 抓取, 人机交互';
};

fprintf('计算机视觉主要应用领域:\n');
fprintf('%-10s | %s\n', '领域', '典型应用');
fprintf('-----------|----------------------------\n');
for i = 1:size(apps, 1)
    fprintf('%-10s | %s\n', apps{i,:});
end

fprintf('\n=== 计算机视觉应用总结 ===\n');
fprintf('1. 图像拼接利用特征匹配实现全景图\n');
fprintf('2. 深度学习极大提升了目标检测性能\n');
fprintf('3. OCR 将图像中的文字转换为可编辑文本\n');
fprintf('4. 计算机视觉在多个领域有广泛应用\n');
