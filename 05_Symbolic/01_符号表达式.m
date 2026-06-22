%% =========================================================================
%  符号表达式
%  学习目标：掌握符号变量的创建、表达式操作、简化与展开
%  需要: Symbolic Math Toolbox
%% =========================================================================

clear; clc; close all;

%% 1. 创建符号变量
disp('--- 创建符号变量 ---');

% 方式一：sym 创建单个符号变量
x = sym('x');
a = sym('a');
fprintf('x = %s, class = %s\n', char(x), class(x));

% 方式二：syms 同时创建多个
syms x y z a b c
fprintf('创建符号变量: x, y, z, a, b, c\n');

% 符号数字（精确表示）
s_pi = sym('pi');
s_half = sym('1/2');
s_sqrt2 = sym('sqrt(2)');
fprintf('sym(''pi'')   = %s\n', char(s_pi));
fprintf('sym(''1/2'')  = %s (非浮点近似)\n', char(s_half));
fprintf('sym(''sqrt(2)'') = %s\n', char(s_sqrt2));

%% 2. 构建符号表达式
disp('--- 符号表达式 ---');

syms x y

% 直接写表达式
f = x^2 + 2*x + 1;
fprintf('f = %s\n', char(f));

g = sin(x) + cos(y);
fprintf('g = %s\n', char(g));

% 分式
h = (x^2 - 1) / (x - 1);
fprintf('h = %s\n', char(h));

% 矩阵
syms a b c d
M = [a, b; c, d];
disp('符号矩阵 M ='); disp(M);

%% 3. 表达式操作
disp('--- 表达式操作 ---');

syms x

% 展开 (expand)
f1 = (x + 1)^3;
fprintf('expand((x+1)^3) = %s\n', char(expand(f1)));

% 因式分解 (factor)
f2 = x^3 - 6*x^2 + 11*x - 6;
fprintf('factor(x^3-6x^2+11x-6) = %s\n', char(factor(f2)));

% 简化 (simplify)
f3 = sin(x)^2 + cos(x)^2;
fprintf('simplify(sin^2+cos^2) = %s\n', char(simplify(f3)));

f4 = (x^2 - 1)/(x + 1);
fprintf('simplify((x^2-1)/(x+1)) = %s\n', char(simplify(f4)));

% 合并同类项 (collect)
syms x y
f5 = x*y + x^2 + 2*x*y + 3*x^2;
fprintf('collect(x 项): %s\n', char(collect(f5, x)));

% 替换 (subs)
f6 = x^2 + 2*x + 1;
f6_sub = subs(f6, x, 3);
fprintf('subs(x^2+2x+1, x=3) = %s\n', char(f6_sub));

%% 4. 代数运算
disp('--- 代数运算 ---');

syms x

% 多项式运算
p1 = x^2 + x + 1;
p2 = x - 1;
fprintf('(x^2+x+1)*(x-1) = %s\n', char(expand(p1 * p2)));

% 分式运算
f = 1/x + 1/(x+1);
fprintf('1/x + 1/(x+1) = %s\n', char(simplify(f)));

% 提取分子分母
[num, den] = numden(f);
fprintf('分子: %s\n', char(num));
fprintf('分母: %s\n', char(den));

%% 5. 符号方程求解
disp('--- 方程求解 ---');

syms x

% 一元方程
eq1 = x^2 - 5*x + 6 == 0;
sol1 = solve(eq1, x);
fprintf('x^2-5x+6=0 的解: [');
fprintf('%s ', char(sol1));
fprintf(']\n');

% 方程组
syms x y
eq2 = [2*x + y == 5, x - y == 1];
sol2 = solve(eq2, [x, y]);
fprintf('2x+y=5, x-y=1 → x=%s, y=%s\n', char(sol2.x), char(sol2.y));

% 不等式
eq3 = x^2 - 4 > 0;
sol3 = solve(eq3, x, 'ReturnConditions', true);
fprintf('x^2-4>0 的解: %s\n', char(sol3.conditions));

%% 6. 符号函数
disp('--- 符号函数 ---');

syms f(x) g(x)

f(x) = x^2 + sin(x);
g(x) = exp(-x);

fprintf('f(x) = %s\n', char(f));
fprintf('f(2) = %s\n', char(f(2)));
fprintf('f(pi) = %s\n', char(simplify(f(pi))));

% 复合函数
h = f(g(x));
fprintf('f(g(x)) = %s\n', char(h));

%% 7. 表达式可视化
disp('--- 符号表达式绘图 ---');

syms x

figure('Name', '符号表达式绘图', 'Position', [100, 100, 800, 400]);

subplot(1,2,1);
fplot(sin(x)/x, [-10, 10], 'LineWidth', 2);
title('fplot: sin(x)/x');
grid on;

subplot(1,2,2);
fplot([sin(x), cos(x), tan(x)], [-pi, pi], 'LineWidth', 1.5);
title('fplot: 三角函数');
legend('sin(x)', 'cos(x)', 'tan(x)', 'Location', 'best');
ylim([-3, 3]);
grid on;

disp('=== 脚本执行完毕 ===');
