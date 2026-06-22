%% =========================================================================
%  曲线拟合
%  学习目标：掌握 polyfit、fit 等曲线拟合方法
%% =========================================================================

clear; clc; close all;

%% 1. 多项式拟合 (polyfit / polyval)
disp('--- 多项式拟合 ---');

rng(42);
x = linspace(0, 10, 50)';
y = 2*x.^2 - 3*x + 5 + randn(size(x))*3;

% 不同阶数拟合
figure('Name', '多项式拟合', 'Position', [100, 100, 800, 400]);

subplot(1,2,1);
scatter(x, y, 15, 'filled', 'MarkerFaceAlpha', 0.5); hold on;
for deg = 1:4
    p = polyfit(x, y, deg);
    y_fit = polyval(p, x);
    plot(x, y_fit, 'LineWidth', 1.5);
end
title('多项式拟合对比');
legend('数据', '1阶', '2阶', '3阶', '4阶', 'Location', 'best');
grid on; hold off;

% 最佳拟合（2阶，匹配真实模型）
p_best = polyfit(x, y, 2);
fprintf('拟合结果: y = %.4f*x^2 + %.4f*x + %.4f\n', p_best(1), p_best(2), p_best(3));
fprintf('真实参数: y = 2*x^2 - 3*x + 5\n');

%% 2. 拟合质量评估
disp('--- 拟合质量评估 ---');

y_pred = polyval(p_best, x);
SS_res = sum((y - y_pred).^2);
SS_tot = sum((y - mean(y)).^2);
R2 = 1 - SS_res / SS_tot;
RMSE = sqrt(mean((y - y_pred).^2));

fprintf('R^2 = %.4f\n', R2);
fprintf('RMSE = %.4f\n', RMSE);

subplot(1,2,2);
scatter(x, y, 15, 'filled', 'MarkerFaceAlpha', 0.5); hold on;
plot(x, y_pred, 'r-', 'LineWidth', 2);
title(sprintf('最佳拟合 R^2=%.4f, RMSE=%.2f', R2, RMSE));
legend('数据', '2阶拟合', 'Location', 'best');
grid on; hold off;

%% 3. fit 函数（Curve Fitting Toolbox）
disp('--- fit 函数 ---');

% 高斯拟合
x_gauss = (-5:0.1:5)';
y_gauss = 3*exp(-x_gauss.^2/2) + 0.2*randn(size(x_gauss));

f_gauss = fit(x_gauss, y_gauss, 'gauss1');
fprintf('高斯拟合: %s\n', formula(f_gauss));
disp(f_gauss);

figure('Name', '高斯拟合', 'Position', [100, 100, 600, 400]);
plot(f_gauss, x_gauss, y_gauss);
title('高斯拟合 gauss1');

%% 4. 指数拟合
disp('--- 指数拟合 ---');

x_exp = (0:0.1:5)';
y_exp = 2*exp(-0.5*x_exp) + 0.1*randn(size(x_exp));

f_exp = fit(x_exp, y_exp, 'exp1');
fprintf('指数拟合: %s\n', formula(f_exp));
disp(f_exp);

figure('Name', '指数拟合', 'Position', [100, 100, 600, 400]);
plot(f_exp, x_exp, y_exp);
title('指数拟合 exp1');

%% 5. 自定义拟合模型
disp('--- 自定义模型 ---');

% 自定义: y = a*sin(b*x) + c
x_custom = (0:0.1:10)';
y_custom = 3*sin(2*x_custom) + 1 + 0.3*randn(size(x_custom));

ft = fittype('a*sin(b*x) + c', 'independent', 'x');
opts = fitoptions(ft);
opts.StartPoint = [1, 1, 0];           % 初始猜测

[f_custom, gof] = fit(x_custom, y_custom, ft, opts);
fprintf('自定义拟合: %s\n', formula(f_custom));
fprintf('参数: a=%.2f, b=%.2f, c=%.2f\n', f_custom.a, f_custom.b, f_custom.c);
fprintf('R^2 = %.4f\n', gof.rsquare);

figure('Name', '自定义拟合', 'Position', [100, 100, 600, 400]);
plot(f_custom, x_custom, y_custom);
title(sprintf('自定义拟合: %s', formula(f_custom)));

disp('=== 脚本执行完毕 ===');
