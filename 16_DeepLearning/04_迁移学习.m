%% 迁移学习 (Transfer Learning)
% 本脚本演示迁移学习的概念和实践方法
% 需要 Deep Learning Toolbox
% 内容: 预训练网络, 微调, 特征提取, 分类新数据
clear; clc; close all;

%% === 第一部分: 预训练网络介绍 ===
fprintf('=== 迁移学习演示 ===\n\n');
fprintf('--- 第一部分: MATLAB 预训练网络 ---\n');

% 列出 MATLAB 中可用的预训练网络
pretrained_networks = {
    'alexnet',        'AlexNet (2012)',        '224x224',  '1000类';
    'vgg16',          'VGG-16 (2014)',         '224x224',  '1000类';
    'vgg19',          'VGG-19 (2014)',         '224x224',  '1000类';
    'googlenet',      'GoogLeNet/Inception',   '224x224',  '1000类';
    'resnet18',       'ResNet-18 (2015)',      '224x224',  '1000类';
    'resnet50',       'ResNet-50 (2015)',      '224x224',  '1000类';
    'resnet101',      'ResNet-101 (2015)',     '224x224',  '1000类';
    'mobilenetv2',    'MobileNet v2 (2018)',   '224x224',  '1000类';
    'squeezenet',     'SqueezeNet',            '227x227',  '1000类';
    'densenet201',    'DenseNet-201',          '224x224',  '1000类';
};

fprintf('MATLAB 可用预训练网络:\n');
fprintf('%-15s | %-25s | %-8s | %s\n', '函数名', '网络', '输入尺寸', '类别数');
fprintf('----------------|---------------------------|----------|--------\n');
for i = 1:size(pretrained_networks, 1)
    fprintf('%-15s | %-25s | %-8s | %s\n', pretrained_networks{i,:});
end

fprintf('\n这些网络在 ImageNet 数据集上预训练, 包含数百万张图像\n');

%% === 第二部分: 加载预训练网络并分析 ===
fprintf('\n--- 第二部分: 加载与分析预训练网络 ---\n');

try
    % 加载预训练网络 (以简单的为例)
    % 尝试加载多个网络, 用第一个可用的
    net = [];
    net_names = {'resnet18', 'googlenet', 'alexnet', 'squeezenet'};
    
    for i = 1:length(net_names)
        try
            fprintf('尝试加载 %s...\n', net_names{i});
            net = eval([net_names{i}]);
            fprintf('成功加载 %s!\n', net_names{i});
            break;
        catch
            fprintf('  %s 不可用, 需要下载支持包\n', net_names{i});
        end
    end
    
    if isempty(net)
        error('没有可用的预训练网络');
    end
    
    % 分析网络结构
    fprintf('\n网络分析:\n');
    fprintf('  层数: %d\n', length(net.Layers));
    
    % 统计各类型层数
    layer_types = cellfun(@(x) class(x), net.Layers, 'UniformOutput', false);
    unique_types = unique(layer_types);
    fprintf('  层类型分布:\n');
    for i = 1:length(unique_types)
        count = sum(strcmp(layer_types, unique_types{i}));
        fprintf('    %-35s: %d 个\n', unique_types{i}, count);
    end
    
    % 显示前几层和后几层
    fprintf('\n  前5层:\n');
    for i = 1:min(5, length(net.Layers))
        fprintf('    [%d] %s\n', i, class(net.Layers(i)));
    end
    fprintf('  ...\n');
    fprintf('  最后5层:\n');
    for i = max(1, length(net.Layers)-4):length(net.Layers)
        fprintf('    [%d] %s\n', i, class(net.Layers(i)));
    end
    
    % 使用预训练网络分类测试图像
    fprintf('\n--- 使用预训练网络分类 ---\n');
    
    % 创建测试图像 (从 MATLAB 内置图像)
    try
        test_img = imread('peppers.png');
        test_img = imresize(test_img, [224 224]);
        
        % 分类
        [label, scores] = classify(net, test_img);
        
        fprintf('测试图像: peppers.png\n');
        fprintf('预测类别: %s\n', char(label));
        fprintf('置信度: %.1f%%\n', max(scores)*100);
        
        % 显示 top-5 预测
        [~, top_idx] = sort(scores, 'descend');
        fprintf('\nTop-5 预测:\n');
        net_classes = net.Layers(end).Classes;
        for i = 1:5
            fprintf('  %d. %-30s (%.1f%%)\n', i, char(net_classes(top_idx(i))), ...
                scores(top_idx(i))*100);
        end
        
        figure('Name', '预训练网络分类', 'Position', [100 100 600 300]);
        subplot(1,2,1);
        imshow(test_img);
        title(sprintf('预测: %s (%.1f%%)', char(label), max(scores)*100));
        
        subplot(1,2,2);
        bar(scores(top_idx(1:10)) * 100, 'horizontal');
        set(gca, 'YTick', 1:10);
        set(gca, 'YTickLabel', cellfun(@char, net_classes(top_idx(1:10)), 'UniformOutput', false));
        xlabel('置信度 (%)');
        title('Top-10 预测');
        grid on;
        
    catch ME
        fprintf('图像分类测试出错: %s\n', ME.message);
    end
    
