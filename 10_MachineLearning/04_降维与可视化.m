%% 04_降维与可视化.m — PCA 与数据可视化
%  涵盖: pca, 散点图矩阵, t-SNE (若可用)
%  需要 Statistics and Machine Learning Toolbox

clear; clc; close all;

%% ===== 1. 生成高维数据 =====
fprintf('===== 1. 生成高维数据 =====\n');

rng(42);
n = 200;
p = 6;  % 6维特征

% 三类数据，在高维空间中
mu1 = [3, 2, 1, 0.5, -1, 2];
mu2 = [-2, 1, 3, -1, 2, 0];
mu3 = [0, -2, -1, 3, 1, -2];

X1 = randn(n/3, p) * 0.8 + repmat(mu1, n/3, 1);
X2 = randn(n/3, p) * 0.9 + repmat(mu2, n/3, 1);
X3 = randn(n/3, p) * 0.7 + repmat(mu3, n/3, 1);

X = [X1; X2; X3];
labels = [ones(n/3,1); 2*ones(n/3,1); 3*ones(n/3,1)];
feature_names = {'F1', 'F2', 'F3', 'F4', 'F5', 'F6'};

fprintf('数据: %d 样本, %d 特征, %d 类\n', size(X,1), size(X,2), 3);

%% ===== 2. PCA 主成分分析 =====
fprintf('\n===== 2. PCA 主成分分析 =====\n');

% pca 函数
[coeff, score, latent, tsquared, explained] = pca(X);

fprintf('各主成分方差解释率:\n');
for i = 1:length(explained)
    fprintf('  PC%d: %.2f%%\n', i, explained(i));
end
fprintf('前2个主成分累计: %.2f%%\n', sum(explained(1:2)));
fprintf('前3个主成分累计: %.2f%%\n', sum(explained(1:3)));

% 碎石图 (Scree Plot)
figure('Name', 'PCA 碎石图', 'Position', [100 100 600 400]);
subplot(1, 2, 1);
bar(1:p, explained, 'FaceColor', [0.3 0.6 0.9]);
xlabel('主成分'); ylabel('方差解释率 (%)');
title('碎石图 (Scree Plot)');
grid on;

subplot(1, 2, 2);
plot(1:p, cumsum(explained), 'ro-', 'LineWidth', 2, 'MarkerSize', 10);
yline(80, 'k--', '80%');
yline(90, 'k--', '90%');
xlabel('主成分数'); ylabel('累计方差解释率 (%)');
title('累计方差解释率');
grid on;

%% ===== 3. PCA 二维/三维投影 =====
fprintf('\n===== 3. PCA 降维投影 =====\n');

% 二维投影
X_pca2 = score(:, 1:2);

figure('Name', 'PCA 二维投影', 'Position', [200 200 600 500]);
gscatter(X_pca2(:,1), X_pca2(:,2), labels, 'rgb', 'o', 8);
xlabel(sprintf('PC1 (%.1f%%)', explained(1)));
ylabel(sprintf('PC2 (%.1f%%)', explained(2)));
title(sprintf('PCA 二维投影 (累计 %.1f%%)', sum(explained(1:2))));
grid on;

% 三维投影
figure('Name', 'PCA 三维投影', 'Position', [300 300 600 500]);
X_pca3 = score(:, 1:3);
scatter3(X_pca3(:,1), X_pca3(:,2), X_pca3(:,3), ...
    30, labels, 'filled');
colormap([1 0 0; 0 0.8 0; 0 0 1]);
xlabel(sprintf('PC1 (%.1f%%)', explained(1)));
ylabel(sprintf('PC2 (%.1f%%)', explained(2)));
zlabel(sprintf('PC3 (%.1f%%)', explained(3)));
title('PCA 三维投影');
grid on;

%% ===== 4. 载荷分析 (Loadings) =====
fprintf('\n===== 4. PCA 载荷分析 =====\n');

% 载荷图: 显示原始特征在主成分空间中的方向
figure('Name', 'PCA 载荷图', 'Position', [100 100 600 500]);

