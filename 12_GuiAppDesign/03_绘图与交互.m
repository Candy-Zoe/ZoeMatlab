%% 03_绘图与交互.m — GUI 中的绘图与交互
%  涵盖: uiaxes, 实时数据更新, 鼠标/键盘回调
%  基础 MATLAB 即可

clear; clc; close all;

%% ===== 1. 交互式绘图应用 =====
fprintf('===== 1. 交互式函数绘图器 =====\n');

fig = uifigure('Name', '交互式函数绘图器', 'Position', [100 100 900 550]);

% 左侧: 控制面板
pnl_ctrl = uipanel(fig, 'Title', '函数设置', 'Position', [10 10 250 520]);

uilabel(pnl_ctrl, 'Text', '函数类型:', 'Position', [10 475 80 20]);
dd_func = uidropdown(pnl_ctrl, ...
    'Items', {'sin(x)', 'cos(x)', 'tan(x)', 'exp(-x^2)', 'sinc(x)', 'x*sin(x)'}, ...
    'Position', [10 448 220 25]);

uilabel(pnl_ctrl, 'Text', 'X 范围:', 'Position', [10 415 80 20]);
edit_xmin = uieditfield(pnl_ctrl, 'numeric', 'Position', [10 390 100 25], ...
    'Value', -10, 'Limits', [-100 100]);
uilabel(pnl_ctrl, 'Text', '到', 'Position', [115 392 20 20]);
edit_xmax = uieditfield(pnl_ctrl, 'numeric', 'Position', [140 390 100 25], ...
    'Value', 10, 'Limits', [-100 100]);

uilabel(pnl_ctrl, 'Text', '频率:', 'Position', [10 355 80 20]);
sld_freq = uislider(pnl_ctrl, 'Position', [10 340 220 15], ...
    'Limits', [0.1 5], 'Value', 1);
lbl_freq = uilabel(pnl_ctrl, 'Text', '1.00', 'Position', [10 320 220 20]);
sld_freq.ValueChangedFcn = @(src,~) set(lbl_freq, 'Text', sprintf('%.2f', src.Value));

uilabel(pnl_ctrl, 'Text', '振幅:', 'Position', [10 290 80 20]);
sld_amp = uislider(pnl_ctrl, 'Position', [10 275 220 15], ...
    'Limits', [0.1 10], 'Value', 1);
lbl_amp = uilabel(pnl_ctrl, 'Text', '1.00', 'Position', [10 255 220 20]);
sld_amp.ValueChangedFcn = @(src,~) set(lbl_amp, 'Text', sprintf('%.2f', src.Value));

chk_grid = uicheckbox(pnl_ctrl, 'Text', '显示网格', 'Position', [10 225 120 25], 'Value', true);
chk_fill = uicheckbox(pnl_ctrl, 'Text', '填充区域', 'Position', [10 195 120 25]);
chk_deriv = uicheckbox(pnl_ctrl, 'Text', '显示导数', 'Position', [130 225 120 25]);

btn_draw = uibutton(pnl_ctrl, 'Text', '绘图', ...
    'Position', [10 150 100 40], ...
    'BackgroundColor', [0.2 0.6 0.9], 'FontColor', 'w', ...
    'FontWeight', 'bold', ...
    'ButtonPushedFcn', @(~,~) draw_function());

btn_clear = uibutton(pnl_ctrl, 'Text', '清除', ...
    'Position', [130 150 100 40], ...
    'BackgroundColor', [0.9 0.3 0.3], 'FontColor', 'w', ...
    'ButtonPushedFcn', @(~,~) clear_plot());

% 右侧: 绘图区域
pnl_plot = uipanel(fig, 'Title', '图形输出', 'Position', [270 10 610 520]);
ax = uiaxes(pnl_plot, 'Position', [20 20 560 460]);

