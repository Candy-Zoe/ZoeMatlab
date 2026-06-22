%% 投资组合优化 (Portfolio Optimization)
% 基础 MATLAB + Statistics Toolbox (可选)
% 内容: 均值-方差模型, 有效前沿, 资产配置
clear; clc; close all;

%% === 第一部分: 资产收益模拟 ===
fprintf('=== 投资组合优化 ===\n\n');
fprintf('--- 第一部分: 多资产收益模拟 ---\n');

rng(42);
N = 252*3;  % 3年日数据
n_assets = 4;
asset_names = {'股票A', '股票B', '债券', '商品'};

% 年化参数
mu = [0.12, 0.08, 0.04, 0.06];       % 年化收益率
vol = [0.25, 0.20, 0.05, 0.15];       % 年化波动率
corr_mat = [1.0 0.6 -0.2 0.3; ...
            0.6 1.0 -0.1 0.2; ...
           -0.2 -0.1 1.0 0.0; ...
            0.3 0.2 0.0 1.0];          % 相关矩阵

% 生成相关收益
L = chol(corr_mat, 'lower');
Z = randn(N, n_assets);
daily_ret = Z * L' * diag(vol/sqrt(252)) + mu/252;

fprintf('%-8s | 年化收益 | 波动率\n', '资产');
fprintf('---------|----------|--------\n');
for i = 1:n_assets
    fprintf('%-8s | %6.1f%%  | %5.1f%%\n', asset_names{i}, mu(i)*100, vol(i)*100);
end

%% === 第二部分: 均值-方差优化 ===
fprintf('\n--- 第二部分: Markowitz 均值-方差模型 ---\n');

% 样本统计
exp_ret = mean(daily_ret) * 252;   % 期望年化收益
cov_mat = cov(daily_ret) * 252;    % 年化协方差

% 随机组合 (蒙特卡洛)
n_portfolios = 5000;
port_ret = zeros(n_portfolios, 1);
port_vol = zeros(n_portfolios, 1);
port_weights = zeros(n_portfolios, n_assets);

for i = 1:n_portfolios
    w = rand(1, n_assets);
    w = w / sum(w);
    port_weights(i,:) = w;
    port_ret(i) = w * exp_ret';
    port_vol(i) = sqrt(w * cov_mat * w');
end

% 最优夏普比率组合
sharpe_ratios = (port_ret - 0.02) ./ port_vol;  % 无风险利率 2%
[~, max_sharpe_idx] = max(sharpe_ratios);
opt_w = port_weights(max_sharpe_idx, :);

fprintf('最优组合权重:\n');
for i = 1:n_assets
    fprintf('  %s: %.1f%%\n', asset_names{i}, opt_w(i)*100);
end
fprintf('  期望收益: %.2f%%\n', port_ret(max_sharpe_idx)*100);
fprintf('  波动率:   %.2f%%\n', port_vol(max_sharpe_idx)*100);
fprintf('  夏普比率: %.3f\n', sharpe_ratios(max_sharpe_idx));

% 最小方差组合
[~, min_var_idx] = min(port_vol);
min_w = port_weights(min_var_idx, :);

figure('Name', '投资组合优化', 'Position', [100 100 900 500]);

subplot(1,2,1);
scatter(port_vol*100, port_ret*100, 8, sharpe_ratios, 'filled');
colormap(jet); colorbar;
hold on;
plot(port_vol(max_sharpe_idx)*100, port_ret(max_sharpe_idx)*100, 'r*', 'MarkerSize', 15);
plot(port_vol(min_var_idx)*100, port_ret(min_var_idx)*100, 'g^', 'MarkerSize', 12);

for i = 1:n_assets
    plot(vol(i)*100, mu(i)*100, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'w');
    text(vol(i)*100+0.5, mu(i)*100+0.5, asset_names{i}, 'FontSize', 9);
end

xlabel('波动率 (%)'); ylabel('期望收益 (%)');
title('均值-方差空间');
legend('随机组合', '最优夏普', '最小方差', 'Location', 'northwest');
grid on;

%% === 第三部分: 有效前沿 ===
fprintf('\n--- 第三部分: 有效前沿 ---\n');

% 计算有效前沿
target_returns = linspace(min(exp_ret), max(exp_ret), 50);
ef_vol = zeros(length(target_returns), 1);
ef_weights = zeros(length(target_returns), n_assets);

for i = 1:length(target_returns)
    target = target_returns(i);
    
    % 简化: 用最小二乘近似
    best_vol = inf; best_w = ones(1, n_assets)/n_assets;
    for trial = 1:1000
        w = rand(1, n_assets);
        w = w / sum(w);
        r = w * exp_ret';
        if abs(r - target) < 0.01
            v = sqrt(w * cov_mat * w');
            if v < best_vol
                best_vol = v;
                best_w = w;
            end
        end
    end
    ef_vol(i) = best_vol;
    ef_weights(i,:) = best_w;
end

subplot(1,2,2);
plot(port_vol*100, port_ret*100, '.', 'Color', [0.7 0.7 0.7], 'MarkerSize', 3); hold on;
plot(ef_vol*100, target_returns*100, 'b-', 'LineWidth', 2.5);
plot(port_vol(max_sharpe_idx)*100, port_ret(max_sharpe_idx)*100, 'r*', 'MarkerSize', 15);

% 资本市场线
x_cml = linspace(0, max(port_vol)*1.2, 100)*100;
y_cml = 0.02*100 + sharpe_ratios(max_sharpe_idx) * x_cml;
plot(x_cml, y_cml, 'r--', 'LineWidth', 1.5);

xlabel('波动率 (%)'); ylabel('期望收益 (%)');
title('有效前沿');
legend('随机组合', '有效前沿', '最优组合', '资本市场线', 'Location', 'northwest');
grid on;

%% === 第四部分: 权重饼图 ===
fprintf('\n--- 第四部分: 组合对比 ---\n');

figure('Name', '组合权重对比', 'Position', [100 100 800 300]);

subplot(1,2,1);
pie(opt_w); title('最优夏普比率组合');
legend(asset_names, 'Location', 'southoutside');

subplot(1,2,2);
pie(min_w); title('最小方差组合');
legend(asset_names, 'Location', 'southoutside');

fprintf('\n最小方差组合:\n');
for i = 1:n_assets
    fprintf('  %s: %.1f%%\n', asset_names{i}, min_w(i)*100);
end

%% === 总结 ===
fprintf('\n=== 投资组合优化总结 ===\n');
fprintf('1. 均值-方差模型是现代投资组合理论的基础\n');
fprintf('2. 有效前沿上的组合在给定风险下收益最高\n');
fprintf('3. 夏普比率衡量风险调整后的超额收益\n');
fprintf('4. 分散化投资可以降低组合波动率\n');
