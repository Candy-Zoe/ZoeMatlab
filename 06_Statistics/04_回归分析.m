%% =========================================================================
%  回归分析
%  学习目标：掌握线性回归、多项式回归、模型评估
%% =========================================================================

clear; clc; close all;

%% 1. 简单线性回归
disp('--- 简单线性回归 ---');

rng(42);
x = (1:50)';
y = 2.5*x + 10 + randn(50, 1)*5;     % y = 2.5x + 10 + noise

% 用 polyfit 进行线性回归（1阶多项式）
p = polyfit(x, y, 1);
fprintf('拟合结果: y = %.4f*x + %.4f\n', p(1), p(2));
fprintf('真实参数: y = 2.5*x + 10\n');

% 计算 R^2
y_pred = polyval(p, x);
SS_res = sum((y - y_pred).^2);
SS_tot = sum((y - mean(y)).^2);
R2 = 1 - SS_res / SS_tot;
fprintf('R^2 = %.4f\n', R2);

% 可视化
figure('Name', '线性回归', 'Position', [100, 100, 700, 400]);
subplot(1,2,1);
scatter(x, y, 30, 'filled', 'MarkerFaceAlpha', 0.5);
hold on;
plot(x, y_pred, 'r-', 'LineWidth', 2);
title(sprintf('线性回归 R^2 = %.4f', R2));
xlabel('x'); ylabel('y');
legend('数据', sprintf('y=%.2fx+%.2f', p(1), p(2)));
grid on;
hold off;

%% 2. 多项式回归
disp('--- 多项式回归 ---');

x2 = linspace(-3, 3, 100)';
y2 = 2*x2.^3 - x2.^2 + 3*x2 + 5 + randn(100, 1)*3;

% 尝试不同阶数拟合
figure('Name', '多项式回归', 'Position', [100, 100, 800, 400]);

subplot(1,2,1);
scatter(x2, y2, 10, 'filled', 'MarkerFaceAlpha', 0.3);
hold on;
for deg = [1, 2, 3, 5]
    p_deg = polyfit(x2, y2, deg);
    y_fit = polyval(p_deg, x2);
    plot(x2, y_fit, 'LineWidth', 1.5);
end
title('多项式回归对比');
legend('数据', '1阶', '2阶', '3阶', '5阶', 'Location', 'best');
grid on;
hold off;

% 过拟合警告
subplot(1,2,2);
scatter(x2, y2, 10, 'filled', 'MarkerFaceAlpha', 0.3);
hold on;
for deg = [3, 10, 20]
    p_deg = polyfit(x2, y2, deg);
    y_fit = polyval(p_deg, x2);
    plot(x2, y_fit, 'LineWidth', 1.5);
end
title('过拟合警告');
legend('数据', '3阶', '10阶', '20阶', 'Location', 'best');
grid on;
hold off;

%% 3. fitlm 线性模型（需要 Statistics Toolbox）
disp('--- fitlm ---');

x3 = (1:100)';
y3 = 3*x3 + 20 + randn(100, 1)*10;

% 使用 fitlm
mdl = fitlm(x3, y3);
disp(mdl);

% 提取信息
fprintf('系数:\n');
disp(mdl.Coefficients);
fprintf('R^2 = %.4f, Adjusted R^2 = %.4f\n', mdl.Rsquared.Ordinary, mdl.Rsquared.Adjusted);
fprintf('RMSE = %.4f\n', mdl.RMSE);

% 残差图
figure('Name', '回归诊断', 'Position', [100, 100, 800, 400]);

subplot(1,2,1);
plotResiduals(mdl, 'fitted');
title('残差 vs 拟合值');

subplot(1,2,2);
plotResiduals(mdl, 'probability');
title('残差正态概率图');

%% 4. 多元线性回归
disp('--- 多元线性回归 ---');

rng(42);
n = 100;
x1 = randn(n, 1)*10;
x2 = randn(n, 1)*5;
x3 = randn(n, 1)*3;
y4 = 2*x1 - 3*x2 + 0.5*x3 + 10 + randn(n, 1)*2;

% 构建设计矩阵
X = [ones(n,1), x1, x2, x3];
% 最小二乘
beta = X \ y4;
fprintf('系数估计: β0=%.2f, β1=%.2f, β2=%.2f, β3=%.2f\n', ...
        beta(1), beta(2), beta(3), beta(4));
fprintf('真实参数: β0=10, β1=2, β2=-3, β3=0.5\n');

% R^2
y4_pred = X * beta;
R2_multi = 1 - sum((y4 - y4_pred).^2) / sum((y4 - mean(y4)).^2);
fprintf('R^2 = %.4f\n', R2_multi);

disp('=== 脚本执行完毕 ===');
