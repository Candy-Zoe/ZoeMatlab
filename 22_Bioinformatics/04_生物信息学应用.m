%% ========================================================================
%  生物信息学应用 - Bioinformatics Applications
%  本脚本演示生物信息学在实际研究中的应用
%  内容包括：基因组分析、蛋白质结构、药物设计、NGS数据分析
%  ========================================================================
clear; clc; close all;

%% === 1. 基因组特征分析 ===
fprintf('=== 1. 基因组特征分析 ===\n');

% 模拟一段基因组序列 (GC含量变化)
rng(42);
genome_length = 10000;
window_size = 500;
positions = 1:window_size:genome_length-window_size+1;

% 生成GC含量沿基因组变化的序列
gc_profile = 0.4 + 0.2 * sin(2*pi*(1:length(positions))/length(positions));
gc_content = zeros(size(positions));

for i = 1:length(positions)
    bases = randi(4, 1, window_size);
    n_gc = round(gc_profile(i) * window_size);
    bases(1:n_gc) = randi([3,4], 1, n_gc);  % G or C
    gc_content(i) = (sum(bases==3) + sum(bases==4)) / window_size;
end

fprintf('基因组长度: %d bp\n', genome_length);
fprintf('窗口大小: %d bp\n', window_size);
fprintf('平均GC含量: %.2f%%\n', mean(gc_content)*100);

figure('Name', '基因组特征分析', 'Position', [100 100 1200 600]);
subplot(2,2,1);
plot(positions/1000, gc_content*100, 'b-', 'LineWidth', 1.5);
hold on;
yline(50, 'r--', '50% GC');
xlabel('基因组位置 (kb)');
ylabel('GC含量 (%)');
title('GC含量分布');

% CpG岛检测 (GC>55% 且 Obs/Exp > 0.65)
cpg_islands = gc_content > 0.55;
island_starts = positions(cpg_islands & [true, diff(cpg_islands)==1]);
island_ends = positions(cpg_islands & [diff(cpg_islands)==-1, true]);

fprintf('CpG岛数量: %d\n', sum(cpg_islands));

subplot(2,2,2);
bar(positions/1000, double(cpg_islands), 1);
xlabel('基因组位置 (kb)');
ylabel('CpG岛');
title('CpG岛分布');

% 基因密度
gene_positions = sort(randi(genome_length, 1, 50));
subplot(2,2,3);
histogram(gene_positions/1000, 20);
xlabel('基因组位置 (kb)');
ylabel('基因数量');
title('基因密度分布');

%% === 2. 蛋白质结构预测基础 ===
fprintf('\n=== 2. 蛋白质结构预测 ===\n');

% 氨基酸理化性质
aa_names = 'ACDEFGHIKLMNPQRSTVWY';
aa_full = {'Ala','Cys','Asp','Glu','Phe','Gly','His','Ile','Lys','Leu',...
           'Met','Asn','Pro','Gln','Arg','Ser','Thr','Val','Trp','Tyr'};

% 疏水性 (Kyte-Doolittle)
hydrophobicity = [1.8, 2.5, -3.5, -3.5, 2.8, -0.4, -3.2, 4.5, -3.9, 3.8, ...
                  1.9, -3.5, -1.6, -3.5, -4.5, -0.8, -0.7, 4.2, -0.9, -1.3];

% 分子量
mw = [89, 121, 133, 147, 165, 75, 155, 131, 146, 131, ...
      149, 132, 115, 146, 174, 105, 119, 117, 204, 181];

fprintf('氨基酸疏水性 (前5个最疏水):\n');
[~, sort_idx] = sort(hydrophobicity, 'descend');
for i = 1:5
    fprintf('  %s (%s): %.1f\n', aa_names(sort_idx(i)), ...
            aa_full{sort_idx(i)}, hydrophobicity(sort_idx(i)));
end

% 模拟蛋白质序列的疏水性分析
protein_seq = 'MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEK';
seq_indices = zeros(1, length(protein_seq));
for i = 1:length(protein_seq)
    idx = find(aa_names == protein_seq(i));
    if ~isempty(idx)
        seq_indices(i) = idx;
    else
        seq_indices(i) = 1;  % 默认
    end
end

% 滑动窗口疏水性
ws = 7;
hp_profile = zeros(1, length(seq_indices)-ws+1);
for i = 1:length(hp_profile)
    hp_profile(i) = mean(hydrophobicity(seq_indices(i:i+ws-1)));
end

subplot(2,2,4);
plot(1:length(hp_profile), hp_profile, 'b-', 'LineWidth', 1.5);
hold on;
yline(0, 'k--');
yline(1.6, 'r--', '跨膜阈值');
xlabel('残基位置');
ylabel('疏水性');
title('Kyte-Doolittle疏水性分析');

%% === 3. 药物-靶标对接评分 (模拟) ===
fprintf('\n=== 3. 药物-靶标对接 ===\n');

% 模拟100个小分子的对接评分
num_compounds = 100;
compound_names = sprintfc('Compound_%03d', 1:num_compounds);

% 对接评分 (kcal/mol, 越负越好)
docking_scores = -5 + 3*randn(1, num_compounds);
docking_scores = max(docking_scores, -15);  % 下限

