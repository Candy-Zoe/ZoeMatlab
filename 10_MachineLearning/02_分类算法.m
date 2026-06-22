%% 02_分类算法.m — 监督学习分类
%  涵盖: KNN, SVM, 决策树, 集成学习, 混淆矩阵
%  需要 Statistics and Machine Learning Toolbox

clear; clc; close all;

%% ===== 1. 准备数据 =====
fprintf('===== 1. 准备数据 =====\n');

rng(42);
n = 300;

% 生成三类数据
X1 = randn(n/3, 2) * 0.9 + [2, 3];
X2 = randn(n/3, 2) * 1.1 + [-2, 2];
X3 = randn(n/3, 2) * 0.7 + [1, -2];
X = [X1; X2; X3];
Y = categorical([ones(n/3,1); 2*ones(n/3,1); 3*ones(n/3,1)]);
categories(Y) = {'类1', '类2', '类3'};

% 划分训练/测试集
cv = cvpartition(Y, 'HoldOut', 0.3);
X_train = X(training(cv), :);
Y_train = Y(training(cv));
X_test = X(test(cv), :);
Y_test = Y(test(cv));

fprintf('训练集: %d 样本, 测试集: %d 样本\n', length(Y_train), length(Y_test));

%% ===== 2. K 近邻 (KNN) =====
fprintf('\n===== 2. KNN 分类器 =====\n');

% 训练 KNN
knn_model = fitcknn(X_train, Y_train, 'NumNeighbors', 5, ...
    'Standardize', true, 'Distance', 'euclidean');

% 预测
Y_pred_knn = predict(knn_model, X_test);
acc_knn = sum(Y_pred_knn == Y_test) / length(Y_test) * 100;
fprintf('KNN (K=5) 准确率: %.1f%%\n', acc_knn);

% 不同 K 值的准确率
k_values = 1:2:25;
acc_k_values = zeros(size(k_values));
for i = 1:length(k_values)
    mdl = fitcknn(X_train, Y_train, 'NumNeighbors', k_values(i), 'Standardize', true);
    Y_p = predict(mdl, X_test);
    acc_k_values(i) = sum(Y_p == Y_test) / length(Y_test) * 100;
end

figure('Name', 'KNN K 值选择', 'Position', [100 100 600 400]);
plot(k_values, acc_k_values, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 8);
xlabel('K 值'); ylabel('准确率 (%)');
title('KNN 不同 K 值的准确率');
grid on;

% 决策边界可视化
figure('Name', 'KNN 决策边界', 'Position', [200 200 600 500]);
[x1g, x2g] = meshgrid(linspace(-5, 5, 150), linspace(-5, 6, 150));
X_grid = [x1g(:), x2g(:)];
Y_grid_knn = predict(knn_model, X_grid);
Y_grid_num = double(Y_grid_knn);
Y_map = reshape(Y_grid_num, size(x1g));
contourf(x1g, x2g, Y_map, [0.5 1.5 2.5 3.5], 'LineStyle', 'none');
colormap([1 0.7 0.7; 0.7 1 0.7; 0.7 0.7 1]);
hold on;
gscatter(X_train(:,1), X_train(:,2), Y_train, 'rgb', 'o', 6);
title(sprintf('KNN 决策边界 (K=5, 准确率=%.1f%%)', acc_knn));
xlabel('特征 1'); ylabel('特征 2');
hold off;

%% ===== 3. 支持向量机 (SVM) =====
fprintf('\n===== 3. SVM 分类器 =====\n');

% 一对多 SVM (多类)
svm_model = fitcecoc(X_train, Y_train, 'Learners', 'svm', ...
    'Standardize', true, 'Coding', 'onevsall');

Y_pred_svm = predict(svm_model, X_test);
acc_svm = sum(Y_pred_svm == Y_test) / length(Y_test) * 100;
fprintf('SVM (线性核) 准确率: %.1f%%\n', acc_svm);

% 使用 RBF 核
svm_rbf = fitcecoc(X_train, Y_train, 'Learners', templateSVM('KernelFunction', 'rbf'), ...
    'Standardize', true, 'Coding', 'onevsall');
Y_pred_rbf = predict(svm_rbf, X_test);
acc_rbf = sum(Y_pred_rbf == Y_test) / length(Y_test) * 100;
fprintf('SVM (RBF 核) 准确率: %.1f%%\n', acc_rbf);

%% ===== 4. 决策树 =====
fprintf('\n===== 4. 决策树 =====\n');