loadings = coeff(:, 1:2);

hold on;
% 画单位圆
theta = linspace(0, 2*pi, 100);
plot(cos(theta), sin(theta), 'k--', 'LineWidth', 0.5);

for i = 1:p
    % 画箭头
    quiver(0, 0, loadings(i,1), loadings(i,2), 0, 'Color', [0.2 0.2 0.8], ...
        'LineWidth', 1.5, 'MaxHeadSize', 0.5);
    % 标注特征名
    text(loadings(i,1)*1.15, loadings(i,2)*1.15, feature_names{i}, ...
        'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', 'r');
end

xlabel(sprintf('PC1 (%.1f%%)', explained(1)));
ylabel(sprintf('PC2 (%.1f%%)', explained(2)));
title('PCA 载荷图 (特征在主成分空间的投影)');
axis equal;
grid on;
hold off;

fprintf('载荷矩阵 (前2个主成分):\n');
fprintf('       PC1      PC2\n');
for i = 1:p
    fprintf('  %s  %7.4f  %7.4f\n', feature_names{i}, coeff(i,1), coeff(i,2));
end

%% ===== 5. 散点图矩阵 =====
fprintf('\n===== 5. 散点图矩阵 =====\n');

% gplotmatrix: 散点图矩阵
figure('Name', '散点图矩阵', 'Position', [200 200 800 700]);
gplotmatrix(X, [], labels, 'rgb', '.', 8);
title('散点图矩阵 (按类别着色)');

%% ===== 6. t-SNE 降维 (若可用) =====
fprintf('\n===== 6. t-SNE 降维 =====\n');

try
    % tsne: t-分布随机邻域嵌入
    X_tsne = tsne(X, 'NumDimensions', 2, 'Perplexity', 30, ...
        'Standardize', true);
    
    figure('Name', 't-SNE 降维', 'Position', [300 300 600 500]);
    gscatter(X_tsne(:,1), X_tsne(:,2), labels, 'rgb', 'o', 8);
    title('t-SNE 二维嵌入');
    xlabel('t-SNE 维度 1'); ylabel('t-SNE 维度 2');
    grid on;
    
    % 不同 Perplexity 的影响
    figure('Name', 't-SNE 参数影响', 'Position', [100 100 900 300]);
    perplexities = [5, 30, 100];
    for pp = 1:3
        X_ts = tsne(X, 'NumDimensions', 2, 'Perplexity', perplexities(pp), ...
            'Standardize', true);
        subplot(1, 3, pp);
        gscatter(X_ts(:,1), X_ts(:,2), labels, 'rgb', 'o', 6);
        title(sprintf('Perplexity = %d', perplexities(pp)));
        grid on;
    end
    
    fprintf('t-SNE: Perplexity 影响聚类效果\n');
    fprintf('小值 -> 局部结构; 大值 -> 全局结构\n');
    
catch ME
    fprintf('tsne 不可用: %s\n', ME.message);
    fprintf('t-SNE 需要较新版本的 MATLAB\n');
end

%% ===== 7. PCA vs t-SNE 对比 =====
fprintf('\n===== 7. 降维方法对比 =====\n');

try
    figure('Name', 'PCA vs t-SNE', 'Position', [200 200 800 400]);
    
    subplot(1, 2, 1);
    gscatter(score(:,1), score(:,2), labels, 'rgb', 'o', 6);
    title('PCA 投影');
    xlabel('PC1'); ylabel('PC2');
    grid on;
    
    subplot(1, 2, 2);
    gscatter(X_tsne(:,1), X_tsne(:,2), labels, 'rgb', 'o', 6);
    title('t-SNE 投影');
    xlabel('t-SNE1'); ylabel('t-SNE2');
    grid on;
    
    fprintf('PCA: 线性降维，保留全局结构\n');
    fprintf('t-SNE: 非线性降维，保留局部结构，适合可视化\n');
catch
    fprintf('跳过对比 (t-SNE 不可用)\n');
end

fprintf('\n===== 降维与可视化模块完成! =====\n');