% 药物性质 (Lipinski五规则)
mw_drug = 200 + 300*rand(1, num_compounds);
logP = -1 + 4*rand(1, num_compounds);
hbd = randi([0,5], 1, num_compounds);
hba = randi([1,10], 1, num_compounds);

% Lipinski过滤
lipinski_pass = (mw_drug <= 500) & (logP <= 5) & (hbd <= 5) & (hba <= 10);

fprintf('化合物总数: %d\n', num_compounds);
fprintf('通过Lipinski规则: %d (%.1f%%)\n', ...
        sum(lipinski_pass), sum(lipinski_pass)/num_compounds*100);
fprintf('最佳对接评分: %.2f kcal/mol (%s)\n', ...
        min(docking_scores), compound_names(docking_scores==min(docking_scores)));

% 虚拟筛选结果可视化
figure('Name', '药物虚拟筛选', 'Position', [100 100 1000 600]);
subplot(2,2,1);
scatter(mw_drug, docking_scores, 30, lipinski_pass*5+1, 'filled');
colorbar;
xline(500, 'r--', 'MW=500');
xlabel('分子量');
ylabel('对接评分 (kcal/mol)');
title('分子量 vs 对接评分');

% 评分分布
subplot(2,2,2);
histogram(docking_scores, 20);
xline(-7, 'r--', '阈值=-7');
xlabel('对接评分 (kcal/mol)');
ylabel('化合物数量');
title('评分分布');

% 类药性雷达图
subplot(2,2,3);
% 选择top5化合物
[~, top5] = sort(docking_scores);
top5 = top5(1:5);
properties_norm = [mw_drug(top5)/500; (logP(top5)+1)/6; ...
                   hbd(top5)/5; hba(top5)/10];
for i = 1:5
    theta = linspace(0, 2*pi, 5);
    vals = [properties_norm(:,i); properties_norm(1,i)];
    polarplot(theta, vals, 'LineWidth', 1.5);
    hold on;
end
ax = gca;
ax.ThetaTick = [0, 90, 180, 270];
ax.ThetaTickLabel = {'MW','LogP','HBD','HBA'};
title('Top 5化合物类药性');

% 对接评分收敛
subplot(2,2,4);
best_so_far = cummin(docking_scores);
plot(best_so_far, 'b-', 'LineWidth', 1.5);
xlabel('筛选化合物数');
ylabel('最佳评分');
title('虚拟筛选收敛曲线');

%% === 4. NGS数据分析 (模拟) ===
fprintf('\n=== 4. NGS测序数据分析 ===\n');

% 模拟测序质量分数 (Phred+33)
num_reads = 1000;
read_length = 150;

% 模拟质量分数 (位置依赖性衰减)
quality = zeros(num_reads, read_length);
for r = 1:num_reads
    base_quality = 35 - 15*(1:read_length)/read_length;
    quality(r,:) = base_quality + randn(1, read_length)*3;
end
quality = max(quality, 2);
quality = min(quality, 40);

fprintf('读取数: %d\n', num_reads);
fprintf('读取长度: %d bp\n', read_length);
fprintf('平均质量: Q%.1f\n', mean(quality(:)));

figure('Name', 'NGS质量分析', 'Position', [100 100 1000 500]);
subplot(2,2,1);
imagesc(quality(1:min(100,end), :));
colorbar;
xlabel('碱基位置');
ylabel('Read');
title('质量分数热图 (前100 reads)');

% 每个位置的平均质量
subplot(2,2,2);
plot(mean(quality), 'b-', 'LineWidth', 2);
hold on;
yline(20, 'r--', 'Q20');
yline(30, 'g--', 'Q30');
xlabel('碱基位置');
ylabel('平均Phred质量');
title('逐位置质量统计');

% GC含量分布
gc_per_read = zeros(num_reads, 1);
for r = 1:num_reads
    gc_per_read(r) = rand() * 0.3 + 0.35;  % 模拟GC含量
end
subplot(2,2,3);
histogram(gc_per_read*100, 20);
xlabel('GC含量 (%)');
ylabel('Read数量');
title('Reads GC含量分布');

% 覆盖度模拟
coverage = zeros(1, 1000);
for r = 1:num_reads
    start_pos = randi(1000 - read_length + 1);
    coverage(start_pos:start_pos+read_length-1) = ...
        coverage(start_pos:start_pos+read_length-1) + 1;
end
subplot(2,2,4);
plot(coverage, 'b-', 'LineWidth', 0.5);
hold on;
yline(mean(coverage), 'r--', sprintf('平均=%.1f', mean(coverage)));
xlabel('基因组位置');
ylabel('覆盖深度');
title('测序覆盖度');

%% === 总结 ===
fprintf('\n=== 生物信息学应用总结 ===\n');
fprintf('1. 基因组分析: GC含量、CpG岛、基因密度\n');
fprintf('2. 蛋白质分析: 疏水性、理化性质、跨膜预测\n');
fprintf('3. 药物设计: 分子对接、Lipinski规则、虚拟筛选\n');
fprintf('4. NGS分析: 质量控制、覆盖度、GC偏差\n');
fprintf('\n推荐工具箱: Bioinformatics Toolbox, Deep Learning Toolbox\n');
