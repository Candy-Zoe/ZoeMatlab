%% ========================================================================
%  系统发育与进化分析 - Phylogenetics & Evolutionary Analysis
%  本脚本演示系统发育树构建和进化分析方法
%  内容包括：距离法、最大简约法、进化速率、分子钟
%  ========================================================================
clear; clc; close all;

%% === 1. 多序列比对 ===
fprintf('=== 1. 多序列比对 ===\n');

% 模拟5个物种的同源基因序列
sequences = {
    'ATGCGTACGTAGCTAGCTAGCTAGCTAG';  % Human
    'ATGCGTACGTAGCTAGCTAGCTAGCTGG';  % Chimp
    'ATGCGTACATAGCTAGCTAGCTAGCTAG';  % Gorilla
    'ATGAGTACGTAGCTGGCTAGCTAGCTAG';  % Orangutan
    'ATGAGTACATAGCTAGCTAGCTAGCTGG';  % Macaque
};
species = {'Human','Chimp','Gorilla','Orangutan','Macaque'};
seq_len = length(sequences{1});

fprintf('物种数: %d, 序列长度: %d\n', length(species), seq_len);
fprintf('序列矩阵:\n');
for i = 1:length(species)
    fprintf('%12s: %s\n', species{i}, sequences{i});
end

% 计算成对Hamming距离
num_sp = length(species);
dist_mat = zeros(num_sp);
for i = 1:num_sp
    for j = i+1:num_sp
        d = sum(sequences{i} ~= sequences{j}) / seq_len;
        dist_mat(i,j) = d;
        dist_mat(j,i) = d;
    end
end

fprintf('\n成对遗传距离矩阵:\n');
disp(array2table(dist_mat, 'RowNames', species, 'VariableNames', species));

%% === 2. 系统发育树构建方法 ===
fprintf('\n=== 2. 系统发育树构建 ===\n');

% 使用MATLAB内置方法构建树
Z = linkage(squareform(dist_mat), 'average');

figure('Name', '系统发育树比较', 'Position', [100 100 1200 500]);

% UPGMA树
subplot(2,2,1);
dendrogram(Z, 0, 'Labels', species, 'Orientation', 'left');
title('UPGMA树 (平均链接)');
xlabel('遗传距离');

% 单链接
subplot(2,2,2);
Z_single = linkage(squareform(dist_mat), 'single');
dendrogram(Z_single, 0, 'Labels', species, 'Orientation', 'left');
title('单链接法');
xlabel('遗传距离');

% 完全链接
subplot(2,2,3);
Z_complete = linkage(squareform(dist_mat), 'complete');
dendrogram(Z_complete, 0, 'Labels', species, 'Orientation', 'left');
title('完全链接法');
xlabel('遗传距离');

% Ward方法
subplot(2,2,4);
Z_ward = linkage(squareform(dist_mat), 'ward');
dendrogram(Z_ward, 0, 'Labels', species, 'Orientation', 'left');
title('Ward方法');
xlabel('遗传距离');

%% === 3. 进化速率分析 ===
fprintf('\n=== 3. 进化速率分析 ===\n');

% 模拟不同基因的进化速率 (替换/位点/百万年)
gene_categories = {'18S rRNA', 'Cytochrome b', 'Hemoglobin', 'Fibrinopeptide'};
% 典型进化速率
rates = [0.001, 0.01, 0.1, 1.0];  % 替换/位点/百万年

% 模拟分子钟
time_mya = 0:1:500;  % 百万年前

figure('Name', '分子钟分析', 'Position', [100 100 1000 600]);
subplot(2,2,1);
for i = 1:length(gene_categories)
    divergence = 2 * rates(i) * time_mya;  % 两条谱系
    divergence = min(divergence, 0.75);      % 饱和效应
    plot(time_mya, divergence, 'LineWidth', 2);
    hold on;
end
legend(gene_categories, 'Location', 'northwest');
xlabel('时间 (百万年前)');
ylabel('序列分歧度');
title('分子钟模型');

