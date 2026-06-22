%% 神经网络基础 (Neural Network Basics)
% 本脚本演示 MATLAB 中基础神经网络的创建和使用
% 需要 Deep Learning Toolbox (原 Neural Network Toolbox)
% 内容: patternnet, feedforwardnet, 训练与预测
clear; clc; close all;

%% === 第一部分: 简单回归网络 ===
fprintf('=== 神经网络基础演示 ===\n\n');
fprintf('--- 第一部分: feedforwardnet 回归 ---\n');

try
    % 生成训练数据: 非线性函数拟合
    x_train = linspace(-5, 5, 200);
    y_train = sin(x_train) + 0.3 * x_train.^2 - 2 + 0.2*randn(size(x_train));
    
    fprintf('训练数据: y = sin(x) + 0.3x^2 - 2 + 噪声\n');
    fprintf('样本数: %d\n', length(x_train));
    
    % 创建前馈神经网络
    hidden_layers = [10, 5];   % 两个隐藏层
    net = feedforwardnet(hidden_layers, 'trainlm');
    
    fprintf('\n网络结构:\n');
    fprintf('  输入层: 1 个神经元\n');
    fprintf('  隐藏层1: %d 个神经元 (tansig)\n', hidden_layers(1));
    fprintf('  隐藏层2: %d 个神经元 (tansig)\n', hidden_layers(2));
    fprintf('  输出层: 1 个神经元 (purelin)\n');
    
    % 配置训练参数
    net.trainParam.epochs = 200;
    net.trainParam.goal = 1e-4;
    net.trainParam.showWindow = false;   % 不显示训练窗口
    net.trainParam.showCommandLine = false;
    
    % 训练网络
    fprintf('\n正在训练网络...\n');
    [net, tr] = train(net, x_train, y_train);
    
    % 训练结果
    fprintf('训练完成:\n');
    fprintf('  训练轮数: %d\n', tr.num_epochs);
    fprintf('  最终MSE: %.6f\n', tr.perf(end));
    fprintf('  最佳训练轮: %d\n', tr.best_epoch);
    
    % 预测
    y_pred = net(x_train);
    mse_val = mean((y_train - y_pred).^2);
    r2 = 1 - sum((y_train - y_pred).^2) / sum((y_train - mean(y_train)).^2);
    fprintf('  预测MSE: %.6f\n', mse_val);
    fprintf('  R^2: %.4f\n', r2);
    
    % 可视化
    figure('Name', '神经网络回归', 'Position', [100 100 1000 400]);
    
    subplot(1,2,1);
    scatter(x_train, y_train, 15, [0.6 0.6 0.6], 'filled'); hold on;
    x_plot = linspace(-5, 5, 500);
    y_plot = net(x_plot);
    plot(x_plot, y_plot, 'r-', 'LineWidth', 2);
    xlabel('x'); ylabel('y');
    title('神经网络拟合结果');
    legend('训练数据', '网络预测', 'Location', 'northwest');
    grid on;
    
    subplot(1,2,2);
    plot(tr.perf, 'b-', 'LineWidth', 1.5);
    xlabel('训练轮数');
    ylabel('MSE');
    title('训练过程');
    grid on;
    set(gca, 'YScale', 'log');
    
catch ME
    fprintf('需要 Deep Learning Toolbox\n');
    fprintf('错误: %s\n', ME.message);
    
    % 简化演示 - 手动实现简单网络
    fprintf('\n--- 手动实现简单神经网络 ---\n');
    
    x = linspace(-3, 3, 100);
    y = sin(x) + 0.1*randn(size(x));
    
    % 单隐藏层网络 (手动)
    n_hidden = 10;
    W1 = randn(n_hidden, 1) * 0.5;
    b1 = randn(n_hidden, 1) * 0.1;
    W2 = randn(1, n_hidden) * 0.5;
    b2 = 0;
    
    lr = 0.01;
    for epoch = 1:1000
        % 前向传播
        z1 = W1 * x + b1;
        a1 = tanh(z1);
        y_pred = W2 * a1 + b2;
        
        % 反向传播
        error = y_pred - y;
        dW2 = error * a1' / length(x);
        db2 = mean(error);
        da1 = W2' * error;
        dz1 = da1 .* (1 - a1.^2);
        dW1 = dz1 * x' / length(x);
        db1 = mean(dz1, 2);
        
        W1 = W1 - lr * dW1;
        b1 = b1 - lr * b1;
        W2 = W2 - lr * dW2;
        b2 = b2 - lr * db2;
    end
    
    y_final = W2 * tanh(W1 * x + b1) + b2;
    
    figure; 
    scatter(x, y, 10, 'filled'); hold on;
    plot(x, y_final, 'r-', 'LineWidth', 2);
    title('手动实现神经网络拟合');
    legend('数据', '预测');
    grid on;
end

%% === 第二部分: patternnet 分类 ===
fprintf('\n--- 第二部分: patternnet 分类网络 ---\n');

