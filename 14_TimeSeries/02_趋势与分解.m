%% 02_趋势与分解.m — 时间序列趋势与季节性分解
%  涵盖: movmean, detrend, 季节性分解
%  基础 MATLAB + 部分 Econometrics Toolbox

clear; clc; close all;

%% ===== 1. 移动平均 =====
fprintf('===== 1. 移动平均 =====\n');

rng(42);
N = 500;
t = 1:N;

% 生成带趋势和噪声的数据
trend = 0.02 * t;
seasonal = 5 * sin(2*pi*t/50);
noise = 2 * randn(1, N);
data = trend + seasonal + noise;

% 不同窗口大小的移动平均
win_sizes = [7, 21, 50];

figure('Name', '移动平均平滑', 'Position', [100 100 800 500]);
for i = 1:length(win_sizes)
    w = win_sizes(i);
    ma = movmean(data, w);
    
    subplot(length(win_sizes), 1, i);
    plot(t, data, 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5); hold on;
    plot(t, ma, 'r-', 'LineWidth', 1.5);
    hold off;
    title(sprintf('移动平均 (窗口 = %d)', w));
    grid on;
    if i == length(win_sizes); xlabel('时间'); end
end

fprintf('窗口越大，平滑效果越强，但延迟也越大\n');

%% ===== 2. detrend 去趋势 =====
fprintf('\n===== 2. 去趋势 (detrend) =====\n');

% 线性去趋势
data_detrend_linear = detrend(data, 'linear');

% 常数去趋势 (去均值)
data_detrend_const = detrend(data, 'constant');

figure('Name', '去趋势', 'Position', [200 200 800 500]);
subplot(3, 1, 1);
plot(t, data, 'b-', 'LineWidth', 0.8);
title('原始数据 (含线性趋势)');
grid on;

subplot(3, 1, 2);
plot(t, data_detrend_const, 'g-', 'LineWidth', 0.8);
title('去均值 (constant detrend)');
grid on;

subplot(3, 1, 3);
plot(t, data_detrend_linear, 'r-', 'LineWidth', 0.8);
title('线性去趋势 (linear detrend)');
xlabel('时间');
grid on;

fprintf('去均值: 去除常数偏移\n');
fprintf('线性去趋势: 去除线性趋势\n');

%% ===== 3. 季节性分解 =====
fprintf('\n===== 3. 季节性分解 =====\n');

% 生成含季节性的数据
period = 12;
n_years = 5;
N_season = n_years * period;
t_season = 1:N_season;

% 趋势 + 季节 + 噪声
trend_s = 0.5 * t_season / period;
seasonal_s = 10 * sin(2*pi*t_season/period) + 3 * cos(4*pi*t_season/period);
noise_s = 2 * randn(1, N_season);
data_s = trend_s + seasonal_s + noise_s;

% 简单季节性分解: 移动平均去趋势 -> 提取季节
ma_season = movmean(data_s, period);
detrended = data_s - ma_season;

% 提取季节模式
season_pattern = zeros(1, period);
for k = 1:period
    season_pattern(k) = mean(detrended(k:period:end), 'omitnan');
end

% 残差
residual = data_s - ma_season - repmat(season_pattern, 1, ceil(N_season/period));
residual = residual(1:N_season);

figure('Name', '季节性分解', 'Position', [300 300 800 600]);
subplot(4, 1, 1);
plot(t_season, data_s, 'b-', 'LineWidth', 0.8);
title('原始数据'); grid on;

subplot(4, 1, 2);
plot(t_season, ma_season, 'r-', 'LineWidth', 1.5);
title('趋势分量 (移动平均)'); grid on;

subplot(4, 1, 3);
bar(1:period, season_pattern, 'FaceColor', [0.3 0.7 0.3]);
title('季节模式'); xlabel('周期'); ylabel('振幅'); grid on;

subplot(4, 1, 4);
plot(t_season, residual, 'k-', 'LineWidth', 0.5);
title('残差 (噪声)'); xlabel('时间'); grid on;

fprintf('季节模式 (前12期):\n');
fprintf('  '); fprintf('%.2f  ', season_pattern);
fprintf('\n');

fprintf('\n===== 趋势与分解模块完成! =====\n');
