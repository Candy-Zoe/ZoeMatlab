%% 03_性能分析.m — 并行性能评估
%  涵盖: tic/toc 对比, 加速比, Amdahl 定律
%  需要 Parallel Computing Toolbox

clear; clc; close all;

%% ===== 1. 基准测试 =====
fprintf('===== 1. 基准测试 =====\n');

% 测试不同矩阵大小的运算时间
sizes = [100, 500, 1000, 2000, 3000, 5000];
ops = {'乘法', '特征值', '逆矩阵'};
times = zeros(length(sizes), length(ops));

for i = 1:length(sizes)
    n = sizes(i);
    A = rand(n);
    
    % 矩阵乘法
    tic; B = A * A; times(i,1) = toc;
    
    % 特征值 (只对较小的矩阵)
    if n <= 2000
        tic; [V,D] = eig(A); times(i,2) = toc;
    else
        times(i,2) = NaN;
    end
    
    % 逆矩阵
    if n <= 3000
        tic; Ai = inv(A); times(i,3) = toc;
    else
        times(i,3) = NaN;
    end
    
    fprintf('N=%d: 乘法=%.4fs, 特征值=%.4fs, 逆=%.4fs\n', ...
        n, times(i,1), times(i,2), times(i,3));
end

figure('Name', '运算时间基准测试', 'Position', [100 100 700 400]);
for j = 1:length(ops)
    semilogy(sizes, times(:,j), 'o-', 'LineWidth', 1.5, 'MarkerSize', 8);
    hold on;
end
hold off;
xlabel('矩阵大小 N'); ylabel('时间 (秒) [对数]');
title('矩阵运算时间基准测试');
legend(ops, 'Location', 'best');
grid on;

%% ===== 2. Amdahl 定律 =====
fprintf('\n===== 2. Amdahl 定律 =====\n');

% Amdahl: Speedup = 1 / ((1-p) + p/N)
% p = 可并行比例, N = 处理器数

p_vals = [0.5, 0.7, 0.9, 0.95, 0.99];
N_procs = 1:32;

figure('Name', 'Amdahl 定律', 'Position', [200 200 700 500]);
hold on;
colors = lines(length(p_vals));
for i = 1:length(p_vals)
    p = p_vals(i);
    speedup = 1 ./ ((1-p) + p./N_procs);
    plot(N_procs, speedup, '-', 'LineWidth', 2, 'Color', colors(i,:));
end
% 理想加速比
plot(N_procs, N_procs, 'k--', 'LineWidth', 1);
hold off;
xlabel('处理器数量'); ylabel('加速比');
title('Amdahl 定律: 理论加速比');
legend(arrayfun(@(p) sprintf('p=%.0f%%', p*100), p_vals, 'UniformOutput', false), ...
    {'理想 (线性)'}, 'Location', 'best');
grid on;

fprintf('Amdahl 定律: Speedup = 1 / ((1-p) + p/N)\n');
fprintf('  p=90%%, N=4: 理论加速比 = %.2fx\n', 1/(0.1+0.9/4));
fprintf('  p=99%%, N=4: 理论加速比 = %.2fx\n', 1/(0.01+0.99/4));
fprintf('  p=99%%, N=16: 理论加速比 = %.2fx\n', 1/(0.01+0.99/16));

%% ===== 3. 并行开销分析 =====
fprintf('\n===== 3. 并行开销 =====\n');

fprintf('并行计算的开销来源:\n');
fprintf('1. 数据分配: 将数据分发到各 worker\n');
fprintf('2. 通信开销: worker 之间的数据交换\n');
fprintf('3. 同步等待: 最慢的 worker 决定总时间\n');
fprintf('4. 串行部分: 不可并行的代码段\n');
fprintf('\n');
fprintf('适用场景:\n');
fprintf('  - 大量独立计算 (蒙特卡洛, 参数扫描)\n');
fprintf('  - 大规模矩阵运算\n');
fprintf('  - 图像处理 (像素级操作)\n');
fprintf('\n不适用场景:\n');
fprintf('  - 迭代依赖 (递推关系)\n');
fprintf('  - 小计算量任务 (开销 > 收益)\n');
fprintf('  - 大量通信的任务\n');

fprintf('\n===== 性能分析模块完成! =====\n');
