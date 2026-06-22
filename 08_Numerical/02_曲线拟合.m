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

%% 6. 样条插值与拟合
fprintf('\n--- 样条拟合 ---\n');

% 自然三次样条
x_sp = [0, 1, 2, 3, 4, 5]';
y_sp = [0, 1.5, 2.0, 1.8, 2.5, 3.0]';

% 三次样条插值 (通过所有点)
pp = spline(x_sp, y_sp);
x_fine = linspace(0, 5, 200)';
y_spline = ppval(pp, x_fine);

% 平滑样条 (csaps, 不通过所有点)
try
    pp_smooth = csaps(x_sp, y_sp + 0.2*randn(size(y_sp)), 0.9);
    y_smooth = fnval(pp_smooth, x_fine);
    has_csaps = true;
catch
    has_csaps = false;
end

figure('Name', '样条拟合', 'Position', [100, 100, 800, 400]);
subplot(1,2,1);
scatter(x_sp, y_sp, 80, 'r', 'filled', 'DisplayName', '原始数据'); hold on;
plot(x_fine, y_spline, 'b-', 'LineWidth', 2, 'DisplayName', '三次样条');
if has_csaps
    plot(x_fine, y_smooth, 'g--', 'LineWidth', 2, 'DisplayName', '平滑样条');
end
xlabel('x'); ylabel('y');
title('样条插值与拟合');
legend('Location', 'best');
grid on;

% pchip (保形分段三次插值)
subplot(1,2,2);
y_pchip = pchip(x_sp, y_sp, x_fine);
scatter(x_sp, y_sp, 80, 'r', 'filled'); hold on;
plot(x_fine, y_spline, 'b-', 'LineWidth', 2); 
plot(x_fine, y_pchip, 'm--', 'LineWidth', 2);
xlabel('x'); ylabel('y');
title('spline vs pchip');
legend('数据', 'spline', 'pchip', 'Location', 'best');
grid on;

%% 7. 残差分析与模型选择
fprintf('\n--- 残差分析 ---\n');

% 用之前的二阶拟合数据
residuals = y - y_pred;

figure('Name', '残差分析', 'Position', [100, 100, 1000, 400]);
subplot(1,3,1);
scatter(y_pred, residuals, 20, 'filled');
hold on;
yline(0, 'r-', 'LineWidth', 2);
xlabel('预测值'); ylabel('残差');
title('残差 vs 预测值');
grid on;

% QQ图
subplot(1,3,2);
qqplot(residuals);
title('残差QQ图 (正态性检验)');

% 残差直方图
subplot(1,3,3);
histogram(residuals, 15, 'Normalization', 'pdf');
hold on;
x_r = linspace(min(residuals), max(residuals), 100);
plot(x_r, normpdf(x_r, mean(residuals), std(residuals)), 'r-', 'LineWidth', 2);
xlabel('残差'); ylabel('概率密度');
title('残差分布');
legend('直方图', '正态拟合');

%% 8. 过拟合与交叉验证概念
fprintf('\n--- 过拟合与交叉验证 ---\n');

% 不同阶数的训练误差 vs 测试误差
rng(42);
x_all = linspace(0, 10, 100)';
y_all = 2*x_all.^2 - 3*x_all + 5 + randn(100,1)*3;

% 分割训练/测试
train_idx = 1:70;
test_idx = 71:100;

train_errors = zeros(1, 6);
test_errors = zeros(1, 6);

for deg = 1:6
    p_deg = polyfit(x_all(train_idx), y_all(train_idx), deg);
    y_train_pred = polyval(p_deg, x_all(train_idx));
    y_test_pred = polyval(p_deg, x_all(test_idx));
    train_errors(deg) = sqrt(mean((y_all(train_idx) - y_train_pred).^2));
    test_errors(deg) = sqrt(mean((y_all(test_idx) - y_test_pred).^2));
end

figure('Name', '过拟合分析');
plot(1:6, train_errors, 'bo-', 'LineWidth', 2, 'MarkerSize', 8); hold on;
plot(1:6, test_errors, 'rs-', 'LineWidth', 2, 'MarkerSize', 8);
xline(2, 'k--', '真实阶数=2');
xlabel('多项式阶数'); ylabel('RMSE');
title('训练误差 vs 测试误差 (过拟合分析)');
legend('训练集', '测试集', 'Location', 'best');
grid on;

fprintf('阶数  训练RMSE  测试RMSE\n');
for deg = 1:6
    fprintf('  %d     %.3f    %.3f\n', deg, train_errors(deg), test_errors(deg));
end
fprintf('\n结论: 阶数过高导致过拟合，测试误差上升\n');

%% === 总结 ===
fprintf('\n=== 曲线拟合总结 ===\n');
fprintf('1. 多项式拟合: polyfit/polyval, 阶数选择\n');
fprintf('2. fit函数: gauss1, exp1, 自定义模型\n');
fprintf('3. 样条拟合: spline, pchip, csaps\n');
fprintf('4. 残差分析: 残差图、QQ图、正态性检验\n');
fprintf('5. 过拟合: 训练/测试误差分离, 交叉验证\n');