catch ME
    fprintf('预训练网络加载失败: %s\n', ME.message);
    fprintf('提示: 需要安装对应网络的支持包\n');
    fprintf('  使用 "addons explorer" 安装 Deep Learning Toolbox Model\n');
    
    % 展示迁移学习概念
    fprintf('\n--- 迁移学习概念演示 ---\n');
    show_transfer_concept();
end

%% === 第三部分: 迁移学习方法 (特征提取) ===
fprintf('\n--- 第三部分: 迁移学习 - 特征提取方法 ---\n');

try
    % 使用预训练网络作为特征提取器
    if exist('net', 'var') && ~isempty(net)
        
        % 生成模拟数据
        n_images = 50;
        n_classes = 3;
        
        % 创建随机彩色图像
        X_data = rand(224, 224, 3, n_images, 'single');
        
        % 激活某一层的输出作为特征
        % 找到最后一个全连接层之前的层
        feature_layer = '';
        for i = length(net.Layers):-1:1
            if isa(net.Layers(i), 'nnet.cnn.layer.FullyConnectedLayer')
                feature_layer = net.Layers(i-1).Name;
                break;
            end
        end
        
        if ~isempty(feature_layer)
            fprintf('使用层 "%s" 的输出作为特征\n', feature_layer);
            
            % 提取特征 (使用 activations)
            features = activations(net, X_data(:,:,:,1:min(5,n_images)), feature_layer);
            fprintf('特征维度: ');
            disp(size(features));
            fprintf('每张图像被表示为 %d 维的特征向量\n', prod(size(features, 1:ndims(features)-1)));
        else
            fprintf('未找到合适的特征层\n');
        end
    end
    
catch ME
    fprintf('特征提取出错: %s\n', ME.message);
end

% 迁移学习方法概念图
figure('Name', '迁移学习策略', 'Position', [100 100 900 400]);

% 策略1: 特征提取
subplot(1,3,1);
text(0.5, 0.9, '策略1: 特征提取', 'HorizontalAlignment', 'center', ...
    'FontSize', 12, 'FontWeight', 'bold');
text(0.5, 0.75, '预训练CNN', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.8 0.9 1]);
text(0.5, 0.6, '(冻结所有层)', 'HorizontalAlignment', 'center', ...
    'FontSize', 9);
text(0.5, 0.45, '提取特征', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.9 1 0.9]);
text(0.5, 0.3, '训练SVM/KNN', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [1 0.9 0.8]);
text(0.5, 0.15, '新数据分类', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [1 1 0.8]);
axis off;
title('Feature Extraction', 'FontSize', 10);

% 策略2: 微调
subplot(1,3,2);
text(0.5, 0.9, '策略2: 网络微调', 'HorizontalAlignment', 'center', ...
    'FontSize', 12, 'FontWeight', 'bold');
text(0.5, 0.75, '预训练CNN', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.8 0.9 1]);
text(0.5, 0.6, '替换最后全连接层', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.9 1 0.9]);
text(0.5, 0.45, '冻结前面层', 'HorizontalAlignment', 'center', ...
    'FontSize', 9);
text(0.5, 0.3, '用小学习率训练', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [1 0.9 0.8]);
text(0.5, 0.15, '逐步解冻更多层', 'HorizontalAlignment', 'center', ...
    'FontSize', 9);
axis off;
title('Fine-Tuning', 'FontSize', 10);

% 策略3: 完全重训练
subplot(1,3,3);
text(0.5, 0.9, '策略3: 架构重用', 'HorizontalAlignment', 'center', ...
    'FontSize', 12, 'FontWeight', 'bold');
text(0.5, 0.75, '使用相同架构', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.8 0.9 1]);
text(0.5, 0.6, '随机初始化权重', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.9 1 0.9]);
text(0.5, 0.45, '在新数据上训练', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [1 0.9 0.8]);
text(0.5, 0.3, '需要大量数据', 'HorizontalAlignment', 'center', ...
    'FontSize', 9, 'Color', 'r');
axis off;
title('Train from Scratch', 'FontSize', 10);

sgtitle('迁移学习三种策略', 'FontSize', 14);

%% === 第四部分: 微调代码模板 ===
fprintf('\n--- 第四部分: 微调 (Fine-Tuning) 代码模板 ---\n');

