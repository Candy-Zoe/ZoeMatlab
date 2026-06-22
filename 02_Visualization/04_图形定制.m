%% =========================================================================
%  图形定制（颜色、线型、标注、图例）
%  学习目标：掌握图形的详细定制方法
%% =========================================================================

clear; clc; close all;

%% 1. 颜色设置
disp('--- 颜色设置 ---');

x = 0:0.1:2*pi;

figure('Name', '颜色设置', 'Position', [100, 100, 800, 500]);

subplot(2,2,1);
% 预定义颜色：r g b c m y k w
plot(x, sin(x), 'r', x, cos(x), 'b');
title('预定义颜色 (r/b)');

subplot(2,2,2);
% RGB 自定义颜色 [R G B]，范围 0~1
plot(x, sin(x), 'Color', [0.8, 0.2, 0.5], 'LineWidth', 2);
hold on;
plot(x, cos(x), 'Color', [0.2, 0.7, 0.4], 'LineWidth', 2);
title('RGB 自定义颜色');
hold off;

subplot(2,2,3);
% 渐变效果（通过 scatter 实现）
scatter(x, sin(x), 30, x, 'filled');
colormap(hot);
colorbar;
title('渐变色散点');

subplot(2,2,4);
% 填充区域
fill([x, fliplr(x)], [sin(x), zeros(size(x))], ...
     [0.2 0.6 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'b');
title('填充区域');

%% 2. 线型与标记
disp('--- 线型与标记 ---');

x = 0:0.5:10;

figure('Name', '线型与标记', 'Position', [100, 100, 800, 300]);

% 线型：- 实线, -- 虚线, : 点线, -. 点划线
subplot(1,2,1);
plot(x, sin(x), '-',  x, sin(x-1), '--', ...
     x, sin(x-2), ':', x, sin(x-3), '-.');
title('四种线型');
legend('实线 -', '虚线 --', '点线 :', '点划线 -.', 'Location', 'best');

% 标记：o + * . x s d ^ v > < p h
subplot(1,2,2);
plot(x(1:5), 1:5, 'ro-', x(1:5), 2:6, 'bs--', ...
     x(1:5), 3:7, 'g^:', x(1:5), 4:8, 'md-.');
title('不同标记');
legend('圆形 o', '方块 s', '三角 ^', '菱形 d', 'Location', 'best');

%% 3. 坐标轴设置
disp('--- 坐标轴设置 ---');

x = 0:0.1:2*pi;

figure('Name', '坐标轴设置', 'Position', [100, 100, 700, 500]);

subplot(2,1,1);
plot(x, sin(x), 'b-', 'LineWidth', 1.5);
title('默认坐标轴');

subplot(2,1,2);
plot(x, sin(x), 'b-', 'LineWidth', 1.5);
xlim([0, 2*pi]);                     % 设置 x 轴范围
ylim([-1.5, 1.5]);                   % 设置 y 轴范围
xticks(0:pi/2:2*pi);                 % 设置刻度位置
xticklabels({'0', '\pi/2', '\pi', '3\pi/2', '2\pi'});  % 自定义刻度标签
title('定制坐标轴');
grid on;

% 双 y 轴
figure('Name', '双Y轴', 'Position', [100, 100, 600, 400]);
x = 0:0.1:10;
yyaxis left;
plot(x, sin(x), 'b-', 'LineWidth', 2);
ylabel('sin(x)', 'Color', 'b');

yyaxis right;
plot(x, x.^2, 'r--', 'LineWidth', 2);
ylabel('x^2', 'Color', 'r');

title('双 Y 轴示例');
xlabel('x');

%% 4. 标注（text, annotation）
disp('--- 标注 ---');

x = 0:0.01:2*pi;

figure('Name', '标注示例', 'Position', [100, 100, 700, 400]);
plot(x, sin(x), 'b-', 'LineWidth', 1.5);
hold on;

% 标注极值点
[ymax, idx] = max(sin(x));
x_max = x(idx);
plot(x_max, ymax, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(x_max + 0.1, ymax - 0.1, ...
     sprintf('最大值 (%.2f, %.2f)', x_max, ymax), ...
     'FontSize', 11, 'Color', 'r');

% 添加箭头标注
annotation('textarrow', [0.5, 0.4], [0.3, 0.5], ...
           'String', '正弦曲线', 'FontSize', 12);

% 矩形和椭圆标注
annotation('rectangle', [0.1, 0.15, 0.3, 0.2], ...
           'Color', 'g', 'LineWidth', 2);
annotation('ellipse', [0.6, 0.15, 0.3, 0.2], ...
           'Color', 'm', 'LineWidth', 2);

title('标注示例');
xlabel('x'); ylabel('y');
hold off;

%% 5. 图例与标题定制
disp('--- 图例与标题 ---');

x = linspace(0, 10, 100);

figure('Name', '图例定制', 'Position', [100, 100, 700, 400]);
h1 = plot(x, sin(x), 'r-', 'LineWidth', 2);
hold on;
h2 = plot(x, cos(x), 'b--', 'LineWidth', 2);
h3 = plot(x, exp(-x/5) .* sin(x), 'g-.', 'LineWidth', 2);

lgd = legend([h1, h2, h3], ...
             {'sin(x)', 'cos(x)', 'e^{-x/5}sin(x)'}, ...
             'Location', 'northeast', ...
             'FontSize', 12);
lgd.Box = 'on';
lgd.Color = [0.95, 0.95, 0.95];

title('图例定制示例', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12, 'FontAngle', 'italic');
hold off;

%% 6. 图形导出设置
disp('--- 图形导出提示 ---');
disp('常用导出方法:');
disp('  saveas(gcf, ''plot.png'')          - 保存为 PNG');
disp('  saveas(gcf, ''plot.fig'')          - 保存为 FIG（可编辑）');
disp('  print(gcf, ''-dpdf'', ''plot.pdf'') - 保存为 PDF');
disp('  exportgraphics(gcf, ''plot.png'', ''Resolution'', 300)');
disp('     - 高分辨率 PNG（R2020a+）');

disp('=== 脚本执行完毕 ===');
