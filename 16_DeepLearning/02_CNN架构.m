%% CNN 架构 (Convolutional Neural Network Architecture)
% 本脚本演示 CNN 各层组件和架构设计
% 需要 Deep Learning Toolbox
% 内容: imageInputLayer, convolution2dLayer, maxPooling2dLayer, fullyConnectedLayer
clear; clc; close all;

%% === 第一部分: CNN 层类型介绍 ===
fprintf('=== CNN 架构演示 ===\n\n');
fprintf('--- 第一部分: CNN 层类型 ---\n');

fprintf('CNN 基本层类型:\n');
fprintf('  1. imageInputLayer      - 输入层, 定义图像尺寸\n');
fprintf('  2. convolution2dLayer   - 卷积层, 提取特征\n');
fprintf('  3. batchNormalizationLayer - 批归一化, 稳定训练\n');
fprintf('  4. reluLayer            - 激活函数 ReLU\n');
fprintf('  5. maxPooling2dLayer    - 最大池化, 降采样\n');
fprintf('  6. averagePooling2dLayer - 平均池化\n');
fprintf('  7. fullyConnectedLayer  - 全连接层\n');
fprintf('  8. softmaxLayer         - Softmax 归一化\n');
fprintf('  9. classificationLayer  - 分类输出层\n');

%% === 第二部分: 构建简单 CNN ===
fprintf('\n--- 第二部分: 构建简单 CNN (LeNet风格) ---\n');

try
    % 定义网络层
    layers = [
        % 输入层: 28x28 灰度图像
        imageInputLayer([28 28 1], 'Name', 'input')
        
        % 第一个卷积块
        convolution2dLayer(5, 20, 'Padding', 'same', 'Name', 'conv1')
        batchNormalizationLayer('Name', 'bn1')
        reluLayer('Name', 'relu1')
        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
        
        % 第二个卷积块
        convolution2dLayer(5, 40, 'Padding', 'same', 'Name', 'conv2')
        batchNormalizationLayer('Name', 'bn2')
        reluLayer('Name', 'relu2')
        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')
        
        % 第三个卷积块
        convolution2dLayer(3, 80, 'Padding', 'same', 'Name', 'conv3')
        batchNormalizationLayer('Name', 'bn3')
        reluLayer('Name', 'relu3')
        
        % 全连接层
        fullyConnectedLayer(128, 'Name', 'fc1')
        reluLayer('Name', 'relu_fc1')
        dropoutLayer(0.5, 'Name', 'dropout1')
        fullyConnectedLayer(10, 'Name', 'fc2')
        softmaxLayer('Name', 'softmax')
        classificationLayer('Name', 'output')
    ];
    
    % 创建网络
    lgraph = layerGraph(layers);
    
    fprintf('网络结构:\n');
    for i = 1:length(layers)
        if ~isempty(layers(i).Name)
            fprintf('  [%2d] %-25s -> %s\n', i, class(layers(i)), layers(i).Name);
        end
    end
    
    % 分析网络
    analyzeNetwork(lgraph);
    
    fprintf('\n网络构建成功! 可使用 analyzeNetwork 查看图形化结构\n');
    
catch ME
    fprintf('构建网络出错: %s\n', ME.message);
    fprintf('尝试使用简化方式展示层结构...\n');
    
    % 简化展示
    fprintf('\n简化 CNN 结构:\n');
    fprintf('  Input:      28x28x1\n');
    fprintf('  Conv1:      5x5, 20 filters -> 28x28x20\n');
    fprintf('  BN + ReLU\n');
    fprintf('  MaxPool1:   2x2, stride 2  -> 14x14x20\n');
    fprintf('  Conv2:      5x5, 40 filters -> 14x14x40\n');
    fprintf('  BN + ReLU\n');
    fprintf('  MaxPool2:   2x2, stride 2  -> 7x7x40\n');
    fprintf('  Conv3:      3x3, 80 filters -> 7x7x80\n');
    fprintf('  BN + ReLU\n');
    fprintf('  FC1:        128 neurons\n');
    fprintf('  Dropout:    0.5\n');
    fprintf('  FC2:        10 neurons (classes)\n');
    fprintf('  Softmax + Classification\n');
