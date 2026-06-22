%% =========================================================================
%  假设检验
%  学习目标：掌握 t 检验、z 检验、卡方检验等基本方法
%  需要: Statistics and Machine Learning Toolbox
%% =========================================================================

clear; clc; close all;

%% 1. 单样本 t 检验
disp('--- 单样本 t 检验 ---');
% 检验样本均值是否等于某个假设值

rng(42);
data = normrnd(52, 5, 1, 30);        % 真实均值52，检验H0: μ=50

[h, p, ci, stats] = ttest(data, 50);
fprintf('H0: μ = 50 vs H1: μ ≠ 50\n');
fprintf('h = %d (1=拒绝H0, 0=不拒绝)\n', h);
fprintf('p = %.4f (p<0.05 则拒绝H0)\n', p);
fprintf('95%% 置信区间: [%.2f, %.2f]\n', ci(1), ci(2));
fprintf('t 统计量: %.4f\n', stats.tstat);

%% 2. 双样本 t 检验
disp('--- 双样本 t 检验 ---');
% 检验两组样本均值是否有显著差异

rng(0);
group_A = normrnd(75, 8, 1, 40);     % A班成绩
group_B = normrnd(80, 8, 1, 40);     % B班成绩

[h2, p2, ci2, stats2] = ttest2(group_A, group_B);
fprintf('H0: μA = μB vs H1: μA ≠ μB\n');
fprintf('A班均值: %.2f, B班均值: %.2f\n', mean(group_A), mean(group_B));
fprintf('h = %d, p = %.4f\n', h2, p2);
fprintf('结论: %s\n', {'不拒绝H0，无显著差异'; '拒绝H0，存在显著差异'});

%% 3. 配对 t 检验
disp('--- 配对 t 检验 ---');
% 同一组对象干预前后的对比

rng(42);
before = normrnd(60, 10, 1, 25);
after  = before + normrnd(5, 3, 1, 25);  % 干预后提升约5分

[h3, p3] = ttest(before - after, 0);
fprintf('干预前均值: %.2f\n', mean(before));
fprintf('干预后均值: %.2f\n', mean(after));
fprintf('h = %d, p = %.6f\n', h3, p3);
fprintf('结论: %s\n', {'干预无显著效果'; '干预有显著效果'});

%% 4. 方差分析 (ANOVA)
disp('--- 单因素方差分析 (ANOVA) ---');

rng(0);
g1 = normrnd(50, 5, 1, 30);
g2 = normrnd(55, 5, 1, 30);
g3 = normrnd(52, 5, 1, 30);

[p_anova, tbl, stats_anova] = anova1({g1, g2, g3}, {'方法A', '方法B', '方法C'});
fprintf('ANOVA p = %.6f\n', p_anova);
fprintf('结论: %s\n', {'各组均值无显著差异'; '至少两组均值存在显著差异'});

%% 5. 卡方拟合优度检验
disp('--- 卡方拟合优度检验 ---');
% 检验数据是否服从均匀分布

rng(42);
dice = randi(6, 1, 600);              % 模拟掷骰子600次
observed = tabulate(dice);             % 观察频数
expected = repmat(100, 1, 6);          % 期望频数（每面100次）

[h_chi, p_chi] = chi2gof(dice, 'CDF', {@unidcdf, 6}, 'NParams', 0);
fprintf('H0: 骰子均匀 vs H1: 不均匀\n');
fprintf('h = %d, p = %.4f\n', h_chi, p_chi);
fprintf('结论: %s\n', {'骰子均匀'; '骰子不均匀'});

%% 6. 可视化：假设检验结果
disp('--- 可视化 ---');

figure('Name', '假设检验可视化', 'Position', [100, 100, 800, 300]);

