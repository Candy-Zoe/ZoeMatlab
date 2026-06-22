%% =========================================================================
%  子图与图形布局
%  学习目标：掌握 subplot, tiledlayout, 多窗口管理
%% =========================================================================

clear; clc; close all;

%% 1. 基本 subplot
disp('--- 基本 subplot ---');

x = 0:0.1:2*pi;

figure('Name', 'subplot 基本用法', 'Position', [100, 100, 800, 600]);

subplot(2, 2, 1);                % 2行2列，第1个位置
plot(x, sin(x), 'r-', 'LineWidth', 2);
title('sin(x)');
xlabel('x'); ylabel('y');
grid on;

subplot(2, 2, 2);                % 第2个位置
plot(x, cos(x), 'b-', 'LineWidth', 2);
title('cos(x)');
xlabel('x'); ylabel('y');
grid on;

subplot(2, 2, 3);                % 第3个位置
plot(x, tan(x), 'g-', 'LineWidth', 2);
title('tan(x)');
xlabel('x'); ylabel('y');
ylim([-5, 5]);
grid on;

subplot(2, 2, 4);                % 第4个位置
plot(x, sin(x) .* cos(x), 'm-', 'LineWidth', 2);
title('sin(x)*cos(x)');
xlabel('x'); ylabel('y');
grid on;

sgtitle('三角函数族', 'FontSize', 14, 'FontWeight', 'bold');  % 总标题

%% 2. 不等大子图
disp('--- 不等大子图 ---');

figure('Name', '不等大子图', 'Position', [100, 100, 800, 400]);

% 上面占两格
subplot(2, 2, [1, 2]);           % 合并第1、2格
plot(x, sin(x) + cos(x), 'k-', 'LineWidth', 2);
title('sin(x) + cos(x) 合并显示');
grid on;

% 下面左格
subplot(2, 2, 3);
plot(x, sin(x), 'r-');
title('sin(x)');
grid on;

% 下面右格
subplot(2, 2, 4);
plot(x, cos(x), 'b-');
title('cos(x)');
grid on;

%% 3. tiledlayout（R2019b+，推荐）
disp('--- tiledlayout ---');

x = 0:0.05:4*pi;

figure('Name', 'tiledlayout 示例', 'Position', [100, 100, 900, 600]);
t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% 第1个图
nexttile;
plot(x, sin(x), 'r-');
title('sin(x)');
xlabel('x'); ylabel('y');

% 第2个图
nexttile;
plot(x, cos(x), 'b-');
title('cos(x)');
xlabel('x'); ylabel('y');

% 第3个图
nexttile;
plot(x, sin(x/2), 'g-');
title('sin(x/2)');
xlabel('x'); ylabel('y');

% 第4个图
nexttile;
plot(x, cos(x/2), 'm-');
title('cos(x/2)');
xlabel('x'); ylabel('y');

title(t, '频率对比', 'FontSize', 14);    % 总标题

%% 4. tiledlayout 不等布局
disp('--- tiledlayout 不等布局 ---');

figure('Name', 'tiledlayout 混合布局', 'Position', [100, 100, 900, 500]);
t = tiledlayout(3, 2);

% 左上占2行
nexttile([2, 1]);
plot(x, sin(x) .* exp(-x/10), 'r-');
title('衰减正弦（占2行）');

% 右上
nexttile;
plot(x, cos(x), 'b-');
title('cos(x)');

% 右中
nexttile;
plot(x, sin(x), 'g-');
title('sin(x)');

% 底部占2列
nexttile([1, 2]);
plot(x, sin(x) + cos(x), 'k-', 'LineWidth', 2);
title('sin(x) + cos(x)（占2列）');

title(t, '混合布局示例');

%% 5. 多窗口管理
disp('--- 多窗口管理 ---');

% 创建指定编号的窗口
f1 = figure(10);
plot(x, sin(x));
title('Figure 10');

f2 = figure(20);
plot(x, cos(x));
title('Figure 20');

% 获取当前窗口
fprintf('当前活动窗口编号: %d\n', gcf);

% 切换回某个窗口
figure(f1);
disp('已切换回 Figure 10');

% 保存图形（取消注释以执行）
% saveas(f1, 'sin_plot.png');
% saveas(f1, 'sin_plot.fig');     % 保存为 MATLAB 格式，可编辑
% print(f1, '-dpdf', 'sin_plot.pdf');

disp('=== 脚本执行完毕 ===');
