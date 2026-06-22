%% =========================================================================
%  运算符
%  学习目标：掌握 MATLAB 中的算术、关系、逻辑运算符
%% =========================================================================

clear; clc; close all;

%% 1. 算术运算符
disp('--- 算术运算符 ---');

a = 10;
b = 3;

fprintf('a + b  = %d  （加法）\n', a + b);
fprintf('a - b  = %d  （减法）\n', a - b);
fprintf('a * b  = %d  （乘法）\n', a * b);
fprintf('a / b  = %.4f  （右除法，a÷b）\n', a / b);
fprintf('a \\ b = %.4f  （左除法，b÷a）\n', a \ b);
fprintf('a ^ b  = %d  （幂运算，10^3）\n', a ^ b);

%% 2. 数组算术运算（逐元素）
disp('--- 数组算术运算 ---');

A = [1, 2, 3; 4, 5, 6];
B = [2, 3, 4; 5, 6, 7];

disp('A ='); disp(A);
disp('B ='); disp(B);
disp('A + B ='); disp(A + B);
disp('A .* B = （逐元素乘法）'); disp(A .* B);
disp('A ./ B = （逐元素除法）'); disp(A ./ B);
disp('A .^ 2 = （逐元素平方）'); disp(A .^ 2);

% 矩阵乘法 vs 逐元素乘法的区别
M = [1, 2; 3, 4];
N = [5, 6; 7, 8];
disp('矩阵乘法 M*N ='); disp(M * N);
disp('逐元素乘法 M.*N ='); disp(M .* N);

%% 3. 关系运算符
disp('--- 关系运算符 ---');
% 返回逻辑值 true(1) 或 false(0)

x = 5;
y = 3;

fprintf('x == y : %d  （等于）\n', x == y);
fprintf('x ~= y : %d  （不等于）\n', x ~= y);
fprintf('x >  y : %d  （大于）\n', x > y);
fprintf('x <  y : %d  （小于）\n', x < y);
fprintf('x >= y : %d  （大于等于）\n', x >= y);
fprintf('x <= y : %d  （小于等于）\n', x <= y);

% 数组比较
v1 = [1, 2, 3, 4, 5];
v2 = [5, 4, 3, 2, 1];
disp('v1 > v2:'); disp(v1 > v2);          % 逐元素比较

%% 4. 逻辑运算符
disp('--- 逻辑运算符 ---');

p = true;
q = false;

fprintf('p & q  = %d  （逻辑与 AND）\n', p & q);
fprintf('p | q  = %d  （逻辑或 OR）\n', p | q);
fprintf('~p     = %d  （逻辑非 NOT）\n', ~p);

% 短路运算符（用于标量，性能更好）
fprintf('p && q = %d  （短路与）\n', p && q);
fprintf('p || q = %d  （短路或）\n', p || q);

% 异或
fprintf('xor(p,q) = %d  （异或 XOR）\n', xor(p, q));
fprintf('xor(1,0) = %d\n', xor(1, 0));
fprintf('xor(1,1) = %d\n', xor(1, 1));

%% 5. 逻辑运算与数组
disp('--- 逻辑运算与数组 ---');

A = [1, 0, 3, 0, 5];
B = [0, 2, 0, 4, 0];

disp('A & B（逐元素与）:'); disp(A & B);
disp('A | B（逐元素或）:'); disp(A | B);
disp('~A  （逐元素非）:'); disp(~A);

% 组合条件
v = [1, 5, 8, 3, 9, 2, 7];
mask = (v > 3) & (v < 8);
fprintf('大于3且小于8的元素: [%s]\n', num2str(v(mask)));

% any / all 函数
fprintf('any(v > 5) = %d  （是否有大于5的元素）\n', any(v > 5));
fprintf('all(v > 0) = %d  （是否全部大于0）\n', all(v > 0));

%% 6. 特殊运算符
disp('--- 特殊运算符 ---');

% 冒号运算符
v = 1:5;
fprintf('1:5       = [%s]\n', num2str(v));
v = 0:2:10;
fprintf('0:2:10    = [%s]\n', num2str(v));

% 转置
M = [1, 2, 3; 4, 5, 6];
disp('M ='); disp(M);
disp('M'' (共轭转置) ='); disp(M');

% 复数
z = 3 + 4i;
fprintf('z = %s\n', num2str(z));
fprintf('|z| = %.1f\n', abs(z));
fprintf('angle(z) = %.4f rad\n', angle(z));
fprintf('real(z) = %.1f, imag(z) = %.1f\n', real(z), imag(z));

%% 7. 运算符优先级
disp('--- 运算符优先级（从高到低）---');
disp('1. 括号 ()');
disp('2. 转置 .'''  ''');
disp('3. 幂 .^  ^');
disp('4. 一元 +  -  ~');
disp('5. 乘法 .* * ./ / .\\ \\');
disp('6. 加法 +  -');
disp('7. 冒号 :');
disp('8. 关系 < <= > >= == ~=');
disp('9. 逻辑与 &');
disp('10. 逻辑或 |');
disp('11. 短路逻辑 && ||');

% 示例
result = 2 + 3 * 4;
fprintf('2 + 3 * 4 = %d  （先乘后加）\n', result);
result = (2 + 3) * 4;
fprintf('(2 + 3) * 4 = %d  （括号优先）\n', result);

disp('=== 脚本执行完毕 ===');
