%% ========================================================================
%  有限元分析基础 - Finite Element Analysis Basics
%  本脚本演示有限元方法的基本原理和MATLAB实现
%  内容包括：一维杆单元、刚度矩阵组装、边界条件、求解
%  ========================================================================
clear; clc; close all;

%% === 1. 一维杆单元分析 ===
fprintf('=== 1. 一维杆单元 ===\n');

% 杆单元: EA/L * [1 -1; -1 1]
E = 200e9;    % 杨氏模量 (Pa, 钢材)
A = 1e-4;     % 截面积 (m^2)
L_total = 1;  % 总长度 (m)
n_elem = 10;  % 单元数
n_nodes = n_elem + 1;
Le = L_total / n_elem;  % 单元长度

fprintf('杆参数:\n');
fprintf('  E = %.0f GPa\n', E/1e9);
fprintf('  A = %.4f m^2\n', A);
fprintf('  L = %.2f m\n', L_total);
fprintf('  单元数: %d, 节点数: %d\n', n_elem, n_nodes);

% 单元刚度矩阵
ke = E*A/Le * [1 -1; -1 1];
fprintf('单元刚度矩阵:\n');
disp(ke);

%% === 2. 全局刚度矩阵组装 ===
fprintf('\n=== 2. 刚度矩阵组装 ===\n');

K_global = zeros(n_nodes);

for e = 1:n_elem
    node1 = e;
    node2 = e + 1;
    
    % 组装
    K_global(node1, node1) = K_global(node1, node1) + ke(1,1);
    K_global(node1, node2) = K_global(node1, node2) + ke(1,2);
    K_global(node2, node1) = K_global(node2, node1) + ke(2,1);
    K_global(node2, node2) = K_global(node2, node2) + ke(2,2);
end

fprintf('全局刚度矩阵 (%dx%d):\n', n_nodes, n_nodes);
% 稀疏可视化
figure('Name', '刚度矩阵', 'Position', [100 100 800 400]);
subplot(1,2,1);
spy(K_global);
title('全局刚度矩阵稀疏结构');

subplot(1,2,2);
imagesc(K_global);
colorbar;
title('刚度矩阵热力图');

%% === 3. 施加边界条件和载荷 ===
fprintf('\n=== 3. 边界条件与求解 ===\n');

% 边界条件: 左端固定 u(1) = 0
% 载荷: 右端力 F = 1000 N
F_global = zeros(n_nodes, 1);
F_global(end) = 1000;  % 右端1000N

% 方法1: 直接消除法 (删除固定自由度)
K_reduced = K_global(2:end, 2:end);
F_reduced = F_global(2:end);

% 求解
u_reduced = K_reduced \ F_reduced;
u = [0; u_reduced];

fprintf('节点位移:\n');
for i = 1:n_nodes
    x_i = (i-1) * Le;
    fprintf('  节点%d (x=%.3f): u = %.6f mm\n', i, x_i, u(i)*1000);
end

% 解析解: u(x) = F*x/(E*A)
x_nodes = (0:n_nodes-1)' * Le;
u_exact = F_global(end) * x_nodes / (E * A);

fprintf('\n最大位移: %.6f mm (解析解: %.6f mm)\n', ...
        max(u)*1000, max(u_exact)*1000);

figure('Name', '杆单元分析', 'Position', [100 100 1000 600]);
subplot(2,2,1);
plot(x_nodes*1000, u*1000, 'bo-', 'LineWidth', 2, 'MarkerSize', 8); hold on;
plot(x_nodes*1000, u_exact*1000, 'r--', 'LineWidth', 2);
xlabel('位置 (mm)'); ylabel('位移 (mm)');
title('轴向位移分布');
legend('FEM','解析解');
grid on;

% 应力计算
subplot(2,2,2);
strain = zeros(n_elem, 1);
stress = zeros(n_elem, 1);
for e = 1:n_elem
    strain(e) = (u(e+1) - u(e)) / Le;
    stress(e) = E * strain(e);
end

x_elem = (0.5:n_elem-0.5)' * Le;
bar(x_elem*1000, stress/1e6);
xlabel('位置 (mm)'); ylabel('应力 (MPa)');
title('单元应力分布');
yline(F_global(end)/A/1e6, 'r--', sprintf('理论=%.0f MPa', F_global(end)/A/1e6));
grid on;

%% === 4. 桁架结构分析 ===
fprintf('\n=== 4. 二维桁架分析 ===\n');

% 简单三角桁架
nodes = [0 0; 2 0; 4 0; 1 1.5; 3 1.5];  % 节点坐标
elements = [1 2; 2 3; 1 4; 2 4; 2 5; 3 5; 4 5];  % 单元连接

