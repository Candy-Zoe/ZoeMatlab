%% =========================================================================
%  字符串操作与处理
%  学习目标：掌握 MATLAB 中 char 与 string 类型的操作函数
%% =========================================================================

clear; clc; close all;

%% 1. 字符数组 (char)
disp('--- 字符数组 (char) ---');

% 创建字符数组（单引号）
s1 = 'Hello, MATLAB!';
s2 = '你好，世界';

fprintf('s1 = %s (长度: %d)\n', s1, length(s1));
fprintf('s2 = %s (长度: %d)\n', s2, length(s2));

% 字符数组本质是数字（ASCII / Unicode）
fprintf('''A'' 的 ASCII 值: %d\n', double('A'));
fprintf('char(65) = %s\n', char(65));

% 多行字符串（每行长度必须相同）
lines = ['第一行    ';
         '第二行    ';
         '第三行    '];
disp(lines);

%% 2. 字符串类型 (string, R2016b+)
disp('--- 字符串类型 (string) ---');

% 创建字符串（双引号）
str1 = "Hello, MATLAB!";
str2 = "你好，世界";

fprintf('str1 = %s (class: %s)\n', str1, class(str1));

% 字符串数组
strs = ["apple", "banana", "cherry"];
disp('字符串数组:'); disp(strs);
fprintf('第2个: %s\n', strs(2));

%% 3. 字符串拼接
disp('--- 字符串拼接 ---');

first = "Hello";
second = "World";

% 方式一：加号 +
result1 = first + " " + second;
fprintf('first + " " + second = %s\n', result1);

% 方式二：strcat 函数
result2 = strcat('Hello', ' ', 'World');
fprintf('strcat = %s\n', result2);

% 方式三：sprintf 格式化
name = 'Zoe';
age = 25;
result3 = sprintf('姓名: %s, 年龄: %d', name, age);
fprintf('sprintf = %s\n', result3);

% 方式四：字符串插值（R2019a+，仅在 string 中可用）
result4 = "姓名: " + name + ", 年龄: " + string(age);
fprintf('插值拼接 = %s\n', result4);

%% 4. 字符串分割与合并
disp('--- 分割与合并 ---');

% 分割
sentence = "apple,banana,cherry,date";
parts = split(sentence, ",");
disp('split 结果:'); disp(parts);

% 合并
words = ["MATLAB", "is", "great"];
joined = join(words, " ");
fprintf('join = %s\n', joined);

% char 版本的分割
c = 'apple,banana,cherry';
c_parts = strsplit(c, ',');
disp('strsplit 结果:'); disp(c_parts);

%% 5. 字符串查找与替换
disp('--- 查找与替换 ---');

s = "MATLAB is a powerful tool. MATLAB is widely used.";

% 查找
idx = strfind(s, "MATLAB");
fprintf('"MATLAB" 出现在位置: [%s]\n', num2str(idx));

% 判断是否包含
fprintf('包含 "powerful": %d\n', contains(s, "powerful"));
fprintf('以 "MATLAB" 开头: %d\n', startsWith(s, "MATLAB"));
fprintf('以 "used." 结尾: %d\n', endsWith(s, "used."));

% 替换
s_new = replace(s, "MATLAB", "Python");
fprintf('替换后: %s\n', s_new);

% 正则表达式
nums = regexp("abc123def456ghi789", '\d+', 'match');
disp('正则提取数字:'); disp(nums);

%% 6. 字符串转换
disp('--- 字符串转换 ---');

% 大小写转换
s = "Hello World";
fprintf('upper: %s\n', upper(s));
fprintf('lower: %s\n', lower(s));

% 去除空格
s_space = "  hello   world  ";
fprintf('原始:    "%s"\n', s_space);
fprintf('strip:   "%s"\n', strip(s_space));       % 两端去空格
fprintf('strip左: "%s"\n', strip(s_space, 'left'));

% char 去空格
c = '  hello  ';
fprintf('strtrim: "%s"\n', strtrim(c));

%% 7. 字符串比较
disp('--- 字符串比较 ---');

s1 = "MATLAB";
s2 = "matlab";
s3 = "MATLAB";

fprintf('s1 == s3 : %d  （完全相等）\n', s1 == s3);
fprintf('strcmpi(s1,s2) : %d  （忽略大小写比较）\n', strcmpi(char(s1), char(s2)));

% char 版本
c1 = 'hello';
c2 = 'Hello';
fprintf('strcmp(c1,c2)  = %d  （区分大小写）\n', strcmp(c1, c2));
fprintf('strcmpi(c1,c2) = %d  （忽略大小写）\n', strcmpi(c1, c2));

%% 8. 数值与字符串互转
disp('--- 数值与字符串互转 ---');

% 数值 → 字符串
fprintf('num2str(42)    = "%s"\n', num2str(42));
fprintf('num2str(pi,"%.4f") = "%s"\n', num2str(pi, '%.4f'));
fprintf('int2str(100)   = "%s"\n', int2str(100));
fprintf('mat2str([1 2;3 4]) = "%s"\n', mat2str([1 2; 3 4]));

% 字符串 → 数值
fprintf('str2double("3.14") = %.2f\n', str2double("3.14"));
fprintf('str2num("2+3i")    = %s\n', num2str(str2num('2+3i')));

%% 9. char 与 string 互转
disp('--- char 与 string 互转 ---');

c = 'hello';
s = string(c);
fprintf('string("hello") = %s (class: %s)\n', s, class(s));

s2 = "world";
c2 = char(s2);
fprintf('char("world") = %s (class: %s)\n', c2, class(c2));

%% 10. 常用字符串函数汇总
disp('--- 常用函数速查 ---');
disp('创建:    ''text'' (char), "text" (string)');
disp('拼接:    +, strcat, sprintf, join');
disp('分割:    split, strsplit');
disp('查找:    strfind, contains, startsWith, endsWith, regexp');
disp('替换:    replace, strrep, regexprep');
disp('转换:    upper, lower, strip, strtrim');
disp('比较:    ==, strcmp, strcmpi');
disp('类型转换: num2str, str2double, string, char');

disp('=== 脚本执行完毕 ===');
