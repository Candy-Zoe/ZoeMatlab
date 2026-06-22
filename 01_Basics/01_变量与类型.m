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

%% 7. datetime 与 duration 类型
disp('--- datetime 与 duration ---');

% datetime: 日期时间类型
dt1 = datetime(2024, 6, 15, 10, 30, 0);  % 2024年6月15日 10:30
dt2 = datetime('today');                   % 今天
dt3 = datetime('now');                     % 当前时间
fprintf('指定时间: %s\n', string(dt1));
fprintf('今天: %s\n', string(dt2));
fprintf('现在: %s\n', string(dt3));

% datetime 运算
dt_later = dt1 + hours(5) + minutes(30);
fprintf('5小时30分后: %s\n', string(dt_later));
dt_diff = dt_later - dt1;
fprintf('时间差: %s (类型: %s)\n', string(dt_diff), class(dt_diff));

% duration 类型
dur1 = duration(1, 30, 0);   % 1小时30分
dur2 = seconds(90);
fprintf('dur1 = %s, dur2 = %s\n', string(dur1), string(dur2));
fprintf('dur1 + dur2 = %s\n', string(dur1 + dur2));

% 时间序列
fprintf('\n--- 时间序列创建 ---');
t_vec = datetime(2024,1,1) + caldays(0:6);
fprintf('一周日期:\n');
for i = 1:length(t_vec)
    fprintf('  %s (%s)\n', string(t_vec(i)), string(t_vec(i), 'eeee'));
end

%% 8. table 类型（表格数据）
disp('--- table 表格 ---');

% 创建表格
names = {'张三'; '李四'; '王五'; '赵六'};
ages = [25; 30; 28; 35];
scores = [85.5; 92.0; 78.3; 88.7];
grades = categorical({'B'; 'A'; 'C'; 'B'});

T = table(names, ages, scores, grades, ...
    'VariableNames', {'姓名', '年龄', '成绩', '等级'});
disp(T);

% 表格索引
fprintf('第2行: %s, 成绩=%.1f\n', T{2,1}, T{2,3});
fprintf('所有人成绩:\n'); disp(T.成绩);

% 表格操作
T.排名 = [3; 1; 4; 2];
fprintf('添加排名列后:\n'); disp(T);

% 筛选
high_scores = T(T.成绩 > 85, :);
fprintf('成绩>85的学生:\n'); disp(high_scores);

%% 9. categorical 类型
disp('--- categorical 分类 ---');

colors = categorical({'红','蓝','红','绿','蓝','红','绿'});
fprintf('类别: %s\n', strjoin(string(categories(colors)), ', '));
fprintf('各类数量: ');
countcats(colors);

% 有序分类
sizes = categorical({'S','M','L','XL','M','L','S','XL'}, ...
    {'S','M','L','XL'}, 'Ordinal', true);
fprintf('有序类别: %s\n', strjoin(string(categories(sizes)), ' < '));
fprintf('L > M: %d\n', sizes(3) > sizes(2));

%% 10. 数据类型可视化总结
figure('Name', 'MATLAB数据类型总览', 'Position', [100 100 600 400]);
text(0.1, 0.95, 'MATLAB 常见数据类型', 'FontSize', 14, 'FontWeight', 'bold');

types_text = {
    '数值类型:'; '  double (默认), single, int8~int64, uint8~uint64';
    ''; '字符与字符串:'; '  char (''单引号''), string ("双引号", R2016b+)';
    ''; '逻辑类型:'; '  logical (true/false)';
    ''; '日期时间:'; '  datetime, duration, calendarDuration';
    ''; '容器类型:'; '  cell (元胞), struct (结构体), table (表格)';
    ''; '分类类型:'; '  categorical (有序/无序)';
};
y_pos = 0.85;
for i = 1:length(types_text)
    text(0.1, y_pos, types_text{i}, 'FontSize', 10, ...
        'FontWeight', {'normal','bold'}(contains(types_text{i},':')+1));
    y_pos = y_pos - 0.06;
end
axis off;
title('MATLAB 数据类型体系');

%% === 总结 ===
fprintf('\n=== 变量与类型总结 ===\n');
fprintf('1. 数值: double/single 浮点, int/uint 整型\n');
fprintf('2. 文本: char 字符数组, string 字符串标量\n');
fprintf('3. 日期: datetime + duration 时间运算\n');
fprintf('4. 表格: table 混合类型数据存储\n');
fprintf('5. 分类: categorical 有限类别集合\n');
fprintf('6. 转换: num2str, str2double, int32, single 等\n');
