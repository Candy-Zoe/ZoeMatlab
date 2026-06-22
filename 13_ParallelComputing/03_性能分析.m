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

%% ===== 4. 向量化技巧 =====
fprintf('\n===== 4. 向量化 vs 循环 =====\n');

% 比较向量化和循环的速度
N_vec = 1e6;
x_vec = rand(N_vec, 1);

% 方法1: 循环
tic;
y_loop = zeros(N_vec, 1);
for i = 1:N_vec
    y_loop(i) = sin(x_vec(i))^2 + cos(x_vec(i))^2;
end
t_loop = toc;

% 方法2: 向量化
tic;
y_vec = sin(x_vec).^2 + cos(x_vec).^2;
t_vec = toc;

% 方法3: 预分配 (已预分配)
fprintf('循环时间:    %.4f s\n', t_loop);
fprintf('向量化时间:  %.4f s\n', t_vec);
fprintf('加速比:      %.1f x\n', t_loop/t_vec);

% 预分配的重要性
fprintf('\n--- 预分配 vs 动态增长 ---\n');
N_alloc = 100000;

% 不预分配
tic;
A_grow = [];
for i = 1:N_alloc
    A_grow(end+1) = i^2;
end
t_grow = toc;

% 预分配
tic;
A_pre = zeros(N_alloc, 1);
for i = 1:N_alloc
    A_pre(i) = i^2;
end
t_pre = toc;

fprintf('不预分配: %.4f s\n', t_grow);
fprintf('预分配:   %.4f s\n', t_pre);
fprintf('加速比:   %.1f x\n', t_grow/t_pre);

%% ===== 5. MATLAB 性能优化技巧 =====
fprintf('\n===== 5. 性能优化技巧 =====\n');

fprintf('核心原则:\n');
fprintf('  1. 预分配数组: zeros(), ones(), NaN()\n');
fprintf('  2. 向量化: 用数组运算代替循环\n');
fprintf('  3. 避免全局变量: 用函数参数传递\n');
fprintf('  4. 使用逻辑索引: A(A>0) 比 find+循环 快\n');
fprintf('  5. 使用内置函数: sum, cumsum, sort 等已优化\n');

% 逻辑索引 vs find
x_test = randn(1, 1e6);

tic;
idx = find(x_test > 2);
count_find = length(idx);
t_find = toc;

tic;
count_logic = sum(x_test > 2);
t_logic = toc;

fprintf('\n逻辑索引示例:\n');
fprintf('  find():  %.6f s (找到 %d 个)\n', t_find, count_find);
fprintf('  sum():   %.6f s (找到 %d 个)\n', t_logic, count_logic);

%% ===== 6. 内存分析 =====
fprintf('\n===== 6. 内存使用分析 =====\n');

% 不同数据类型的内存占用
var_sizes = {
    'double标量', 8;
    'single标量', 4;
    'int32标量', 4;
    'int8标量', 1;
    'logical标量', 1;
    'double 1000x1000', 8e6;
    'single 1000x1000', 4e6;
    'sparse 1000x1000 (1%非零)', 1000*16+1000*8;
};

fprintf('%-30s %12s\n', '数据类型', '内存 (bytes)');
fprintf('%s\n', repmat('-', 1, 45));
for i = 1:size(var_sizes, 1)
    fprintf('%-30s %12.0f\n', var_sizes{i,1}, var_sizes{i,2});
end

% whos查看当前变量
fprintf('\n当前工作区变量:\n');
whos;

%% ===== 总结 =====
fprintf('\n=== 性能分析总结 ===\n');
fprintf('1. Amdahl定律: 并行加速的理论上限\n');
fprintf('2. 向量化: 用数组运算替代循环 (10-100x加速)\n');
fprintf('3. 预分配: 避免数组动态增长 (10x+加速)\n');
fprintf('4. 内存管理: 选择合适的数据类型\n');
fprintf('5. 并行适用: 独立计算、大矩阵、参数扫描\n');