tree_model = fitctree(X_train, Y_train, 'MaxNumSplits', 10);
Y_pred_tree = predict(tree_model, X_test);
acc_tree = sum(Y_pred_tree == Y_test) / length(Y_test) * 100;
fprintf('决策树准确率: %.1f%%\n', acc_tree);

% 可视化决策树
figure('Name', '决策树结构', 'Position', [300 300 800 500]);
view(tree_model, 'Mode', 'graph');

%% ===== 5. 集成学习 =====
fprintf('\n===== 5. 集成学习 =====\n');

% Bagging (随机森林)
bag_model = fitcensemble(X_train, Y_train, 'Method', 'Bag', ...
    'NumLearningCycles', 100, 'Learners', templateTree('MaxNumSplits', 10));
Y_pred_bag = predict(bag_model, X_test);
acc_bag = sum(Y_pred_bag == Y_test) / length(Y_test) * 100;
fprintf('随机森林 (Bag) 准确率: %.1f%%\n', acc_bag);

% AdaBoost
ada_model = fitcensemble(X_train, Y_train, 'Method', 'AdaBoostM2', ...
    'NumLearningCycles', 100);
Y_pred_ada = predict(ada_model, X_test);
acc_ada = sum(Y_pred_ada == Y_test) / length(Y_test) * 100;
fprintf('AdaBoost 准确率: %.1f%%\n', acc_ada);

%% ===== 6. 混淆矩阵与性能对比 =====
fprintf('\n===== 6. 混淆矩阵 =====\n');

figure('Name', '分类器性能对比', 'Position', [100 100 900 700]);

% KNN 混淆矩阵
subplot(2, 3, 1);
cm_knn = confusionmat(Y_test, Y_pred_knn);
imagesc(cm_knn); colorbar;
title(sprintf('KNN (%.1f%%)', acc_knn));
for i = 1:3
    for j = 1:3
        text(j, i, num2str(cm_knn(i,j)), 'HorizontalAlignment', 'center', ...
            'FontSize', 12, 'FontWeight', 'bold');
    end
end
xlabel('预测'); ylabel('真实');

% SVM 混淆矩阵
subplot(2, 3, 2);
cm_svm = confusionmat(Y_test, Y_pred_svm);
imagesc(cm_svm); colorbar;
title(sprintf('SVM (%.1f%%)', acc_svm));
for i = 1:3
    for j = 1:3
        text(j, i, num2str(cm_svm(i,j)), 'HorizontalAlignment', 'center', ...
            'FontSize', 12, 'FontWeight', 'bold');
    end
end
xlabel('预测'); ylabel('真实');

% 决策树混淆矩阵
subplot(2, 3, 3);
cm_tree = confusionmat(Y_test, Y_pred_tree);
imagesc(cm_tree); colorbar;
title(sprintf('决策树 (%.1f%%)', acc_tree));
for i = 1:3
    for j = 1:3
        text(j, i, num2str(cm_tree(i,j)), 'HorizontalAlignment', 'center', ...
            'FontSize', 12, 'FontWeight', 'bold');
    end
end
xlabel('预测'); ylabel('真实');

% 准确率对比柱状图
subplot(2, 3, 4);
methods = {'KNN', 'SVM线性', 'SVM-RBF', '决策树', '随机森林', 'AdaBoost'};
accs = [acc_knn, acc_svm, acc_rbf, acc_tree, acc_bag, acc_ada];
bar(accs, 'FaceColor', [0.3 0.6 0.9]);
set(gca, 'XTickLabel', methods);
ylabel('准确率 (%)');
title('分类器准确率对比');
grid on;
ylim([70, 105]);

% 学习曲线 (KNN 训练样本量)
subplot(2, 3, 5);
train_sizes = round(linspace(20, length(Y_train), 8));
acc_curve = zeros(size(train_sizes));
for i = 1:length(train_sizes)
    idx_sub = randsample(length(Y_train), train_sizes(i));
    mdl_sub = fitcknn(X_train(idx_sub,:), Y_train(idx_sub), 'NumNeighbors', 5, 'Standardize', true);
    Y_p = predict(mdl_sub, X_test);
    acc_curve(i) = sum(Y_p == Y_test) / length(Y_test) * 100;
end
plot(train_sizes, acc_curve, 'ro-', 'LineWidth', 1.5);
xlabel('训练样本数'); ylabel('测试准确率 (%)');
title('KNN 学习曲线');
grid on;

fprintf('\n===== 分类算法模块完成! =====\n');