n_n = size(nodes, 1);
n_e = size(elements, 1);
dof = 2 * n_n;  % 每个节点2个自由度

fprintf('节点数: %d, 单元数: %d, 自由度: %d\n', n_n, n_e, dof);

% 组装全局刚度矩阵
K_truss = zeros(dof);

for e = 1:n_e
    n1 = elements(e, 1);
    n2 = elements(e, 2);
    
    dx = nodes(n2,1) - nodes(n1,1);
    dy = nodes(n2,2) - nodes(n1,2);
    L_e = sqrt(dx^2 + dy^2);
    
    c = dx / L_e;  % cos
    s = dy / L_e;  % sin
    
    % 单元刚度 (2D)
    k = E*A/L_e;
    ke2 = k * [c^2, c*s, -c^2, -c*s;
               c*s, s^2, -c*s, -s^2;
               -c^2, -c*s, c^2, c*s;
               -c*s, -s^2, c*s, s^2];
    
    % DOF映射
    dof_map = [2*n1-1, 2*n1, 2*n2-1, 2*n2];
    
    for i = 1:4
        for j = 1:4
            K_truss(dof_map(i), dof_map(j)) = ...
                K_truss(dof_map(i), dof_map(j)) + ke2(i,j);
        end
    end
end

% 边界条件: 节点1固定(x,y), 节点3固定(y)
% 载荷: 节点4向下1000N
F_truss = zeros(dof, 1);
F_truss(2*4) = -5000;  % 节点4 y方向 -5000N
F_truss(2*5) = -5000;  % 节点5 y方向 -5000N

% 固定DOF: 1,2 (节点1), 6 (节点3的y)
fixed_dof = [1, 2, 6];
free_dof = setdiff(1:dof, fixed_dof);

K_free = K_truss(free_dof, free_dof);
F_free = F_truss(free_dof);

u_free = K_free \ F_free;
u_truss = zeros(dof, 1);
u_truss(free_dof) = u_free;

% 可视化
subplot(2,2,3);
scale = 100;  % 变形放大
for e = 1:n_e
    n1 = elements(e,1); n2 = elements(e,2);
    % 原始
    plot([nodes(n1,1), nodes(n2,1)], [nodes(n1,2), nodes(n2,2)], ...
         'b-', 'LineWidth', 3); hold on;
    % 变形
    x1_d = nodes(n1,1) + scale*u_truss(2*n1-1);
    y1_d = nodes(n1,2) + scale*u_truss(2*n1);
    x2_d = nodes(n2,1) + scale*u_truss(2*n2-1);
    y2_d = nodes(n2,2) + scale*u_truss(2*n2);
    plot([x1_d, x2_d], [y1_d, y2_d], 'r--', 'LineWidth', 2);
end

% 画节点
scatter(nodes(:,1), nodes(:,2), 100, 'k', 'filled');
for i = 1:n_n
    xd = nodes(i,1) + scale*u_truss(2*i-1);
    yd = nodes(i,2) + scale*u_truss(2*i);
    scatter(xd, yd, 100, 'r', 'filled');
end
title(sprintf('桁架变形 (放大%d倍)', scale));
xlabel('X (m)'); ylabel('Y (m)');
axis equal; grid on;

% 单元力
subplot(2,2,4);
forces = zeros(n_e, 1);
for e = 1:n_e
    n1 = elements(e,1); n2 = elements(e,2);
    dx = nodes(n2,1) - nodes(n1,1);
    dy = nodes(n2,2) - nodes(n1,2);
    L_e = sqrt(dx^2 + dy^2);
    c = dx/L_e; s = dy/L_e;
    
    du = [u_truss(2*n1-1), u_truss(2*n1), u_truss(2*n2-1), u_truss(2*n2)];
    strain_e = [-c, -s, c, s] * du' / L_e;
    forces(e) = E * A * strain_e;
end

bar(1:n_e, forces/1000);
xlabel('单元编号'); ylabel('轴力 (kN)');
title('桁架单元轴力');
grid on;

fprintf('\n桁架分析结果:\n');
for e = 1:n_e
    fprintf('  单元%d: 轴力 = %.2f kN\n', e, forces(e)/1000);
end

%% === 总结 ===
fprintf('\n=== 有限元基础总结 ===\n');
fprintf('1. 单元刚度矩阵: 基于材料力学推导\n');
fprintf('2. 全局组装: 按节点自由度叠加\n');
fprintf('3. 边界条件: 消除法、罚函数法\n');
fprintf('4. 桁架分析: 2D杆单元、力计算\n');
