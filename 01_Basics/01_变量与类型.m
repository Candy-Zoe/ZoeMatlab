%% =========================================================================
%  变量定义与数据类型
%  学习目标：掌握 MATLAB 中的变量赋值、常见数据类型及其转换方法
%% =========================================================================

clear; clc; close all;

%% 1. 变量赋值
% MATLAB 中变量不需要声明类型，直接赋值即可使用
a = 10;              % 数值（默认为 double）
b = 3.14;            % 浮点数
name = 'Zoe';        % 字符数组（单引号）
flag = true;         % 逻辑值（true / false）

fprintf('a = %d, b = %.2f, name = %s, flag = %d\n', a, b, name, flag);

%% 2. 特殊常量
% MATLAB 提供了一些内置的特殊常量
disp('--- 特殊常量 ---');
disp(['pi    = ', num2str(pi)]);        % 圆周率
disp(['eps   = ', num2str(eps)]);       % 浮点精度（最小可分辨差）
disp(['inf   = ', num2str(inf)]);       % 无穷大
disp(['NaN   = ', num2str(NaN)]);       % 非数字 (Not a Number)
disp(['ans 为上一个未赋值表达式的结果']);

%% 3. 查看变量信息
disp('--- 变量信息 ---');
whos;                                  % 显示所有变量的详细信息

%% 4. 数据类型
disp('--- 数据类型示例 ---');

% double（默认数值类型）
x = 42;
fprintf('x: class = %s, size = [%s]\n', class(x), num2str(size(x)));

% int8 / int16 / int32 / int64（整型）
x_int = int32(42);
fprintf('x_int: class = %s, size = %d bytes\n', class(x_int), sizeof(x_int));

% single（单精度浮点）
x_single = single(3.14);
fprintf('x_single: class = %s\n', class(x_single));

% logical（逻辑型）
x_logic = (5 > 3);
fprintf('x_logic: class = %s, value = %d\n', class(x_logic), x_logic);

% char（字符数组）
x_char = 'Hello MATLAB';
fprintf('x_char: class = %s, length = %d\n', class(x_char), length(x_char));

% string（字符串，R2016b+）
x_str = "Hello MATLAB";
fprintf('x_str: class = %s, length = %d\n', class(x_str), strlength(x_str));

%% 5. 数据类型转换
disp('--- 类型转换 ---');

% 数值转字符串
num = 123;
str_from_num = num2str(num);
fprintf('num2str(%d) = "%s" (class: %s)\n', num, str_from_num, class(str_from_num));

% 字符串转数值
str_val = '45.6';
num_from_str = str2double(str_val);
fprintf('str2double("%s") = %.1f (class: %s)\n', str_val, num_from_str, class(num_from_str));

% 整型转换
val = 3.7;
val_int = int32(val);                   % 四舍五入到整数
fprintf('int32(%.1f) = %d\n', val, val_int);

% 类型判断
disp('--- 类型判断函数 ---');
fprintf('isnumeric(42)    = %d\n', isnumeric(42));
fprintf('ischar("abc")    = %d (string 不是 char)\n', ischar("abc"));
fprintf('ischar(''abc'')   = %d\n', ischar('abc'));
fprintf('islogical(true)  = %d\n', islogical(true));
fprintf('isempty([])      = %d\n', isempty([]));

%% 6. 类型转换注意事项
disp('--- 注意事项 ---');
% char 与 string 的区别
c = 'hello';       % char: 1x5 字符数组，每个字符占 2 字节
s = "hello";       % string: 1x1 字符串标量
fprintf('char ''hello''  size: [%s]\n', num2str(size(c)));
fprintf('string "hello" size: [%s]\n', num2str(size(s)));

% 强制类型转换可能丢失精度
big_num = 1e10;
small_int = int8(big_num);              % 溢出，结果为 127（int8 最大值）
fprintf('int8(1e10) = %d （溢出！）\n', small_int);

disp('=== 脚本执行完毕 ===');
