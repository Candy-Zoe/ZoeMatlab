%% 01_数据预处理.m — 机器学习数据准备
%  涵盖: zscore, normalize, cvpartition, 特征选择
%  需要 Statistics and Machine Learning Toolbox

clear; clc; close all;

%% ===== 1. 生成示例数据集 =====
fprintf('===== 1. 生成示例数据集 =====\n');

rng(42);
n = 200;

% 生成三类二维数据
X1 = randn(n/3, 2) * 1.0 + [2, 2];
X2 = randn(n/3, 2) * 1.2 + [-2, 2];
X3 = randn(n/3, 2) * 0.8 + [0, -2];

X = [X1; X2; X3];  % 200 x 2
Y = [ones(n/3,1); 2*ones(n/3,1); 3*ones(n/3,1)];  % 类别标签

% 添加更多特征（含噪声特征和冗余特征）
X_extra = randn(n, 3);  % 噪声特征
X_redundant = X(:,1) * 0.8 + randn(n, 1) * 0.2;  % 冗余特征
X_full = [X, X_extra, X_redundant];  % 200 x 6

fprintf('数据集: %d 样本, %d 特征, %d 类\n', size(X_full, 1), size(X_full, 2), max(Y));

% 可视化原始数据
figure('Name', '数据分布', 'Position', [100 100 600 400]);
gscatter(X(:,1), X(:,2), Y, 'rgb', 'o', 6);
title('三类数据分布');
xlabel('特征 1'); ylabel('特征 2');
legend('类1', '类2', '类3', 'Location', 'best');
grid on;

%% ===== 2. 数据标准化 =====
fprintf('\n===== 2. 数据标准化 =====\n');

% 方法1: z-score 标准化 (均值=0, 标准差=1)
[X_z, mu, sigma] = zscore(X_full);

fprintf('标准化前 - 均值: [');
fprintf('%.2f ', mean(X_full));
fprintf(']\n');
fprintf('标准化前 - 标准差: [');
fprintf('%.2f ', std(X_full));
fprintf(']\n');

fprintf('标准化后 - 均值: [');
fprintf('%.4f ', mean(X_z));
fprintf(']\n');
fprintf('标准化后 - 标准差: [');
fprintf('%.4f ', std(X_z));
fprintf(']\n');

% 方法2: min-max 归一化 [0, 1]
X_minmax = normalize(X_full, 'range');

% 方法3: 中位数/MAD 标准化 (对异常值鲁棒)
X_robust = normalize(X_full, 'zscore', 'center', 'median', 'scale', 'mad');

figure('Name', '标准化方法对比', 'Position', [200 200 900 300]);
subplot(1, 3, 1);
boxplot(X_full); title('原始数据'); xlabel('特征'); ylabel('值');
subplot(1, 3, 2);
boxplot(X_z); title('z-score 标准化'); xlabel('特征'); ylabel('值');
subplot(1, 3, 3);
boxplot(X_minmax); title('min-max 归一化'); xlabel('特征'); ylabel('值');

%% ===== 3. 数据集划分 =====
fprintf('\n===== 3. 数据集划分 =====\n');

% cvpartition: 交叉验证划分
% Hold-out 划分 (70% 训练, 30% 测试)
cv_ho = cvpartition(Y, 'HoldOut', 0.3);
idx_train = training(cv_ho);
idx_test = test(cv_ho);

X_train = X_z(idx_train, :);
Y_train = Y(idx_train);
X_test = X_z(idx_test, :);
Y_test = Y(idx_test);

fprintf('Hold-out 划分:\n');
fprintf('  训练集: %d 样本\n', sum(idx_train));
fprintf('  测试集: %d 样本\n', sum(idx_test));

% K-Fold 交叉验证
K = 5;
cv_kfold = cvpartition(Y, 'KFold', K);
fprintf('\n%d-Fold 交叉验证:\n', K);
for i = 1:K
    fprintf('  Fold %d: 训练 %d, 测试 %d\n', ...
        i, length(training(cv_kfold, i)), length(test(cv_kfold, i)));
end

% 分层抽样保证类别比例
cv_strat = cvpartition(Y, 'HoldOut', 0.3);
fprintf('\n分层抽样 - 训练集类别分布:\n');
tabulate(Y(training(cv_strat)));
fprintf('分层抽样 - 测试集类别分布:\n');
tabulate(Y(test(cv_strat)));

%% ===== 4. 缺失值处理 =====
fprintf('\n===== 4. 缺失值处理 =====\n');

% 创建含缺失值的数据
X_missing = X_z;
missing_idx = randperm(n * size(X_z, 2), round(0.1 * n * size(X_z, 2)));
X_missing(missing_idx) = NaN;

fprintf('缺失值比例: %.1f%%\n', sum(isnan(X_missing(:))) / numel(X_missing) * 100);

% 方法1: 删除含缺失值的行
X_del_row = X_missing(~any(isnan(X_missing), 2), :);
fprintf('删除行后: %d 样本 (丢失 %d)\n', size(X_del_row, 1), n - size(X_del_row, 1));

% 方法2: 均值填充
X_mean_fill = X_missing;
for j = 1:size(X_missing, 2)
    col = X_missing(:, j);
    X_mean_fill(isnan(col), j) = mean(col, 'omitnan');
end
fprintf('均值填充后缺失值: %d\n', sum(isnan(X_mean_fill(:))));

% 方法3: 中位数填充
X_med_fill = X_missing;
for j = 1:size(X_missing, 2)
    col = X_missing(:, j);
    X_med_fill(isnan(col), j) = median(col, 'omitnan');
end
fprintf('中位数填充后缺失值: %d\n', sum(isnan(X_med_fill(:))));

%% ===== 5. 特征相关性分析 =====
fprintf('\n===== 5. 特征相关性分析 =====\n');

% 相关系数矩阵
corr_mat = corrcoef(X_z);

figure('Name', '特征相关性', 'Position', [300 300 600 500]);
subplot(1, 2, 1);
imagesc(corr_mat);
colorbar;
title('相关系数矩阵');
for i = 1:size(corr_mat, 1)
    for j = 1:size(corr_mat, 2)
        text(j, i, sprintf('%.2f', corr_mat(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 8);
    end
end
xlabel('特征'); ylabel('特征');

% 特征与类别的相关性
feature_labels = {'F1(x)', 'F2(y)', '噪声1', '噪声2', '噪声3', '冗余'};
class_corr = zeros(size(X_z, 2), 1);
for j = 1:size(X_z, 2)
    class_corr(j) = abs(corr(X_z(:,j), Y));
end

subplot(1, 2, 2);
barh(class_corr);
set(gca, 'YTick', 1:6, 'YTickLabel', feature_labels);
xlabel('|相关系数|');
title('特征与类别的相关性');
grid on;

fprintf('各特征与类别的相关性:\n');
for j = 1:length(feature_labels)
    fprintf('  %s: %.4f\n', feature_labels{j}, class_corr(j));
end

fprintf('\n===== 数据预处理模块完成! =====\n');
