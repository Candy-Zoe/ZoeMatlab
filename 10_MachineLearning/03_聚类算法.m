%% 03_聚类算法.m — 无监督学习聚类
%  涵盖: kmeans, linkage/dendrogram, silhouette, evalclusters
%  需要 Statistics and Machine Learning Toolbox

clear; clc; close all;

%% ===== 1. 生成聚类数据 =====
fprintf('===== 1. 生成聚类数据 =====\n');

rng(42);
n = 300;

% 生成有簇结构的数据
X1 = randn(n/3, 2) * 0.8 + [3, 3];
X2 = randn(n/3, 2) * 1.0 + [-2, 1];
X3 = randn(n/3, 2) * 0.6 + [0, -3];
X = [X1; X2; X3];

% 真实标签 (用于评估)
true_labels = [ones(n/3,1); 2*ones(n/3,1); 3*ones(n/3,1)];

figure('Name', '原始数据', 'Position', [100 100 500 400]);
scatter(X(:,1), X(:,2), 15, [0.5 0.5 0.5], 'filled');
title('待聚类数据 (300 样本)');
xlabel('特征 1'); ylabel('特征 2');
grid on;

fprintf('数据: %d 样本, %d 特征, 真实 %d 簇\n', size(X,1), size(X,2), 3);

%% ===== 2. K-Means 聚类 =====
fprintf('\n===== 2. K-Means 聚类 =====\n');

% K-Means (K=3)
K = 3;
[idx_km, centers] = kmeans(X, K, 'Replicates', 10, 'Display', 'final');

figure('Name', 'K-Means 聚类结果', 'Position', [200 200 600 400]);
colors = [1 0 0; 0 0.8 0; 0 0 1];
hold on;
for k = 1:K
    mask = (idx_km == k);
    scatter(X(mask,1), X(mask,2), 15, colors(k,:), 'filled');
    plot(centers(k,1), centers(k,2), 'kx', 'MarkerSize', 15, 'LineWidth', 3);
end
hold off;
title(sprintf('K-Means 聚类 (K=%d)', K));
xlabel('特征 1'); ylabel('特征 2');
legend('簇1', '', '簇2', '', '簇3', '', '中心', 'Location', 'best');
grid on;

% 不同 K 值的 Within-cluster Sum of Squares (WSS)
K_range = 1:10;
WSS = zeros(size(K_range));
for i = 1:length(K_range)
    [~, ~, sumd] = kmeans(X, K_range(i), 'Replicates', 5, 'Display', 'off');
    WSS(i) = sum(sumd);
end

figure('Name', '肘部法则', 'Position', [300 300 500 400]);
plot(K_range, WSS, 'bo-', 'LineWidth', 2, 'MarkerSize', 10);
xlabel('K 值'); ylabel('簇内平方和 (WSS)');
title('肘部法则 (Elbow Method)');
grid on;
% 标记最优 K
hold on;
plot(3, WSS(3), 'r*', 'MarkerSize', 20);
text(3.2, WSS(3), '最优 K=3', 'FontSize', 12, 'Color', 'r');
hold off;

fprintf('K-Means 各簇样本数:\n');
for k = 1:K
    fprintf('  簇 %d: %d 样本\n', k, sum(idx_km == k));
end

%% ===== 3. 层次聚类 =====
fprintf('\n===== 3. 层次聚类 =====\n');

% 使用子集进行层次聚类（大数据集很慢）
n_sub = min(100, size(X, 1));
idx_sub = randsample(size(X, 1), n_sub);
X_sub = X(idx_sub, :);
true_sub = true_labels(idx_sub);

% 计算距离矩阵并聚类
Y_dist = pdist(X_sub);
Z = linkage(Y_dist, 'ward');  % Ward 链接法

figure('Name', '层次聚类树状图', 'Position', [100 100 800 500]);
dendrogram(Z, 15);  % 显示15个叶节点
title('层次聚类树状图 (Ward 链接)');
xlabel('样本'); ylabel('距离');

% 从树状图截取 3 簇
T = cluster(Z, 'maxclust', 3);

figure('Name', '层次聚类结果', 'Position', [200 200 500 400]);
gscatter(X_sub(:,1), X_sub(:,2), T, 'rgb', 'o', 6);
title('层次聚类结果 (K=3)');
xlabel('特征 1'); ylabel('特征 2');
grid on;

