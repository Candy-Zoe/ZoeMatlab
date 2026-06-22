%% 04_完整应用示例.m — 综合 GUI 小工具
%  涵盖: 完整函数计算器应用
%  基础 MATLAB 即可

clear; clc; close all;

%% ===== 完整应用: 数据统计分析工具 =====
fprintf('===== 创建数据统计分析工具 =====\n');

fig = uifigure('Name', '数据统计分析工具', 'Position', [50 50 1000 650]);

% === 数据 ===
app_data.x = [];
app_data.y = [];

% === 工具栏 ===
pnl_toolbar = uipanel(fig, 'Position', [0 610 1000 40], ...
    'BackgroundColor', [0.9 0.9 0.95]);
uibutton(pnl_toolbar, 'Text', '生成数据', 'Position', [10 5 90 30], ...
    'ButtonPushedFcn', @(~,~) generate_data());
uibutton(pnl_toolbar, 'Text', '导入CSV', 'Position', [110 5 90 30], ...
    'ButtonPushedFcn', @(~,~) import_csv());
uibutton(pnl_toolbar, 'Text', '清空', 'Position', [210 5 60 30], ...
    'ButtonPushedFcn', @(~,~) clear_all());
lbl_info = uilabel(pnl_toolbar, 'Text', '就绪', ...
    'Position', [300 10 400 20], 'FontColor', [0.3 0.3 0.3]);

% === 左侧: 数据表 ===
pnl_data = uipanel(fig, 'Title', '数据表', 'Position', [10 310 350 290]);
tbl = uitable(pnl_data, 'Position', [10 10 320 245], ...
    'ColumnName', {'X', 'Y'}, 'Data', {});

% === 右上: 统计信息 ===
pnl_stats = uipanel(fig, 'Title', '统计信息', 'Position', [10 30 350 270]);
stats_labels = {'样本数:', '均值:', '标准差:', '最小值:', '最大值:', ...
    '中位数:', '偏度:', '峰度:', '相关系数:'};
lbl_names = {};
lbl_values = {};
y_pos = 230;
for i = 1:length(stats_labels)
    lbl_names{i} = uilabel(pnl_stats, 'Text', stats_labels{i}, ...
        'Position', [10 y_pos 70 20], 'FontWeight', 'bold');
    lbl_values{i} = uilabel(pnl_stats, 'Text', '-', ...
        'Position', [90 y_pos 150 20]);
    y_pos = y_pos - 25;
end

% === 右侧: 图形区域 ===
pnl_plot = uipanel(fig, 'Title', '图形显示', 'Position', [370 30 610 580]);

% 选项卡
tg = uitabgroup(pnl_plot);

tab_scatter = uitab(tg, 'Title', '散点图');
ax_scatter = uiaxes(tab_scatter, 'Position', [30 50 540 440]);

tab_hist = uitab(tg, 'Title', '直方图');
ax_hist = uiaxes(tab_hist, 'Position', [30 50 540 440]);

tab_fit = uitab(tg, 'Title', '曲线拟合');
ax_fit = uiaxes(tab_fit, 'Position', [30 50 540 440]);
pnl_fit_ctrl = uipanel(tab_fit, 'Position', [30 5 540 40], ...
    'BorderType', 'none');
uilabel(pnl_fit_ctrl, 'Text', '多项式阶数:', 'Position', [0 10 80 20]);
dd_order = uidropdown(pnl_fit_ctrl, 'Items', {'1', '2', '3', '4', '5'}, ...
    'Position', [90 8 60 25], 'Value', '1');
uibutton(pnl_fit_ctrl, 'Text', '拟合', 'Position', [170 5 60 30], ...
    'ButtonPushedFcn', @(~,~) fit_curve());
lbl_fit_eq = uilabel(pnl_fit_ctrl, 'Text', '', ...
    'Position', [250 10 300 20], 'FontSize', 9);

tab_box = uitab(tg, 'Title', '箱线图');
ax_box = uiaxes(tab_box, 'Position', [30 50 540 440]);

% === 功能函数 ===
function generate_data()
    n = 100;
    x = sort(randn(n, 1) * 3 + 5);
    y = 2.5 * x - 3 + randn(n, 1) * 2;
    app_data.x = x;
    app_data.y = y;
    
    tbl.Data = num2cell([x, y], 2);
    lbl_info.Text = sprintf('已生成 %d 个数据点', n);
    update_stats();
    plot_all();