end

%% === 第三部分: 卷积操作可视化 ===
fprintf('\n--- 第三部分: 卷积操作理解 ---\n');

% 创建一个简单的测试图像
img_size = 16;
img = zeros(img_size, img_size);

% 画一些简单模式
img(3:5, 3:5) = 1;      % 方块
img(8:12, 6:10) = 0.8;  % 矩形
img(13:14, 13:15) = 0.6; % 小方块

% 定义不同卷积核
kernels = {
    [1 0 -1; 1 0 -1; 1 0 -1], '垂直边缘检测';
    [1 1 1; 0 0 0; -1 -1 -1], '水平边缘检测';
    [1 1 1; 1 -8 1; 1 1 1],   '边缘增强 (Laplacian)';
    ones(3)/9,                  '均值平滑'
};

figure('Name', '卷积操作可视化', 'Position', [100 100 1200 400]);

% 显示原图
subplot(2, 5, 1);
imagesc(img); colormap(gray); colorbar;
title('原始图像'); axis equal tight;

% 显示各卷积核效果
for k = 1:4
    kernel = kernels{k, 1};
    kernel_name = kernels{k, 2};
    
    % 手动卷积
    result = zeros(img_size-2, img_size-2);
    for i = 2:img_size-1
        for j = 2:img_size-1
            patch = img(i-1:i+1, j-1:j+1);
            result(i-1, j-1) = sum(sum(patch .* kernel));
        end
    end
    
    % 显示卷积核
    subplot(2, 5, k+1);
    imagesc(kernel); colorbar;
    title(sprintf('核: %s', kernel_name));
    axis equal tight;
    
    % 显示卷积结果
    subplot(2, 5, k+6);
    imagesc(result); colormap(gray); colorbar;
    title(sprintf('输出: %s', kernel_name));
    axis equal tight;
end

fprintf('卷积核决定了网络提取什么样的特征\n');
fprintf('  - 垂直核 -> 检测垂直边缘\n');
fprintf('  - 水平核 -> 检测水平边缘\n');
fprintf('  - Laplacian -> 检测所有方向边缘\n');
fprintf('  - 均值核 -> 平滑/模糊\n');

%% === 第四部分: 经典 CNN 架构对比 ===
fprintf('\n--- 第四部分: 经典 CNN 架构 ---\n');

architectures = {
    'LeNet-5',      1998, '7层',    '60K',    '手写数字识别';
    'AlexNet',      2012, '8层',    '60M',    'ImageNet竞赛冠军';
    'VGG-16',       2014, '16层',   '138M',   '深层小卷积核';
    'GoogLeNet',    2014, '22层',   '5M',     'Inception模块';
    'ResNet-50',    2015, '50层',   '25M',    '残差连接';
    'MobileNet',    2017, '28层',   '4M',     '深度可分离卷积';
};

fprintf('%-12s | 年份 | 深度  | 参数量 | 特点\n', '架构');
fprintf('-------------|------|-------|--------|----------------\n');
for i = 1:size(architectures, 1)
    fprintf('%-12s | %d  | %-5s | %-6s | %s\n', ...
        architectures{i,:});
end