fprintf('不同链接方法比较:\n');
methods = {'single', 'complete', 'average', 'ward'};
for m = 1:length(methods)
    Zm = linkage(Y_dist, methods{m});
    Tm = cluster(Zm, 'maxclust', 3);
    fprintf('  %s 链接: 簇大小 = [%d, %d, %d]\n', ...
        methods{m}, sum(Tm==1), sum(Tm==2), sum(Tm==3));
end

%% ===== 4. 轮廓分析 =====
fprintf('\n===== 4. 轮廓分析 (Silhouette) =====\n');

% 计算轮廓值
sil_vals = silhouette(X, idx_km);
avg_sil = mean(sil_vals);
fprintf('K=3 平均轮廓值: %.4f\n', avg_sil);

figure('Name', '轮廓图', 'Position', [300 300 600 500]);
silhouette(X, idx_km);
title(sprintf('轮廓图 (平均轮廓值 = %.3f)', avg_sil));

% 不同 K 值的平均轮廓值
K_range_sil = 2:8;
avg_sils = zeros(size(K_range_sil));
for i = 1:length(K_range_sil)
    [idx_k, ~] = kmeans(X, K_range_sil(i), 'Replicates', 5, 'Display', 'off');
    s = silhouette(X, idx_k);
    avg_sils(i) = mean(s);
    fprintf('K=%d: 平均轮廓值 = %.4f\n', K_range_sil(i), avg_sils(i));
end

figure('Name', '轮廓值 vs K', 'Position', [100 100 500 400]);
plot(K_range_sil, avg_sils, 'ro-', 'LineWidth', 2, 'MarkerSize', 10);
xlabel('K 值'); ylabel('平均轮廓值');
title('轮廓值分析选择最优 K');
grid on;
[best_sil, best_k_idx] = max(avg_sils);
hold on;
plot(K_range_sil(best_k_idx), best_sil, 'b*', 'MarkerSize', 20);
text(K_range_sil(best_k_idx)+0.2, best_sil, sprintf('最优 K=%d', K_range_sil(best_k_idx)));
hold off;

%% ===== 5. 聚类评估 (evalclusters) =====
fprintf('\n===== 5. evalclusters 自动评估 =====\n');

try
    % 使用 Calinski-Harabasz 准则
    eva = evalclusters(X, 'kmeans', 'CalinskiHarabasz', 'KList', 2:8);
    
    fprintf('Calinski-Harabasz 最优 K: %d\n', eva.OptimalK);
    
    figure('Name', '聚类评估', 'Position', [200 200 600 400]);
    plot(eva);
    title('聚类数评估 (Calinski-Harabasz 准则)');
    
    % Gap 准则
    eva_gap = evalclusters(X, 'kmeans', 'gap', 'KList', 2:6);
    fprintf('Gap 准则最优 K: %d\n', eva_gap.OptimalK);
    
catch ME
    fprintf('evalclusters 不可用: %s\n', ME.message);
    fprintf('跳过自动评估，使用肘部法则和轮廓分析结果\n');
end

%% ===== 6. 聚类结果对比 =====
fprintf('\n===== 6. 聚类结果与真实标签对比 =====\n');

% 调整标签顺序使匹配最优
% 简单方法: 尝试所有排列
from_labels = idx_km;
to_labels = true_labels;
perms_mat = perms(1:3);
best_acc = 0;
best_perm = perms_mat(1,:);
for p = 1:size(perms_mat, 1)
    mapped = zeros(size(from_labels));
    for k = 1:3
        mapped(from_labels == k) = perms_mat(p, k);
    end
    acc = sum(mapped == to_labels) / length(to_labels);
    if acc > best_acc
        best_acc = acc;
        best_perm = perms_mat(p,:);
    end
end
mapped_labels = zeros(size(from_labels));
for k = 1:3
    mapped_labels(from_labels == k) = best_perm(k);
end

fprintf('聚类纯度 (最佳匹配准确率): %.1f%%\n', best_acc * 100);

figure('Name', '聚类 vs 真实标签', 'Position', [300 300 900 400]);
subplot(1, 2, 1);
gscatter(X(:,1), X(:,2), true_labels, 'rgb', 'o', 6);
title('真实标签');
xlabel('特征 1'); ylabel('特征 2');
grid on;

subplot(1, 2, 2);
gscatter(X(:,1), X(:,2), mapped_labels, 'rgb', 'o', 6);
title(sprintf('K-Means 结果 (准确率 %.1f%%)', best_acc*100));
xlabel('特征 1'); ylabel('特征 2');
grid on;

fprintf('\n===== 聚类算法模块完成! =====\n');
