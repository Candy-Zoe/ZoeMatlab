%% ========================================================================
%  热传导有限元 - Heat Conduction FEM
%  本脚本演示热传导问题的有限元求解
%  内容包括：稳态热传导、瞬态热传导、对流边界、温度场可视化
%  ========================================================================
clear; clc; close all;

%% === 1. 一维稳态热传导 ===
fprintf('=== 1. 一维稳态热传导 ===\n');

% 问题: 细长杆, 左端T=100°C, 右端T=20°C
% 控制方程: d/dx(k*dT/dx) + Q = 0
k_thermal = 50;    % 热导率 (W/m·K)
L_rod = 0.5;       % 杆长 (m)
Q_source = 10000;  % 内热源 (W/m^3)
n_elem_h = 20;
n_nodes_h = n_elem_h + 1;
Le = L_rod / n_elem_h;

fprintf('热参数:\n');
fprintf('  热导率: %.0f W/(m·K)\n', k_thermal);
fprintf('  杆长: %.2f m\n', L_rod);
fprintf('  内热源: %.0f W/m^3\n', Q_source);

% 单元传导矩阵: k/L * [1 -1; -1 1]
% 单元载荷向量: Q*L/2 * [1; 1]
Ke = k_thermal/Le * [1 -1; -1 1];
Fe = Q_source * Le / 2 * [1; 1];

% 全局组装
K_h = zeros(n_nodes_h);
F_h = zeros(n_nodes_h, 1);

for e = 1:n_elem_h
    n1 = e; n2 = e + 1;
    K_h(n1,n1) = K_h(n1,n1) + Ke(1,1);
    K_h(n1,n2) = K_h(n1,n2) + Ke(1,2);
    K_h(n2,n1) = K_h(n2,n1) + Ke(2,1);
    K_h(n2,n2) = K_h(n2,n2) + Ke(2,2);
    F_h(n1) = F_h(n1) + Fe(1);
    F_h(n2) = F_h(n2) + Fe(2);
end

% 边界条件: T(1) = 100, T(end) = 20
T_bc = [100, 20];
fixed = [1, n_nodes_h];
free = setdiff(1:n_nodes_h, fixed);

% 修正载荷向量
F_h = F_h - K_h(:, fixed) * T_bc';
K_free = K_h(free, free);
F_free = F_h(free);

T = zeros(n_nodes_h, 1);
T(fixed) = T_bc;
T(free) = K_free \ F_free;

x_nodes = (0:n_nodes_h-1)' * Le;

% 解析解: T(x) = -Q/(2k)*x^2 + (T_R-T_L)/L*x + Q*L^2/(2k)*x/L + T_L
T_exact = -Q_source/(2*k_thermal)*x_nodes.^2 + ...
          ((T_bc(2)-T_bc(1))/L_rod + Q_source*L_rod/(2*k_thermal))*x_nodes + T_bc(1);

figure('Name', '稳态热传导', 'Position', [100 100 1000 500]);
subplot(1,2,1);
plot(x_nodes*100, T, 'bo-', 'LineWidth', 2, 'MarkerSize', 6); hold on;
plot(x_nodes*100, T_exact, 'r--', 'LineWidth', 2);
xlabel('位置 (cm)'); ylabel('温度 (°C)');
title('稳态温度分布');
legend('FEM','解析解');
grid on;

% 热流
subplot(1,2,2);
q = zeros(n_elem_h, 1);
for e = 1:n_elem_h
    q(e) = -k_thermal * (T(e+1) - T(e)) / Le;
end
x_elem = (0.5:n_elem_h-0.5)' * Le;
bar(x_elem*100, q, 'FaceColor', [0.8 0.2 0.2]);
xlabel('位置 (cm)'); ylabel('热流密度 (W/m^2)');
title('热流分布');
grid on;

%% === 2. 二维稳态热传导 ===
fprintf('\n=== 2. 二维稳态热传导 ===\n');

% 方形区域, 三角网格
Nx = 20; Ny = 20;
dx = 1/Nx; dy = 1/Ny;

% 生成节点
[x_g, y_g] = meshgrid(0:dx:1, 0:dy:1);
nodes_g = [x_g(:), y_g(:)];
n_nodes_g = size(nodes_g, 1);

% 生成三角单元 (每个矩形分为2个三角形)
elements_g = [];
for j = 1:Ny
    for i = 1:Nx
        n1 = (j-1)*(Nx+1) + i;
        n2 = n1 + 1;
        n3 = n1 + (Nx+1);
        n4 = n3 + 1;
        elements_g = [elements_g; n1 n2 n3; n2 n4 n3];
    end
end
n_elem_g = size(elements_g, 1);

fprintf('2D网格: %d个节点, %d个三角形单元\n', n_nodes_g, n_elem_g);

