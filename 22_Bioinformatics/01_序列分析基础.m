%% ========================================================================
%  生物信息学基础 - Bioinformatics Basics
%  本脚本演示生物信息学的核心概念和MATLAB实现
%  内容包括：序列分析、基因表达、系统发育树、生物网络
%  ========================================================================
clear; clc; close all;

%% === 1. DNA序列分析基础 ===
% DNA序列由A、T、G、C四种碱基组成
fprintf('=== 1. DNA序列分析 ===\n');

% 生成随机DNA序列
rng(42);
bases = 'ATGC';
seq_length = 100;
dna_seq = bases(randi(4, 1, seq_length));
fprintf('随机DNA序列 (长度%d):\n%s\n\n', seq_length, dna_seq);

% 碱基组成统计
base_count = [sum(dna_seq=='A'), sum(dna_seq=='T'), ...
              sum(dna_seq=='G'), sum(dna_seq=='C')];
fprintf('碱基组成: A=%d, T=%d, G=%d, C=%d\n', base_count);
fprintf('GC含量: %.2f%%\n', (base_count(3)+base_count(4))/seq_length*100);

% 碱基频率可视化
figure('Name', 'DNA序列分析', 'Position', [100 100 1200 400]);
subplot(1,3,1);
bar(base_count);
set(gca, 'XTickLabel', {'A','T','G','C'});
title('碱基计数');
ylabel('数量');

subplot(1,3,2);
pie(base_count);
title('碱基组成比例');

% 密码子分析 (每3个碱基为一组)
codons = reshape(dna_seq(1:99), 3, [])';
unique_codons = unique(codons);
fprintf('不同密码子数量: %d\n', length(unique_codons));

subplot(1,3,3);
histogram(categorical(codons), 'DisplayOrder', unique_codons(1:min(10,end)));
title('密码子频率 (前10)');
xlabel('密码子');

%% === 2. 序列比对 - Needleman-Wunsch算法 ===
fprintf('\n=== 2. 序列比对 ===\n');

% 简单全局比对实现
seq1 = 'ACGTAC';
seq2 = 'ACGTC';
fprintf('序列1: %s\n', seq1);
fprintf('序列2: %s\n', seq2);

% 比对参数
match_score = 2;
mismatch_score = -1;
gap_penalty = -2;

% 动态规划矩阵
m = length(seq1);
n = length(seq2);
F = zeros(m+1, n+1);

% 初始化
for i = 0:m
    F(i+1, 1) = i * gap_penalty;
end
for j = 0:n
    F(1, j+1) = j * gap_penalty;
end

% 填充矩阵
for i = 1:m
    for j = 1:n
        if seq1(i) == seq2(j)
            score = match_score;
        else
            score = mismatch_score;
        end
        F(i+1, j+1) = max([F(i,j) + score, ...
                          F(i+1,j) + gap_penalty, ...
                          F(i,j+1) + gap_penalty]);
    end
end

% 回溯获得比对结果
aligned1 = '';
aligned2 = '';
i = m; j = n;
while i > 0 || j > 0
    if i > 0 && j > 0
        if seq1(i) == seq2(j)
            score = match_score;
        else
            score = mismatch_score;
        end
        if F(i+1,j+1) == F(i,j) + score
            aligned1 = [seq1(i), aligned1];
            aligned2 = [seq2(j), aligned2];
            i = i - 1;
            j = j - 1;
            continue;
        end
    end
    if i > 0 && F(i+1,j+1) == F(i,j+1) + gap_penalty
        aligned1 = [seq1(i), aligned1];
        aligned2 = ['-', aligned2];
        i = i - 1;
    else
        aligned1 = ['-', aligned1];
        aligned2 = [seq2(j), aligned2];
        j = j - 1;
    end
end

fprintf('比对结果:\n%s\n%s\n', aligned1, aligned2);
fprintf('比对得分: %d\n', F(m+1, n+1));

% 可视化得分矩阵
figure('Name', '序列比对得分矩阵');
imagesc(F);
colorbar;
title('Needleman-Wunsch得分矩阵');
xlabel('序列2');
ylabel('序列1');

%% === 3. 基因表达分析 ===
fprintf('\n=== 3. 基因表达分析 ===\n');

% 模拟微阵列数据：10个基因在5个样本中的表达
num_genes = 10;
num_samples = 5;
gene_names = {'TP53','BRCA1','EGFR','MYC','KRAS',...
              'PTEN','RB1','APC','VHL','CDH1'};

% 生成模拟表达数据 (对数正态分布)
rng(123);
expression_data = lognrnd(2, 0.5, num_genes, num_samples);

fprintf('基因表达矩阵 (%d基因 x %d样本):\n', num_genes, num_samples);
disp(array2table(expression_data, ...
    'RowNames', gene_names, ...
    'VariableNames', {'S1','S2','S3','S4','S5'}));

