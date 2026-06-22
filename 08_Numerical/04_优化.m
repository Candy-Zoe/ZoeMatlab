%% 04_优化.m — 数值优化方法
%  涵盖: fminsearch, fminunc, linprog, 最小二乘优化
%  无需额外工具箱（基础 MATLAB 即可）

clear; clc; close all;

%% ===== 1. 无约束优化: fminsearch =====
% fminsearch 使用 Nelder-Mead 单纯形法，不需要梯度信息

fprintf('===== 1. fminsearch (Nelder-Mead) =====\n');

% 示例: 求 Rosenbrock 函数的最小值
% f(x,y) = (1-x)^2 + 100*(y-x^2)^2
rosenbrock = @(x) (1 - x(1))^2 + 100 * (x(2) - x(1)^2)^2;

x0 = [-1, 1];  % 初始猜测
[x_opt, fval, exitflag, output] = fminsearch(rosenbrock, x0);

fprintf('最优解: x = %.6f, y = %.6f\n', x_opt(1), x_opt(2));
fprintf('最优值: f = %.2e\n', fval);
fprintf('迭代次数: %d, 函数评估次数: %d\n', output.iterations, output.funcCount);

% 可视化 Rosenbrock 函数等高线与优化路径
figure('Name', 'fminsearch 优化过程', 'Position', [100 100 800 400]);

x_range = linspace(-2, 2, 200);
y_range = linspace(-1, 3, 200);
[X, Y] = meshgrid(x_range, y_range);
Z = (1 - X).^2 + 100 * (Y - X.^2).^2;

subplot(1, 2, 1);
contour(X, Y, log10(Z + 1e-6), 30, 'LineWidth', 0.8);
hold on;
plot(x_opt(1), x_opt(2), 'r*', 'MarkerSize', 15, 'DisplayName', '最优解');
plot(x0(1), x0(2), 'go', 'MarkerSize', 10, 'DisplayName', '初始点');
hold off;
xlabel('x'); ylabel('y');
title('Rosenbrock 函数等高线');
legend('Location', 'best');
colorbar;

% 使用 optimset 设置选项
subplot(1, 2, 2);
options = optimset('Display', 'off', 'MaxIter', 500, 'MaxFunEvals', 2000);
[x_opt2, fval2] = fminsearch(rosenbrock, [-2, 2], options);
fprintf('\n不同初始点结果:\n');
fprintf('初始点 [-2, 2] -> 最优 (%.4f, %.4f), f = %.2e\n', x_opt2(1), x_opt2(2), fval2);

% 多个初始点对比
starts = [-2 2; 0 0; 1.5 1.5; -1 -0.5];
colors = ['r', 'b', 'g', 'm'];
hold on;
for i = 1:size(starts, 1)
    [xi, fi] = fminsearch(rosenbrock, starts(i,:), options);
    plot(xi(1), xi(2), [colors(i) 'o'], 'MarkerSize', 8, 'MarkerFaceColor', colors(i));
    fprintf('初始点 (%.1f, %.1f) -> (%.4f, %.4f), f = %.2e\n', ...
        starts(i,1), starts(i,2), xi(1), xi(2), fi);
end
hold off;
title('多初始点优化结果');
legend('Location', 'best');

%% ===== 2. 无约束优化: fminunc =====
% fminunc 使用梯度信息，收敛更快更精确（需要 Optimization Toolbox）

fprintf('\n===== 2. fminunc (梯度法) =====\n');

