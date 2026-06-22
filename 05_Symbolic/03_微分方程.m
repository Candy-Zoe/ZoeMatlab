%% =========================================================================
%  微分方程
%  学习目标：掌握常微分方程的符号求解方法
%  需要: Symbolic Math Toolbox
%% =========================================================================

clear; clc; close all;

%% 1. 一阶常微分方程 (dsolve)
disp('--- 一阶 ODE ---');

syms y(x)

% dy/dx = y  (指数增长)
eq1 = diff(y, x) == y;
sol1 = dsolve(eq1, y(0) == 1);
fprintf('dy/dx = y, y(0)=1 → y = %s\n', char(sol1));

% dy/dx + 2y = x  (一阶线性)
eq2 = diff(y, x) + 2*y == x;
sol2 = dsolve(eq2, y(0) == 0);
fprintf('dy/dx + 2y = x, y(0)=0 → y = %s\n', char(simplify(sol2)));

% 无初值条件（通解）
eq3 = diff(y, x) == x^2 + y;
sol3 = dsolve(eq3);
fprintf('dy/dx = x^2 + y → y = %s  (通解)\n', char(sol3));

%% 2. 二阶常微分方程
disp('--- 二阶 ODE ---');

syms y(x)

% 简谐振动: y'' + y = 0
eq_harmonic = diff(y, x, 2) + y == 0;
sol_harmonic = dsolve(eq_harmonic, y(0) == 1, diff(y,x)(0) == 0);
fprintf("y'' + y = 0, y(0)=1, y'(0)=0 → y = %s\n", char(sol_harmonic));

% 受迫振动: y'' + 4y = sin(2x)
eq_forced = diff(y, x, 2) + 4*y == sin(2*x);
sol_forced = dsolve(eq_forced, y(0) == 0, diff(y,x)(0) == 0);
fprintf("y'' + 4y = sin(2x) → y = %s\n", char(simplify(sol_forced)));

%% 3. 微分方程组
disp('--- 微分方程组 ---');

syms x(t) y(t)

% dx/dt = y, dy/dt = -x (简谐运动的等价形式)
eq_sys = [diff(x,t) == y, diff(y,t) == -x];
sol_sys = dsolve(eq_sys, x(0)==1, y(0)==0);
fprintf('x(t) = %s\n', char(sol_sys.x));
fprintf('y(t) = %s\n', char(sol_sys.y));

%% 4. 可视化 ODE 解
disp('--- ODE 解可视化 ---');

syms y(x)

% 一族解（不同初值）
eq = diff(y,x) == -2*y + 3;
figure('Name', 'ODE 解族', 'Position', [100, 100, 700, 400]);
hold on;

t_vals = 0:0.01:3;
for y0 = [0, 0.5, 1, 1.5, 2, 2.5, 3]
    sol = dsolve(eq, y(0) == y0);
    sol_num = double(subs(sol, x, t_vals));
    plot(t_vals, sol_num, 'LineWidth', 1.5);
end

% 平衡解
yline(1.5, 'k--', 'LineWidth', 2);
text(2.5, 1.6, '平衡解 y=3/2', 'FontSize', 12);

title('dy/dx = -2y + 3 的解族');
xlabel('x'); ylabel('y');
legend('y(0)=0', 'y(0)=0.5', 'y(0)=1', 'y(0)=1.5', ...
       'y(0)=2', 'y(0)=2.5', 'y(0)=3', 'Location', 'best');
grid on;
hold off;

%% 5. 向量场可视化
disp('--- 向量场 ---');

figure('Name', '向量场 dy/dx = -2y + 3', 'Position', [100, 100, 600, 500]);
[x_g, y_g] = meshgrid(0:0.4:3, -1:0.4:4);
dx = ones(size(x_g));
dy = -2*y_g + 3;

quiver(x_g, y_g, dx, dy, 0.3, 'Color', [0.3 0.5 0.7]);
hold on;
% 叠加一条解曲线
syms y_sym(x_sym)
sol = dsolve(diff(y_sym, x_sym) == -2*y_sym + 3, y_sym(0) == 0);
x_plot = 0:0.01:3;
y_plot = double(subs(sol, x_sym, x_plot));
plot(x_plot, y_plot, 'r-', 'LineWidth', 3);
title('向量场与解曲线');
xlabel('x'); ylabel('y');
grid on;
hold off;

disp('=== 脚本执行完毕 ===');