% 热图可视化
figure('Name', '基因表达热图', 'Position', [100 100 800 600]);
subplot(2,2,1);
imagesc(expression_data);
colorbar;
set(gca, 'YTick', 1:num_genes, 'YTickLabel', gene_names);
title('基因表达热图');
xlabel('样本');
ylabel('基因');

% 标准化 (Z-score)
expr_normalized = zscore(expression_data')';
subplot(2,2,2);
imagesc(expr_normalized);
colorbar;
set(gca, 'YTick', 1:num_genes, 'YTickLabel', gene_names);
title('Z-score标准化');
xlabel('样本');

% 差异表达分析 (简单t检验)
group1 = expression_data(:, 1:3);  % 对照组
group2 = expression_data(:, 4:5);  % 实验组
pvalues = zeros(num_genes, 1);
for g = 1:num_genes
    [~, pvalues(g)] = ttest2(group1(g,:), group2(g,:));
end

subplot(2,2,3);
bar(-log10(pvalues));
set(gca, 'XTick', 1:num_genes, 'XTickLabel', gene_names, 'XTickLabelRotation', 45);
yline(-log10(0.05), 'r--', 'p=0.05');
title('差异表达分析 (-log10 p值)');
ylabel('-log10(p-value)');

% PCA降维
[coeff, score, latent] = pca(expression_data');
subplot(2,2,4);
scatter(score(:,1), score(:,2), 'filled');
text(score(:,1)+0.1, score(:,2), {'S1','S2','S3','S4','S5'});
xlabel('PC1');
ylabel('PC2');
title('PCA分析');

%% === 4. 系统发育树 ===
fprintf('\n=== 4. 系统发育树 ===\n');

% 模拟物种间遗传距离矩阵
species = {'Human','Chimp','Gorilla','Orangutan','Gibbon','Macaque'};
num_species = length(species);

% 构建距离矩阵 (对称)
dist_matrix = [
    0.00  0.02  0.04  0.06  0.08  0.12;
    0.02  0.00  0.03  0.05  0.07  0.11;
    0.04  0.03  0.00  0.04  0.06  0.10;
    0.06  0.05  0.04  0.00  0.05  0.09;
    0.08  0.07  0.06  0.05  0.00  0.08;
    0.12  0.11  0.10  0.09  0.08  0.00
];

fprintf('物种间遗传距离矩阵:\n');
disp(array2table(dist_matrix, 'RowNames', species, 'VariableNames', species));

% 简单UPGMA聚类
figure('Name', '系统发育树');
subplot(1,2,1);
Z = linkage(squareform(dist_matrix), 'average');
dendrogram(Z, 0, 'Labels', species);
title('UPGMA系统发育树');
xlabel('物种');
ylabel('遗传距离');

% 邻接法
subplot(1,2,2);
Z2 = linkage(squareform(dist_matrix), 'single');
dendrogram(Z2, 0, 'Labels', species);
title('邻接法系统发育树');

%% === 5. 生物网络分析 ===
fprintf('\n=== 5. 生物网络分析 ===\n');

% 蛋白质相互作用网络
num_proteins = 15;
protein_names = {'P1','P2','P3','P4','P5','P6','P7','P8',...
                 'P9','P10','P11','P12','P13','P14','P15'};

% 随机生成邻接矩阵
rng(456);
adj_matrix = rand(num_proteins) > 0.7;
adj_matrix = triu(adj_matrix, 1);
adj_matrix = adj_matrix | adj_matrix';

fprintf('蛋白质相互作用网络:\n');
fprintf('节点数: %d\n', num_proteins);
fprintf('边数: %d\n', sum(adj_matrix(:))/2);

% 计算节点度
node_degree = sum(adj_matrix, 2);
fprintf('平均度: %.2f\n', mean(node_degree));
fprintf('Hub蛋白 (度>5): %s\n', strjoin(protein_names(node_degree > 5)));

% 网络可视化
figure('Name', '蛋白质相互作用网络');
G = graph(adj_matrix, 'upper');
p = plot(G, 'Layout', 'force');
highlight(p, find(node_degree > 5), 'NodeColor', 'r', 'NodeLineWidth', 2);
title('蛋白质相互作用网络 (红色=Hub蛋白)');

%% === 总结 ===
fprintf('\n=== 生物信息学总结 ===\n');
fprintf('1. DNA序列分析: 碱基组成、GC含量、密码子使用\n');
fprintf('2. 序列比对: Needleman-Wunsch动态规划算法\n');
fprintf('3. 基因表达: 微阵列数据分析、差异表达、PCA\n');
fprintf('4. 系统发育: 距离矩阵、UPGMA聚类、进化树\n');
fprintf('5. 生物网络: 蛋白质互作、Hub识别、图论分析\n');
fprintf('\n推荐工具箱: Bioinformatics Toolbox\n');
