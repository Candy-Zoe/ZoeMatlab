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

%% 6. 二阶ODE: 阻尼振动
fprintf('\n--- 阻尼振动 ---\n');

syms y2(x)
% y'' + 2*zeta*wn*y' + wn^2*y = 0
wn = 2;  % 固有频率
zeta_vals = [0.1, 0.5, 1.0, 2.0];  % 不同阻尼比
labels = {'欠阻尼(ζ=0.1)', '欠阻尼(ζ=0.5)', '临界(ζ=1.0)', '过阻尼(ζ=2.0)'};

figure('Name', '阻尼振动', 'Position', [100, 100, 800, 400]);
for i = 1:length(zeta_vals)
    z = zeta_vals(i);
    eq_damp = diff(y2,x,2) + 2*z*wn*diff(y2,x) + wn^2*y2 == 0;
    sol_damp = dsolve(eq_damp, y2(0)==1, diff(y2,x)(0)==0);
    
    x_vals = 0:0.01:8;
    y_vals = double(subs(sol_damp, x, x_vals));
    plot(x_vals, real(y_vals), 'LineWidth', 2, 'DisplayName', labels{i}); hold on;
end
xlabel('时间 t'); ylabel('位移 y');
title('不同阻尼比下的振动响应');
legend('Location', 'best');
grid on;

%% 7. 非线性 ODE: 逻辑斯谛方程
fprintf('\n--- 非线性 ODE ---\n');

syms P(t)
% dP/dt = r*P*(1-P/K)
r = 0.5;  K_pop = 100;
eq_logistic = diff(P,t) == r*P*(1-P/K_pop);
sol_logistic = dsolve(eq_logistic, P(0)==10);
fprintf('逻辑斯谛方程解: %s\n', char(simplify(sol_logistic)));

t_vals = 0:0.1:30;
P_vals = double(subs(sol_logistic, t, t_vals));

figure('Name', '逻辑斯谛增长', 'Position', [100, 100, 700, 400]);
plot(t_vals, P_vals, 'b-', 'LineWidth', 2); hold on;
yline(K_pop, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('K=%d', K_pop));
yline(K_pop/2, 'g:', 'LineWidth', 1.5, 'DisplayName', '拐点 K/2');
xlabel('时间'); ylabel('种群数量');
title('逻辑斯谛增长模型');
legend('种群数量', 'Location', 'best');
grid on;

%% 8. 符号解 vs 数值解比较
fprintf('\n--- 符号解 vs 数值解 ---\n');

% 符号解
syms y3(x)
eq_comp = diff(y3,x) == -y3 + x;
sol_sym = dsolve(eq_comp, y3(0)==1);
fprintf('符号解: y = %s\n', char(sol_sym));

% 数值解 (ode45)
f_ode = @(x,y) -y + x;
[x_num, y_num] = ode45(f_ode, [0 5], 1);

% 符号解求值
x_comp = 0:0.1:5;
y_sym_vals = double(subs(sol_sym, x, x_comp));

figure('Name', '符号解vs数值解');
plot(x_comp, y_sym_vals, 'b-', 'LineWidth', 3); hold on;
plot(x_num, y_num, 'ro', 'MarkerSize', 4);
xlabel('x'); ylabel('y');
title('符号解与数值解比较');
legend('符号解 (dsolve)', '数值解 (ode45)');
grid on;

% 误差
y_sym_at_nodes = double(subs(sol_sym, x, x_num));
max_err = max(abs(y_num - y_sym_at_nodes));
fprintf('最大误差: %.2e\n', max_err);

%% === 总结 ===
fprintf('\n=== 微分方程总结 ===\n');
fprintf('1. 一阶ODE: dsolve求解, 通解与特解\n');
fprintf('2. 二阶ODE: 简谐振动、阻尼振动、受迫振动\n');
fprintf('3. 方程组: 多变量微分方程组求解\n');
fprintf('4. 可视化: 解族、向量场、相平面\n');
fprintf('5. 非线性: 逻辑斯谛方程等\n');
fprintf('6. 符号vs数值: dsolve + ode45互补使用\n');
