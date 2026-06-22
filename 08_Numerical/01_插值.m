%% =========================================================================
%  插值
%  学习目标：掌握一维/二维插值方法
%% =========================================================================

clear; clc; close all;

%% 1. 一维线性插值 (interp1)
disp('--- 一维线性插值 ---');

% 原始数据点
x = [1, 2, 3, 4, 5];
y = [2, 4, 3, 5, 4];

% 插值查询点
xq = 1:0.1:5;

% 不同插值方法
y_linear = interp1(x, y, xq, 'linear');
y_nearest = interp1(x, y, xq, 'nearest');
y_cubic = interp1(x, y, xq, 'cubic');
y_spline = interp1(x, y, xq, 'spline');

figure('Name', '一维插值对比', 'Position', [100, 100, 800, 500]);

subplot(2,2,1);
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); hold on;
plot(xq, y_linear, 'r-', 'LineWidth', 1.5);
title('线性插值 (linear)');
grid on; hold off;

subplot(2,2,2);
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); hold on;
plot(xq, y_nearest, 'b-', 'LineWidth', 1.5);
title('最近邻插值 (nearest)');
grid on; hold off;

subplot(2,2,3);
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); hold on;
plot(xq, y_cubic, 'g-', 'LineWidth', 1.5);
title('三次插值 (cubic)');
grid on; hold off;

subplot(2,2,4);
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); hold on;
plot(xq, y_spline, 'm-', 'LineWidth', 1.5);
title('样条插值 (spline)');
grid on; hold off;

%% 2. 样条插值
disp('--- 样条插值 ---');

% 用更少的点重建连续信号
t_full = 0:0.01:10;
y_full = sin(t_full) + 0.3*sin(5*t_full);

% 稀疏采样
t_sparse = 0:1:10;
y_sparse = sin(t_sparse) + 0.3*sin(5*t_sparse);

% 不同插值
t_interp = 0:0.05:10;
y_linear_i = interp1(t_sparse, y_sparse, t_interp, 'linear');
y_spline_i = interp1(t_sparse, y_sparse, t_interp, 'spline');

figure('Name', '样条插值', 'Position', [100, 100, 700, 300]);
plot(t_full, y_full, 'k-', 'LineWidth', 2); hold on;
plot(t_sparse, y_sparse, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
plot(t_interp, y_linear_i, 'r--', 'LineWidth', 1.5);
plot(t_interp, y_spline_i, 'b-', 'LineWidth', 1.5);
title('稀疏信号重建');
xlabel('t'); ylabel('y');
legend('原始信号', '采样点', '线性插值', '样条插值', 'Location', 'best');
grid on;
hold off;

% 误差对比
y_linear_full = interp1(t_sparse, y_sparse, t_full, 'linear');
y_spline_full = interp1(t_sparse, y_sparse, t_full, 'spline');
fprintf('线性插值误差 (RMSE): %.4f\n', sqrt(mean((y_full - y_linear_full).^2)));
fprintf('样条插值误差 (RMSE): %.4f\n', sqrt(mean((y_full - y_spline_full).^2)));

%% 3. 二维插值 (interp2)
disp('--- 二维插值 ---');

% 创建低分辨率数据
[X_lo, Y_lo] = meshgrid(1:0.5:5, 1:0.5:5);
Z_lo = sin(X_lo) .* cos(Y_lo);

% 高分辨率插值
[X_hi, Y_hi] = meshgrid(1:0.05:5, 1:0.05:5);
Z_linear_2d = interp2(X_lo, Y_lo, Z_lo, X_hi, Y_hi, 'linear');
Z_cubic_2d = interp2(X_lo, Y_lo, Z_lo, X_hi, Y_hi, 'cubic');

figure('Name', '二维插值', 'Position', [100, 100, 900, 300]);

subplot(1,3,1);
surf(X_lo, Y_lo, Z_lo, 'EdgeColor', 'k');
title('原始低分辨率');

subplot(1,3,2);
surf(X_hi, Y_hi, Z_linear_2d, 'EdgeColor', 'none');
title('线性插值');
colormap(parula);

subplot(1,3,3);
surf(X_hi, Y_hi, Z_cubic_2d, 'EdgeColor', 'none');
title('三次插值');
colormap(parula);

disp('=== 脚本执行完毕 ===');
