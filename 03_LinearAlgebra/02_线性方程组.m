%% =========================================================================
%  线性方程组求解
%  学习目标：掌握 MATLAB 中线性方程组的多种求解方法
%% =========================================================================

clear; clc; close all;

%% 1. 基本线性方程组 Ax = b
disp('--- 基本线性方程组 ---');

% 3x3 方程组:
%  2x +  y -  z =  8
% -3x -  y + 2z = -11
% -2x +  y + 2z = -3

A = [2,  1, -1;
    -3, -1,  2;
    -2,  1,  2];
b = [8; -11; -3];

fprintf('系数矩阵 A:\n'); disp(A);
fprintf('右端向量 b:\n'); disp(b);

% 方法一：左除（推荐，数值最稳定）
x1 = A \ b;
fprintf('方法一 A\\b: x = [%s]\n', num2str(x1'));

% 方法二：inv 函数（不推荐，仅作对比）
x2 = inv(A) * b;
fprintf('方法二 inv(A)*b: x = [%s]\n', num2str(x2'));

% 方法三：linsolve
x3 = linsolve(A, b);
fprintf('方法三 linsolve: x = [%s]\n', num2str(x3'));

% 验证
fprintf('验证 A*x - b = [%s] （应接近零）\n', num2str((A*x1 - b)'));

%% 2. 超定方程组（方程多于未知数，最小二乘）
disp('--- 超定方程组（最小二乘）---');

% 数据拟合示例：y = a*x + b
x_data = [1; 2; 3; 4; 5];
y_data = [2.1; 3.9; 6.2; 7.8; 10.1];

% 构造设计矩阵
A_ols = [x_data, ones(size(x_data))];    % [x, 1]

% 最小二乘求解
coeff = A_ols \ y_data;
fprintf('拟合结果: y = %.4f*x + %.4f\n', coeff(1), coeff(2));

% 可视化
figure('Name', '最小二乘拟合', 'Position', [100, 100, 600, 400]);
scatter(x_data, y_data, 80, 'filled', 'MarkerFaceColor', 'b');
hold on;
x_fit = linspace(0, 6, 100);
y_fit = coeff(1) * x_fit + coeff(2);
plot(x_fit, y_fit, 'r-', 'LineWidth', 2);
title('最小二乘线性拟合');
xlabel('x'); ylabel('y');
legend('数据点', sprintf('拟合: y = %.2fx + %.2f', coeff(1), coeff(2)));
grid on;
hold off;

%% 3. 欠定方程组（方程少于未知数）
disp('--- 欠定方程组 ---');

% 2个方程，3个未知数
A_under = [1, 2, 3;
           4, 5, 6];
b_under = [7; 8];

% 左除给出最小范数解
x_under = A_under \ b_under;
fprintf('A\\b 解: x = [%s]\n', num2str(x_under'));
fprintf('验证 A*x = [%s]\n', num2str((A_under * x_under)'));

% pinv 也可以求解
x_pinv = pinv(A_under) * b_under;
fprintf('pinv 解: x = [%s]\n', num2str(x_pinv'));

%% 4. 齐次方程组 Ax = 0
disp('--- 齐次方程组 ---');

A_hom = [1, 2, 3;
         4, 5, 6;
         7, 8, 9];

fprintf('rank(A) = %d (小于 %d，有非零解)\n', rank(A_hom), size(A_hom, 2));

% 零空间（null space）
N = null(A_hom);
fprintf('零空间基向量:\n'); disp(N);

% 验证
fprintf('A * N = [%.2e] （应接近零）\n', norm(A_hom * N));

%% 5. 多种右端向量同时求解
disp('--- 多种右端向量 ---');

A = [1, 2, 3;
     4, 5, 6;
     7, 8, 10];

% 多个右端向量排成矩阵的列
B = [1, 0, 0;
     0, 1, 0;
     0, 0, 1];       % 实际就是求逆

X = A \ B;
disp('A \ I = inv(A):'); disp(X);

% 对比直接求逆
fprintf('误差范数: %.2e\n', norm(X - inv(A)));

%% 6. 稀疏矩阵方程组
disp('--- 稀疏矩阵 ---');

% 创建大型稀疏对角矩阵
n = 100;
A_sparse = spdiags([ones(n,1), -2*ones(n,1), ones(n,1)], [-1, 0, 1], n, n);
b_sparse = randn(n, 1);

% 求解
tic;
x_sparse = A_sparse \ b_sparse;
t1 = toc;
fprintf('稀疏矩阵求解 (%dx%d): 耗时 %.4f 秒\n', n, n, t1);

% 对比密集矩阵
A_dense = full(A_sparse);
tic;
x_dense = A_dense \ b_dense;
t2 = toc;
fprintf('密集矩阵求解 (%dx%d): 耗时 %.4f 秒\n', n, n, t2);
fprintf('稀疏加速比: %.1fx\n', t2/t1);

disp('=== 脚本执行完毕 ===');
