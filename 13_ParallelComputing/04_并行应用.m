%% 04_并行应用.m — 并行计算实际应用
%  涵盖: 蒙特卡洛并行, 矩阵运算加速, 图像处理并行
%  需要 Parallel Computing Toolbox

clear; clc; close all;

%% ===== 1. 蒙特卡洛法计算 Pi (并行) =====
fprintf('===== 1. 蒙特卡洛计算 Pi =====\n');

N = 1e7;  % 采样点数

% 串行版本
rng(42);
tic;
x = rand(N, 1);
y = rand(N, 1);
inside = sum(x.^2 + y.^2 <= 1);
pi_serial = 4 * inside / N;
t_serial = toc;
fprintf('串行: Pi = %.8f, 误差 = %.2e, 时间 = %.3fs\n', ...
    pi_serial, abs(pi_serial - pi), t_serial);

% 并行版本
tic;
x_par = rand(N, 1);
y_par = rand(N, 1);
inside_par = 0;
n_chunks = 100;
chunk_size = ceil(N / n_chunks);
parfor c = 1:n_chunks
    idx_start = (c-1)*chunk_size + 1;
    idx_end = min(c*chunk_size, N);
    xc = x_par(idx_start:idx_end);
    yc = y_par(idx_start:idx_end);
    inside_par = inside_par + sum(xc.^2 + yc.^2 <= 1);
end
pi_parallel = 4 * inside_par / N;
t_parallel = toc;
fprintf('并行: Pi = %.8f, 误差 = %.2e, 时间 = %.3fs\n', ...
    pi_parallel, abs(pi_parallel - pi), t_parallel);
fprintf('加速比: %.2fx\n', t_serial / t_parallel);

% 可视化
figure('Name', '蒙特卡洛 Pi', 'Position', [100 100 600 400]);
n_show = 5000;
x_s = rand(n_show, 1); y_s = rand(n_show, 1);
in = x_s.^2 + y_s.^2 <= 1;
scatter(x_s(in), y_s(in), 3, 'b', 'filled'); hold on;
scatter(x_s(~in), y_s(~in), 3, 'r', 'filled');
theta = linspace(0, pi/2, 100);
plot(cos(theta), sin(theta), 'k-', 'LineWidth', 2);
hold off;
axis equal;
title(sprintf('蒙特卡洛 Pi 估计 (N=%d): Pi ≈ %.6f', n_show, pi_serial));

%% ===== 2. 参数扫描 (并行) =====
fprintf('\n===== 2. 参数扫描 =====\n');

% 并行计算不同参数的优化结果
% Rosenbrock 函数, 不同初始点
n_starts = 500;
x0_all = randn(n_starts, 2) * 3;
results = zeros(n_starts, 3);  % [x_opt, y_opt, fval]

rosenbrock = @(x) (1-x(1))^2 + 100*(x(2)-x(1)^2)^2;

tic;
parfor i = 1:n_starts
    opts = optimset('Display', 'off', 'MaxIter', 500);
    [xopt, fval] = fminsearch(rosenbrock, x0_all(i,:), opts);
    results(i,:) = [xopt, fval];
end
t_par = toc;

tic;
results_s = zeros(n_starts, 3);
for i = 1:n_starts
    opts = optimset('Display', 'off', 'MaxIter', 500);
    [xopt, fval] = fminsearch(rosenbrock, x0_all(i,:), opts);
    results_s(i,:) = [xopt, fval];
end
t_ser = toc;

fprintf('参数扫描 (%d 个初始点):\n', n_starts);
fprintf('  并行: %.3f 秒\n', t_par);
fprintf('  串行: %.3f 秒\n', t_ser);
fprintf('  加速比: %.2fx\n', t_ser / t_par);

% 收敛统计
converged = sum(results(:,3) < 1e-6);
fprintf('  收敛到最优的比例: %d/%d (%.1f%%)\n', ...
    converged, n_starts, converged/n_starts*100);

figure('Name', '参数扫描结果', 'Position', [200 200 600 500]);
scatter(results(:,1), results(:,2), 10, results(:,3), 'filled');
colormap('hot'); colorbar;
hold on;
plot(1, 1, 'g*', 'MarkerSize', 20);
text(1.1, 1.1, '全局最优 (1,1)', 'FontSize', 11, 'Color', 'g');
hold off;
title('Rosenbrock 优化: 不同初始点的收敛位置');
xlabel('x'); ylabel('y');

%% ===== 3. 图像处理并行 =====
fprintf('\n===== 3. 图像处理并行 =====\n');

% 创建大图像
img_size = 2000;
img = rand(img_size, img_size);

% 串行滤波
tic;
kernel = fspecial('gaussian', [15 15], 3);
img_filt_serial = zeros(img_size);
half = 7;
for i = half+1:img_size-half
    for j = half+1:img_size-half
        patch = img(i-half:i+half, j-half:j+half);
        img_filt_serial(i,j) = sum(patch .* kernel, 'all');
    end
end
t_filt_serial = toc;
fprintf('串行逐像素滤波: %.3f 秒\n', t_filt_serial);

% 并行分块处理
tic;
n_blocks = 4;
block_size = floor(img_size / n_blocks);
img_filt_par = zeros(img_size);
parfor b = 1:n_blocks
    row_start = (b-1)*block_size + half + 1;
    row_end = min(b*block_size, img_size - half);
    for i = row_start:row_end
        for j = half+1:img_size-half
            patch = img(i-half:i+half, j-half:j+half);
            img_filt_par(i,j) = sum(patch .* kernel, 'all');
        end
    end
end
t_filt_par = toc;
fprintf('并行分块滤波: %.3f 秒\n', t_filt_par);
fprintf('加速比: %.2fx\n', t_filt_serial / t_filt_par);

fprintf('\n===== 并行应用模块完成! =====\n');