try
    % 方法1: 不提供梯度
    options_nograd = optimoptions('fminunc', 'Display', 'off', ...
        'Algorithm', 'quasi-newton');
    [x_unc, fval_unc, exitflag_unc, output_unc] = ...
        fminunc(rosenbrock, [-1, 1], options_nograd);
    
    fprintf('fminunc (无梯度): x = (%.6f, %.6f), f = %.2e\n', ...
        x_unc(1), x_unc(2), fval_unc);
    fprintf('迭代次数: %d\n', output_unc.iterations);
    
    % 方法2: 提供梯度函数
    rosenbrock_grad = @(x) deal(...
        (1-x(1))^2 + 100*(x(2)-x(1)^2)^2, ...
        [-2*(1-x(1)) - 400*x(1)*(x(2)-x(1)^2); ...
          200*(x(2)-x(1)^2)]);
    
    options_grad = optimoptions('fminunc', 'Display', 'off', ...
        'SpecifyObjectiveGradient', true, 'Algorithm', 'trust-region');
    [x_grad, fval_grad, ~, output_grad] = ...
        fminunc(rosenbrock_grad, [-1, 1], options_grad);
    
    fprintf('fminunc (有梯度): x = (%.6f, %.6f), f = %.2e\n', ...
        x_grad(1), x_grad(2), fval_grad);
    fprintf('迭代次数: %d\n', output_grad.iterations);
    
catch ME
    fprintf('fminunc 不可用 (需要 Optimization Toolbox): %s\n', ME.message);
end

%% ===== 3. 有界约束优化: fminbnd =====
% fminbnd 求单变量函数在区间 [a, b] 上的最小值

fprintf('\n===== 3. fminbnd (单变量有界优化) =====\n');

% 示例: 求 f(x) = x*sin(x) 在 [0, 10] 上的最小值
f_bnd = @(x) x .* sin(x);
[x_bnd, fval_bnd] = fminbnd(f_bnd, 0, 10);

fprintf('f(x) = x*sin(x) 在 [0, 10] 上的最小值:\n');
fprintf('x = %.6f, f(x) = %.6f\n', x_bnd, fval_bnd);

