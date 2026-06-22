%% 01_传递函数.m — 控制系统建模
%  涵盖: tf, zpk, 零极点图, 传递函数运算
%  需要 Control System Toolbox

clear; clc; close all;

%% ===== 1. 创建传递函数 =====
fprintf('===== 1. 创建传递函数 =====\n');

% 方法1: 用 tf 创建 (分子/分母系数)
% G(s) = 10 / (s^2 + 3s + 2)
num1 = [10];
den1 = [1 3 2];
G1 = tf(num1, den1);

fprintf('G1(s) = \n');
disp(G1);

% 方法2: 用 zpk 创建 (零点/极点/增益)
% G(s) = 5(s+1) / ((s+2)(s+3))
z = [-1];
p = [-2, -3];
k = 5;
G2 = zpk(z, p, k);

fprintf('G2(s) = \n');
disp(G2);

% 相互转换
G1_zpk = zpk(G1);
G2_tf = tf(G2);

fprintf('G1 零极点形式:\n'); disp(G1_zpk);
fprintf('G2 传递函数形式:\n'); disp(G2_tf);

%% ===== 2. 传递函数运算 =====
fprintf('\n===== 2. 传递函数运算 =====\n');

% 串联
G_series = G1 * G2;  % 或 series(G1, G2)
fprintf('串联 G1*G2:\n'); disp(G_series);

% 并联
G_parallel = G1 + G2;  % 或 parallel(G1, G2)
fprintf('并联 G1+G2:\n'); disp(G_parallel);

% 负反馈
G_feedback = feedback(G1, G2);  % 默认负反馈
fprintf('负反馈 feedback(G1, G2):\n'); disp(G_feedback);

% 单位负反馈
G_unit_fb = feedback(G1, 1);
fprintf('单位负反馈 feedback(G1, 1):\n'); disp(G_unit_fb);

%% ===== 3. 零极点图 =====
fprintf('\n===== 3. 零极点图 =====\n');

% 创建多个系统
s = tf('s');
G3 = 10 / (s^2 + 2*s + 5);          % 欠阻尼
G4 = 10 / (s^2 + 6*s + 5);          % 过阻尼
G5 = 10 / (s^2 + 2*sqrt(5)*s + 5);  % 临界阻尼

figure('Name', '零极点图', 'Position', [100 100 800 600]);
subplot(1, 2, 1);
pzmap(G3);
title('G3: 欠阻尼 (\zeta < 1)');
grid on;

subplot(1, 2, 2);
pzmap(G4);
title('G4: 过阻尼 (\zeta > 1)');
grid on;

% 多系统对比
figure('Name', '零极点分布对比', 'Position', [200 200 600 500]);
pzmap(G3, G4, G5);
title('不同阻尼系统的零极点分布');
legend('欠阻尼', '过阻尼', '临界阻尼', 'Location', 'best');
grid on;

% 获取零极点
[z3, p3, k3] = zpkdata(G3);
[z4, p4, k4] = zpkdata(G4);
[z5, p5, k5] = zpkdata(G5);

fprintf('G3 极点: '); disp(p3');
fprintf('G4 极点: '); disp(p4');
fprintf('G5 极点: '); disp(p5');

%% ===== 4. 系统特性参数 =====
fprintf('\n===== 4. 系统特性参数 =====\n');

% 二阶系统参数
% G(s) = wn^2 / (s^2 + 2*zeta*wn*s + wn^2)
wn = sqrt(5);  % 自然频率
zeta_vals = [0.2, 0.5, 0.707, 1.0, 2.0];
labels = {'\zeta=0.2 欠阻尼', '\zeta=0.5 欠阻尼', '\zeta=0.707 临界', ...
    '\zeta=1.0 临界阻尼', '\zeta=2.0 过阻尼'};

fprintf('二阶系统参数 (wn = %.2f):\n', wn);
fprintf('  \zeta     极点                    阻尼类型\n');
for i = 1:length(zeta_vals)
    zeta = zeta_vals(i);
    sys = tf(wn^2, [1 2*zeta*wn wn^2]);
    [~, poles] = zpkdata(sys);
    fprintf('  %.3f   %.3f + %.3fi   %s\n', zeta, real(poles(1)), ...
        abs(imag(poles(1))), labels{i});
end

%% ===== 5. 离散系统 =====
fprintf('\n===== 5. 离散传递函数 =====\n');

Ts = 0.1;  % 采样周期 0.1s
Gd = c2d(G3, Ts, 'zoh');  % 连续 -> 离散 (零阶保持)

fprintf('连续系统 G3:\n'); disp(G3);
fprintf('离散系统 (Ts=%.1fs, ZOH):\n', Ts); disp(Gd);

% 离散零极点图
figure('Name', '离散系统零极点', 'Position', [300 300 500 500]);
zplane(Gd);
title('离散系统零极点图 (z 平面)');

fprintf('\n===== 传递函数模块完成! =====\n');
