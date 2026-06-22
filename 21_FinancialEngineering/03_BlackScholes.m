%% Black-Scholes 期权定价 (Option Pricing)
% 基础 MATLAB 即可
% 内容: BS公式, 希腊字母, 隐含波动率, 蒙特卡洛定价
clear; clc; close all;

%% === 第一部分: Black-Scholes 公式 ===
fprintf('=== Black-Scholes 期权定价 ===\n\n');
fprintf('--- 第一部分: BS 公式 ---\n\n');

fprintf('Black-Scholes 公式:\n');
fprintf('  Call = S*N(d1) - K*exp(-rT)*N(d2)\n');
fprintf('  Put  = K*exp(-rT)*N(-d2) - S*N(-d1)\n\n');
fprintf('  d1 = [ln(S/K) + (r + sigma^2/2)*T] / (sigma*sqrt(T))\n');
fprintf('  d2 = d1 - sigma*sqrt(T)\n\n');
fprintf('  S: 当前价格, K: 行权价, r: 无风险利率\n');
fprintf('  sigma: 波动率, T: 到期时间, N(): 标准正态CDF\n\n');

% 计算 BS 价格
S = 100; K = 100; r = 0.05; sigma = 0.20; T = 1;

d1 = (log(S/K) + (r + sigma^2/2)*T) / (sigma*sqrt(T));
d2 = d1 - sigma*sqrt(T);
call_price = S*normcdf(d1) - K*exp(-r*T)*normcdf(d2);
put_price = K*exp(-r*T)*normcdf(-d2) - S*normcdf(-d1);

fprintf('参数: S=%g, K=%g, r=%.1f%%, sigma=%.0f%%, T=%g年\n', S, K, r*100, sigma*100, T);
fprintf('Call 价格: %.4f\n', call_price);
fprintf('Put 价格:  %.4f\n', put_price);
fprintf('Put-Call Parity 验证: C-P = %.4f, S-K*exp(-rT) = %.4f\n', ...
    call_price-put_price, S-K*exp(-r*T));

%% === 第二部分: 期权价格曲面 ===
fprintf('\n--- 第二部分: 期权价格曲面 ---\n');

S_range = linspace(70, 130, 50);
T_range = linspace(0.1, 2, 50);
[S_grid, T_grid] = meshgrid(S_range, T_range);

% Call 价格曲面
d1_grid = (log(S_grid/K) + (r + sigma^2/2)*T_grid) ./ (sigma*sqrt(T_grid));
d2_grid = d1_grid - sigma*sqrt(T_grid);
call_grid = S_grid.*normcdf(d1_grid) - K*exp(-r*T_grid).*normcdf(d2_grid);

figure('Name', '期权价格曲面', 'Position', [100 100 900 400]);

subplot(1,2,1);
surf(S_grid, T_grid, call_grid, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
xlabel('标的价格 S'); ylabel('到期时间 T'); zlabel('Call 价格');
title('欧式看涨期权价格'); colormap(jet); colorbar;
view(45, 30);

% 不同行权价的期权价格
subplot(1,2,2);
K_vals = [80, 90, 100, 110, 120];
S_plot = linspace(50, 150, 200);
for i = 1:length(K_vals)
    d1_p = (log(S_plot/K_vals(i)) + (r + sigma^2/2)*T) ./ (sigma*sqrt(T));
    d2_p = d1_p - sigma*sqrt(T);
    call_p = S_plot.*normcdf(d1_p) - K_vals(i)*exp(-r*T).*normcdf(d2_p);
    plot(S_plot, call_p, 'LineWidth', 1.5); hold on;
end
xline(K, 'k--', 'S=K=100');
xlabel('标的价格 S'); ylabel('Call 价格');
title('不同行权价的期权价格');
legend(arrayfun(@(k) sprintf('K=%d', k), K_vals, 'UniformOutput', false), 'Location', 'northwest');
grid on;

%% === 第三部分: 希腊字母 (Greeks) ===
fprintf('\n--- 第三部分: 希腊字母 ---\n\n');

% Delta
delta_call = normcdf(d1);
delta_put = delta_call - 1;

% Gamma
gamma_val = normpdf(d1) / (S * sigma * sqrt(T));

% Theta (per day)
theta_call = -(S*normpdf(d1)*sigma/(2*sqrt(T)) + r*K*exp(-r*T)*normcdf(d2)) / 365;

% Vega (per 1% change)
vega_val = S * normpdf(d1) * sqrt(T) / 100;

% Rho
rho_call = K * T * exp(-r*T) * normcdf(d2) / 100;

fprintf('Greeks (Call, ATM):\n');
fprintf('  Delta: %.4f  (价格变动敏感度)\n', delta_call);
fprintf('  Gamma: %.4f  (Delta变动率)\n', gamma_val);
fprintf('  Theta: %.4f  (每日时间衰减)\n', theta_call);
fprintf('  Vega:  %.4f  (波动率敏感度)\n', vega_val);
fprintf('  Rho:   %.4f  (利率敏感度)\n', rho_call);

% 可视化 Greeks
figure('Name', 'Greeks', 'Position', [100 100 900 500]);
S_g = linspace(70, 130, 100);

% Delta
d1_g = (log(S_g/K) + (r+sigma^2/2)*T) ./ (sigma*sqrt(T));
delta_g = normcdf(d1_g);

subplot(2,2,1);
plot(S_g, delta_g, 'b-', 'LineWidth', 2);
xlabel('S'); ylabel('Delta'); title('Delta vs S'); grid on;
yline(0.5, 'k--');

% Gamma
gamma_g = normpdf(d1_g) ./ (S_g * sigma * sqrt(T));
subplot(2,2,2);
plot(S_g, gamma_g, 'r-', 'LineWidth', 2);
xlabel('S'); ylabel('Gamma'); title('Gamma vs S'); grid on;

% Theta vs T
T_g = linspace(0.01, 1, 100);
d1_t = (log(S/K) + (r+sigma^2/2)*T_g) ./ (sigma*sqrt(T_g));
d2_t = d1_t - sigma*sqrt(T_g);
theta_g = -(S*normpdf(d1_t)*sigma./(2*sqrt(T_g)) + r*K*exp(-r*T_g).*normcdf(d2_t)) / 365;

subplot(2,2,3);
plot(T_g, theta_g, 'g-', 'LineWidth', 2);
xlabel('T (年)'); ylabel('Theta (日)'); title('Theta vs T'); grid on;

% Vega vs sigma
sigma_g = linspace(0.05, 0.5, 100);
d1_s = (log(S/K) + (r+sigma_g.^2/2)*T) ./ (sigma_g*sqrt(T));
vega_g = S * normpdf(d1_s) * sqrt(T) / 100;

subplot(2,2,4);
plot(sigma_g*100, vega_g, 'm-', 'LineWidth', 2);
xlabel('波动率 (%)'); ylabel('Vega'); title('Vega vs sigma'); grid on;

%% === 总结 ===
fprintf('\n=== Black-Scholes 总结 ===\n');
fprintf('1. BS公式为欧式期权提供封闭形式定价\n');
fprintf('2. Greeks量化期权对各种因素的敏感度\n');
fprintf('3. Put-Call Parity: C-P = S - K*exp(-rT)\n');
fprintf('4. 隐含波动率是从市场价格反推的波动率\n');
