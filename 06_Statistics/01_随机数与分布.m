%% =========================================================================
%  随机数与分布
%  学习目标：掌握随机数生成、常见概率分布及可视化
%  需要: Statistics and Machine Learning Toolbox（部分功能基础 MATLAB 即可）
%% =========================================================================

clear; clc; close all;

%% 1. 随机数生成
disp('--- 随机数生成 ---');

% rand: 均匀分布 [0,1]
rng(42);                                % 设置种子保证可重复
u = rand(1, 5);
fprintf('rand(1,5):  [%.4f %.4f %.4f %.4f %.4f]\n', u);

% randn: 标准正态分布 N(0,1)
n = randn(1, 5);
fprintf('randn(1,5): [%.4f %.4f %.4f %.4f %.4f]\n', n);

% randi: 随机整数
i = randi([1, 10], 1, 5);
fprintf('randi(1~10): [%d %d %d %d %d]\n', i);

% 指定大小的随机矩阵
A = rand(3, 4);
fprintf('rand(3,4) 大小: [%s]\n', num2str(size(A)));

% 控制范围: [a, b]
a = 10; b = 20;
x = a + (b-a)*rand(1, 5);
fprintf('[10,20] 均匀: [%.2f %.2f %.2f %.2f %.2f]\n', x);

%% 2. 常见概率分布
disp('--- 常见分布 ---');

x_norm = -4:0.1:4;
x_exp  = 0:0.01:5;
x_chi2 = 0:0.1:20;
x_binom = 0:20;

figure('Name', '概率密度函数', 'Position', [100, 100, 900, 600]);

% 正态分布
subplot(2,2,1);
plot(x_norm, normpdf(x_norm, 0, 1), 'b-', 'LineWidth', 2); hold on;
plot(x_norm, normpdf(x_norm, 0, 0.5), 'r--');
plot(x_norm, normpdf(x_norm, 0, 2), 'g--');
title('正态分布 N(μ, σ^2)');
legend('N(0,1)', 'N(0,0.25)', 'N(0,4)', 'Location', 'best');
grid on; hold off;

% 指数分布
subplot(2,2,2);
plot(x_exp, exppdf(x_exp, 1), 'b-', 'LineWidth', 2); hold on;
plot(x_exp, exppdf(x_exp, 0.5), 'r--');
plot(x_exp, exppdf(x_exp, 2), 'g--');
title('指数分布 Exp(λ)');
legend('λ=1', 'λ=2', 'λ=0.5', 'Location', 'best');
grid on; hold off;

% 卡方分布
subplot(2,2,3);
plot(x_chi2, chi2pdf(x_chi2, 2), 'b-', 'LineWidth', 2); hold on;
plot(x_chi2, chi2pdf(x_chi2, 5), 'r--');
plot(x_chi2, chi2pdf(x_chi2, 10), 'g--');
title('卡方分布 χ^2(k)');
legend('k=2', 'k=5', 'k=10', 'Location', 'best');
grid on; hold off;

% 二项分布
subplot(2,2,4);
stem(x_binom, binopdf(x_binom, 20, 0.3), 'b', 'filled'); hold on;
stem(x_binom, binopdf(x_binom, 20, 0.5), 'r', 'filled');
title('二项分布 B(n, p)');
legend('B(20,0.3)', 'B(20,0.5)', 'Location', 'best');
grid on; hold off;

%% 3. 随机采样可视化
disp('--- 随机采样 ---');

rng(0);
N = 5000;

figure('Name', '随机采样', 'Position', [100, 100, 900, 400]);

% 正态采样 + 直方图
subplot(1,3,1);
samples_norm = randn(N, 1);
histogram(samples_norm, 50, 'Normalization', 'pdf', 'FaceColor', [0.2 0.6 0.8]);
hold on;
plot(x_norm, normpdf(x_norm), 'r-', 'LineWidth', 2);
title('N(0,1) 采样');
legend('直方图', '理论密度');
hold off;

% 均匀采样散点
subplot(1,3,2);
scatter(rand(N,1), rand(N,1), 2, 'filled', 'MarkerFaceAlpha', 0.1);
title('U(0,1) 二维采样');
axis equal;

% 二维正态采样
subplot(1,3,3);
samples_2d = mvnrnd([0,0], [1 0.8; 0.8 1], N);
scatter(samples_2d(:,1), samples_2d(:,2), 2, 'filled', 'MarkerFaceAlpha', 0.1);
title('二元正态 (ρ=0.8)');
axis equal;

disp('=== 脚本执行完毕 ===');
