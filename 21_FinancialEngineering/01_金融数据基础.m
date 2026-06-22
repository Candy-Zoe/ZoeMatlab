%% 金融数据基础 (Financial Data Basics)
% 基础 MATLAB + Financial Toolbox (可选)
% 内容: 时间序列, 收益率, 风险指标, K线图
clear; clc; close all;

%% === 第一部分: 金融时间序列 ===
fprintf('=== 金融工程基础 ===\n\n');
fprintf('--- 第一部分: 金融时间序列 ---\n');

% 模拟股票价格 (几何布朗运动)
S0 = 100;      % 初始价格
mu = 0.08;     % 年化收益率 8%
sigma = 0.20;  % 年化波动率 20%
T = 1;         % 1年
N = 252;       % 交易日
dt = T/N;

rng(42);
t = (0:N)' * dt;
W = cumsum([0; randn(N,1)] * sqrt(dt));
S = S0 * exp((mu - sigma^2/2)*t + sigma*W);

% 计算日收益率
returns = diff(S) ./ S(1:end-1);

fprintf('模拟股票参数:\n');
fprintf('  初始价格: %.0f\n', S0);
fprintf('  年化收益率: %.1f%%\n', mu*100);
fprintf('  年化波动率: %.1f%%\n', sigma*100);
fprintf('  最终价格: %.2f\n', S(end));
fprintf('  总收益率: %.2f%%\n', (S(end)/S0-1)*100);

figure('Name', '股票价格与收益', 'Position', [100 100 900 500]);

subplot(2,2,1);
plot(t, S, 'b-', 'LineWidth', 1.5);
xlabel('时间 (年)'); ylabel('价格');
title('股票价格模拟'); grid on;

subplot(2,2,2);
histogram(returns, 50, 'Normalization', 'pdf', 'FaceColor', [0.3 0.6 0.9]);
hold on;
x_norm = linspace(min(returns), max(returns), 100);
plot(x_norm, normpdf(x_norm, mean(returns), std(returns)), 'r-', 'LineWidth', 2);
xlabel('日收益率'); ylabel('概率密度');
title('收益率分布'); legend('直方图', '正态拟合');

%% === 第二部分: K线图 ===
fprintf('\n--- 第二部分: K线图 (蜡烛图) ---\n');

% 生成OHLC数据
n_days = 30;
OHLC = zeros(n_days, 4); % Open, High, Low, Close
S_ohlc = S(end-n_days*2:end-1);

for i = 1:n_days
    idx_start = (i-1)*2 + 1;
    idx_end = min(i*2, length(S_ohlc));
    segment = S_ohlc(idx_start:idx_end);
    OHLC(i,:) = [segment(1), max(segment), min(segment), segment(end)];
end

figure('Name', 'K线图', 'Position', [100 100 800 400]);
ax = axes;
hold on;

for i = 1:n_days
    o = OHLC(i,1); h = OHLC(i,2); l = OHLC(i,3); c = OHLC(i,4);
    
    % 影线
    plot([i i], [l h], 'k-', 'LineWidth', 0.8);
    
    % 实体
    if c >= o  % 阳线 (涨)
        rectangle('Position', [i-0.3, o, 0.6, c-o], 'FaceColor', [1 0.3 0.3], 'EdgeColor', 'k');
    else       % 阴线 (跌)
        rectangle('Position', [i-0.3, c, 0.6, o-c], 'FaceColor', [0.3 0.8 0.3], 'EdgeColor', 'k');
    end
end

xlabel('交易日'); ylabel('价格');
title('K线图 (蜡烛图)');
grid on;

fprintf('K线图说明:\n');
fprintf('  红色实体 = 上涨 (收盘 > 开盘)\n');
fprintf('  绿色实体 = 下跌 (收盘 < 开盘)\n');
fprintf('  上影线 = 最高价\n');
fprintf('  下影线 = 最低价\n');

%% === 第三部分: 风险指标 ===
fprintf('\n--- 第三部分: 风险指标 ---\n');

% 日收益率统计
daily_ret = returns;
annual_ret = mean(daily_ret) * 252;
annual_vol = std(daily_ret) * sqrt(252);
sharpe = annual_ret / annual_vol;

% VaR (Value at Risk) - 95%
VaR_95 = -quantile(daily_ret, 0.05);
% CVaR (Expected Shortfall)
CVaR_95 = -mean(daily_ret(daily_ret < -VaR_95));

% 最大回撤
cum_ret = cumprod(1 + daily_ret);
running_max = cummax(cum_ret);
drawdown = (running_max - cum_ret) ./ running_max;
max_dd = max(drawdown);

fprintf('风险指标:\n');
fprintf('  年化收益率:    %.2f%%\n', annual_ret*100);
fprintf('  年化波动率:    %.2f%%\n', annual_vol*100);
fprintf('  夏普比率:      %.3f\n', sharpe);
fprintf('  VaR (95%%):     %.3f (日)\n', VaR_95);
fprintf('  CVaR (95%%):    %.3f (日)\n', CVaR_95);
fprintf('  最大回撤:      %.2f%%\n', max_dd*100);

subplot(2,2,3);
plot(t(2:end), cum_ret, 'b-', 'LineWidth', 1.5);
xlabel('时间'); ylabel('累计收益');
title('累计收益率'); grid on;

subplot(2,2,4);
plot(t(2:end), drawdown*100, 'r-', 'LineWidth', 1);
fill([t(2:end); flipud(t(2:end))], [drawdown*100; zeros(length(drawdown),1)], ...
    [1 0.5 0.5], 'FaceAlpha', 0.3);
xlabel('时间'); ylabel('回撤 (%)');
title(sprintf('回撤 (最大: %.1f%%)', max_dd*100)); grid on;

%% === 总结 ===
fprintf('\n=== 金融数据基础总结 ===\n');
fprintf('1. 几何布朗运动是股票价格的经典模型\n');
fprintf('2. K线图直观展示开盘/最高/最低/收盘价\n');
fprintf('3. 夏普比率衡量风险调整后的收益\n');
fprintf('4. VaR和CVaR量化尾部风险\n');
fprintf('5. 最大回撤衡量从峰值到谷底的最大损失\n');