try
    % 生成分类数据 (3类)
    N_per_class = 100;
    
    % 类别1: 均值(2,2)
    class1 = [2 + randn(N_per_class,1), 2 + randn(N_per_class,1)]';
    % 类别2: 均值(-2,-1)
    class2 = [-2 + randn(N_per_class,1), -1 + randn(N_per_class,1)]';
    % 类别3: 均值(0,-3)
    class3 = [0 + randn(N_per_class,1), -3 + randn(N_per_class,1)]';
    
    X = [class1, class2, class3];
    T = zeros(3, 3*N_per_class);   % one-hot编码
    T(1, 1:N_per_class) = 1;
    T(2, N_per_class+1:2*N_per_class) = 1;
    T(3, 2*N_per_class+1:end) = 1;
    
    fprintf('分类数据: 3类, 每类 %d 个样本\n', N_per_class);
    fprintf('特征维度: 2\n');
    
    % 创建模式识别网络
    net_class = patternnet([15, 10]);
    net_class.trainParam.epochs = 300;
    net_class.trainParam.goal = 1e-3;
    net_class.trainParam.showWindow = false;
    net_class.trainParam.showCommandLine = false;
    
    % 划分数据集
    net_class.divideParam.trainRatio = 0.7;
    net_class.divideParam.valRatio = 0.15;
    net_class.divideParam.testRatio = 0.15;
    
    % 训练
    fprintf('正在训练分类网络...\n');
    [net_class, tr_class] = train(net_class, X, T);
    
    % 测试
    Y = net_class(X);
    [~, predicted] = max(Y, [], 1);
    [~, actual] = max(T, [], 1);
    accuracy = sum(predicted == actual) / length(actual) * 100;
    
    fprintf('分类准确率: %.1f%%\n', accuracy);
    
    % 混淆矩阵
    conf = confusionmat(actual, predicted);
    fprintf('\n混淆矩阵:\n');
    disp(conf);
    
    % 可视化
    figure('Name', '分类结果', 'Position', [100 100 1000 400]);
    
    subplot(1,2,1);
    scatter(class1(1,:), class1(2,:), 30, 'r', 'filled'); hold on;
    scatter(class2(1,:), class2(2,:), 30, 'g', 'filled');
    scatter(class3(1,:), class3(2,:), 30, 'b', 'filled');
    xlabel('特征1'); ylabel('特征2');
    title('训练数据分布');
    legend('类别1', '类别2', '类别3', 'Location', 'best');
    grid on;
    
    % 决策边界
    subplot(1,2,2);
    [xx, yy] = meshgrid(linspace(-5, 5, 100), linspace(-5, 5, 100));
    grid_points = [xx(:)'; yy(:)'];
    Y_grid = net_class(grid_points);
    [~, class_grid] = max(Y_grid, [], 1);
    class_map = reshape(class_grid, size(xx));
    
    contourf(xx, yy, class_map, [0.5 1.5 2.5 3.5], ...
        'FaceAlpha', 0.3, 'LineWidth', 0);
    hold on;
    scatter(class1(1,:), class1(2,:), 20, 'r', 'filled');
    scatter(class2(1,:), class2(2,:), 20, 'g', 'filled');
    scatter(class3(1,:), class3(2,:), 20, 'b', 'filled');
    xlabel('特征1'); ylabel('特征2');
    title('决策边界');
    grid on;
    
catch ME
    fprintf('patternnet 演示出错: %s\n', ME.message);
end

%% === 第三部分: 网络结构探索 ===
fprintf('\n--- 第三部分: 网络结构对比 ---\n');

try
    % 不同隐藏层大小的影响
    hidden_sizes = [3, 5, 10, 20, 50];
    x_reg = linspace(-3, 3, 150);
    y_reg = sin(2*x_reg) + 0.3*x_reg + 0.1*randn(size(x_reg));
    
    mse_results = zeros(size(hidden_sizes));
    
    for i = 1:length(hidden_sizes)
        net_i = feedforwardnet(hidden_sizes(i), 'trainlm');
        net_i.trainParam.epochs = 200;
        net_i.trainParam.showWindow = false;
        net_i.trainParam.showCommandLine = false;
        
        [net_i, tr_i] = train(net_i, x_reg, y_reg);
        y_pred_i = net_i(x_reg);
        mse_results(i) = mean((y_reg - y_pred_i).^2);
        fprintf('  隐藏层大小 %2d: MSE = %.6f\n', hidden_sizes(i), mse_results(i));
    end
    
    figure('Name', '网络容量 vs 性能', 'Position', [100 100 600 400]);
    bar(hidden_sizes, mse_results, 'FaceColor', [0.2 0.6 0.8]);
    xlabel('隐藏层神经元数');
    ylabel('MSE');
    title('网络容量与拟合性能');
    grid on;
    
catch ME
    fprintf('网络对比出错: %s\n', ME.message);
end

%% === 总结 ===
fprintf('\n=== 神经网络基础总结 ===\n');
fprintf('1. feedforwardnet: 通用前馈网络, 适用于回归任务\n');
fprintf('2. patternnet: 模式识别网络, 适用于分类任务\n');
fprintf('3. 训练函数: trainlm (Levenberg-Marquardt), trainbr, trainscg\n');
fprintf('4. 网络容量 (隐藏层大小) 影响拟合能力\n');
fprintf('5. 合理划分训练/验证/测试集防止过拟合\n');