% 可视化
figure('Name', 'fminbnd 有界优化', 'Position', [100 100 600 400]);
x_plot = linspace(0, 10, 500);
plot(x_plot, f_bnd(x_plot), 'b-', 'LineWidth', 1.5); hold on;
plot(x_bnd, fval_bnd, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
plot(0, f_bnd(0), 'go', 'MarkerSize', 10);
plot(10, f_bnd(10), 'go', 'MarkerSize', 10);
hold off;
xlabel('x'); ylabel('f(x)');
title('f(x) = x \cdot sin(x) 在 [0, 10] 上的最小值');
legend('f(x)', '最小值点', '边界', 'Location', 'best');
grid on;

%% ===== 4. 线性规划: linprog =====
% 求解: min f'*x, 约束 A*x <= b, Aeq*x = beq, lb <= x <= ub

fprintf('\n===== 4. 线性规划 (linprog) =====\n');

try
    % 示例: 生产计划问题
    % 产品A利润3元，产品B利润5元
    % 约束: 工时 2x1 + x2 <= 100, 材料 x1 + 3*x2 <= 90
    %        x1 >= 0, x2 >= 0
    
    f_cost = [-3; -5];  % linprog 求最小值，所以取负
    A = [2, 1; 1, 3];
    b = [100; 90];
    lb = [0; 0];
    
    [x_lp, fval_lp, exitflag_lp] = linprog(f_cost, A, b, [], [], lb);
    
    if exitflag_lp > 0
        fprintf('最优生产计划:\n');
        fprintf('产品A: %.1f 件\n', x_lp(1));
        fprintf('产品B: %.1f 件\n', x_lp(2));
        fprintf('最大利润: %.1f 元\n', -fval_lp);
    end
    
    % 可视化可行域
    figure('Name', '线性规划可行域', 'Position', [100 100 600 500]);
    x1 = linspace(0, 55, 200);
    
    % 约束边界
    y1 = (100 - 2*x1);       % 2*x1 + x2 <= 100
    y2 = (90 - x1) / 3;      % x1 + 3*x2 <= 90
    
    fill([0, 50, 0], [0, 0, 100], [0.9 0.9 1], 'EdgeColor', 'none'); hold on;
    
    plot(x1, y1, 'b-', 'LineWidth', 2, 'DisplayName', '2x_1 + x_2 = 100');
    plot(x1, y2, 'r-', 'LineWidth', 2, 'DisplayName', 'x_1 + 3x_2 = 90');
    
    % 可行域
    y_feasible = min(max(y1, 0), max(y2, 0));
    y_lower = min(y1, y2);
    y_lower(y_lower < 0) = 0;
    x1_feas = x1(y_lower >= 0 & y_lower <= max(y1, y2));
    
    % 标记最优解
    plot(x_lp(1), x_lp(2), 'k*', 'MarkerSize', 15, 'DisplayName', '最优解');
    plot(0, 0, 'ko', 'MarkerSize', 8);
    
    hold off;
    xlabel('x_1 (产品A)'); ylabel('x_2 (产品B)');
    title('线性规划可行域与最优解');
    legend('Location', 'best');
    grid on;
    xlim([0 55]); ylim([0 105]);
    
    % 等利润线
    hold on;
    for profit = [50, 100, 150, -fval_lp]
        x1_line = linspace(0, 55, 100);
        x2_line = (profit + 3*x1_line) / 5;
        if abs(profit - (-fval_lp)) < 0.1
            plot(x1_line, x2_line, 'g--', 'LineWidth', 2, ...
                'DisplayName', sprintf('最优利润 = %.0f', profit));
        else
            plot(x1_line, x2_line, 'k--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
        end
    end
    hold off;
    
catch ME
    fprintf('linprog 不可用: %s\n', ME.message);
end

%% ===== 5. 最小二乘优化 =====
% lsqlin: 约束线性最小二乘
% lsqcurvefit: 非线性曲线拟合（最小二乘）

fprintf('\n===== 5. 最小二乘优化 =====\n');

% --- 5.1 线性最小二乘 (反斜杠运算符) ---
fprintf('\n--- 5.1 线性最小二乘 ---\n');

% 生成数据: y = 2*x + 3 + 噪声
rng(42);
x_data = (1:20)';
y_true = 2 * x_data + 3;
y_data = y_true + 2 * randn(size(x_data));

% 构建设计矩阵 A = [x, 1]
A = [x_data, ones(size(x_data))];
params = A \ y_data;  % 最小二乘解

fprintf('拟合结果: y = %.4f*x + %.4f\n', params(1), params(2));
fprintf('真实参数: y = 2*x + 3\n');

% 可视化
figure('Name', '最小二乘拟合', 'Position', [100 100 800 400]);

subplot(1, 2, 1);
scatter(x_data, y_data, 30, 'b', 'filled', 'DisplayName', '观测数据');
hold on;
x_fit = linspace(0, 22, 100);
plot(x_fit, params(1)*x_fit + params(2), 'r-', 'LineWidth', 2, 'DisplayName', '最小二乘拟合');
plot(x_data, y_true, 'g--', 'LineWidth', 1.5, 'DisplayName', '真实关系');
hold off;
xlabel('x'); ylabel('y');
title('线性最小二乘拟合');
legend('Location', 'best');
grid on;

% --- 5.2 非线性最小二乘 (lsqcurvefit) ---
subplot(1, 2, 2);

try
    % 拟合指数衰减: y = a * exp(-b * x) + c
    rng(123);
    x_exp = linspace(0, 5, 30)';
    y_exp_true = 3 * exp(-0.8 * x_exp) + 0.5;
    y_exp = y_exp_true + 0.15 * randn(size(x_exp));
    
    % 定义模型函数
    model_fun = @(p, x) p(1) * exp(-p(2) * x) + p(3);
    
    % 初始猜测
    p0 = [1, 1, 0];
    
    % 使用 lsqcurvefit
    options_lsq = optimoptions('lsqcurvefit', 'Display', 'off');
    [p_opt, resnorm, residual] = lsqcurvefit(model_fun, p0, x_exp, y_exp, ...
        [], [], options_lsq);
    
    fprintf('\n非线性最小二乘拟合: y = a*exp(-b*x) + c\n');
    fprintf('拟合参数: a=%.4f, b=%.4f, c=%.4f\n', p_opt(1), p_opt(2), p_opt(3));
    fprintf('真实参数: a=3, b=0.8, c=0.5\n');
    fprintf('残差平方和: %.6f\n', resnorm);
    
    % 可视化
    scatter(x_exp, y_exp, 30, 'b', 'filled', 'DisplayName', '观测数据');
    hold on;
    x_smooth = linspace(0, 5, 200);
    plot(x_smooth, model_fun(p_opt, x_smooth), 'r-', 'LineWidth', 2, ...
        'DisplayName', '拟合曲线');
    plot(x_smooth, 3*exp(-0.8*x_smooth) + 0.5, 'g--', 'LineWidth', 1.5, ...
        'DisplayName', '真实曲线');
    hold off;
    xlabel('x'); ylabel('y');
    title('非线性最小二乘 (指数衰减)');
    legend('Location', 'best');
    grid on;
    
catch ME
    % 若 lsqcurvefit 不可用，用 fminsearch 替代
    fprintf('lsqcurvefit 不可用，使用 fminsearch 替代:\n');
    
    rng(123);
    x_exp = linspace(0, 5, 30)';
    y_exp_true = 3 * exp(-0.8 * x_exp) + 0.5;
    y_exp = y_exp_true + 0.15 * randn(size(x_exp));
    
    % 用 fminsearch 最小化残差平方和
    cost_fun = @(p) sum((y_exp - (p(1)*exp(-p(2)*x_exp) + p(3))).^2);
    p0 = [1, 1, 0];
    p_opt = fminsearch(cost_fun, p0);
    
    fprintf('拟合参数: a=%.4f, b=%.4f, c=%.4f\n', p_opt(1), p_opt(2), p_opt(3));
    
    scatter(x_exp, y_exp, 30, 'b', 'filled', 'DisplayName', '观测数据');
    hold on;
    x_smooth = linspace(0, 5, 200);
    plot(x_smooth, p_opt(1)*exp(-p_opt(2)*x_smooth) + p_opt(3), 'r-', ...
        'LineWidth', 2, 'DisplayName', '拟合曲线');
    hold off;
    xlabel('x'); ylabel('y');
    title('fminsearch 替代拟合');
    legend('Location', 'best');
    grid on;
end

%% ===== 6. 综合示例: 多方法对比 =====

fprintf('\n===== 6. 优化方法对比 =====\n');

% 目标函数: Himmelblau 函数（有4个局部最小值）
% f(x,y) = (x^2+y-11)^2 + (x+y^2-7)^2
himmelblau = @(x) (x(1)^2 + x(2) - 11)^2 + (x(1) + x(2)^2 - 7)^2;

% 从不同初始点出发
starts = [3 2; -3 2; -3 -3; 3 -3];
true_minima = [3, 2; -2.8051, 3.1313; -3.7793, -3.2832; 3.5844, -1.8481];

fprintf('Himmelblau 函数 (全局最小值 = 0):\n');
fprintf('4个真实最小值点:\n');
for i = 1:4
    fprintf('  (%.4f, %.4f)\n', true_minima(i,1), true_minima(i,2));
end
fprintf('\n');

figure('Name', '优化方法对比', 'Position', [100 100 700 500]);

% 等高线
x_range = linspace(-5, 5, 300);
y_range = linspace(-5, 5, 300);
[Xg, Yg] = meshgrid(x_range, y_range);
Z = (Xg.^2 + Yg - 11).^2 + (Xg + Yg.^2 - 7).^2;

contour(Xg, Yg, log10(Z + 0.01), 40, 'LineWidth', 0.6);
hold on;

% 标记4个真实最小值
plot(true_minima(:,1), true_minima(:,2), 'k+', 'MarkerSize', 12, ...
    'LineWidth', 2, 'DisplayName', '真实最小值');

% fminsearch 从各初始点出发
colors = {'r', 'b', 'g', 'm'};
for i = 1:size(starts, 1)
    [xi, fi] = fminsearch(himmelblau, starts(i,:));
    plot(xi(1), xi(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', colors{i}, ...
        'DisplayName', sprintf('fminsearch 从 (%g,%g)', starts(i,1), starts(i,2)));
    fprintf('初始 (%g, %g) -> (%.4f, %.4f), f = %.2e\n', ...
        starts(i,1), starts(i,2), xi(1), xi(2), fi);
end

hold off;
xlabel('x'); ylabel('y');
title('Himmelblau 函数优化 (fminsearch)');
legend('Location', 'bestoutside');
colorbar;

fprintf('\n===== 优化模块学习完成! =====\n');
