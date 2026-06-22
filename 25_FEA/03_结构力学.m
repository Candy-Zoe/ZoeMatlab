%% ========================================================================
%  结构力学有限元 - Structural Mechanics FEM
%  本脚本演示结构力学问题的有限元分析
%  内容包括：梁单元、平面应力、模态分析、应力集中
%  ========================================================================
clear; clc; close all;

%% === 1. 欧拉梁单元 ===
fprintf('=== 1. 梁单元分析 ===\n');

% 梁参数
E_beam = 200e9;   % 杨氏模量 (Pa)
I_beam = 1e-6;    % 惯性矩 (m^4)
A_beam = 1e-4;    % 截面积 (m^2)
L_beam = 2;       % 梁长 (m)
n_elem_b = 10;
Le_b = L_beam / n_elem_b;

fprintf('梁参数: E=%.0f GPa, I=%.2e m^4, L=%.1f m\n', ...
        E_beam/1e9, I_beam, L_beam);

% 梁单元刚度矩阵 (4x4: w1, theta1, w2, theta2)
ke_beam = E_beam*I_beam/Le_b^3 * [12, 6*Le_b, -12, 6*Le_b;
                                    6*Le_b, 4*Le_b^2, -6*Le_b, 2*Le_b^2;
                                    -12, -6*Le_b, 12, -6*Le_b;
                                    6*Le_b, 2*Le_b^2, -6*Le_b, 4*Le_b^2];

fprintf('梁单元刚度矩阵 (4x4):\n');
disp(ke_beam);

% 全局组装 (每个节点2个DOF: w, theta)
n_nodes_b = n_elem_b + 1;
dof_b = 2 * n_nodes_b;
K_beam = zeros(dof_b);

for e = 1:n_elem_b
    d = [2*e-1, 2*e, 2*e+1, 2*e+2];
    K_beam(d,d) = K_beam(d,d) + ke_beam;
end

% 载荷: 均布载荷 q = 1000 N/m
q_load = 1000;  % N/m
F_beam = zeros(dof_b, 1);
for e = 1:n_elem_b
    fe = q_load*Le_b/12 * [6; Le_b; 6; -Le_b];
    d = [2*e-1, 2*e, 2*e+1, 2*e+2];
    F_beam(d) = F_beam(d) + fe;
end

% 边界条件: 简支梁 (w1=0, wn=0)
fixed_b = [1, dof_b-1];  % 节点1的w, 节点n的w
free_b = setdiff(1:dof_b, fixed_b);

K_free_b = K_beam(free_b, free_b);
F_free_b = F_beam(free_b);

u_beam = zeros(dof_b, 1);
u_beam(free_b) = K_free_b \ F_free_b;

% 提取挠度
w_nodes = u_beam(1:2:end);
x_beam = (0:n_nodes_b-1)' * Le_b;

% 解析解: w(x) = q*x*(L^3 - 2*L*x^2 + x^3) / (24*E*I)
w_exact = q_load * x_beam .* (L_beam^3 - 2*L_beam*x_beam.^2 + x_beam.^3) / (24*E_beam*I_beam);

figure('Name', '梁分析', 'Position', [100 100 1000 600]);
subplot(2,2,1);
plot(x_beam, w_nodes*1000, 'bo-', 'LineWidth', 2, 'MarkerSize', 6); hold on;
plot(x_beam, w_exact*1000, 'r--', 'LineWidth', 2);
xlabel('位置 (m)'); ylabel('挠度 (mm)');
title(sprintf('简支梁挠度 (q=%d N/m)', q_load));
legend('FEM','解析解');
grid on;

fprintf('最大挠度: %.4f mm (解析: %.4f mm)\n', ...
        max(abs(w_nodes))*1000, max(abs(w_exact))*1000);

% 转角
subplot(2,2,2);
theta_nodes = u_beam(2:2:end);
plot(x_beam, theta_nodes*180/pi, 'g-o', 'LineWidth', 2);
xlabel('位置 (m)'); ylabel('转角 (度)');
title('梁截面转角');
grid on;

%% === 2. 悬臂梁模态分析 ===
fprintf('\n=== 2. 模态分析 ===\n');

% 悬臂梁: 左端固定
n_elem_m = 20;
Le_m = L_beam / n_elem_m;
n_nodes_m = n_elem_m + 1;
dof_m = 2 * n_nodes_m;

K_m = zeros(dof_m);
M_m = zeros(dof_m);

% 质量矩阵
rho_beam = 7800;
me_mass = rho_beam*A_beam*Le_m/420 * [156, 22*Le_m, 54, -13*Le_m;
                                       22*Le_m, 4*Le_m^2, 13*Le_m, -3*Le_m^2;
                                       54, 13*Le_m, 156, -22*Le_m;
                                       -13*Le_m, -3*Le_m^2, -22*Le_m, 4*Le_m^2];

ke_m = E_beam*I_beam/Le_m^3 * [12, 6*Le_m, -12, 6*Le_m;
                                6*Le_m, 4*Le_m^2, -6*Le_m, 2*Le_m^2;
                                -12, -6*Le_m, 12, -6*Le_m;
                                6*Le_m, 2*Le_m^2, -6*Le_m, 4*Le_m^2];

for e = 1:n_elem_m
    d = [2*e-1, 2*e, 2*e+1, 2*e+2];
    K_m(d,d) = K_m(d,d) + ke_m;
    M_m(d,d) = M_m(d,d) + me_mass;
end

% 固定左端 (w1=0, theta1=0)
fixed_m = [1, 2];
free_m = setdiff(1:dof_m, fixed_m);

K_fm = K_m(free_m, free_m);
M_fm = M_m(free_m, free_m);

