%% =========================================================================
%  矩阵分解
%  学习目标：掌握 LU、QR、Cholesky、SVD 等矩阵分解方法
%% =========================================================================

clear; clc; close all;

%% 1. LU 分解
disp('--- LU 分解 ---');
% 将矩阵分解为 下三角(L) * 上三角(U) = P*A

A = [2, 1, 1;
     4, 3, 3;
     8, 7, 9];

[L, U, P] = lu(A);
fprintf('P (置换矩阵):\n'); disp(P);
fprintf('L (下三角矩阵):\n'); disp(L);
fprintf('U (上三角矩阵):\n'); disp(U);

% 验证 P*A = L*U
fprintf('||P*A - L*U|| = %.2e\n', norm(P*A - L*U));

% 用 LU 分解求解方程组
b = [1; 1; 1];
% P*A*x = P*b → L*U*x = P*b
y = L \ (P * b);
x = U \ y;
fprintf('LU 求解 Ax=b: x = [%s]\n', num2str(x'));
fprintf('直接求解: x = [%s]\n', num2str((A\b)'));

%% 2. QR 分解
disp('--- QR 分解 ---');
% 将矩阵分解为 正交矩阵(Q) * 上三角矩阵(R)

A = [1, 2;
     3, 4;
     5, 6];

[Q, R] = qr(A);
fprintf('Q (%s, 正交矩阵):\n', num2str(size(Q))); disp(Q);
fprintf('R (%s, 上三角矩阵):\n', num2str(size(R))); disp(R);

% 验证 A = Q*R
fprintf('||A - Q*R|| = %.2e\n', norm(A - Q*R));

% Q 的正交性验证
fprintf('||Q''*Q - I|| = %.2e\n', norm(Q'*Q - eye(size(Q,2))));

% 用 QR 分解求解超定方程组（最小二乘）
A_qr = [1, 1; 2, 1; 3, 1; 4, 1];
b_qr = [1; 3; 4; 5];
[Q_qr, R_qr] = qr(A_qr, 0);   % 经济型 QR
x_qr = R_qr \ (Q_qr' * b_qr);
x_direct = A_qr \ b_qr;
fprintf('QR 最小二乘: [%.4f, %.4f]\n', x_qr(1), x_qr(2));
fprintf('直接最小二乘: [%.4f, %.4f]\n', x_direct(1), x_direct(2));

%% 3. Cholesky 分解
disp('--- Cholesky 分解 ---');
% 对称正定矩阵分解为 L*L' (L 为下三角)

% 构造对称正定矩阵
A_chol = [4, 12, -16;
          12, 37, -43;
         -16, -43, 98];

fprintf('A 对称正定: det = %.1f\n', det(A_chol));

L_chol = chol(A_chol, 'lower');
fprintf('L (下三角):\n'); disp(L_chol);

% 验证 A = L*L'
fprintf('||A - L*L''|| = %.2e\n', norm(A_chol - L_chol*L_chol'));

% Cholesky 求解方程组
b_chol = [1; 2; 3];
y = L_chol \ b_chol;
x = L_chol' \ y;
fprintf('Cholesky 求解: x = [%s]\n', num2str(x'));

% 非正定矩阵会报错
% B = [1, 2; 2, 1];    % 非正定
% chol(B);              % 会报错

%% 4. 奇异值分解 (SVD)
disp('--- 奇异值分解 SVD ---');
% A = U * S * V'

A_svd = [1, 2, 3;
         4, 5, 6;
         7, 8, 9];

[U, S, V] = svd(A_svd);
fprintf('U (%s):\n', num2str(size(U))); disp(U);
fprintf('S (%s, 奇异值矩阵):\n', num2str(size(S))); disp(S);
fprintf('V (%s):\n', num2str(size(V))); disp(V);

% 验证
fprintf('||A - U*S*V''|| = %.2e\n', norm(A_svd - U*S*V'));

% 奇异值
sigma = diag(S);
fprintf('奇异值: [');
fprintf('%.4f ', sigma);
fprintf(']\n');

% 秩的确定
r = sum(sigma > 1e-10);
fprintf('数值秩 = %d (奇异值 > 1e-10 的个数)\n', r);

%% 5. 经济型 SVD 与低秩近似
disp('--- 低秩近似 ---');

A_full = randn(20, 15);
[U, S, V] = svd(A_full);
sigma = diag(S);

% 保留前 k 个奇异值进行低秩近似
k = 3;
A_approx = U(:, 1:k) * S(1:k, 1:k) * V(:, 1:k)';
err = norm(A_full - A_approx, 'fro') / norm(A_full, 'fro');
fprintf('保留 %d 个奇异值的近似误差: %.2f%%\n', k, err*100);

% 可视化奇异值衰减
figure('Name', '奇异值衰减', 'Position', [100, 100, 700, 400]);

subplot(1,2,1);
bar(sigma, 'FaceColor', [0.2 0.6 0.8]);
title('奇异值分布');
xlabel('序号'); ylabel('奇异值');
hold on;
bar(sigma(1:k), 'FaceColor', [0.9 0.3 0.2]);
hold off;

subplot(1,2,2);
energy = cumsum(sigma.^2) / sum(sigma.^2) * 100;
plot(1:length(sigma), energy, 'bo-', 'LineWidth', 2, 'MarkerSize', 6);
hold on;
yline(95, 'r--', 'LineWidth', 1.5);
plot(k, energy(k), 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
title('累积能量');
xlabel('保留的奇异值个数'); ylabel('累积能量 (%)');
legend('累积能量', '95%阈值', sprintf('k=%d (%.1f%%)', k, energy(k)));
grid on;
hold off;

%% 6. 特征值分解 vs SVD 对比
disp('--- 特征值分解 vs SVD ---');
disp('特征值分解 (eig):');
disp('  - 仅适用于方阵');
disp('  - A = V * D * V^(-1)');
disp('  - 特征值可以是复数');
disp('');
disp('奇异值分解 (SVD):');
disp('  - 适用于任意大小的矩阵');
disp('  - A = U * S * V''');
disp('  - 奇异值始终为非负实数');
disp('  - U, V 均为正交矩阵');
disp('');
disp('选择建议:');
disp('  - 方阵分析（稳定性、动力系统）→ eig');
disp('  - 最小二乘、降维、推荐系统 → svd');

disp('=== 脚本执行完毕 ===');