% 绘图函数
function draw_function()
    cla(ax);
    f = sld_freq.Value;
    a = sld_amp.Value;
    x = linspace(edit_xmin.Value, edit_xmax.Value, 1000);
    
    func_type = dd_func.Value;
    switch func_type
        case 'sin(x)'
            y = a * sin(f * x);
            y_deriv = a * f * cos(f * x);
        case 'cos(x)'
            y = a * cos(f * x);
            y_deriv = -a * f * sin(f * x);
        case 'tan(x)'
            y = a * tan(f * x);
            y(isnan(y) | abs(y) > 100) = NaN;
            y_deriv = a * f * sec(f * x).^2;
            y_deriv(isnan(y_deriv) | abs(y_deriv) > 100) = NaN;
        case 'exp(-x^2)'
            y = a * exp(-(f*x).^2);
            y_deriv = -2 * f^2 * x .* y;
        case 'sinc(x)'
            y = a * sinc(f * x / pi);
            y_deriv = gradient(y, x);
        case 'x*sin(x)'
            y = a * x .* sin(f * x);
            y_deriv = a * (sin(f*x) + f*x.*cos(f*x));
    end
    
    plot(ax, x, y, 'b-', 'LineWidth', 2); hold(ax, 'on');
    
    if chk_fill.Value
        fill(ax, [x fliplr(x)], [y zeros(size(y))], [0.8 0.9 1], ...
            'EdgeColor', 'none', 'FaceAlpha', 0.5);
    end
    
    if chk_deriv.Value
        plot(ax, x, y_deriv, 'r--', 'LineWidth', 1.5);
    end
    
    if chk_grid.Value
        grid(ax, 'on');
    end
    
    title_str = sprintf('y = %.1f * %s (f=%.2f)', a, func_type, f);
    if chk_deriv.Value
        title_str = [title_str ' (红色=导数)'];
    end
    title(ax, title_str);
    xlabel(ax, 'x'); ylabel(ax, 'y');
    hold(ax, 'off');
end

function clear_plot()
    cla(ax);
    title(ax, '点击 "绘图" 按钮开始');
end

% 初始绘图
draw_function();

fprintf('交互式绘图器已创建\n');

%% ===== 2. 实时数据更新 =====
fprintf('\n===== 2. 实时数据演示 =====\n');

fig2 = uifigure('Name', '实时数据监控', 'Position', [200 200 700 400]);

pnl2 = uipanel(fig2, 'Position', [10 10 670 370]);
ax2 = uiaxes(pnl2, 'Position', [20 60 620 280]);

btn_start = uibutton(pnl2, 'Text', '开始', ...
    'Position', [20 15 80 35], 'BackgroundColor', [0.2 0.7 0.3], 'FontColor', 'w');
btn_stop = uibutton(pnl2, 'Text', '停止', ...
    'Position', [120 15 80 35], 'BackgroundColor', [0.9 0.3 0.3], 'FontColor', 'w');
lbl_status = uilabel(pnl2, 'Text', '状态: 停止', 'Position', [220 22 150 20]);

% 使用 timer 实现实时更新
t = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, ...
    'TimerFcn', @(~,~) update_data());

data_buffer = zeros(1, 100);
t_idx = 0;

btn_start.ButtonPushedFcn = @(~,~) start_timer();
btn_stop.ButtonPushedFcn = @(~,~) stop_timer();

function start_timer()
    start(t);
    lbl_status.Text = '状态: 运行中';
    lbl_status.FontColor = 'g';
    fprintf('实时数据: 启动\n');
end

function stop_timer()
    stop(t);
    lbl_status.Text = '状态: 停止';
    lbl_status.FontColor = 'r';
    fprintf('实时数据: 停止\n');
end

function update_data()
    t_idx = t_idx + 1;
    new_val = sin(t_idx * 0.1) + 0.3 * randn();
    data_buffer = [data_buffer(2:end), new_val];
    
    plot(ax2, data_buffer, 'b-', 'LineWidth', 1.5);
    xlabel(ax2, '采样点'); ylabel(ax2, '值');
    title(ax2, sprintf('实时数据 (最新值: %.3f)', new_val));
    grid(ax2, 'on');
    drawnow;
end

fprintf('实时数据监控窗口已创建\n');
fprintf('提示: 关闭窗口前请先点击 "停止"\n');

fprintf('\n===== 绘图与交互模块完成! =====\n');
