%% 训练与评估 (Training and Evaluation)
% 本脚本演示深度学习网络的训练配置和性能评估
% 需要 Deep Learning Toolbox
% 内容: trainNetwork, trainingOptions, 训练曲线, confusionchart
clear; clc; close all;

%% === 第一部分: trainingOptions 配置 ===
fprintf('=== 深度学习训练与评估 ===\n\n');
fprintf('--- 第一部分: 训练选项配置 ---\n');

try
    % 配置训练选项
    options = trainingOptions('adam', ...
        'MaxEpochs', 30, ...
        'MiniBatchSize', 32, ...
        'InitialLearnRate', 0.001, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropPeriod', 10, ...
        'LearnRateDropFactor', 0.5, ...
        'Momentum', 0.9, ...
        'L2Regularization', 1e-4, ...
        'GradientThreshold', 1, ...
        'ValidationFrequency', 50, ...
        'ValidationPatience', 5, ...
        'Shuffle', 'every-epoch', ...
        'Verbose', false, ...
        'Plots', 'none');
    
    fprintf('训练选项 (Adam 优化器):\n');
    fprintf('  优化器:       Adam\n');
    fprintf('  最大轮数:     30\n');
    fprintf('  批大小:       32\n');
    fprintf('  初始学习率:   0.001\n');
    fprintf('  学习率策略:   分段下降\n');
    fprintf('  下降周期:     10\n');
    fprintf('  下降因子:     0.5\n');
    fprintf('  L2正则化:     1e-4\n');
    fprintf('  梯度裁剪:     1\n');
    fprintf('  验证频率:     每50次迭代\n');
    fprintf('  早停耐心:     5\n');
    fprintf('  数据打乱:     每轮\n');
    
catch ME
    fprintf('trainingOptions 配置出错: %s\n', ME.message);
end

% 常用优化器对比
fprintf('\n常用优化器对比:\n');
fprintf('  SGD:    基础优化器, 需要精心调节学习率\n');
fprintf('  SGDM:   加入动量, 加速收敛\n');
fprintf('  Adam:   自适应学习率, 通常效果最好\n');
fprintf('  RMSprop: 自适应学习率, 适合RNN\n');

%% === 第二部分: 生成模拟图像数据并训练 ===
fprintf('\n--- 第二部分: 使用模拟数据训练 CNN ---\n');

