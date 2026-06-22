%% =========================================================================
%  微积分
%  学习目标：掌握符号微分、积分、极限、级数展开
%  需要: Symbolic Math Toolbox
%% =========================================================================

clear; clc; close all;

%% 1. 求导 (diff)
disp('--- 符号求导 ---');

syms x

% 一阶导数
f = x^3 + 2*x^2 - 5*x + 1;
df = diff(f, x);
fprintf('f = %s\n', char(f));
fprintf('f'' = %s\n', char(df));

% 高阶导数
d2f = diff(f, x, 2);
fprintf('f'''' = %s\n', char(d2f));

% 三角函数求导
g = sin(x) * exp(x);
dg = diff(g, x);
fprintf('(sin(x)*e^x)'' = %s\n', char(simplify(dg)));

% 多元函数偏导
syms x y z
h = x^2*y + y^3*z;
dh_dx = diff(h, x);
dh_dy = diff(h, y);
fprintf('h = %s\n', char(h));
fprintf('∂h/∂x = %s\n', char(dh_dx));
fprintf('∂h/∂y = %s\n', char(dh_dy));

%% 2. 不定积分 (int)
disp('--- 不定积分 ---');

syms x

% 基本积分
f1 = 2*x;
F1 = int(f1, x);
fprintf('∫ 2x dx = %s + C\n', char(F1));

% 三角积分
f2 = sin(x)^2;
F2 = int(f2, x);
fprintf('∫ sin^2(x) dx = %s + C\n', char(simplify(F2)));

% 指数积分
f3 = x * exp(x);
F3 = int(f3, x);
fprintf('∫ x*e^x dx = %s + C\n', char(F3));

%% 3. 定积分
disp('--- 定积分 ---');

syms x

% 定积分
f = x^2;
I = int(f, x, 0, 1);
fprintf('∫_0^1 x^2 dx = %s\n', char(I));

% 三角函数定积分
g = sin(x);
J = int(g, x, 0, pi);
fprintf('∫_0^π sin(x) dx = %s\n', char(J));

% 广义积分
h = exp(-x^2);
K = int(h, x, -inf, inf);
fprintf('∫_{-∞}^{∞} e^{-x^2} dx = %s\n', char(K));

%% 4. 极限 (limit)
disp('--- 极限 ---');

syms x

% 基本极限
L1 = limit(sin(x)/x, x, 0);
fprintf('lim(x→0) sin(x)/x = %s\n', char(L1));

% 无穷极限
L2 = limit((1 + 1/x)^x, x, inf);
fprintf('lim(x→∞) (1+1/x)^x = %s\n', char(L2));

% 左右极限
syms x
L3_left  = limit(1/x, x, 0, 'left');
L3_right = limit(1/x, x, 0, 'right');
fprintf('lim(x→0⁻) 1/x = %s\n', char(L3_left));
fprintf('lim(x→0⁺) 1/x = %s\n', char(L3_right));

%% 5. 泰勒级数 (taylor)
disp('--- 泰勒展开 ---');

syms x

% sin(x) 在 x=0 处的泰勒展开（6阶）
T_sin = taylor(sin(x), x, 'Order', 8);
fprintf('sin(x) ≈ %s\n', char(T_sin));

% exp(x) 的泰勒展开
T_exp = taylor(exp(x), x, 'Order', 6);
fprintf('e^x ≈ %s\n', char(T_exp));

% 可视化泰勒近似的精度
figure('Name', '泰勒展开近似', 'Position', [100, 100, 700, 400]);
x_num = -pi:0.01:pi;

subplot(1,2,1);
plot(x_num, sin(x_num), 'k-', 'LineWidth', 2); hold on;
for n = [3, 5, 7]
    T = taylor(sin(x), x, 'Order', n);
    T_num = double(subs(T, x, x_num));
    plot(x_num, T_num, '--', 'LineWidth', 1.5);
end
title('sin(x) 泰勒近似');
legend('sin(x)', '3阶', '5阶', '7阶', 'Location', 'best');
grid on; hold off;

subplot(1,2,2);
plot(x_num, exp(x_num), 'k-', 'LineWidth', 2); hold on;
for n = [2, 4, 6]
    T = taylor(exp(x), x, 'Order', n);
    T_num = double(subs(T, x, x_num));
    plot(x_num, T_num, '--', 'LineWidth', 1.5);
end
title('e^x 泰勒近似');
legend('e^x', '2阶', '4阶', '6阶', 'Location', 'best');
grid on; hold off;

%% 6. 级数求和 (symsum)
disp('--- 级数求和 ---');

syms n x

% 有限级数
S1 = symsum(n, n, 1, 100);
fprintf('∑_{n=1}^{100} n = %s\n', char(S1));

% 无穷级数
S2 = symsum(1/n^2, n, 1, inf);
fprintf('∑_{n=1}^{∞} 1/n^2 = %s\n', char(S2));

% 幂级数
S3 = symsum(x^n/n, n, 1, inf);
fprintf('∑_{n=1}^{∞} x^n/n = %s\n', char(S3));

disp('=== 脚本执行完毕 ===');
