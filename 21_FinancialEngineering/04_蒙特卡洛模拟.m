%% 蒙特卡洛模拟 (Monte Carlo Simulation)
% 基础 MATLAB 即可
% 内容: 蒙特卡洛期权定价, 风险中性测度, 收敛分析
clear; clc; close all;

%% === 第一部分: 蒙特卡洛期权定价 ===
fprintf('=== 蒙特卡洛金融模拟 ===\n\n');
fprintf('--- 第一部分: MC 期权定价 ---\n');

S0 = 100; K = 100; r = 0.05; sigma = 0.20; T = 1;
n_paths = 100000;
n_steps = 252;
dt = T/n_steps;

rng(42);
% 模拟路径
S_paths = S0 * exp(cumsum([(r-sigma^2/2)*dt + sigma*sqrt(dt)*randn(n_paths,1), ...
    (r-sigma^2/2)*dt + sigma*sqrt(dt)*randn(n_paths, n_steps-1)], 2));
S_paths = [S0*ones(n_paths,1), S_paths];

% 欧式看涨期权
call_payoff = max(S_paths(:,end) - K, 0);
call_mc = exp(-r*T) * mean(call_payoff);
call_std = exp(-r*T) * std(call_payoff) / sqrt(n_paths);

% BS 精确解
d1 = (log(S0/K) + (r+sigma^2/2)*T) / (sigma*sqrt(T));
d2 = d1 - sigma*sqrt(T);
call_bs = S0*normcdf(d1) - K*exp(-r*T)*normcdf(d2);

fprintf('Monte Carlo Call: %.4f ± %.4f\n', call_mc, 1.96*call_std);
fprintf('Black-Scholes:    %.4f\n', call_bs);
fprintf('误差: %.4f (%.2f%%)\n', abs(call_mc-call_bs), abs(call_mc-call_bs)/call_bs*100);

figure('Name', '蒙特卡洛路径', 'Position', [100 100 900 400]);
subplot(1,2,1);
t_sim = linspace(0, T, n_steps+1);
for i = 1:min(50, n_paths)
    plot(t_sim, S_paths(i,:), 'Color', [0.5 0.5 0.9], 'LineWidth', 0.3); hold on;
end
yline(K, 'r--', 'K=100', 'LineWidth', 1.5);
xlabel('时间 (年)'); ylabel('价格');
title(sprintf('模拟路径 (%d 条)', n_paths)); grid on;

%% === 第二部分: 收敛分析 ===
fprintf('\n--- 第二部分: 收敛分析 ---\n');

n_sims = [100, 500, 1000, 5000, 10000, 50000, 100000];
mc_prices = zeros(size(n_sims));
mc_errors = zeros(size(n_sims));

for i = 1:length(n_sims)
    n = n_sims(i);
    S_T = S0 * exp((r-sigma^2/2)*T + sigma*sqrt(T)*randn(n,1));
    payoff = max(S_T - K, 0);
    mc_prices(i) = exp(-r*T) * mean(payoff);
    mc_errors(i) = exp(-r*T) * std(payoff) / sqrt(n);
end

subplot(1,2,2);
errorbar(log10(n_sims), mc_prices, 1.96*mc_errors, 'o-', 'LineWidth', 1.5);
hold on;
yline(call_bs, 'r--', 'LineWidth', 2, 'DisplayName', 'BS 精确值');
xlabel('log_{10}(模拟次数)'); ylabel('期权价格');
title('蒙特卡洛收敛');
legend('MC ± 95% CI', 'BS 精确值'); grid on;

fprintf('收敛结果:\n');
for i = 1:length(n_sims)
    fprintf('  N=%7d: %.4f ± %.4f\n', n_sims(i), mc_prices(i), 1.96*mc_errors(i));
end

%% === 第三部分: 方差缩减技术 ===
fprintf('\n--- 第三部分: 方差缩减 ---\n\n');

fprintf('常用方差缩减方法:\n');
fprintf('  1. 对偶变量法: 使用 Z 和 -Z 配对\n');
fprintf('  2. 控制变量法: 用已知期望值的变量减方差\n');
fprintf('  3. 重要性采样: 改变采样分布提高效率\n\n');

% 对偶变量法
n_half = n_paths/2;
Z = randn(n_half, 1);
S_T_1 = S0 * exp((r-sigma^2/2)*T + sigma*sqrt(T)*Z);
S_T_2 = S0 * exp((r-sigma^2/2)*T + sigma*sqrt(T)*(-Z));
payoff_1 = max(S_T_1 - K, 0);
payoff_2 = max(S_T_2 - K, 0);
mc_antithetic = exp(-r*T) * mean((payoff_1 + payoff_2)/2);
se_antithetic = exp(-r*T) * std((payoff_1+payoff_2)/2) / sqrt(n_half);

fprintf('标准 MC:      %.4f ± %.4f\n', call_mc, 1.96*call_std);
fprintf('对偶变量 MC:  %.4f ± %.4f\n', mc_antithetic, 1.96*se_antithetic);
fprintf('方差缩减比:   %.2f x\n', (call_std/se_antithetic)^2);

%% === 总结 ===
fprintf('\n=== 蒙特卡洛模拟总结 ===\n');
fprintf('1. MC方法通过大量随机模拟估计期权价格\n');
fprintf('2. 精度随 1/sqrt(N) 收敛\n');
fprintf('3. 方差缩减技术可显著提高效率\n');
fprintf('4. MC 特别适合路径依赖型期权 (如亚式期权)\n');