% 构建 ResNet 风格的残差块
fprintf('\n--- ResNet 残差块示例 ---\n');
try
    % 残差块: 跳跃连接
    residual_layers = [
        imageInputLayer([32 32 16], 'Name', 'res_input')
        
        convolution2dLayer(3, 16, 'Padding', 'same', 'Name', 'res_conv1')
        batchNormalizationLayer('Name', 'res_bn1')
        reluLayer('Name', 'res_relu1')
        
        convolution2dLayer(3, 16, 'Padding', 'same', 'Name', 'res_conv2')
        batchNormalizationLayer('Name', 'res_bn2')
        
        additionLayer(2, 'Name', 'res_add')  % 跳跃连接
        reluLayer('Name', 'res_relu2')
    ];
    
    lgraph_res = layerGraph(residual_layers);
    
    % 添加跳跃连接 (skip connection)
    lgraph_res = addLayers(lgraph_res, residual_layers(end));
    lgraph_res = connectLayers(lgraph_res, 'res_input', 'res_add/in2');
    
    fprintf('残差块构建成功!\n');
    fprintf('结构: Input -> Conv -> BN -> ReLU -> Conv -> BN -> Add(跳过) -> ReLU\n');
    fprintf('关键: 跳跃连接 (skip connection) 缓解梯度消失问题\n');
    
    figure('Name', '残差块结构', 'Position', [100 100 600 300]);
    plot(lgraph_res);
    title('ResNet 残差块 (Skip Connection)');
    
catch ME
    fprintf('残差块构建出错: %s\n', ME.message);
    
    % 文字说明
    fprintf('\n残差块结构:\n');
    fprintf('  输入 x\n');
    fprintf('    |\n');
    fprintf('    +----> Conv -> BN -> ReLU -> Conv -> BN --> +\n');
    fprintf('    |                                            |\n');
    fprintf('    +------------- 跳跃连接 (identity) --------->+\n');
    fprintf('                                                 |\n');
    fprintf('                                              ReLU\n');
    fprintf('                                                 |\n');
    fprintf('                                               输出\n');
    fprintf('\n  F(x) + x: 网络学习残差, 而非完整映射\n');
end

%% === 第五部分: 特征图维度计算 ===
fprintf('\n--- 第五部分: 特征图维度计算 ---\n');

% 公式: output_size = (input_size - kernel_size + 2*padding) / stride + 1
calc_output = @(in, k, p, s) floor((in - k + 2*p) / s) + 1;

fprintf('维度计算公式: out = floor((in - k + 2p) / s) + 1\n\n');

input_size = 224;
fprintf('输入: %dx%dx3 (如 ImageNet 图像)\n\n', input_size, input_size);

layers_info = {
    'Conv1 (7x7, s=2)',    7, 3, 2;
    'MaxPool (3x3, s=2)',  3, 0, 2;
    'Conv2 (3x3)',         3, 1, 1;
    'Conv3 (3x3, s=2)',    3, 1, 2;
    'Conv4 (3x3)',         3, 1, 1;
    'Conv5 (3x3, s=2)',    3, 1, 2;
    'GlobalAvgPool',       0, 0, 0;
};

current_size = input_size;
current_depth = 3;
depths = [64, 64, 128, 128, 256, 512];

fprintf('%-25s | 输出尺寸\n', '层');
fprintf('--------------------------|----------------\n');
for i = 1:size(layers_info, 1)
    name = layers_info{i, 1};
    k = layers_info{i, 2};
    p = layers_info{i, 3};
    s = layers_info{i, 4};
    
    if k > 0
        current_size = calc_output(current_size, k, p, s);
        if i <= length(depths)
            current_depth = depths(i);
        end
    else
        current_size = 1;
    end
    
    fprintf('%-25s | %dx%dx%d\n', name, current_size, current_size, current_depth);
end

%% === 总结 ===
fprintf('\n=== CNN 架构总结 ===\n');
fprintf('1. 卷积层提取空间特征, 参数共享减少计算量\n');
fprintf('2. 池化层降采样, 减少参数并增加感受野\n');
fprintf('3. 批归一化稳定训练, 加速收敛\n');
fprintf('4. 残差连接解决深层网络梯度消失问题\n');
fprintf('5. 经典架构从 LeNet 到 ResNet, 网络越来越深\n');
