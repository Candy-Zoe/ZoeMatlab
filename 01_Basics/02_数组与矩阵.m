%% =========================================================================
%  数组与矩阵
%  学习目标：掌握数组/矩阵的创建、索引、切片、常用操作
%% =========================================================================

clear; clc; close all;

%% 1. 创建数组（行向量 / 列向量）
disp('--- 创建数组 ---');

% 行向量
row = [1, 2, 3, 4, 5];           % 逗号分隔
row2 = [1 2 3 4 5];               % 空格分隔（效果相同）
fprintf('row  = [%s], size = [%s]\n', num2str(row), num2str(size(row)));

% 列向量
col = [1; 2; 3; 4; 5];            % 分号换行
fprintf('col  size = [%s]\n', num2str(size(col)));

% 等差序列
t1 = 1:5;                          % 步长为1：[1 2 3 4 5]
t2 = 0:0.5:3;                      % 步长为0.5：[0 0.5 1 ... 3]
t3 = linspace(0, 1, 6);            % 0到1之间等间距6个点
fprintf('t1 = [%s]\n', num2str(t1));
fprintf('t2 = [%s]\n', num2str(t2));
fprintf('t3 = [%s]\n', num2str(t3));

% 特殊向量
disp('--- 特殊向量/矩阵 ---');
disp('zeros(2,3) ='); disp(zeros(2,3));
disp('ones(2,3)  ='); disp(ones(2,3));
disp('eye(3)     ='); disp(eye(3));
disp('rand(2,3)  ='); disp(rand(2,3));       % 均匀分布随机矩阵
disp('randn(2,3) ='); disp(randn(2,3));      % 正态分布随机矩阵

%% 2. 创建矩阵
disp('--- 创建矩阵 ---');

A = [1, 2, 3;
     4, 5, 6;
     7, 8, 9];
disp('A ='); disp(A);

% 矩阵大小
[rows, cols] = size(A);
fprintf('A 的大小: %d 行 x %d 列\n', rows, cols);
fprintf('A 的元素总数: %d\n', numel(A));

%% 3. 索引与切片
disp('--- 索引与切片 ---');
% MATLAB 索引从 1 开始（不是 0！）

% 单元素索引
fprintf('A(2,3) = %d\n', A(2,3));           % 第2行第3列
fprintf('A(5)   = %d  （线性索引）\n', A(5));  % 按列展开第5个元素

% 行/列选取
fprintf('A 第2行: [%s]\n', num2str(A(2,:)));
fprintf('A 第3列: [%s]\n', num2str(A(:,3)'));

% 子矩阵（切片）
sub = A(1:2, 2:3);
disp('A(1:2, 2:3) ='); disp(sub);

% end 关键字
fprintf('A 最后一行: [%s]\n', num2str(A(end,:)));
fprintf('A 最后一列: [%s]\n', num2str(A(:,end)'));

% 逻辑索引
mask = A > 5;
disp('A > 5 的逻辑矩阵:'); disp(mask);
fprintf('A 中大于5的元素: [%s]\n', num2str(A(mask)'));

%% 4. 修改元素
disp('--- 修改元素 ---');

B = A;
B(1,1) = 99;                        % 修改单个元素
B(2,:) = [10, 20, 30];              % 修改整行
B(:,3) = [100; 200; 300];           % 修改整列
disp('修改后的 B ='); disp(B);

% 删除行/列
C = A;
C(2,:) = [];                         % 删除第2行
disp('删除第2行后的 C ='); disp(C);

%% 5. 矩阵拼接
disp('--- 矩阵拼接 ---');

X = [1, 2; 3, 4];
Y = [5, 6; 7, 8];

% 水平拼接
H = [X, Y];                          % 或 horzcat(X, Y)
disp('水平拼接 [X, Y] ='); disp(H);

% 垂直拼接
V = [X; Y];                          % 或 vertcat(X, Y)
disp('垂直拼接 [X; Y] ='); disp(V);

%% 6. 数组运算（逐元素）vs 矩阵运算
disp('--- 数组运算 vs 矩阵运算 ---');

a = [1, 2, 3];
b = [4, 5, 6];

% 数组运算（逐元素，用 . 前缀）
fprintf('a + b  = [%s]\n', num2str(a + b));
fprintf('a .* b = [%s]  （逐元素乘法）\n', num2str(a .* b));
fprintf('a ./ b = [%s]  （逐元素除法）\n', num2str(a ./ b));
fprintf('a .^ 2 = [%s]  （逐元素幂）\n', num2str(a .^ 2));

% 矩阵乘法
M1 = [1, 2; 3, 4];
M2 = [5, 6; 7, 8];
fprintf('矩阵乘法 M1 * M2 =\n'); disp(M1 * M2);

% 矩阵转置
fprintf('M1'' (转置) =\n'); disp(M1');

%% 7. 常用矩阵函数
disp('--- 常用矩阵函数 ---');
M = [1, 2, 3; 4, 5, 6; 7, 8, 9];

fprintf('sum(M)      = [%s]  （每列求和）\n', num2str(sum(M)));
fprintf('sum(M,2)    = [%s]  （每行求和）\n', num2str(sum(M,2)'));
fprintf('mean(M)     = [%s]  （每列均值）\n', num2str(mean(M)));
fprintf('max(M)      = [%s]  （每列最大值）\n', num2str(max(M)));
fprintf('min(M(:))   = %d  （全局最小值）\n', min(M(:)));
fprintf('diag(M)     = [%s]  （主对角线元素）\n', num2str(diag(M)'));
fprintf('trace(M)    = %d  （迹）\n', trace(M));

% 排序
v = [3, 1, 4, 1, 5, 9, 2, 6];
[v_sorted, idx] = sort(v);
fprintf('原始:   [%s]\n', num2str(v));
fprintf('升序:   [%s]\n', num2str(v_sorted));
fprintf('索引:   [%s]\n', num2str(idx));

% 查找
positions = find(v > 4);
fprintf('大于4的位置: [%s]\n', num2str(positions));

disp('=== 脚本执行完毕 ===');