try
    % 生成简单的模拟图像数据 (3类几何图形)
    img_size = 32;
    n_per_class = 100;
    n_classes = 3;
    
    X_train = zeros(img_size, img_size, 1, n_per_class * n_classes);
    Y_train = zeros(n_per_class * n_classes, 1);
    
    rng(42);
    idx = 0;
    
    % 类别1: 圆形
    [xx, yy] = meshgrid(1:img_size, 1:img_size);
    cx = img_size/2; cy = img_size/2;
    for i = 1:n_per_class
        idx = idx + 1;
        r = 6 + randi(4);
        noise = 0.05 * randn(img_size);
        mask = (xx - cx - randi([-1,1])).^2 + (yy - cy - randi([-1,1])).^2 < r^2;
        X_train(:,:,1,idx) = mask + noise;
        Y_train(idx) = 1;
    end
    
    % 类别2: 水平条纹
    for i = 1:n_per_class
        idx = idx + 1;
        noise = 0.05 * randn(img_size);
        img = zeros(img_size);
        for row = 1:4:img_size
            img(row:min(row+1,img_size), :) = 1;
        end
        shift = randi([-2,2]);
        img = circshift(img, [shift, 0]);
        X_train(:,:,1,idx) = img + noise;
        Y_train(idx) = 2;
    end
    
    % 类别3: 对角线
    for i = 1:n_per_class
        idx = idx + 1;
        noise = 0.05 * randn(img_size);
        img = zeros(img_size);
        for d = -img_size:img_size
            for r = 1:img_size
                c = r + d + randi([-1,1]);
                if c >= 1 && c <= img_size && abs(d) < 4
                    img(r, c) = 1;
                end
            end
        end
        X_train(:,:,1,idx) = min(max(img + noise, 0), 1);
        Y_train(idx) = 3;
    end
    
    % 转换为 categorical 标签
    classNames = {'圆形', '条纹', '对角线'};
    Y_cat = categorical(Y_train, [1 2 3], classNames);
    
    fprintf('训练数据: %d 张 %dx%d 图像, %d 类\n', ...
        size(X_train, 4), img_size, img_size, n_classes);
    fprintf('类别: %s\n', strjoin(classNames, ', '));
    
    % 划分训练/验证集
    cv = cvpartition(numel(Y_train), 'HoldOut', 0.2);
    XTrain = X_train(:,:,:,cv.training);
    YTrain = Y_cat(cv.training);
    XVal = X_train(:,:,:,cv.test);
    YVal = Y_cat(cv.test);
    
    fprintf('训练集: %d, 验证集: %d\n', numel(YTrain), numel(YVal));
    
    % 定义 CNN 架构
    layers = [
        imageInputLayer([img_size img_size 1], 'Name', 'input')
        
        convolution2dLayer(3, 16, 'Padding', 'same')
        batchNormalizationLayer
        reluLayer
        maxPooling2dLayer(2, 'Stride', 2)
        
        convolution2dLayer(3, 32, 'Padding', 'same')
        batchNormalizationLayer
        reluLayer
        maxPooling2dLayer(2, 'Stride', 2)
        
        convolution2dLayer(3, 64, 'Padding', 'same')
        batchNormalizationLayer
        reluLayer
        
        fullyConnectedLayer(64)
        reluLayer
        dropoutLayer(0.3)
        
        fullyConnectedLayer(n_classes)
        softmaxLayer
        classificationLayer
    ];
    
    % 训练选项
    options = trainingOptions('adam', ...
        'MaxEpochs', 20, ...
        'MiniBatchSize', 16, ...
        'InitialLearnRate', 0.001, ...
        'ValidationData', {XVal, YVal}, ...
        'ValidationFrequency', 30, ...
        'Shuffle', 'every-epoch', ...
        'Verbose', false, ...
        'Plots', 'none');
    
    % 训练网络
    fprintf('\n正在训练网络 (可能需要一些时间)...\n');
    [net, info] = trainNetwork(XTrain, YTrain, layers, options);
    
    fprintf('训练完成!\n');
    fprintf('  最终训练准确率: %.1f%%\n', info.TrainingAccuracy(end)*100);
    fprintf('  最终验证准确率: %.1f%%\n', info.ValidationAccuracy(end)*100);
    fprintf('  训练轮数: %d\n', info.Epoch(end));
    
    % === 第三部分: 训练曲线 ===
    fprintf('\n--- 第三部分: 训练曲线可视化 ---\n');
    
    figure('Name', '训练过程', 'Position', [100 100 1000 400]);
    
    subplot(1,2,1);
    plot(info.TrainingLoss, 'b-', 'LineWidth', 1.5); hold on;
    plot(info.ValidationLoss, 'r--', 'LineWidth', 1.5);
    xlabel('迭代次数');
    ylabel('损失 (Loss)');
    title('训练损失 vs 验证损失');
    legend('训练损失', '验证损失', 'Location', 'best');
    grid on;
    
    subplot(1,2,2);
    plot(info.TrainingAccuracy * 100, 'b-', 'LineWidth', 1.5); hold on;
    plot(info.ValidationAccuracy * 100, 'r--', 'LineWidth', 1.5);
    xlabel('迭代次数');
    ylabel('准确率 (%)');
    title('训练准确率 vs 验证准确率');
    legend('训练准确率', '验证准确率', 'Location', 'southeast');
    grid on;
    ylim([0 105]);
    
    % === 第四部分: 评估与混淆矩阵 ===
    fprintf('\n--- 第四部分: 模型评估 ---\n');
    
    % 预测
    YPred = classify(net, XVal);
    
    % 计算准确率
    accuracy = sum(YPred == YVal) / numel(YVal) * 100;
    fprintf('测试准确率: %.1f%%\n', accuracy);
    
    % 混淆矩阵
    figure('Name', '混淆矩阵', 'Position', [100 100 800 400]);
    
    subplot(1,2,1);
    cm = confusionchart(YVal, YPred);
    cm.Title = '混淆矩阵';
    cm.ColumnSummary = 'column-normalized';
    cm.RowSummary = 'row-normalized';
    
    % 各类指标
    subplot(1,2,2);
    confmat = confusionmat(YVal, YPred);
    
    precision = zeros(n_classes, 1);
    recall = zeros(n_classes, 1);
    f1 = zeros(n_classes, 1);
    
    for c = 1:n_classes
        tp = confmat(c, c);
        fp = sum(confmat(:, c)) - tp;
        fn = sum(confmat(c, :)) - tp;
        
        precision(c) = tp / max(tp + fp, 1);
        recall(c) = tp / max(tp + fn, 1);
        f1(c) = 2 * precision(c) * recall(c) / max(precision(c) + recall(c), eps);
    end
    
    bar_data = [precision, recall, f1];
    b = bar(bar_data);
    b(1).FaceColor = [0.2 0.6 0.8];
    b(2).FaceColor = [0.8 0.4 0.2];
    b(3).FaceColor = [0.2 0.8 0.4];
    set(gca, 'XTickLabel', classNames);
    xlabel('类别');
    ylabel('指标值');
    title('分类指标');
    legend('精确率', '召回率', 'F1分数', 'Location', 'best');
    grid on;
    ylim([0 1.1]);
    
    fprintf('\n各类指标:\n');
    fprintf('%-10s | 精确率  | 召回率  | F1\n', '类别');
    fprintf('-----------|---------|---------|------\n');
    for c = 1:n_classes
        fprintf('%-10s | %.3f  | %.3f  | %.3f\n', ...
            classNames{c}, precision(c), recall(c), f1(c));
    end
    
    % 可视化一些预测结果
    figure('Name', '预测示例', 'Position', [100 100 800 300]);
    n_show = 8;
    show_idx = randperm(numel(YVal), n_show);
    
    for i = 1:n_show
        subplot(1, n_show, i);
        imshow(XVal(:,:,1,show_idx(i)), []);
        true_label = char(YVal(show_idx(i)));
        pred_label = char(YPred(show_idx(i)));
        if strcmp(true_label, pred_label)
            title(sprintf('%s (正确)', pred_label), 'Color', 'g');
        else
            title(sprintf('%s/%s', pred_label, true_label), 'Color', 'r');
        end
        axis off;
    end
    sgtitle('预测结果示例 (绿色=正确, 红色=错误)');
    
