%% ========================================================================
%  PDE工具箱与高级应用 - PDE Toolbox & Advanced FEA
%  本脚本演示MATLAB PDE工具箱和高级有限元技术
%  内容包括：PDE工具箱、网格细化、自适应分析、多物理场
%  ========================================================================
clear; clc; close all;

%% === 1. PDE工具箱基础 ===
fprintf('=== 1. PDE工具箱基础 ===\n');

try
    % 创建PDE模型
    model = createpde();
    
    % 定义几何: L形区域
    gd = [3 4 0 1 1 0 0 0 1 1]';
    ns = char('L')';
    sf = 'L';
    g = decsg(gd, sf, ns);
    
    geometryFromEdges(model, g);
    
    % 指定PDE系数: -div(c*grad(u)) = f
    % 泊松方程: -Laplacian(u) = 10
    specifyCoefficients(model, 'm', 0, 'd', 0, 'c', 1, 'a', 0, 'f', 10);
    
    % 边界条件: u=0 on all edges
    applyBoundaryCondition(model, 'dirichlet', 'Edge', 1:model.Geometry.NumEdges, 'u', 0);
    
    % 生成网格
    generateMesh(model, 'Hmax', 0.1);
    
    fprintf('网格节点数: %d\n', size(model.Mesh.Nodes, 2));
    fprintf('单元数: %d\n', size(model.Mesh.Elements, 2));
    
    % 求解
    result = solvepde(model);
    u_pde = result.NodalSolution;
    
    % 可视化
    figure('Name', 'PDE工具箱', 'Position', [100 100 1200 500]);
    subplot(1,3,1);
    pdeplot(model, 'XYData', u_pde, 'Contour', 'on', 'ColorMap', 'jet');
    title('泊松方程解: -\nabla^2 u = 10');
    xlabel('X'); ylabel('Y');
    
    % 网格
    subplot(1,3,2);
    pdemesh(model);
    title('有限元网格');
    
    % 梯度
    [gradx, grady] = pdegrad(model, u_pde);
    subplot(1,3,3);
    pdeplot(model, 'FlowData', [gradx; grady]);
    title('梯度场');
    
    fprintf('最大解值: %.4f\n', max(u_pde));
    