% Kimura 2参数模型 (K2P)
fprintf('\nKimura 2参数距离校正:\n');
P = [0.01, 0.05, 0.10, 0.20, 0.30];  % 转换差异比例
Q = [0.005, 0.02, 0.05, 0.10, 0.15]; % 颠换差异比例
d_k2p = -0.5 * log(1 - 2*P - Q) - 0.25 * log(1 - 2*Q);
d_raw = P + Q;

fprintf('%10s %10s %10s\n', 'P(转换)', 'Q(颠换)', 'K2P距离');
for i = 1:length(P)
    fprintf('%10.3f %10.3f %10.4f\n', P(i), Q(i), d_k2p(i));
end

subplot(2,2,2);
scatter(d_raw, d_k2p, 50, 'filled');
hold on;
plot([0 max(d_raw)], [0 max(d_raw)], 'k--');
xlabel('观测距离 (p-distance)');
ylabel('K2P校正距离');
title('距离校正比较');

% 位点变异率
subplot(2,2,3);
site_rates = gamrnd(0.5, 2, 1, seq_len);  % Gamma分布的位点速率
bar(site_rates);
xlabel('位点');
ylabel('相对进化速率');
title('位点间速率变异 (Gamma分布)');

% 密码子位置分析
subplot(2,2,4);
pos_rates = [0.05, 0.15, 0.80];  % 第1,2,3密码子位
bar(pos_rates);
set(gca, 'XTickLabel', {'位置1','位置2','位置3'});
ylabel('相对进化速率');
title('密码子位置进化速率');

%% === 4. Bootstrap检验 ===
fprintf('\n=== 4. Bootstrap检验 ===\n');

% 模拟Bootstrap重采样
n_bootstrap = 100;
tree_topologies = zeros(n_bootstrap, 1);

% 原始树拓扑 (1=Human+Chimp, 2=Human+Gorilla, 3=Chimp+Gorilla)
rng(789);
for b = 1:n_bootstrap
    % 重采样位点 (有放回)
    resampled = randi(seq_len, 1, seq_len);
    
    % 计算重采样后的距离矩阵
    resampled_dist = zeros(num_sp);
    for i = 1:num_sp
        for j = i+1:num_sp
            d = sum(sequences{i}(resampled) ~= sequences{j}(resampled)) / seq_len;
            resampled_dist(i,j) = d;
            resampled_dist(j,i) = d;
        end
    end
    
    % 构建树并记录拓扑
    try
        Z_b = linkage(squareform(resampled_dist), 'average');
        % 简化：检查最近聚类的物种对
        if Z_b(1,1) <= 2 && Z_b(1,2) <= 2
            tree_topologies(b) = 1;  % Human+Chimp
        elseif (Z_b(1,1)==1 && Z_b(1,2)==3) || (Z_b(1,1)==3 && Z_b(1,2)==1)
            tree_topologies(b) = 2;  % Human+Gorilla
        else
            tree_topologies(b) = 3;  % Chimp+Gorilla
        end
    catch
        tree_topologies(b) = 1;
    end
end

bootstrap_support = [sum(tree_topologies==1), ...
                     sum(tree_topologies==2), ...
                     sum(tree_topologies==3)] / n_bootstrap * 100;

fprintf('Bootstrap结果 (%d次):\n', n_bootstrap);
fprintf('  Human+Chimp聚类:  %.1f%%\n', bootstrap_support(1));
fprintf('  Human+Gorilla聚类: %.1f%%\n', bootstrap_support(2));
fprintf('  Chimp+Gorilla聚类: %.1f%%\n', bootstrap_support(3));

% Bootstrap结果可视化
figure('Name', 'Bootstrap分析');
pie(bootstrap_support);
legend(sprintfc('%.1f%%', bootstrap_support), ...
       'Labels', {'Human+Chimp','Human+Gorilla','Chimp+Gorilla'});
title('Bootstrap支持率');

%% === 总结 ===
fprintf('\n=== 系统发育分析总结 ===\n');
fprintf('1. 多序列比对: Hamming距离、遗传距离矩阵\n');
fprintf('2. 建树方法: UPGMA、单链接、完全链接、Ward\n');
fprintf('3. 进化模型: 分子钟、K2P校正、Gamma速率变异\n');
fprintf('4. 可靠性: Bootstrap重采样检验\n');
