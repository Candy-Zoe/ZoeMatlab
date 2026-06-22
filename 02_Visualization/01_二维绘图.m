%% =========================================================================
%  基础二维绘图
%  学习目标：掌握 plot, scatter, bar, stem, area 等二维图函数
%% =========================================================================

clear; clc; close all;

%% 1. 基本折线图 (plot)
disp('--- 基本折线图 ---');

x = 0:0.1:2*pi;
y = sin(x);

figure('Name', '基本折线图');
plot(x, y);
title('正弦函数 y = sin(x)');
xlabel('x (rad)');
ylabel('y');
grid on;

%% 2. 多条曲线
disp('--- 多条曲线 ---');

x = 0:0.1:2*pi;
y1 = sin(x);
y2 = cos(x);
y3 = sin(2*x);

figure('Name', '多条曲线');
plot(x, y1, 'r-', ...    % 红色实线
     x, y2, 'b--', ...   % 蓝色虚线
     x, y3, 'g-.');       % 绿色点划线
title('三角函数对比');
xlabel('x (rad)');
ylabel('y');
legend('sin(x)', 'cos(x)', 'sin(2x)', 'Location', 'best');
grid on;

%% 3. 散点图 (scatter)
disp('--- 散点图 ---');

rng(42);                                 % 固定随机种子
x = randn(100, 1);
y = 2*x + randn(100, 1) * 0.5;

figure('Name', '散点图');
scatter(x, y, 50, 'filled', 'MarkerFaceAlpha', 0.6);
title('散点图示例');
xlabel('X');
ylabel('Y');
grid on;

% 按颜色分组
groups = repmat([1;2], 50, 1);
figure('Name', '分组散点图');
gscatter(x, y, groups, 'rb', 'ox', 60, 'filled');
title('分组散点图');
legend('组A', '组B', 'Location', 'best');

%% 4. 柱状图 (bar)
disp('--- 柱状图 ---');

categories = {'语文', '数学', '英语', '物理', '化学'};
scores = [85, 92, 78, 88, 95];

figure('Name', '柱状图');
bar(scores, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTickLabel', categories);
title('各科成绩');
ylabel('分数');
grid on;
ylim([0, 100]);

% 在每个柱子上标注数值
for i = 1:length(scores)
    text(i, scores(i) + 2, num2str(scores(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 10);
end

%% 5. 分组柱状图
disp('--- 分组柱状图 ---');

data = [85, 90;
        92, 88;
        78, 85;
        88, 92;
        95, 90];

figure('Name', '分组柱状图');
b = bar(data, 'grouped');
b(1).FaceColor = [0.2 0.6 0.8];
b(2).FaceColor = [0.9 0.3 0.2];
set(gca, 'XTickLabel', categories);
title('期中 vs 期末成绩对比');
ylabel('分数');
legend('期中', '期末', 'Location', 'best');
grid on;

%% 6. 茎叶图 (stem) 和 面积图 (area)
disp('--- 茎叶图与面积图 ---');

% 茎叶图
n = 0:15;
y_stem = sin(n*pi/8);

figure('Name', '茎叶图');
stem(n, y_stem, 'filled', 'MarkerSize', 6);
title('离散信号 - 茎叶图');
xlabel('n');
ylabel('y');
grid on;

% 面积图
x = 1:10;
y_area = [3, 5, 2, 8, 6, 9, 4, 7, 5, 8];

figure('Name', '面积图');
area(x, y_area, 'FaceColor', [0.2 0.6 0.8], 'FaceAlpha', 0.5);
title('面积图示例');
xlabel('X');
ylabel('Y');
grid on;

%% 7. 饼图 (pie)
disp('--- 饼图 ---');

labels = {'产品A', '产品B', '产品C', '产品D'};
values = [35, 25, 20, 20];
explode = [0, 1, 0, 0];       % 第2块突出显示

figure('Name', '饼图');
pie(values, explode, labels);
title('产品销售占比');

%% 8. 直方图 (histogram)
disp('--- 直方图 ---');

rng(0);
data = randn(1000, 1);

figure('Name', '直方图');
histogram(data, 30, 'FaceColor', [0.2 0.6 0.8], 'FaceAlpha', 0.7);
title('正态分布直方图');
xlabel('值');
ylabel('频数');
grid on;

% 添加正态曲线
hold on;
x_fit = -4:0.1:4;
y_fit = normpdf(x_fit, 0, 1) * 1000 * (8/30);
plot(x_fit, y_fit, 'r-', 'LineWidth', 2);
legend('直方图', '正态曲线');
hold off;

%% 9. 极坐标图 (polarplot)
disp('--- 极坐标图 ---');

theta = 0:0.01:2*pi;
rho = sin(3*theta);

figure('Name', '极坐标图');
polarplot(theta, rho, 'LineWidth', 2);
title('三叶玫瑰线 r = sin(3\theta)');

disp('=== 脚本执行完毕，共生成多个图形窗口 ===');