% 组装刚度矩阵 (线性三角元)
K_2d = sparse(n_nodes_g, n_nodes_g);
for e = 1:n_elem_g
    idx = elements_g(e, :);
    x1 = nodes_g(idx(1),1); y1 = nodes_g(idx(1),2);
    x2 = nodes_g(idx(2),1); y2 = nodes_g(idx(2),2);
    x3 = nodes_g(idx(3),1); y3 = nodes_g(idx(3),2);
    
    % 面积
    Ae = 0.5 * abs((x2-x1)*(y3-y1) - (x3-x1)*(y2-y1));
    
    % 形函数梯度
    b = [y2-y3; y3-y1; y1-y2];
    c = [x3-x2; x1-x3; x2-x1];
    
    % 单元传导矩阵
    ke_2d = k_thermal / (4*Ae) * (b*b' + c*c');
    
    for i = 1:3
        for j = 1:3
            K_2d(idx(i), idx(j)) = K_2d(idx(i), idx(j)) + ke_2d(i,j);
        end
    end
end

% 边界条件:
% 左边 T=100, 右边 T=50, 上下绝热 (自然边界)
left_nodes = find(nodes_g(:,1) < dx/2);
right_nodes = find(nodes_g(:,1) > 1-dx/2);

fixed_2d = [left_nodes; right_nodes];
T_fixed = [100*ones(length(left_nodes),1); 50*ones(length(right_nodes),1)];
free_2d = setdiff(1:n_nodes_g, fixed_2d);

K_free_2d = K_2d(free_2d, free_2d);
F_2d = -K_2d(:, fixed_2d) * T_fixed;
F_free_2d = F_2d(free_2d);

T_2d = zeros(n_nodes_g, 1);
T_2d(fixed_2d) = T_fixed;
T_2d(free_2d) = K_free_2d \ F_free_2d;

figure('Name', '2D热传导', 'Position', [100 100 1000 500]);
subplot(1,2,1);
trisurf(elements_g, nodes_g(:,1), nodes_g(:,2), T_2d);
view(2);
colorbar;
title('2D稳态温度场 (°C)');
xlabel('X'); ylabel('Y');

% 网格
subplot(1,2,2);
triplot(elements_g, nodes_g(:,1), nodes_g(:,2), 'b', 'LineWidth', 0.3);
title(sprintf('三角网格 (%d单元)', n_elem_g));
xlabel('X'); ylabel('Y');

%% === 3. 瞬态热传导 ===
fprintf('\n=== 3. 瞬态热传导 ===\n');

% 1D瞬态: rho*c*dT/dt = k*d2T/dx2
rho = 7800;  % 密度 (kg/m^3)
c_p = 500;   % 比热 (J/(kg·K))
alpha = k_thermal / (rho * c_p);  % 热扩散率

fprintf('热扩散率: %.2e m^2/s\n', alpha);

% 使用之前的1D网格, 初始温度T=100, 两端突然降到20
T_trans = 100 * ones(n_nodes_h, 1);
T_trans(1) = 20; T_trans(end) = 20;

% 质量矩阵 (一致质量)
Me = rho*c_p*Le/6 * [2 1; 1 2];
M_h = zeros(n_nodes_h);
for e = 1:n_elem_h
    M_h(e,e) = M_h(e,e) + Me(1,1);
    M_h(e,e+1) = M_h(e,e+1) + Me(1,2);
    M_h(e+1,e) = M_h(e+1,e) + Me(2,1);
    M_h(e+1,e+1) = M_h(e+1,e+1) + Me(2,2);
end

% 时间步进 (后向Euler)
dt = 0.5;  % 时间步长
N_time = 200;
T_snapshots = zeros(n_nodes_h, 5);
snapshot_times = [1, 10, 50, 100, 200];

for t_step = 1:N_time
    % (M + dt*K) * T^{n+1} = M * T^n
    T_old = T_trans;
    
    rhs = M_h * T_old;
    
    % 修正边界
    fixed_t = [1, n_nodes_h];
    free_t = setdiff(1:n_nodes_h, fixed_t);
    rhs = rhs - (M_h(:,fixed_t) + dt*K_h(:,fixed_t)) * [20; 20];
    
    A_sys = M_h(free_t, free_t) + dt * K_h(free_t, free_t);
    T_trans(free_t) = A_sys \ rhs(free_t);
    T_trans(fixed_t) = [20; 20];
    
    for s = 1:length(snapshot_times)
        if t_step == snapshot_times(s)
            T_snapshots(:, s) = T_trans;
        end
    end
end

figure('Name', '瞬态热传导');
plot(x_nodes*100, T_snapshots, 'LineWidth', 2); hold on;
xlabel('位置 (cm)'); ylabel('温度 (°C)');
title('温度随时间演化');
legend(sprintfc('t=%d步', snapshot_times), 'Location', 'best');
grid on;

fprintf('瞬态分析完成, 总步数: %d\n', N_time);

%% === 总结 ===
fprintf('\n=== 热传导有限元总结 ===\n');
fprintf('1. 稳态热传导: 传导矩阵 + 热源 + 边界条件\n');
fprintf('2. 二维问题: 三角元、形函数梯度、面积计算\n');
fprintf('3. 瞬态问题: 质量矩阵 + 时间积分 (后向Euler)\n');
fprintf('4. 后处理: 温度场、热流、等温线\n');
