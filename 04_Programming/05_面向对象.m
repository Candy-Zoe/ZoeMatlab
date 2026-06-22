%% =========================================================================
%  面向对象编程基础
%  学习目标：掌握 MATLAB 中类定义、继承、方法重载
%  注意：MATLAB 类通常需要在单独文件中定义（文件名 = 类名）
%        本脚本演示概念，完整类定义见同目录的 @ClassName 文件夹
%% =========================================================================

clear; clc; close all;

%% 1. 内置类的面向对象概念
disp('--- 内置类的面向对象 ---');

% 一切都是对象
x = 42;
fprintf('class(42) = %s\n', class(x));
fprintf('isa(42, ''double'') = %d\n', isa(x, 'double'));

s = "hello";
fprintf('class("hello") = %s\n', class(s));
fprintf('isa("hello", ''string'') = %d\n', isa(s, 'string'));

% 方法调用（dot notation）
str = "  Hello World  ";
fprintf('str.strip() = "%s"\n', strip(str));
fprintf('str.upper()  = "%s"\n', upper(char(str)));

%% 2. 结构体模拟对象
disp('--- 结构体模拟对象 ---');

% 用结构体模拟一个简单的"学生"对象
student = struct();
student.name = '张三';
student.age = 20;
student.scores = [85, 92, 78];

% 模拟方法
fprintf('姓名: %s\n', student.name);
fprintf('平均分: %.1f\n', mean(student.scores));
fprintf('最高分: %d\n', max(student.scores));

%% 3. MATLAB 类定义语法（概念演示）
disp('--- 类定义语法 ---');
disp('MATLAB 类定义示例（需在单独文件中）:');
disp('');
disp('classdef MyClass < handle');
disp('    properties');
disp('        x');
disp('        y');
disp('    end');
disp('');
disp('    methods');
disp('        function obj = MyClass(x, y)');
disp('            obj.x = x;');
disp('            obj.y = y;');
disp('        end');
disp('');
disp('        function result = add(obj)');
disp('            result = obj.x + obj.y;');
disp('        end');
disp('    end');
disp('end');

%% 4. 值类 vs 句柄类
disp('--- 值类 vs 句柄类 ---');
disp('值类 (value class):');
disp('  - 赋值时创建副本');
disp('  - 修改副本不影响原对象');
disp('  - 类似 struct 的行为');
disp('');
disp('句柄类 (handle class):');
disp('  - 赋值时共享引用');
disp('  - 修改副本会影响原对象');
disp('  - 类似其他语言的 class');

% 演示（使用内置的 handle 子类）
disp('--- 句柄行为演示 (用 containers.Map) ---');

% containers.Map 是句柄类
map1 = containers.Map({'a','b'}, {1, 2});
map2 = map1;                          % map2 与 map1 共享同一对象
map2('c') = 3;

fprintf('map1 的键: [%s]\n', strjoin(keys(map1), ', '));
fprintf('map2 的键: [%s]\n', strjoin(keys(map2), ', '));
disp('（修改 map2 也影响了 map1，因为是句柄类）');

%% 5. 使用 containers.Map（字典/哈希表）
disp('--- containers.Map ---');

% 创建
scores = containers.Map();
scores('张三') = 85;
scores('李四') = 92;
scores('王五') = 78;

% 访问
fprintf('张三的分数: %d\n', scores('张三'));

% 遍历
k = keys(scores);
v = values(scores);
fprintf('所有成绩:\n');
for i = 1:length(k)
    fprintf('  %s: %d\n', k{i}, v{i});
end

% 检查是否存在
fprintf('包含"赵六": %d\n', isKey(scores, '赵六'));

% 删除
remove(scores, '王五');
fprintf('删除王五后: %d 条记录\n', scores.Count);

%% 6. table 类（数据分析常用）
disp('--- table 类 ---');

% 创建表格
T = table({'张三';'李四';'王五';'赵六'}, ...
          [85; 92; 78; 95], ...
          [90; 88; 95; 82], ...
          'VariableNames', {'姓名', '数学', '英语'});

disp('表格:');
disp(T);

% 访问列
fprintf('数学成绩: [%s]\n', num2str(T.数学'));

% 条件筛选
high_math = T(T.数学 > 85, :);
disp('数学>85的学生:');
disp(high_math);

% 添加计算列
T.平均 = (T.数学 + T.英语) / 2;
disp('添加平均列:');
disp(T);

% 排序
T_sorted = sortrows(T, '平均', 'descend');
disp('按平均分降序:');
disp(T_sorted);

%% 7. 类层次与继承概念
disp('--- 继承概念 ---');
disp('classdef Animal');
disp('    properties');
disp('        name');
disp('        sound');
disp('    end');
disp('    methods');
disp('        function obj = Animal(name, sound)');
disp('            obj.name = name;');
disp('            obj.sound = sound;');
disp('        end');
disp('        function speak(obj)');
disp('            fprintf(''%s says %s\n'', obj.name, obj.sound);');
disp('        end');
disp('    end');
disp('end');
disp('');
disp('classdef Dog < Animal');
disp('    methods');
disp('        function obj = Dog(name)');
disp('            obj = obj@Animal(name, ''Woof!'');');
disp('        end');
disp('        function fetch(obj, item)');
disp('            fprintf(''%s fetches %s\n'', obj.name, item);');
disp('        end');
disp('    end');
disp('end');

%% 8. 实际可用的 OOP 模式：函数封装
disp('--- 函数封装模式 ---');

% 用结构体 + 函数模拟类（无需单独文件）
bank = create_bank_account('张三', 1000);
bank = deposit(bank, 500);
bank = withdraw(bank, 200);
fprintf('余额: %.2f\n', bank.balance);

disp('=== 脚本执行完毕 ===');

%% ========================================================================
%  局部函数：模拟银行账户
%% ========================================================================

function account = create_bank_account(owner, initial_balance)
    account.owner = owner;
    account.balance = initial_balance;
    account.history = {sprintf('开户: 初始余额 %.2f', initial_balance)};
    fprintf('创建账户: %s, 余额: %.2f\n', owner, initial_balance);
end

function account = deposit(account, amount)
    account.balance = account.balance + amount;
    account.history{end+1} = sprintf('存入: %.2f, 余额: %.2f', amount, account.balance);
    fprintf('存入 %.2f, 余额: %.2f\n', amount, account.balance);
end

function account = withdraw(account, amount)
    if amount > account.balance
        fprintf('余额不足! 当前余额: %.2f\n', account.balance);
        return;
    end
    account.balance = account.balance - amount;
    account.history{end+1} = sprintf('取出: %.2f, 余额: %.2f', amount, account.balance);
    fprintf('取出 %.2f, 余额: %.2f\n', amount, account.balance);
end