catch ME
    fprintf('训练演示出错: %s\n', ME.message);
    
    % 展示模拟训练曲线
    fprintf('\n展示模拟训练曲线...\n');
    epochs = 1:20;
    train_loss = 2.0 * exp(-0.15*epochs) + 0.1 + 0.05*randn(size(epochs));
    val_loss = 2.0 * exp(-0.12*epochs) + 0.2 + 0.08*randn(size(epochs));
    train_acc = 100 * (1 - exp(-0.2*epochs)) - 5*randn(size(epochs));
    val_acc = 100 * (1 - exp(-0.18*epochs)) - 8 + 5*randn(size(epochs));
    
    figure('Name', '模拟训练曲线', 'Position', [100 100 800 400]);
    subplot(1,2,1);
    plot(epochs, train_loss, 'b-', 'LineWidth', 2); hold on;
    plot(epochs, val_loss, 'r--', 'LineWidth', 2);
    xlabel('训练轮数'); ylabel('损失');
    title('损失曲线'); legend('训练', '验证'); grid on;
    
    subplot(1,2,2);
    plot(epochs, train_acc, 'b-', 'LineWidth', 2); hold on;
    plot(epochs, val_acc, 'r--', 'LineWidth', 2);
    xlabel('训练轮数'); ylabel('准确率(%)');
    title('准确率曲线'); legend('训练', '验证'); grid on;
end

%% === 总结 ===
fprintf('\n=== 训练与评估总结 ===\n');
fprintf('1. trainingOptions 配置训练超参数 (学习率、批大小、正则化)\n');
fprintf('2. trainNetwork 执行训练, 返回网络对象和训练信息\n');
fprintf('3. 训练曲线帮助诊断过拟合/欠拟合\n');
fprintf('4. 混淆矩阵和 F1 分数全面评估分类性能\n');
fprintf('5. 验证集监控 + 早停策略防止过拟合\n');
