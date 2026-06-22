%% =========================================================================
%  流程控制
%  学习目标：掌握 if / switch / for / while / break / continue
%% =========================================================================

clear; clc; close all;

%% 1. if-elseif-else 条件判断
disp('--- if-elseif-else ---');

score = 85;

if score >= 90
    grade = 'A';
elseif score >= 80
    grade = 'B';
elseif score >= 70
    grade = 'C';
elseif score >= 60
    grade = 'D';
else
    grade = 'F';
end

fprintf('分数 %d → 等级 %s\n', score, grade);

% 嵌套 if
x = 15;
if x > 0
    if mod(x, 2) == 0
        fprintf('%d 是正偶数\n', x);
    else
        fprintf('%d 是正奇数\n', x);
    end
else
    fprintf('%d 不是正数\n', x);
end

%% 2. switch-case 多分支
disp('--- switch-case ---');

day = 3;

switch day
    case 1
        day_name = '星期一';
    case 2
        day_name = '星期二';
    case 3
        day_name = '星期三';
    case 4
        day_name = '星期四';
    case 5
        day_name = '星期五';
    case {6, 7}                    % 多个值用花括号
        day_name = '周末';
    otherwise
        day_name = '无效日期';
end

fprintf('第 %d 天: %s\n', day, day_name);

% switch 配合字符串
color = 'red';
switch lower(color)
    case 'red'
        rgb = [1, 0, 0];
    case 'green'
        rgb = [0, 1, 0];
    case 'blue'
        rgb = [0, 0, 1];
    otherwise
        rgb = [0, 0, 0];
end
fprintf('颜色 %s → RGB = [%s]\n', color, num2str(rgb));

%% 3. for 循环
disp('--- for 循环 ---');

% 基本 for 循环
sum_val = 0;
for i = 1:10
    sum_val = sum_val + i;
end
fprintf('1 到 10 的和: %d\n', sum_val);

% 自定义步长
fprintf('偶数: ');
for i = 2:2:20
    fprintf('%d ', i);
end
fprintf('\n');

% 递减循环
fprintf('倒计时: ');
for i = 10:-2:0
    fprintf('%d ', i);
end
fprintf('\n');

% 嵌套循环：九九乘法表
disp('九九乘法表:');
for i = 1:9
    for j = 1:i
        fprintf('%dx%d=%-3d', j, i, i*j);
    end
    fprintf('\n');
end

% 遍历数组
names = {'张三', '李四', '王五', '赵六'};
for k = 1:length(names)
    fprintf('第%d个: %s\n', k, names{k});
end

%% 4. while 循环
disp('--- while 循环 ---');

% 基本 while
n = 1;
while n^2 < 100
    n = n + 1;
end
fprintf('第一个平方大于100的数: %d (%d^2 = %d)\n', n, n, n^2);

% 猜数字游戏（自动版）
target = 42;
guess = 0;
attempts = 0;

rng(42);
while guess ~= target
    guess = randi(100);     % 随机猜1-100
    attempts = attempts + 1;
end
fprintf('猜中 %d 用了 %d 次\n', target, attempts);

%% 5. break 和 continue
disp('--- break 和 continue ---');

% break：提前退出循环
disp('break 示例 - 找第一个完全平方数大于50:');
for i = 1:100
    if i^2 > 50
        fprintf('找到: %d (平方=%d)\n', i, i^2);
        break;
    end
end

% continue：跳过当前迭代
disp('continue 示例 - 跳过偶数:');
fprintf('奇数: ');
for i = 1:10
    if mod(i, 2) == 0
        continue;           % 跳过偶数
    end
    fprintf('%d ', i);
end
fprintf('\n');

%% 6. 综合示例：冒泡排序
disp('--- 冒泡排序 ---');

arr = [64, 34, 25, 12, 22, 11, 90];
fprintf('排序前: [%s]\n', num2str(arr));

n = length(arr);
for i = 1:n-1
    swapped = false;
    for j = 1:n-i
        if arr(j) > arr(j+1)
            % 交换
            temp = arr(j);
            arr(j) = arr(j+1);
            arr(j+1) = temp;
            swapped = true;
        end
    end
    if ~swapped
        break;              % 已经排好序，提前退出
    end
end

fprintf('排序后: [%s]\n', num2str(arr));

%% 7. 综合示例：斐波那契数列
disp('--- 斐波那契数列 ---');

n = 15;
fib = zeros(1, n);
fib(1) = 0;
fib(2) = 1;

for i = 3:n
    fib(i) = fib(i-1) + fib(i-2);
end

fprintf('前 %d 个斐波那契数:\n', n);
fprintf('[%s]\n', num2str(fib));

disp('=== 脚本执行完毕 ===');