end

function import_csv()
    [fname, fpath] = uigetfile('*.csv', '选择 CSV 文件');
    if fname == 0; return; end
    data = readmatrix(fullfile(fpath, fname));
    app_data.x = data(:,1);
    app_data.y = data(:,2);
    tbl.Data = num2cell([app_data.x, app_data.y], 2);
    lbl_info.Text = sprintf('已导入 %s (%d 行)', fname, size(data,1));
    update_stats();
    plot_all();
end

function clear_all()
    app_data.x = []; app_data.y = [];
    tbl.Data = {};
    for i = 1:length(lbl_values)
        lbl_values{i}.Text = '-';
    end
    cla(ax_scatter); cla(ax_hist); cla(ax_fit); cla(ax_box);
    lbl_info.Text = '已清空';
end

function update_stats()
    x = app_data.x; y = app_data.y;
    n = length(x);
    if n == 0; return; end
    
    vals = {
        sprintf('%d', n),
        sprintf('%.4f / %.4f', mean(x), mean(y)),
        sprintf('%.4f / %.4f', std(x), std(y)),
        sprintf('%.4f / %.4f', min(x), min(y)),
        sprintf('%.4f / %.4f', max(x), max(y)),
        sprintf('%.4f / %.4f', median(x), median(y)),
        sprintf('%.4f / %.4f', skewness(x), skewness(y)),
        sprintf('%.4f / %.4f', kurtosis(x), kurtosis(y)),
        sprintf('%.4f', corr(x, y))
    };
    for i = 1:length(vals)
        lbl_values{i}.Text = vals{i};
    end
end

function plot_all()
    x = app_data.x; y = app_data.y;
    if isempty(x); return; end
    
    % 散点图
    cla(ax_scatter);
    scatter(ax_scatter, x, y, 30, 'b', 'filled');
    xlabel(ax_scatter, 'X'); ylabel(ax_scatter, 'Y');
    title(ax_scatter, '散点图');
    grid(ax_scatter, 'on');
    
    % 直方图
    cla(ax_hist);
    histogram(ax_hist, x, 'Normalization', 'pdf', 'FaceColor', [0.3 0.6 0.9]);
    hold(ax_hist, 'on');
    histogram(ax_hist, y, 'Normalization', 'pdf', 'FaceColor', [0.9 0.5 0.3]);
    hold(ax_hist, 'off');
    title(ax_hist, 'X 和 Y 的直方图');
    legend(ax_hist, 'X', 'Y');
    grid(ax_hist, 'on');
    
    % 拟合 (1阶)
    fit_curve();
    
    % 箱线图
    cla(ax_box);
    boxplot(ax_box, [x, y], {'X', 'Y'});
    title(ax_box, '箱线图');
    grid(ax_box, 'on');
end

function fit_curve()
    x = app_data.x; y = app_data.y;
    if isempty(x); return; end
    
    order = str2double(dd_order.Value);
    p = polyfit(x, y, order);
    y_fit = polyval(p, x);
    
    cla(ax_fit);
    scatter(ax_fit, x, y, 20, 'b', 'filled'); hold(ax_fit, 'on');
    [xs, idx] = sort(x);
    plot(ax_fit, xs, y_fit(idx), 'r-', 'LineWidth', 2);
    hold(ax_fit, 'off');
    xlabel(ax_fit, 'X'); ylabel(ax_fit, 'Y');
    title(ax_fit, sprintf('%d 阶多项式拟合', order));
    grid(ax_fit, 'on');
    
    eq_str = 'y = ';
    for i = 1:length(p)
        if i < length(p)
            eq_str = [eq_str sprintf('%.3f*x^%d + ', p(i), length(p)-i)];
        else
            eq_str = [eq_str sprintf('%.3f', p(i))];
        end
    end
    r2 = 1 - sum((y - y_fit).^2) / sum((y - mean(y)).^2);
    lbl_fit_eq.Text = sprintf('%s  (R^2=%.4f)', eq_str, r2);
end

% 初始生成数据
generate_data();

fprintf('\n数据统计分析工具已创建!\n');
fprintf('功能: 数据生成/导入, 统计信息, 散点图, 直方图, 曲线拟合, 箱线图\n');
fprintf('\n===== 完整应用示例模块完成! =====\n');
