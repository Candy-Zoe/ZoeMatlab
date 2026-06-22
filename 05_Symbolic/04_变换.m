%% =========================================================================
%  变换
%  学习目标：了解傅里叶变换、拉普拉斯变换的符号计算
%  需要: Symbolic Math Toolbox
%% =========================================================================

clear; clc; close all;

%% 1. 傅里叶变换 (fourier)
disp('--- 傅里叶变换 ---');

syms t w

% 基本变换
f1 = exp(-t^2);
F1 = fourier(f1, t, w);
fprintf('F{e^{-t^2}} = %s\n', char(F1));

% 矩形脉冲
f2 = heaviside(t + 1) - heaviside(t - 1);
F2 = fourier(f2, t, w);
fprintf('F{rect(t)} = %s\n', char(simplify(F2)));

% 逆变换
syms w
F3 = 1/(1 + w^2);
f3 = ifourier(F3, w, t);
fprintf('F^{-1}{1/(1+w^2)} = %s\n', char(f3));

%% 2. 拉普拉斯变换 (laplace)
disp('--- 拉普拉斯变换 ---');

syms t s

% 基本变换
g1 = 1;
G1 = laplace(g1, t, s);
fprintf('L{1} = %s\n', char(G1));

g2 = t;
G2 = laplace(g2, t, s);
fprintf('L{t} = %s\n', char(G2));

g3 = exp(-2*t);
G3 = laplace(g3, t, s);
fprintf('L{e^{-2t}} = %s\n', char(G3));

g4 = sin(3*t);
G4 = laplace(g4, t, s);
fprintf('L{sin(3t)} = %s\n', char(G4));

g5 = t * exp(-t);
G5 = laplace(g5, t, s);
fprintf('L{t*e^{-t}} = %s\n', char(G5));

%% 3. 拉普拉斯逆变换
disp('--- 拉普拉斯逆变换 ---');

syms s t

H1 = 1/s;
h1 = ilaplace(H1, s, t);
fprintf('L^{-1}{1/s} = %s\n', char(h1));

H2 = 1/(s^2 + 4);
h2 = ilaplace(H2, s, t);
fprintf('L^{-1}{1/(s^2+4)} = %s\n', char(h2));

H3 = (2*s + 1)/(s^2 + 2*s + 5);
h3 = ilaplace(H3, s, t);
fprintf('L^{-1}{(2s+1)/(s^2+2s+5)} = %s\n', char(simplify(h3)));

%% 4. 用拉普拉斯变换解 ODE
disp('--- 用拉氏变换解 ODE ---');

% y'' + 3y' + 2y = 0, y(0)=1, y'(0)=0
syms t s Y
y0 = 1;  dy0 = 0;

% 对方程两边取拉氏变换
% L{y''} = s^2*Y - s*y(0) - y'(0)
% L{y'}  = s*Y - y(0)
% L{y}   = Y

eq_laplace = (s^2*Y - s*y0 - dy0) + 3*(s*Y - y0) + 2*Y == 0;
Y_sol = solve(eq_laplace, Y);
fprintf('Y(s) = %s\n', char(Y_sol));

y_sol = ilaplace(Y_sol, s, t);
fprintf('y(t) = %s\n', char(simplify(y_sol)));

% 验证：用 dsolve 对比
syms y_d(t)
sol_dsolve = dsolve(diff(y_d,t,2) + 3*diff(y_d,t) + 2*y_d == 0, ...
                    y_d(0)==1, diff(y_d,t)(0)==0);
fprintf('dsolve 验证: y(t) = %s\n', char(simplify(sol_dsolve)));

%% 5. 传递函数概念
disp('--- 传递函数概念 ---');
disp('控制系统中，传递函数 H(s) = Y(s)/X(s)');
disp('');
disp('常见传递函数:');
disp('  一阶系统: H(s) = 1/(Ts+1)');
disp('  二阶系统: H(s) = ω_n^2/(s^2+2ζω_n*s+ω_n^2)');
disp('');
disp('MATLAB 中可用 tf() 创建传递函数（需要 Control System Toolbox）');
disp('示例: sys = tf([1], [1 2 1])  % 1/(s^2+2s+1)');

disp('=== 脚本执行完毕 ===');
