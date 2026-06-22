%% =========================================================================
%  描述统计
%  学习目标：掌握基本统计量计算与可视化
%  需要: Statistics and Machine Learning Toolbox
%% =========================================================================

clear; clc; close all;

%% 1. 基本统计量
disp('--- 基本统计量 ---');

rng(42);
data = normrnd(50, 10, 1, 100);       % 100个 N(50,10) 样本

fprintf('均值 mean     = %.2f\n', mean(data));
fprintf('中位数 median = %.2f\n', median(data));
fprintf('标准差 std    = %.2f\n', std(data));
fprintf('方差 var      = %.2f\n', var(data));
fprintf('最大值 max    = %.2f\n', max(data));
fprintf('最小值 min    = %.2f\n', min(data));
fprintf('极差 range    = %.2f\n', range(data));

% 分位数
fprintf('25%%分位数     = %.2f\n', prctile(data, 25));
fprintf('50%%分位数     = %.2f\n', prctile(data, 50));
fprintf('75%%分位数     = %.2f\n', prctile(data, 75));

%% 2. 偏度与峰度
disp('--- 偏度与峰度 ---');

fprintf('偏度 skewness = %.4f  (>0 右偏, <0 左偏)\n', skewness(data));
fprintf('峰度 kurtosis = %.4f  (>3 尖峰, <3 扁平)\n', kurtosis(data));

% 对比不同分布
data_skew_right = exprnd(2, 1, 1000);
data_skew_left  = -exprnd(2, 1, 1000) + 10;
data_symmetric  = normrnd(5, 1, 1, 1000);

fprintf('\n右偏分布: 偏度=%.2f, 峰度=%.2f\n', skewness(data_skew_right), kurtosis(data_skew_right));
fprintf('左偏分布: 偏度=%.2f, 峰度=%.2f\n', skewness(data_skew_left), kurtosis(data_skew_left));
fprintf('对称分布: 偏度=%.2f, 峰度=%.2f\n', skewness(data_symmetric), kurtosis(data_symmetric));

%% 3. 箱线图 (boxplot)
disp('--- 箱线图 ---');

rng(0);
group1 = normrnd(50, 10, 1, 100);
group2 = normrnd(55, 8, 1, 100);
group3 = normrnd(48, 15, 1, 100);

figure('Name', '箱线图', 'Position', [100, 100, 700, 400]);
boxplot([group1; group2; group3]', {'组A', '组B', '组C'});
title('三组数据箱线图对比');
ylabel('值');
grid on;

%% 4. 相关性分析
disp('--- 相关性 ---');

rng(42);
x = randn(100, 1);
y1 = 2*x + randn(100, 1)*0.5;         % 强正相关
y2 = -x + randn(100, 1)*0.5;          % 负相关
y3 = randn(100, 1);                    % 无相关

fprintf('corr(x, y1) = %.4f  (强正相关)\n', corr(x, y1));
fprintf('corr(x, y2) = %.4f  (负相关)\n', corr(x, y2));
fprintf('corr(x, y3) = %.4f  (无相关)\n', corr(x, y3));

% 相关矩阵
data_corr = [x, y1, y2, y3];
R = corrcoef(data_corr);
disp('相关系数矩阵:'); disp(R);

%% 5. 多维统计可视化
disp('--- 多维统计可视化 ---');

rng(42);
data_2d = mvnrnd([50, 60], [100 80; 80 100], 500);

figure('Name', '多维统计', 'Position', [100, 100, 800, 400]);

subplot(1,2,1);
scatter(data_2d(:,1), data_2d(:,2), 5, 'filled', 'MarkerFaceAlpha', 0.3);
hold on;
% 画均值点
plot(mean(data_2d(:,1)), mean(data_2d(:,2)), 'r*', 'MarkerSize', 15);
title('二维散点 + 均值');
xlabel('X'); ylabel('Y');
grid on;
hold off;

subplot(1,2,2);
% 协方差椭圆
cov_mat = cov(data_2d);
[eigvec, eigval] = eig(cov_mat);
theta = linspace(0, 2*pi, 100);
ellipse = [cos(theta); sin(theta)];
for scale = [1, 2, 3]
    pts = eigvec * sqrt(eigval) * scale * ellipse;
    plot(pts(1,:) + mean(data_2d(:,1)), pts(2,:) + mean(data_2d(:,2)), ...
         'LineWidth', 1.5);
    hold on;
end
plot(mean(data_2d(:,1)), mean(data_2d(:,2)), 'r*', 'MarkerSize', 15);
title('协方差椭圆 (1σ, 2σ, 3σ)');
xlabel('X'); ylabel('Y');
axis equal;
grid on;
hold off;

disp('=== 脚本执行完毕 ===');
