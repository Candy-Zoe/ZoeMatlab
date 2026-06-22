%% 01_时间序列基础.m — 时间序列数据操作
%  涵盖: timeseries, datetime, 重采样, 缺失值处理
%  部分功能需要 Econometrics Toolbox

clear; clc; close all;

%% ===== 1. datetime 日期时间 =====
fprintf('===== 1. datetime 日期时间 =====\n');

% 创建日期时间
t1 = datetime(2024, 1, 15);
t2 = datetime('2024-06-30');
t3 = datetime('2024-03-15 14:30:00');
t_range = datetime(2024, 1, 1):calmonths(1):datetime(2024, 12, 31);

fprintf('t1 = %s\n', string(t1));
fprintf('t2 = %s\n', string(t2));
fprintf('t3 = %s\n', string(t3, 'yyyy-MM-dd HH:mm:ss'));
fprintf('日期范围: %s ~ %s (%d 个月)\n', ...
    string(t_range(1)), string(t_range(end)), length(t_range));

% 日期运算
dt = t2 - t1;
fprintf('\nt2 - t1 = %d 天\n', days(dt));
fprintf('t1 + 30天 = %s\n', string(t1 + days(30)));
fprintf('t1 + 2月 = %s\n', string(t1 + calmonths(2)));

% 日期属性
fprintf('\n当前时间: %s\n', string(datetime('now'), 'yyyy-MM-dd HH:mm:ss'));
fprintf('星期几: %s\n', string(t1, 'eeee'));

%% ===== 2. timeseries 时间序列 =====
fprintf('\n===== 2. timeseries 对象 =====\n');

% 创建时间序列数据
rng(42);
N = 365;
t = datetime(2024, 1, 1) + days(0:N-1);
data = 50 + 10*sin(2*pi*(1:N)/365) + 5*randn(1, N);

ts = timeseries(data, t, 'Name', '每日温度');

fprintf('时间序列: %s\n', ts.Name);
fprintf('数据点数: %d\n', ts.DataLength);
fprintf('时间范围: %s ~ %s\n', string(ts.Time(1)), string(ts.Time(end)));
fprintf('数据范围: [%.1f, %.1f]\n', min(ts.Data), max(ts.Data));

figure('Name', '时间序列', 'Position', [100 100 800 400]);
plot(ts.Time, ts.Data, 'b-', 'LineWidth', 0.8);
xlabel('日期'); ylabel('温度');
title('每日温度时间序列 (2024年)');
grid on;

%% ===== 3. 重采样 =====
fprintf('\n===== 3. 重采样 =====\n');

% 周均值重采样
ts_weekly = resample(ts, ts.Time(1):calweeks(1):ts.Time(end), 'linear');

figure('Name', '重采样', 'Position', [200 200 800 400]);
plot(ts.Time, ts.Data, 'b-', 'LineWidth', 0.5); hold on;
plot(ts_weekly.Time, ts_weekly.Data, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold off;
xlabel('日期'); ylabel('温度');
title('日数据 vs 周均值重采样');
legend('日数据', '周均值', 'Location', 'best');
grid on;

fprintf('日数据: %d 点\n', ts.DataLength);
fprintf('周数据: %d 点\n', ts_weekly.DataLength);

%% ===== 4. 缺失值处理 =====
fprintf('\n===== 4. 缺失值处理 =====\n');

% 创建含缺失值的数据
data_missing = data;
missing_idx = randperm(N, round(0.1*N));
data_missing(missing_idx) = NaN;

ts_missing = timeseries(data_missing, t);
fprintf('缺失值: %d (%.1f%%)\n', ...
    sum(isnan(ts_missing.Data)), ...
    sum(isnan(ts_missing.Data))/N*100);

% 插值填充
ts_interp = resample(ts_missing, ts_missing.Time);
ts_interp.Data = interp1(ts_missing.Time, ts_missing.Data, ...
    ts_missing.Time, 'linear');

figure('Name', '缺失值处理', 'Position', [300 300 800 400]);
subplot(2, 1, 1);
plot(ts_missing.Time, ts_missing.Data, 'b-');
title('含缺失值的时间序列');
grid on;

subplot(2, 1, 2);
plot(ts_interp.Time, ts_interp.Data, 'g-');
hold on;
plot(ts_missing.Time(missing_idx), NaN*ones(1,length(missing_idx)), 'rx', 'MarkerSize', 8);
hold off;
title('线性插值填充后');
grid on;

fprintf('插值后缺失值: %d\n', sum(isnan(ts_interp.Data)));

fprintf('\n===== 时间序列基础模块完成! =====\n');
