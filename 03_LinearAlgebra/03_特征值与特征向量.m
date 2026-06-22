%% =========================================================================
%  特征值与特征向量
%  学习目标：掌握特征值/向量的计算及可视化
%% =========================================================================

clear; clc; close all;

%% 1. 基本特征值计算 (eig)
disp('--- 基本特征值计算 ---');

A = [4, -2;
     1,  1];

% 特征值
lambda = eig(A);
fprintf('特征值: '); disp(lambda');

% 特征向量和特征值
[V, D] = eig(A);
fprintf('特征向量矩阵 V:\n'); disp(V);
fprintf('特征值对角矩阵 D:\n'); disp(D);

% 验证 A*v = lambda*v
for i = 1:size(A, 2)
    v = V(:, i);
    lam = D(i, i);
    fprintf('特征值 %.4f: ||A*v - lambda*v|| = %.2e\n', lam, norm(A*v - lam*v));
end

%% 2. 对称矩阵的特征值
disp('--- 对称矩阵 ---');

S = [2, -1, 0;
    -1,  2, -1;
     0, -1,  2];

[V_s, D_s] = eig(S);
fprintf('对称矩阵 S 的特征值: [');
fprintf('%.4f ', diag(D_s));
fprintf(']\n');
disp('特征向量矩阵 V:'); disp(V_s);

% 对称矩阵的性质：特征向量正交
fprintf('V''*V (应为单位矩阵):\n'); disp(V_s' * V_s);
fprintf('正交性验证误差: %.2e\n', norm(V_s'*V_s - eye(3)));

%% 3. 特征值分解的应用：矩阵幂
disp('--- 矩阵幂 A^n ---');

A = [0.9, 0.1;
     0.2, 0.8];

[V, D] = eig(A);

% A^n = V * D^n * V^(-1)
n = 10;
A_n_direct = A^n;
A_n_eig = V * D^n * inv(V);

fprintf('A^%d 直接计算:\n', n); disp(A_n_direct);
fprintf('A^%d 特征值分解:\n', n); disp(A_n_eig);
fprintf('误差范数: %.2e\n', norm(A_n_direct - A_n_eig));

% 稳态分布（马尔可夫链）
fprintf('稳态分布: [%.4f, %.4f]\n', A_n_direct(1,:), A_n_direct(2,:));

%% 4. 广义特征值问题
disp('--- 广义特征值 A*x = lambda*B*x ---');

A = [1, 2; 3, 4];
B = [2, 1; 1, 2];

[V_gen, D_gen] = eig(A, B);
fprintf('广义特征值: [');
fprintf('%.4f ', diag(D_gen));
fprintf(']\n');
disp('广义特征向量:'); disp(V_gen);

% 验证
for i = 1:2
    v = V_gen(:, i);
    lam = D_gen(i, i);
    fprintf('lambda=%.4f: ||A*v - lambda*B*v|| = %.2e\n', ...
            lam, norm(A*v - lam*B*v));
end

%% 5. 特征值可视化（2D）
disp('--- 特征值可视化 ---');

A = [2, 1;
     1, 2];

[V, D] = eig(A);
lambda = diag(D);

figure('Name', '特征向量可视化', 'Position', [100, 100, 600, 600]);
hold on;

% 画单位圆
theta = linspace(0, 2*pi, 100);
plot(cos(theta), sin(theta), 'k--', 'Color', [0.7 0.7 0.7]);

% 画一些向量及其变换
angles = linspace(0, 2*pi, 25);
for ang = angles(1:end-1)
    v = [cos(ang); sin(ang)];
    Av = A * v;
    % 原向量（灰色）
    quiver(0, 0, v(1), v(2), 0, 'Color', [0.7 0.7 0.7], 'MaxHeadSize', 0.3);
    % 变换后向量（蓝色）
    quiver(0, 0, Av(1), Av(2), 0, 'Color', 'b', 'MaxHeadSize', 0.2);
end

% 画特征向量（红色）
for i = 1:2
    v = V(:, i);
    Av = A * v;
    quiver(0, 0, v(1), v(2), 0, 'Color', 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
    quiver(0, 0, Av(1), Av(2), 0, 'Color', 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
    text(v(1)*1.2, v(2)*1.2, sprintf('v_%d (\\lambda=%.0f)', i, lambda(i)), ...
         'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
end

axis equal;
grid on;
xlim([-4, 4]); ylim([-4, 4]);
title('矩阵变换与特征向量 (红=特征向量, 绿=A*v)');
xlabel('x'); ylabel('y');
legend('单位圆', '', '', '特征向量', 'A*特征向量', 'Location', 'best');
hold off;

%% 6. 奇异值分解 (SVD) 简介
disp('--- 奇异值分解 SVD ---');

A = [1, 2, 3;
     4, 5, 6];

[U, S, V] = svd(A);
fprintf('U (%s):\n', num2str(size(U))); disp(U);
fprintf('S (%s):\n', num2str(size(S))); disp(S);
fprintf('V (%s):\n', num2str(size(V))); disp(V);

% 验证 A = U*S*V'
fprintf('||A - U*S*V''|| = %.2e\n', norm(A - U*S*V'));

% 奇异值
fprintf('奇异值: [');
fprintf('%.4f ', diag(S));
fprintf(']\n');

disp('=== 脚本执行完毕 ===');
