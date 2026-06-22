%% ========================================================================
%  基因表达分析 - Gene Expression Analysis
%  本脚本演示基因表达数据分析的完整流程
%  内容包括：数据预处理、差异表达、聚类分析、通路富集
%  ========================================================================
clear; clc; close all;

%% === 1. 模拟基因表达数据集 ===
fprintf('=== 1. 基因表达数据集 ===\n');

rng(42);
num_genes = 500;
num_samples = 20;

% 定义样本分组
group_labels = [ones(1,10), 2*ones(1,10)];  % 1=正常, 2=肿瘤
sample_names = sprintfc('Sample_%d', 1:num_samples);

% 模拟表达数据: 大部分基因无差异, 部分差异表达
expression = lognrnd(3, 0.8, num_genes, num_samples);

% 注入差异表达基因 (前50个上调, 51-80下调)
for g = 1:50
    expression(g, 11:20) = expression(g, 11:20) * 3;  % 上调3倍
end
for g = 51:80
    expression(g, 11:20) = expression(g, 11:20) * 0.3;  % 下调70%
end

gene_names = sprintfc('Gene_%03d', 1:num_genes);
fprintf('数据集: %d个基因 x %d个样本\n', num_genes, num_samples);
fprintf('正常样本: %d, 肿瘤样本: %d\n', sum(group_labels==1), sum(group_labels==2));

%% === 2. 数据预处理与质量控制 ===
fprintf('\n=== 2. 数据预处理 ===\n');

% 对数变换 (log2)
expr_log2 = log2(expression + 1);
fprintf('Log2变换完成\n');

% 箱线图显示样本分布
figure('Name', '数据质量控制', 'Position', [100 100 1000 400]);
subplot(1,2,1);
boxplot(expr_log2, 'Labels', sample_names);
title('Log2表达值分布 (变换后)');
xlabel('样本');
ylabel('Log2(Expression+1)');
xtickangle(45);

% 标准化 (分位数标准化)
expr_norm = quantilenorm(expr_log2');
expr_norm = expr_norm';
fprintf('分位数标准化完成\n');

subplot(1,2,2);
boxplot(expr_norm, 'Labels', sample_names);
title('标准化后分布');
xlabel('样本');
xtickangle(45);

%% === 3. 差异表达分析 ===
fprintf('\n=== 3. 差异表达分析 ===\n');

normal = expr_norm(:, group_labels==1);
tumor = expr_norm(:, group_labels==2);

% t检验 + 多重检验校正
pvalues = zeros(num_genes, 1);
log2fc = zeros(num_genes, 1);
for g = 1:num_genes
    log2fc(g) = mean(tumor(g,:)) - mean(normal(g,:));
    [~, pvalues(g)] = ttest2(normal(g,:), tumor(g,:));
end

% Benjamini-Hochberg FDR校正
[~, sortidx] = sort(pvalues);
sorted_p = pvalues(sortidx);
n = length(pvalues);
fdr = zeros(n, 1);
for i = 1:n
    fdr(i) = min(sorted_p(i) * n / i, 1);
end
for i = n-1:-1:1
    fdr(i) = min(fdr(i), fdr(i+1));
end
adj_pvalues = zeros(n, 1);
adj_pvalues(sortidx) = fdr;

% 统计显著基因
sig_genes = adj_pvalues < 0.05 & abs(log2fc) > 1;
fprintf('显著差异表达基因 (FDR<0.05, |log2FC|>1): %d\n', sum(sig_genes));
fprintf('  上调: %d\n', sum(sig_genes & log2fc > 0));
fprintf('  下调: %d\n', sum(sig_genes & log2fc < 0));

% 火山图
figure('Name', '火山图');
scatter(log2fc(~sig_genes), -log10(adj_pvalues(~sig_genes)), 15, [0.7 0.7 0.7], 'filled');
hold on;
scatter(log2fc(sig_genes & log2fc>0), -log10(adj_pvalues(sig_genes & log2fc>0)), 20, 'r', 'filled');
scatter(log2fc(sig_genes & log2fc<0), -log10(adj_pvalues(sig_genes & log2fc<0)), 20, 'b', 'filled');
xline(1, 'k--'); xline(-1, 'k--');
yline(-log10(0.05), 'k--');
xlabel('Log2 Fold Change');
ylabel('-Log10(Adjusted P-value)');
title('火山图');
legend('不显著', '上调', '下调', 'Location', 'best');

%% === 4. 聚类分析 ===
fprintf('\n=== 4. 聚类分析 ===\n');

% 选择变异最大的前100个基因
gene_var = var(expr_norm, 0, 2);
[~, var_idx] = sort(gene_var, 'descend');
top_genes = var_idx(1:100);

% 层次聚类 - 样本
figure('Name', '层次聚类', 'Position', [100 100 1200 500]);
subplot(1,2,1);
Z_samples = linkage(pdist(expr_norm(top_genes,:)'), 'ward');
dendrogram(Z_samples, 0, 'Labels', sample_names);
title('样本聚类树状图');
ylabel('距离');

% 热图
subplot(1,2,2);
imagesc(expr_norm(top_genes, :));
title('Top 100变异基因热图');
ylabel('基因');
xlabel('样本');

% K-means聚类基因
fprintf('\nK-means聚类 (k=4):\n');
[idx, centers] = kmeans(expr_norm(top_genes,:)', 4, 'Replicates', 10);
for k = 1:4
    fprintf('  簇 %d: %d 个样本\n', k, sum(idx==k));
end

% 基因聚类
figure('Name', '基因聚类');
Z_genes = linkage(pdist(expr_norm(top_genes,:)), 'ward');
dendrogram(Z_genes, 0, 'Labels', gene_names(top_genes));
title('基因聚类树状图 (Top 100)');
xlabel('基因');

%% === 5. 通路富集分析 (模拟) ===
fprintf('\n=== 5. 通路富集分析 ===\n');

% 模拟通路数据库
pathways = {'Cell Cycle','p53 Signaling','Apoptosis','Wnt Signaling',...
            'MAPK','PI3K-Akt','NF-kappaB','TGF-beta','VEGF','JAK-STAT'};
pathway_sizes = [80, 45, 60, 55, 90, 70, 50, 40, 35, 65];

% 超几何检验 (模拟)
fprintf('通路富集分析结果:\n');
fprintf('%-20s %8s %8s %10s\n', '通路名称', '通路大小', '命中数', 'p值');
fprintf('%s\n', repmat('-', 1, 50));

enrich_pvals = zeros(length(pathways), 1);
for i = 1:length(pathways)
    hits = randi([2, 20]);
    % 超几何分布 p值
    enrich_pvals(i) = 1 - hygecdf(hits-1, num_genes, pathway_sizes(i), ...
                                   sum(sig_genes));
    fprintf('%-20s %8d %8d %10.4f\n', pathways{i}, pathway_sizes(i), ...
            hits, enrich_pvals(i));
end

% 富集柱状图
figure('Name', '通路富集分析');
barh(-log10(enrich_pvals));
set(gca, 'YTick', 1:length(pathways), 'YTickLabel', pathways);
xline(-log10(0.05), 'r--', 'p=0.05');
xlabel('-Log10(P-value)');
title('通路富集分析');

%% === 总结 ===
fprintf('\n=== 基因表达分析总结 ===\n');
fprintf('1. 数据预处理: Log2变换、分位数标准化\n');
fprintf('2. 差异表达: t检验 + BH-FDR校正、火山图\n');
fprintf('3. 聚类分析: 层次聚类、K-means、热图\n');
fprintf('4. 通路富集: 超几何检验、生物学解释\n');