% 左图：两组对比
subplot(1,2,1);
boxplot([group_A; group_B]', {'A班', 'B班'});
hold on;
if h2
    text(1.5, max([group_A, group_B])+2, sprintf('p=%.4f ***', p2), ...
         'HorizontalAlignment', 'center', 'Color', 'r', 'FontSize', 12);
else
    text(1.5, max([group_A, group_B])+2, sprintf('p=%.4f (n.s.)', p2), ...
         'HorizontalAlignment', 'center', 'Color', 'k', 'FontSize', 12);
end
title('双样本 t 检验');
ylabel('成绩');
hold off;

% 右图：配对对比
subplot(1,2,2);
differences = after - before;
histogram(differences, 15, 'FaceColor', [0.2 0.6 0.8]);
hold on;
xline(0, 'r-', 'LineWidth', 2);
title(sprintf('配对差异 (p=%.4f)', p3));
xlabel('干预后 - 干预前');
ylabel('频数');
hold off;

%% 7. 非参数检验
fprintf('\n--- 非参数检验 ---\n');

% Wilcoxon秩和检验 (Mann-Whitney U)
rng(42);
sample_a = exprnd(5, 1, 30);   % 指数分布
sample_b = exprnd(7, 1, 30);

[p_rank, h_rank] = ranksum(sample_a, sample_b);
fprintf('Wilcoxon秩和检验:\n');
fprintf('  H0: 两样本来自同一分布\n');
fprintf('  h = %d, p = %.4f\n', h_rank, p_rank);

% Kruskal-Wallis检验 (多组非参数ANOVA)
g_a = exprnd(5, 1, 25);
g_b = exprnd(7, 1, 25);
g_c = exprnd(6, 1, 25);

[p_kw] = kruskalwallis({g_a, g_b, g_c});
fprintf('Kruskal-Wallis检验: p = %.4f\n', p_kw);

% Kolmogorov-Smirnov检验 (分布拟合)
[p_ks, h_ks] = kstest(sample_a, 'CDF', [sample_a', expcdf(sample_a', mean(sample_a))]);
fprintf('K-S检验 (指数分布拟合): h=%d, p=%.4f\n', h_ks, p_ks);

%% 8. 效应量与统计功效
fprintf('\n--- 效应量与统计功效 ---\n');

% Cohen's d 效应量
d_effect = abs(mean(group_B) - mean(group_A)) / sqrt((var(group_A)+var(group_B))/2);
fprintf('Cohen\'s d = %.3f', d_effect);
if d_effect < 0.2
    fprintf(' (微小效应)\n');
elseif d_effect < 0.5
    fprintf(' (小效应)\n');
elseif d_effect < 0.8
    fprintf(' (中等效应)\n');
else
    fprintf(' (大效应)\n');
end

% 功效分析 (简化版)
% 对于t检验，给定效应量d、样本量n、显著性水平alpha
alpha_level = 0.05;
n_per_group = 30;

% 使用非中心t分布计算功效 (简化近似)
ncp = d_effect * sqrt(n_per_group/2);  % 非中心参数
t_crit = tinv(1-alpha_level/2, 2*n_per_group-2);
power_approx = 1 - tcdf(t_crit, 2*n_per_group-2, ncp);

fprintf('统计功效 (1-β) = %.3f\n', power_approx);
fprintf('  (给定 d=%.2f, n=%d, α=%.2f)\n', d_effect, n_per_group, alpha_level);

% 样本量与功效曲线
figure('Name', '功效分析', 'Position', [100, 100, 700, 400]);
n_range = 5:5:100;
d_vals = [0.2, 0.5, 0.8, 1.0];
labels_d = {'d=0.2(小)', 'd=0.5(中)', 'd=0.8(大)', 'd=1.0'};

for i = 1:length(d_vals)
    power_curve = zeros(size(n_range));
    for j = 1:length(n_range)
        ncp_j = d_vals(i) * sqrt(n_range(j)/2);
        t_c = tinv(1-alpha_level/2, 2*n_range(j)-2);
        power_curve(j) = 1 - tcdf(t_c, 2*n_range(j)-2, ncp_j);
    end
    plot(n_range, power_curve, 'LineWidth', 2, 'DisplayName', labels_d{i}); hold on;
end
yline(0.8, 'k--', 'LineWidth', 1.5, 'DisplayName', '功效=0.8');
xlabel('每组样本量'); ylabel('统计功效 (1-β)');
title('功效分析: 样本量 vs 功效');
legend('Location', 'best');
grid on;

%% === 总结 ===
fprintf('\n=== 假设检验总结 ===\n');
fprintf('1. t检验: 单样本、双样本、配对\n');
fprintf('2. ANOVA: 单因素方差分析\n');
fprintf('3. 卡方检验: 拟合优度、独立性\n');
fprintf('4. 非参数: Wilcoxon、Kruskal-Wallis、K-S\n');
fprintf('5. 效应量: Cohen\'s d 衡量实际意义\n');
fprintf('6. 功效分析: 确定所需样本量\n');