fprintf('以下是微调预训练网络的典型步骤:\n\n');
fprintf('%% 1. 加载预训练网络\n');
fprintf('net = resnet50;\n');
fprintf('lgraph = layerGraph(net);\n\n');

fprintf('%% 2. 替换最后的分类层\n');
fprintf('newFC = fullyConnectedLayer(numClasses, ...\n');
fprintf('    ''WeightLearnRateFactor'', 10, ...\n');
fprintf('    ''BiasLearnRateFactor'', 10);\n');
fprintf('lgraph = replaceLayer(lgraph, ''fc1000'', newFC);\n\n');

fprintf('%% 3. 冻结前面层的权重\n');
fprintf('for i = 1:length(lgraph.Layers)\n');
fprintf('    lgraph.Layers(i).WeightLearnRateFactor = 0;\n');
fprintf('    lgraph.Layers(i).BiasLearnRateFactor = 0;\n');
fprintf('end\n\n');

fprintf('%% 4. 解冻最后几层 (可选)\n');
fprintf('for i = end-5:end\n');
fprintf('    lgraph.Layers(i).WeightLearnRateFactor = 1;\n');
fprintf('    lgraph.Layers(i).BiasLearnRateFactor = 1;\n');
fprintf('end\n\n');

fprintf('%% 5. 训练\n');
fprintf('options = trainingOptions(''sgdm'', ...\n');
fprintf('    ''InitialLearnRate'', 1e-4, ...\n');
fprintf('    ''MaxEpochs'', 10);\n');
fprintf('net_new = trainNetwork(trainData, lgraph, options);\n');

% 迁移学习决策指南
figure('Name', '迁移学习决策', 'Position', [100 100 800 400]);

% 创建决策流程图
axes('Position', [0.05 0.05 0.9 0.9]);
hold on;
axis off;

% 标题
text(0.5, 0.95, '迁移学习策略选择指南', 'HorizontalAlignment', 'center', ...
    'FontSize', 14, 'FontWeight', 'bold');

% 决策节点1
text(0.5, 0.8, '数据量大吗?', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.9 0.95 1], 'FontSize', 11, 'EdgeColor', 'k');
% 小数据
text(0.2, 0.6, '特征相似吗?', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.95 0.95 1], 'FontSize', 10, 'EdgeColor', 'k');
% 大数据
text(0.8, 0.6, '特征相似吗?', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.95 0.95 1], 'FontSize', 10, 'EdgeColor', 'k');

% 结果
text(0.1, 0.35, '特征提取', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.8 1 0.8], 'FontSize', 10);
text(0.3, 0.35, '微调顶层', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [1 1 0.8], 'FontSize', 10);
text(0.7, 0.35, '微调全部', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [1 1 0.8], 'FontSize', 10);
text(0.9, 0.35, '重新训练', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [1 0.9 0.8], 'FontSize', 10);

% 标签
text(0.35, 0.72, '少', 'FontSize', 9, 'Color', 'r');
text(0.65, 0.72, '多', 'FontSize', 9, 'Color', 'b');
text(0.15, 0.52, '是', 'FontSize', 9, 'Color', 'r');
text(0.25, 0.52, '否', 'FontSize', 9, 'Color', 'b');
text(0.75, 0.52, '是', 'FontSize', 9, 'Color', 'r');
text(0.85, 0.52, '否', 'FontSize', 9, 'Color', 'b');

title('迁移学习策略决策图');

%% === 总结 ===
fprintf('\n=== 迁移学习总结 ===\n');
fprintf('1. 预训练网络在大规模数据上训练过, 具有强大的特征提取能力\n');
fprintf('2. 特征提取: 冻结CNN, 用输出特征训练简单分类器 (数据少时首选)\n');
fprintf('3. 微调: 替换分类层, 用小学习率更新部分权重\n');
fprintf('4. 策略选择取决于数据量和任务相似度\n');
fprintf('5. 迁移学习大幅减少训练时间和数据需求\n');

%% === 辅助函数 ===
function show_transfer_concept()
    fprintf('\n迁移学习基本概念:\n');
    fprintf('  源任务 (Source Task): ImageNet 1000类图像分类\n');
    fprintf('  目标任务 (Target Task): 你自己的分类任务\n');
    fprintf('  \n');
    fprintf('  知识迁移:\n');
    fprintf('    - 底层卷积核: 边缘、纹理等通用特征 (可直接复用)\n');
    fprintf('    - 中层特征: 局部形状、模式 (大部分可复用)\n');
    fprintf('    - 高层特征: 类别特定特征 (需要适应新任务)\n');
    fprintf('  \n');
    fprintf('  关键优势:\n');
    fprintf('    - 减少训练数据需求\n');
    fprintf('    - 缩短训练时间\n');
    fprintf('    - 提高小数据集上的性能\n');
end
