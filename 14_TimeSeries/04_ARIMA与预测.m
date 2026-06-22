%% 04_ARIMA与预测.m — ARIMA 模型与时间序列预测
%  涵盖: arima 模型, estimate, forecast, 置信区间
%  需要 Econometrics Toolbox

clear; clc; close all;

%% ===== 1. 生成 AR 数据 =====
fprintf('===== 1. 生成 AR 过程数据 =====\n');

rng(42);
N = 200;
N_forecast = 50;

% AR(1) 过程: y(t) = 0.7*y(t-1) + e(t)
data_ar1 = zeros(N + N_forecast, 1);
for i = 2:length(data_ar1)
    data_ar1(i) = 0.7 * data_ar1(i-1) + randn();
end
data_train = data_ar1(1:N);
data_true_future = data_ar1(N+1:end);

figure('Name', 'AR(1) 过程', 'Position', [100 100 800 300]);
plot(1:N, data_train, 'b-', 'LineWidth', 0.8); hold on;
plot(N+1:N+N_forecast, data_true_future, 'r-', 'LineWidth', 0.8);
hold off;
xlabel('时间'); ylabel('值');
title('AR(1) 过程 (蓝=训练, 红=测试)');
grid on;

%% ===== 2. 简单 AR 预测 =====
fprintf('\n===== 2. AR 模型拟合 =====\n');

% 使用 regress 拟合 AR(1)
y = data_train(2:end);
X = data_train(1:end-1);
phi = X \ y;
fprintf('AR(1) 估计系数: phi = %.4f (真实: 0.7)\n', phi);

% AR(2) 拟合
y2 = data_train(3:end);
X2 = [data_train(2:end-1), data_train(1:end-2)];
phi2 = X2 \ y2;
fprintf('AR(2) 估计系数: phi1 = %.4f, phi2 = %.4f\n', phi2(1), phi2(2));

% AR(3) 拟合
y3 = data_train(4:end);
X3 = [data_train(3:end-1), data_train(2:end-2), data_train(1:end-3)];
phi3 = X3 \ y3;
fprintf('AR(3) 估计系数: phi1 = %.4f, phi2 = %.4f, phi3 = %.4f\n', phi3);

% 残差分析
residuals = y - phi * X;
fprintf('\nAR(1) 残差标准差: %.4f\n', std(residuals));

%% ===== 3. 滚动预测 =====
fprintf('\n===== 3. 滚动预测 =====\n');

% 使用 AR(1) 进行递推预测
predictions = zeros(N_forecast, 1);
predictions(1) = phi * data_train(end);
for i = 2:N_forecast
    predictions(i) = phi * predictions(i-1);
end

% 预测置信区间 (95%)
sigma = std(residuals);
ci_width = 1.96 * sigma;
ci_upper = predictions + ci_width * sqrt(1:N_forecast)';
ci_lower = predictions - ci_width * sqrt(1:N_forecast)';

% 评估
mse = mean((predictions - data_true_future).^2);
mae = mean(abs(predictions - data_true_future));
fprintf('预测 MSE: %.4f\n', mse);
fprintf('预测 MAE: %.4f\n', mae);

figure('Name', 'AR(1) 预测', 'Position', [200 200 800 500]);
plot(1:N, data_train, 'b-', 'LineWidth', 0.8); hold on;
plot(N+1:N+N_forecast, data_true_future, 'r-', 'LineWidth', 1);
plot(N+1:N+N_forecast, predictions, 'g--', 'LineWidth', 2);
fill([N+1:N+N_forecast, N+N_forecast:-1:N+1], ...
    [ci_upper', ci_lower(N_forecast:-1:1)'], ...
    [0.8 1 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold off;
xlabel('时间'); ylabel('值');
title('AR(1) 预测 (绿色=预测, 灰色=95%置信区间)');
legend('训练数据', '真实未来', 'AR(1) 预测', '置信区间', 'Location', 'best');
grid on;

%% ===== 4. arima 模型 (若可用) =====
fprintf('\n===== 4. ARIMA 模型 =====\n');

try
    % 创建 ARIMA(1,0,0) 模型
    model = arima(1, 0, 0);
    
    % 估计参数
    [est_model, est_param] = estimate(model, data_train, 'Display', 'off');
    fprintf('ARIMA(1,0,0) 估计结果:\n');
    disp(est_param);
    
    % 预测
    [y_pred, y_ci] = forecast(est_model, N_forecast, 'Y0', data_train);
    
    fprintf('\nARIMA 预测 (前5步):\n');
    for i = 1:5
        fprintf('  步 %d: %.4f [%.4f, %.4f]\n', ...
            i, y_pred(i), y_ci(i,1), y_ci(i,2));
    end
    
    figure('Name', 'ARIMA 预测', 'Position', [300 300 800 500]);
    plot(1:N, data_train, 'b-'); hold on;
    plot(N+1:N+N_forecast, data_true_future, 'r-', 'LineWidth', 1.5);
    plot(N+1:N+N_forecast, y_pred, 'g--', 'LineWidth', 2);
    plot(N+1:N+N_forecast, y_ci(:,1), 'g:', 'LineWidth', 1);
    plot(N+1:N+N_forecast, y_ci(:,2), 'g:', 'LineWidth', 1);
    hold off;
    title('ARIMA(1,0,0) 预测');
    legend('训练', '真实', '预测', '置信下界', '置信上界', 'Location', 'best');
    grid on;
    
catch ME
    fprintf('arima 不可用 (需要 Econometrics Toolbox): %s\n', ME.message);
    fprintf('使用手动 AR(1) 结果代替\n');
end

%% ===== 5. 模型阶数选择 =====
fprintf('\n===== 5. AR 阶数选择 (AIC/BIC) =====\n');

max_order = 10;
aic = zeros(max_order, 1);
bic = zeros(max_order, 1);

for p = 1:max_order
    yp = data_train(p+1:end);
    Xp = zeros(length(yp), p);
    for j = 1:p
        Xp(:, j) = data_train(p+1-j:end-j);
    end
    phi_p = Xp \ yp;
    res_p = yp - Xp * phi_p;
    n = length(res_p);
    sigma2 = sum(res_p.^2) / n;
    logL = -n/2 * (log(2*pi) + log(sigma2) + 1);
    k = p + 1;  % 参数数
    aic(p) = -2*logL + 2*k;
    bic(p) = -2*logL + k*log(n);
end

[~, best_aic] = min(aic);
[~, best_bic] = min(bic);
fprintf('AIC 最优阶数: %d\n', best_aic);
fprintf('BIC 最优阶数: %d\n', best_bic);

figure('Name', 'AR 阶数选择', 'Position', [100 100 600 400]);
plot(1:max_order, aic, 'bo-', 'LineWidth', 1.5); hold on;
plot(1:max_order, bic, 'rs-', 'LineWidth', 1.5);
plot(best_aic, aic(best_aic), 'b*', 'MarkerSize', 15);
plot(best_bic, bic(best_bic), 'r*', 'MarkerSize', 15);
hold off;
xlabel('AR 阶数 p'); ylabel('信息准则值');
title('AR 阶数选择 (AIC/BIC)');
legend('AIC', 'BIC', 'Location', 'best');
grid on;

fprintf('\n===== ARIMA 与预测模块完成! =====\n');
