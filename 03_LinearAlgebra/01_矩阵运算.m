%% =========================================================================
%  矩阵运算基础
%  学习目标：掌握矩阵创建、转置、逆、行列式、秩等基本运算
%% =========================================================================

clear; clc; close all;

%% 1. 矩阵创建
disp('--- 矩阵创建 ---');

% 直接输入
A = [1, 2, 3;
     4, 5, 6;
     7, 8, 10];
disp('A ='); disp(A);

% 特殊矩阵
disp('单位矩阵 eye(3):'); disp(eye(3));
disp('零矩阵 zeros(2,3):'); disp(zeros(2,3));
disp('全一矩阵 ones(2,3):'); disp(ones(2,3));
disp('魔方阵 magic(4):'); disp(magic(4));    % 每行每列和对角线和相等
disp('随机矩阵 rand(3,3):'); disp(rand(3,3));
disp('对角矩阵 diag([1,2,3]):'); disp(diag([1,2,3]));

% Hilbert 矩阵、Pascal 矩阵
disp('Hilbert 矩阵 hilb(3):'); disp(hilb(3));
disp('Pascal 矩阵 pascal(4):'); disp(pascal(4));

%% 2. 矩阵基本属性
disp('--- 矩阵基本属性 ---');

A = [1, 2, 3; 4, 5, 6; 7, 8, 10];

[m, n] = size(A);
fprintf('大小: %d x %d\n', m, n);
fprintf('元素总数: %d\n', numel(A));

% 秩 (rank)
r = rank(A);
fprintf('秩 rank(A) = %d\n', r);

% 迹 (trace)
tr = trace(A);
fprintf('迹 trace(A) = %d\n', tr);

% 范数 (norm)
fprintf('1-范数 norm(A,1) = %.4f\n', norm(A, 1));
fprintf('2-范数 norm(A)   = %.4f\n', norm(A));
fprintf('无穷范数 norm(A,inf) = %.4f\n', norm(A, inf));
fprintf('Frobenius 范数 norm(A,''fro'') = %.4f\n', norm(A, 'fro'));

%% 3. 转置与共轭转置
disp('--- 转置 ---');

M = [1+2i, 3+4i;
     5+6i, 7+8i];

disp('M ='); disp(M);
disp('M'' (共轭转置) ='); disp(M');
disp('M.'' (非共轭转置) ='); disp(M.');

% 实数矩阵
B = [1, 2, 3; 4, 5, 6];
disp('B ='); disp(B);
disp('B'' (转置) ='); disp(B');

%% 4. 行列式 (det)
disp('--- 行列式 ---');

A = [1, 2, 3;
     4, 5, 6;
     7, 8, 10];

d = det(A);
fprintf('det(A) = %.4f\n', d);

% 行列式为 0 的矩阵（奇异矩阵）
B = [1, 2, 3;
     4, 5, 6;
     7, 8, 9];
fprintf('det(B) = %.4f （奇异矩阵，不可逆）\n', det(B));

%% 5. 逆矩阵 (inv)
disp('--- 逆矩阵 ---');

A = [1, 2, 3;
     4, 5, 6;
     7, 8, 10];

A_inv = inv(A);
disp('inv(A) ='); disp(A_inv);

% 验证 A * inv(A) = I
I_check = A * A_inv;
disp('A * inv(A) ='); disp(I_check);
fprintf('误差范数: %.2e\n', norm(I_check - eye(3)));

% 伪逆（适用于非方阵）
M = [1, 2; 3, 4; 5, 6];
M_pinv = pinv(M);
disp('pinv(M) ='); disp(M_pinv);
fprintf('M * pinv(M) 大小: [%s]\n', num2str(size(M * M_pinv)));

%% 6. 幂与指数
disp('--- 矩阵幂与指数 ---');

A = [1, 2; 3, 4];
disp('A ='); disp(A);
disp('A^2 ='); disp(A^2);
disp('A^3 ='); disp(A^3);
disp('A^(-1) ='); disp(A^(-1));
disp('expm(A) （矩阵指数）='); disp(expm(A));
disp('sqrtm(A) （矩阵平方根）='); disp(sqrtm(A));

%% 7. Kronecker 积
disp('--- Kronecker 积 ---');

A = [1, 2; 3, 4];
B = [0, 1; 1, 0];
K = kron(A, B);
disp('kron(A,B) ='); disp(K);

%% 8. 矩阵操作汇总
disp('--- 常用函数速查 ---');
disp('创建: eye, zeros, ones, rand, randn, magic, hilb, pascal, diag');
disp('属性: size, length, numel, rank, trace, norm, det');
disp('运算: '', .'', inv, pinv, expm, sqrtm, kron');
disp('提取: diag, tril, triu, reshape, repmat');

% 上下三角提取
A = [1, 2, 3; 4, 5, 6; 7, 8, 9];
disp('tril(A) ='); disp(tril(A));      % 下三角
disp('triu(A) ='); disp(triu(A));      % 上三角

disp('=== 脚本执行完毕 ===');
