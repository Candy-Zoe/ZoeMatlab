%% =========================================================================
%  函数定义、匿名函数与函数句柄
%  学习目标：掌握 MATLAB 中函数的多种定义方式与使用
%% =========================================================================

clear; clc; close all;

%% 1. 脚本中的局部函数（在脚本末尾定义）
disp('--- 调用局部函数 ---');

% 调用脚本末尾定义的函数
result = add_numbers(3, 5);
fprintf('add_numbers(3, 5) = %d\n', result);

area = circle_area(5);
fprintf('circle_area(5) = %.4f\n', area);

[val, idx] = find_max([3, 7, 2, 9, 4]);
fprintf('find_max: 值=%d, 位置=%d\n', val, idx);

%% 2. 多输入多输出函数
disp('--- 多输入多输出 ---');

% 统计函数
data = [4, 8, 15, 16, 23, 42];
[m, s, med] = calc_stats(data);
fprintf('数据: [%s]\n', num2str(data));
fprintf('均值: %.2f, 标准差: %.2f, 中位数: %.2f\n', m, s, med);

%% 3. 匿名函数（单行表达式）
disp('--- 匿名函数 ---');

% 基本匿名函数
square = @(x) x.^2;
fprintf('square(5) = %d\n', square(5));
fprintf('square([1 2 3]) = [%s]\n', num2str(square([1 2 3])));

% 多参数
add = @(a, b) a + b;
fprintf('add(3, 4) = %d\n', add(3, 4));

% 带常量的闭包
a = 2; b = 3;
linear = @(x) a*x + b;
fprintf('linear(5) = %d  (a=2, b=3)\n', linear(5));

%% 4. 函数句柄
disp('--- 函数句柄 ---');

% 指向内置函数
f_sin = @sin;
f_cos = @cos;

x = pi/4;
fprintf('f_sin(pi/4) = %.4f\n', f_sin(x));
fprintf('f_cos(pi/4) = %.4f\n', f_cos(x));

% feval 调用
fprintf('feval(@sqrt, 16) = %.1f\n', feval(@sqrt, 16));

%% 5. 函数数组（cellfun / arrayfun）
disp('--- 函数数组与高阶函数 ---');

% cellfun：对元胞数组中每个元素应用函数
C = {1:5, 1:10, 1:3};
sums = cellfun(@sum, C);
fprintf('各元胞的和: [%s]\n', num2str(sums));

lengths = cellfun(@length, C);
fprintf('各元胞的长度: [%s]\n', num2str(lengths));

% arrayfun：对数组中每个元素应用函数
v = [1, 4, 9, 16, 25];
roots = arrayfun(@sqrt, v);
fprintf('平方根: [%s]\n', num2str(roots));

% 自定义函数 + arrayfun
f = @(x) x^3 - 2*x + 1;
x_vals = -2:0.5:2;
y_vals = arrayfun(f, x_vals);
fprintf('f(x) = x^3 - 2x + 1:\n');
for k = 1:length(x_vals)
    fprintf('  f(%.1f) = %.2f\n', x_vals(k), y_vals(k));
end

%% 6. 嵌套函数
disp('--- 嵌套函数示例 ---');

% 计数器（利用嵌套函数的变量共享）
counter = make_counter();
fprintf('count() = %d\n', counter());
fprintf('count() = %d\n', counter());
fprintf('count() = %d\n', counter());

%% 7. 可变参数（varargin / varargout）
disp('--- 可变参数 ---');

% varargin 示例
total = sum_all(1, 2, 3, 4, 5);
fprintf('sum_all(1,2,3,4,5) = %d\n', total);

% 默认参数
print_info('张三');
print_info('李四', 25);
print_info('王五', 30, '北京');

%% 8. 函数可视化示例
disp('--- 函数可视化 ---');

figure('Name', '函数可视化', 'Position', [100, 100, 800, 400]);

x = -5:0.1:5;

% 绘制多个函数
funcs = {@(x) sin(x), @(x) cos(x), @(x) exp(-x.^2/2)};
names = {'sin(x)', 'cos(x)', 'e^{-x^2/2}'};
colors = {'r', 'b', 'g'};

subplot(1,2,1);
hold on;
for k = 1:3
    plot(x, funcs{k}(x), colors{k}, 'LineWidth', 2);
end
title('函数对比');
legend(names, 'Location', 'best');
grid on;
hold off;

% fplot 绘制
subplot(1,2,2);
fplot(@(x) sin(x)/x, [-10, 10], 'b-', 'LineWidth', 2);
title('sinc 函数 (fplot)');
xlabel('x'); ylabel('y');
grid on;

disp('=== 脚本执行完毕 ===');

%% ========================================================================
%  以下为局部函数定义（必须在脚本末尾）
%% ========================================================================

function result = add_numbers(a, b)
    % 两数相加
    result = a + b;
end

function area = circle_area(r)
    % 计算圆面积
    area = pi * r^2;
end

function [max_val, max_idx] = find_max(arr)
    % 找最大值及其位置
    [max_val, max_idx] = max(arr);
end

function [m, s, med] = calc_stats(data)
    % 计算均值、标准差、中位数
    m = mean(data);
    s = std(data);
    med = median(data);
end

function counter = make_counter()
    % 创建计数器（嵌套函数 + 闭包）
    count = 0;
    counter = @increment;
    
    function val = increment()
        count = count + 1;
        val = count;
    end
end

function total = sum_all(varargin)
    % 可变参数求和
    total = 0;
    for k = 1:nargin
        total = total + varargin{k};
    end
end

function print_info(name, varargin)
    % 带默认参数的函数
    age = 0;
    city = '未知';
    if nargin >= 2
        age = varargin{1};
    end
    if nargin >= 3
        city = varargin{2};
    end
    fprintf('姓名: %s, 年龄: %d, 城市: %s\n', name, age, city);
end