catch ME
    fprintf('PDE工具箱不可用: %s\n', ME.message);
    fprintf('使用手动实现演示...\n');
    
    figure('Name', 'PDE手动实现', 'Position', [100 100 800 500]);
    
    % 手动有限差分求解泊松方程
    Nx = 30; Ny = 30;
    dx = 1/Nx; dy = 1/Ny;
    [X, Y] = meshgrid(0:dx:1, 0:dy:1);
    
    % 创建系统矩阵
    n = (Nx+1)*(Ny+1);
    A_pde = sparse(n, n);
    b_pde = zeros(n, 1);
    
    for j = 1:Ny+1
        for i = 1:Nx+1
            idx = (j-1)*(Nx+1) + i;
            
            % 边界
            if i==1 || i==Nx+1 || j==1 || j==Ny+1
                A_pde(idx, idx) = 1;
                b_pde(idx) = 0;
            else
                A_pde(idx, idx) = -2/dx^2 - 2/dy^2;
                if i > 1
                    A_pde(idx, idx-1) = 1/dx^2;
                end
                if i < Nx+1
                    A_pde(idx, idx+1) = 1/dx^2;
                end
                if j > 1
                    A_pde(idx, idx-(Nx+1)) = 1/dy^2;
                end
                if j < Ny+1
                    A_pde(idx, idx+(Nx+1)) = 1/dy^2;
                end
                b_pde(idx) = 10;
            end
        end
    end
    
    u_fd = A_pde \ b_pde;
    U = reshape(u_fd, Nx+1, Ny+1);
    
    subplot(1,2,1);
    surf(X, Y, U', 'EdgeColor', 'none');
    title('泊松方程解 (有限差分)');
    xlabel('X'); ylabel('Y'); zlabel('u');
    
    subplot(1,2,2);
    contourf(X, Y, U', 20);
    colorbar;
    title('等值线');
end

%% === 2. 网格收敛性分析 ===
fprintf('\n=== 2. 网格收敛性分析 ===\n');

% 不同网格密度的收敛性
h_values = [0.5, 0.25, 0.1, 0.05, 0.025];
errors = zeros(size(h_values));

% 1D问题: -u'' = pi^2 * sin(pi*x), u(0)=u(1)=0
% 解析解: u = sin(pi*x)
for hi = 1:length(h_values)
    h = h_values(hi);
    x_h = (0:h:1)';
    n_h = length(x_h);
    
    K_h2 = spdiags([-ones(n_h,1), 2*ones(n_h,1), -ones(n_h,1)], [-1 0 1], n_h, n_h);
    K_h2 = K_h2 / h^2;
    f_h = pi^2 * sin(pi * x_h);
    
    % 边界条件
    K_h2(1,:) = 0; K_h2(1,1) = 1; f_h(1) = 0;
    K_h2(end,:) = 0; K_h2(end,end) = 1; f_h(end) = 0;
    
    u_h = K_h2 \ f_h;
    u_exact_h = sin(pi * x_h);
    
    errors(hi) = max(abs(u_h - u_exact_h));
    fprintf('h=%.3f: 最大误差=%.2e\n', h, errors(hi));
end

figure('Name', '收敛性分析', 'Position', [100 100 800 400]);
subplot(1,2,1);
loglog(h_values, errors, 'bo-', 'LineWidth', 2, 'MarkerSize', 8); hold on;
loglog(h_values, h_values.^2 * errors(1)/h_values(1)^2, 'r--', 'LineWidth', 1.5);
xlabel('网格尺寸 h');
ylabel('最大误差');
title('收敛阶分析');
legend('实际误差','O(h^2)参考线');
grid on;

%% === 3. 自适应网格细化 ===
fprintf('\n=== 3. 自适应网格细化概念 ===\n');

% 演示: 在解变化大的区域加密
subplot(1,2,2);

% 初始粗网格
x_coarse = 0:0.2:1;
u_coarse = sin(pi*x_coarse);

% 细化策略: 基于二阶导数
for refine = 1:3
    d2u = [0, diff(u_coarse, 2)/diff(x_coarse(1:3)).^2, 0];
    threshold = 5;
    
    x_new = x_coarse;
    u_new = u_coarse;
    
    for i = length(x_coarse)-1:-1:2
        if abs(d2u(i)) > threshold
            % 插入中点
            mid_x = (x_coarse(i-1) + x_coarse(i)) / 2;
            mid_u = sin(pi * mid_x);  % 精确求解
            idx = i;
            x_new = [x_new(1:idx-1), mid_x, x_new(idx:end)];
            u_new = [u_new(1:idx-1), mid_u, u_new(idx:end)];
        end
    end
    
    x_coarse = x_new;
    u_coarse = u_new;
end

x_fine = 0:0.01:1;
plot(x_fine, sin(pi*x_fine), 'k-', 'LineWidth', 2); hold on;
plot(x_coarse, u_coarse, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 5);
xlabel('X'); ylabel('u');
title('自适应网格细化');
legend('精确解','自适应网格');
grid on;

fprintf('自适应细化后节点数: %d (初始: 6)\n', length(x_coarse));

%% === 4. 多物理场耦合概念 ===
fprintf('\n=== 4. 多物理场耦合 ===\n');

% 热-结构耦合: 热膨胀
alpha_T = 12e-6;  % 热膨胀系数 (1/K)
T_ref = 20;       % 参考温度 (°C)
T_applied = 120;  % 工作温度 (°C)
delta_T = T_applied - T_ref;

% 简单热应力计算 (约束杆)
sigma_thermal = -E_beam * alpha_T * delta_T;
fprintf('热应力分析:\n');
fprintf('  温升: %d °C\n', delta_T);
fprintf('  热膨胀系数: %.2e /K\n', alpha_T);
fprintf('  约束热应力: %.2f MPa\n', sigma_thermal/1e6);

% 温度分布引起的热应力
T_dist = T_ref + (T_applied-T_ref) * sin(pi*x_beam/L_beam);
strain_thermal = alpha_T * (T_dist - T_ref);
stress_thermal = E_beam * strain_thermal;  % 完全约束

figure('Name', '多物理场', 'Position', [100 100 800 400]);
subplot(1,2,1);
yyaxis left;
plot(x_beam, T_dist, 'r-', 'LineWidth', 2);
ylabel('温度 (°C)');
yyaxis right;
plot(x_beam, stress_thermal/1e6, 'b-', 'LineWidth', 2);
ylabel('热应力 (MPa)');
xlabel('位置 (m)');
title('热-结构耦合');
grid on;

% 压电效应概念
subplot(1,2,2);
% 压电本构关系: S = s*T + d*E, D = d*T + eps*E
d33 = 300e-12;  % 压电常数 (m/V)
eps33 = 1500 * 8.854e-12;  % 介电常数
V_piezo = linspace(0, 100, 50);
strain_piezo = d33 * V_piezo / 0.001;  % 0.001m厚

plot(V_piezo, strain_piezo*1e6, 'b-', 'LineWidth', 2);
xlabel('电压 (V)');
ylabel('应变 (\mum/m)');
title('压电效应 (概念)');
grid on;

fprintf('\n多物理场耦合类型:\n');
fprintf('  热-结构: 热膨胀、热应力\n');
fprintf('  电-结构: 压电效应\n');
fprintf('  流-结构: 流固耦合 (FSI)\n');
fprintf('  电-热: 焦耳热\n');

%% === 总结 ===
fprintf('\n=== 有限元分析总结 ===\n');
fprintf('1. PDE工具箱: 几何建模、网格生成、求解、后处理\n');
fprintf('2. 收敛性: h细化、p细化、自适应\n');
fprintf('3. 多物理场: 热-结构、电-结构、流-固耦合\n');
fprintf('\n推荐工具箱: PDE Toolbox, Partial Differential Equation Toolbox\n');
fprintf('其他: COMSOL Multiphysics (MATLAB接口)\n');