% 特征值求解
[V, D] = eigs(K_fm, M_fm, 5, 'smallestabs');
omega = sqrt(diag(D));
freq_hz = omega / (2*pi);

fprintf('前5阶固有频率:\n');
for i = 1:min(5, length(freq_hz))
    % 解析频率
    beta_L = [1.8751, 4.6941, 7.8548, 10.9955, 14.1372];
    if i <= length(beta_L)
        f_analytical = beta_L(i)^2 / (2*pi*L_beam^2) * sqrt(E_beam*I_beam/(rho_beam*A_beam));
        fprintf('  第%d阶: %.2f Hz (解析: %.2f Hz)\n', i, freq_hz(i), f_analytical);
    end
end

% 模态形状
subplot(2,2,3);
x_m = (0:n_nodes_m-1)' * Le_m;
colors = lines(min(4, size(V,2)));
for i = 1:min(4, size(V,2))
    mode_full = zeros(dof_m, 1);
    mode_full(free_m) = V(:,i);
    w_mode = mode_full(1:2:end);
    % 标准化
    w_mode = w_mode / max(abs(w_mode));
    plot(x_m, w_mode + i*1.5, '-', 'Color', colors(i,:), 'LineWidth', 2); hold on;
end
xlabel('位置 (m)'); ylabel('模态形状');
title('悬臂梁前4阶模态');
grid on;

%% === 3. 平面应力单元 ===
fprintf('\n=== 3. 平面应力分析 ===\n');

% 带孔板拉伸 (应力集中)
% 简化: 1/4模型
W = 0.1;   % 半宽 (m)
H = 0.2;   % 半高 (m)
r_hole = 0.02;  % 孔半径 (m)

% 生成网格 (结构化)
Nx2 = 15; Ny2 = 20;
x_mesh = linspace(r_hole, W, Nx2);
y_mesh = linspace(0, H, Ny2);
[X_mesh, Y_mesh] = meshgrid(x_mesh, y_mesh);
nodes_ps = [X_mesh(:), Y_mesh(:)];
n_nps = size(nodes_ps, 1);

elements_ps = [];
for j = 1:Ny2-1
    for i = 1:Nx2-1
        n1 = (j-1)*Nx2 + i;
        n2 = n1 + 1;
        n3 = n1 + Nx2 + 1;
        n4 = n1 + Nx2;
        elements_ps = [elements_ps; n1 n2 n3; n1 n3 n4];
    end
end
n_eps = size(elements_ps, 1);

% 材料矩阵 (平面应力)
nu = 0.3;  % 泊松比
t_thick = 0.01;  % 厚度
D_mat = E_beam/(1-nu^2) * [1 nu 0; nu 1 0; 0 0 (1-nu)/2];

% 组装
K_ps = sparse(n_nps*2, n_nps*2);
for e = 1:n_eps
    idx = elements_ps(e,:);
    xy = nodes_ps(idx, :);
    
    x1 = xy(1,1); y1 = xy(1,2);
    x2 = xy(2,1); y2 = xy(2,2);
    x3 = xy(3,1); y3 = xy(3,2);
    
    Ae = 0.5*abs((x2-x1)*(y3-y1)-(x3-x1)*(y2-y1));
    
    b = [y2-y3; y3-y1; y1-y2];
    c = [x3-x2; x1-x3; x2-x1];
    
    B = 1/(2*Ae) * [b(1) 0 b(2) 0 b(3) 0;
                     0 c(1) 0 c(2) 0 c(3);
                     c(1) b(1) c(2) b(2) c(3) b(3)];
    
    ke_ps = t_thick * Ae * B' * D_mat * B;
    
    dof_map = [2*idx(1)-1 2*idx(1) 2*idx(2)-1 2*idx(2) 2*idx(3)-1 2*idx(3)];
    for i = 1:6
        for j = 1:6
            K_ps(dof_map(i), dof_map(j)) = K_ps(dof_map(i), dof_map(j)) + ke_ps(i,j);
        end
    end
end

% 边界条件
sigma_applied = 10e6;  % 10 MPa拉伸
left_nodes = find(nodes_ps(:,1) < r_hole + (W-r_hole)/Nx2);
bottom_nodes = find(nodes_ps(:,2) < H/Ny2/2);
top_nodes = find(nodes_ps(:,2) > H - H/Ny2/2);

fixed_ps = [2*left_nodes; 2*bottom_nodes-1];
T_ps = zeros(2*n_nps, 1);
for tn = top_nodes'
    T_ps(2*tn) = sigma_applied * (W-r_hole)/Nx2 * t_thick;
end

free_ps = setdiff(1:2*n_nps, fixed_ps);
K_fps = K_ps(free_ps, free_ps);
F_fps = T_ps(free_ps);

u_ps = zeros(2*n_nps, 1);
u_ps(free_ps) = K_fps \ F_fps;

% 可视化
subplot(2,2,4);
displacement = sqrt(u_ps(1:2:end).^2 + u_ps(2:2:end).^2);
trisurf(elements_ps, nodes_ps(:,1)*100, nodes_ps(:,2)*100, displacement*1000);
view(2);
colorbar;
title('位移场 (mm)');
xlabel('X (cm)'); ylabel('Y (cm)');

fprintf('平面应力分析完成: %d节点, %d单元\n', n_nps, n_eps);

%% === 总结 ===
fprintf('\n=== 结构力学有限元总结 ===\n');
fprintf('1. 梁单元: 欧拉梁、挠度、转角\n');
fprintf('2. 模态分析: 特征值问题、固有频率、模态形状\n');
fprintf('3. 平面应力: 三角元、D矩阵、应力集中\n');
fprintf('4. 推荐工具箱: PDE Toolbox, Structural Mechanics Toolbox\n');
