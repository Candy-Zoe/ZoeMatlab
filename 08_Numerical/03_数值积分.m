%% =========================================================================
%  数值积分
%  学习目标：掌握定积分的数值计算方法
%% =========================================================================

clear; clc; close all;

%% 1. 一维定积分 (integral)
disp('--- 一维定积分 ---');

% 基本用法
f = @(x) x.^2;
I1 = integral(f, 0, 1);
fprintf('∫_0^1 x^2 dx = %.6f (理论值: 1/3)\n', I1);

% 更复杂的函数
g = @(x) exp(-x.^2);
I2 = integral(g, -inf, inf);
fprintf('∫_{-∞}^{∞} e^{-x^2} dx = %.6f (理论值: √π ≈ %.6f)\n', I2, sqrt(pi));

% 振荡函数
h = @(x) sin(10*x) ./ x;
I3 = integral(h, 0.01, 10, 'RelTol', 1e-8);
fprintf('∫ sin(10x)/x dx [0.01,10] = %.6f\n', I3);

%% 2. 带参数的积分
disp('--- 参数积分 ---');

% ∫_0^1 a*x^n dx
a = 3; n = 4;
f_param = @(x) a * x.^n;
I_param = integral(f_param, 0, 1);
fprintf('∫_0^1 %d*x^%d dx = %.6f (理论值: %d/%d = %.6f)\n', ...
        a, n, I_param, a, n+1, a/(n+1));

%% 3. 二维积分 (integral2)
disp('--- 二维积分 ---');

% ∫∫ x*y dx dy, x∈[0,1], y∈[0,2]
f_2d = @(x, y) x .* y;
I_2d = integral2(f_2d, 0, 1, 0, 2);
fprintf('∫∫ x*y dx dy = %.6f (理论值: 1)\n', I_2d);

% 圆形区域积分
f_circle = @(x, y) exp(-(x.^2 + y.^2));
I_circle = integral2(f_circle, -2, 2, @(x) -sqrt(max(4-x.^2,0)), ...
                     @(x) sqrt(max(4-x.^2,0)));
fprintf('圆形区域 ∫∫ e^{-(x^2+y^2)} = %.6f\n', I_circle);

%% 4. 梯形法 (trapz)
disp('--- 梯形法 ---');

% 离散数据积分
x = linspace(0, 2*pi, 100);
y = sin(x);

I_trapz = trapz(x, y);
fprintf('∫_0^{2π} sin(x) dx (trapz) = %.6f (理论值: 0)\n', I_trapz);

% 不同采样密度的精度
fprintf('\n不同采样密度的精度:\n');
for N = [10, 50, 100, 500, 1000]
    x_N = linspace(0, pi, N);
    y_N = sin(x_N);
    I_N = trapz(x_N, y_N);
    fprintf('  N=%4d: ∫ sin(x) dx = %.8f (误差: %.2e)\n', N, I_N, abs(I_N - 2));
end

%% 5. 累积积分 (cumtrapz)
disp('--- 累积积分 ---');

x = linspace(0, 4*pi, 200);
y = sin(x);
y_cum = cumtrapz(x, y);                % 累积积分

figure('Name', '累积积分', 'Position', [100, 100, 700, 400]);

subplot(2,1,1);
plot(x, y, 'b-', 'LineWidth', 1.5);
title('f(x) = sin(x)');
xlabel('x'); ylabel('f(x)');
grid on;

subplot(2,1,2);
plot(x, y_cum, 'r-', 'LineWidth', 2);
hold on;
plot(x, -cos(x) + 1, 'k--', 'LineWidth', 1.5);   % 理论值: 1-cos(x)
title('∫ sin(x) dx = 1 - cos(x)');
xlabel('x'); ylabel('F(x)');
legend('cumtrapz', '理论值 1-cos(x)', 'Location', 'best');
grid on;
hold off;

%% 6. 数值积分应用：求面积
disp('--- 应用：求曲线下面积 ---');

% 用蒙特卡罗方法估算 π
rng(42);
N = 100000;
pts = rand(N, 2) * 2 - 1;             % [-1, 1] 内的随机点
inside = sum(pts(:,1).^2 + pts(:,2).^2 <= 1);
pi_mc = 4 * inside / N;
fprintf('蒙特卡罗估算 π = %.4f (真实值: %.4f)\n', pi_mc, pi);

figure('Name', '蒙特卡罗估算π', 'Position', [100, 100, 500, 500]);
scatter(pts(1:min(N,5000),1), pts(1:min(N,5000),2), 1, ...
        pts(1:min(N,5000),1).^2 + pts(1:min(N,5000),2).^2 <= 1, ...
        'filled', 'MarkerFaceAlpha', 0.3);
colormap([0.7 0.7 0.7; 0.2 0.6 0.8]);
title(sprintf('蒙特卡罗估算 π ≈ %.4f', pi_mc));
axis equal;
hold on;
theta = linspace(0, 2*pi, 100);
plot(cos(theta), sin(theta), 'k-', 'LineWidth', 2);
hold off;

disp('=== 脚本执行完毕 ===');
