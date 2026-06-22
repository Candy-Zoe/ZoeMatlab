%% 02_布局管理.m — GUI 布局设计
%  涵盖: uigridlayout, uipanel, 响应式布局
%  基础 MATLAB 即可

clear; clc; close all;

%% ===== 1. 网格布局基础 =====
fprintf('===== 1. 网格布局 (uigridlayout) =====\n');

fig = uifigure('Name', '网格布局示例', 'Position', [100 100 800 600]);

% 创建 3x3 网格布局
grid = uigridlayout(fig, [3 3]);
grid.RowHeight = {'1x', '2x', '1x'};   % 行高比例
grid.ColumnWidth = {'1x', '2x', '1x'};  % 列宽比例
grid.Padding = 10;
grid.RowSpacing = 8;
grid.ColumnSpacing = 8;

% 在每个格子放置控件
% 第1行
uilabel(grid, 'Text', '标题栏', 'FontWeight', 'bold', ...
    'FontSize', 16, 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.9 0.9 1], ...
    'Layout', uigridlayout([1 1], 'RowSpan', 1, 'ColumnSpan', 3));

% 第2行: 左中右
pnl_left = uipanel(grid, 'Title', '左侧面板', 'Layout', uigridlayout([2 2], 'Row', 2, 'Column', 1));
uibutton(pnl_left, 'Text', '按钮 A', 'Position', [10 60 80 30]);
uibutton(pnl_left, 'Text', '按钮 B', 'Position', [10 20 80 30]);

pnl_center = uipanel(grid, 'Title', '主工作区', 'Layout', uigridlayout([2 2], 'Row', 2, 'Column', 2));
ax = uiaxes(pnl_center, 'Position', [10 10 200 150]);
plot(ax, 1:10, rand(1,10), 'b-o');
title(ax, '示例图表');

pnl_right = uipanel(grid, 'Title', '右侧工具', 'Layout', uigridlayout([2 2], 'Row', 2, 'Column', 3));
uilabel(pnl_right, 'Text', '参数设置:', 'Position', [10 120 100 20]);
uieditfield(pnl_right, 'numeric', 'Position', [10 90 100 25], 'Value', 100);
uislider(pnl_right, 'Position', [10 50 100 15]);
uicheckbox(pnl_right, 'Text', '自动更新', 'Position', [10 10 100 25]);

% 第3行: 状态栏
uilabel(grid, 'Text', '状态: 就绪 | 内存: 正常 | 连接: 已建立', ...
    'FontColor', [0.5 0.5 0.5], 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.95 0.95 0.95], ...
    'Layout', uigridlayout([1 1], 'Row', 3, 'ColumnSpan', 3));

fprintf('网格布局: 3行3列，响应式窗口缩放\n');

%% ===== 2. 选项卡布局 =====
fprintf('\n===== 2. 选项卡布局 =====\n');

fig2 = uifigure('Name', '选项卡示例', 'Position', [200 200 700 500]);

% 选项卡组
tg = uitabgroup(fig2);

% Tab 1: 数据
tab1 = uitab(tg, 'Title', '数据查看');
uibutton(tab1, 'Text', '加载数据', 'Position', [20 400 120 35], ...
    'BackgroundColor', [0.2 0.6 0.9], 'FontColor', 'w');
uit = uitable(tab1, 'Position', [20 100 640 280], ...
    'Data', rand(10, 5), ...
    'ColumnName', {'变量A', '变量B', '变量C', '变量D', '变量E'});

% Tab 2: 图形
tab2 = uitab(tg, 'Title', '图形显示');
ax2 = uiaxes(tab2, 'Position', [30 50 400 350]);
surf(ax2, peaks(30));
title(ax2, '3D 曲面图');

% Tab 3: 设置
tab3 = uitab(tg, 'Title', '系统设置');
uilabel(tab3, 'Text', '语言:', 'Position', [20 400 50 20]);
uidropdown(tab3, 'Items', {'中文', 'English', '日本語'}, ...
    'Position', [80 398 120 25]);
uilabel(tab3, 'Text', '主题:', 'Position', [20 360 50 20]);
uidropdown(tab3, 'Items', {'浅色', '深色', '自动'}, ...
    'Position', [80 358 120 25]);
uicheckbox(tab3, 'Text', '自动保存', 'Position', [20 320 150 25]);
uicheckbox(tab3, 'Text', '显示网格', 'Position', [20 290 150 25], 'Value', true);

fprintf('选项卡: 3 个标签页 (数据, 图形, 设置)\n');

%% ===== 3. 嵌套布局 =====
fprintf('\n===== 3. 嵌套布局设计 =====\n');

fig3 = uifigure('Name', '嵌套布局示例', 'Position', [300 300 900 600]);

% 外层: 水平分割 (工具栏 + 主区域)
outer_grid = uigridlayout(fig3, [2 1]);
outer_grid.RowHeight = {40, '1x'};

% 工具栏
toolbar = uipanel(outer_grid, 'Layout', uigridlayout([1 1], 'Row', 1));
toolbar.BackgroundColor = [0.85 0.85 0.9];
uibutton(toolbar, 'Text', '新建', 'Position', [10 5 60 30]);
uibutton(toolbar, 'Text', '打开', 'Position', [80 5 60 30]);
uibutton(toolbar, 'Text', '保存', 'Position', [150 5 60 30]);
uibutton(toolbar, 'Text', '打印', 'Position', [220 5 60 30]);

% 主区域: 左侧导航 + 右侧内容
main_grid = uigridlayout(outer_grid, [1 2]);
main_grid.ColumnWidth = {200, '1x'};
main_grid.Layout = uigridlayout([1 1], 'Row', 2);

% 左侧导航
nav_panel = uipanel(main_grid, 'Title', '导航', ...
    'Layout', uigridlayout([1 1], 'Column', 1));
uilistbox(nav_panel, 'Position', [10 10 170 470], ...
    'Items', {'概览', '数据管理', '可视化', '分析工具', '导出报告'});

% 右侧内容
content_panel = uipanel(main_grid, 'Title', '内容区域', ...
    'Layout', uigridlayout([1 1], 'Column', 2));
ax3 = uiaxes(content_panel, 'Position', [20 120 600 350]);
bar(ax3, randi([10 50], 1, 6));
title(ax3, '月度数据');
ylabel(ax3, '数值');
uilabel(content_panel, 'Text', '最后更新: 2024-01-15 14:30', ...
    'FontColor', [0.5 0.5 0.5], 'Position', [20 20 300 20]);

fprintf('嵌套布局: 工具栏 + (导航栏 + 内容区)\n');

%% ===== 4. 响应式设计要点 =====
fprintf('\n===== 4. 响应式设计要点 =====\n');

fprintf('响应式布局技巧:\n');
fprintf('1. 使用 uigridlayout 替代固定 Position\n');
fprintf('2. RowHeight/ColumnWidth 用 {''1x'', ''2x''} 比例分配\n');
fprintf('3. 嵌套网格实现复杂布局\n');
fprintf('4. Padding 和 Spacing 统一间距\n');
fprintf('5. 窗口缩放时控件自动调整\n');

fprintf('\n===== 布局管理模块完成! =====\n');
