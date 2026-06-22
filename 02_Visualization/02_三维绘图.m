%% =========================================================================
%  三维绘图
%  学习目标：掌握 plot3, surf, mesh, contour3 等三维图函数
%% =========================================================================

clear; clc; close all;

%% 1. 三维折线图 (plot3)
disp('--- 三维折线图 ---');

t = 0:0.1:10*pi;
x = cos(t);
y = sin(t);
z = t;

figure('Name', '三维折线图');
plot3(x, y, z, 'LineWidth', 2);
title('三维螺旋线');
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
view(45, 30);       % 设置视角：方位角45°，仰角30°

%% 2. 网格图 (mesh)
disp('--- 网格图 ---');

[X, Y] = meshgrid(-3:0.2:3, -3:0.2:3);
Z = sin(X) .* cos(Y);

figure('Name', '网格图');
mesh(X, Y, Z);
title('mesh: z = sin(x)*cos(y)');
xlabel('X');
ylabel('Y');
zlabel('Z');
colorbar;
colormap(jet);

%% 3. 曲面图 (surf)
disp('--- 曲面图 ---');

figure('Name', '曲面图');
surf(X, Y, Z);
title('surf: z = sin(x)*cos(y)');
xlabel('X');
ylabel('Y');
zlabel('Z');
colorbar;
shading interp;       % 平滑着色（faceted/flat/interp）

%% 4. 等高线三维图 (contour3 / surfc)
disp('--- 等高线三维图 ---');

figure('Name', '等高线三维图');
surfc(X, Y, Z);       % surf + contour 组合
title('surfc: 曲面 + 底部等高线');
xlabel('X');
ylabel('Y');
zlabel('Z');
colorbar;

% 纯三维等高线
figure('Name', '三维等高线');
contour3(X, Y, Z, 20, 'LineWidth', 1.5);
title('contour3: 20条等高线');
xlabel('X');
ylabel('Y');
zlabel('Z');
colorbar;

%% 5. 特殊三维曲面
disp('--- 特殊三维曲面 ---');

% 峰函数 (peaks)
figure('Name', 'peaks 函数');
peaks(40);
title('MATLAB 内置 peaks 函数');

% 球体
figure('Name', '球体');
[x_s, y_s, z_s] = sphere(30);
surf(x_s, y_s, z_s);
title('球体');
axis equal;
shading interp;
colormap(bone);
light;                % 添加光源

% 圆柱
figure('Name', '圆柱');
[x_c, y_c, z_c] = cylinder([1, 0.5, 1], 30);
surf(x_c, y_c, z_c);
title('变半径圆柱');
axis equal;
shading interp;

%% 6. 三维散点图 (scatter3)
disp('--- 三维散点图 ---');

rng(42);
n = 200;
x = randn(n, 1);
y = randn(n, 1);
z = randn(n, 1);
colors = sqrt(x.^2 + y.^2 + z.^2);   % 按距离着色

figure('Name', '三维散点图');
scatter3(x, y, z, 40, colors, 'filled', 'MarkerFaceAlpha', 0.7);
title('三维散点图（按距离着色）');
xlabel('X');
ylabel('Y');
zlabel('Z');
colorbar;
colormap(hot);
grid on;

%% 7. 瀑布图 (waterfall) 和 彩带图 (ribbon)
disp('--- 瀑布图与彩带图 ---');

[X, Y] = meshgrid(-2:0.3:2, -2:0.3:2);
Z = X .* exp(-X.^2 - Y.^2);

figure('Name', '瀑布图');
waterfall(X, Y, Z);
title('waterfall 瀑布图');
xlabel('X');
ylabel('Y');
zlabel('Z');

figure('Name', '彩带图');
ribbon(X, Z, 0.8);
title('ribbon 彩带图');
xlabel('X');
ylabel('Y');
zlabel('Z');

%% 8. 视角控制
disp('--- 视角控制 ---');

[X, Y] = meshgrid(-3:0.3:3);
Z = peaks(X, Y);

figure('Name', '不同视角', 'Position', [100, 100, 1000, 300]);

subplot(1,3,1);
surf(X, Y, Z);
title('默认视角');
shading interp;

subplot(1,3,2);
surf(X, Y, Z);
view(0, 90);             % 俯视图
title('俯视图 view(0,90)');
shading interp;

subplot(1,3,3);
surf(X, Y, Z);
view(0, 0);              % 侧视图
title('侧视图 view(0,0)');
shading interp;

disp('=== 脚本执行完毕，共生成多个三维图形 ===');
