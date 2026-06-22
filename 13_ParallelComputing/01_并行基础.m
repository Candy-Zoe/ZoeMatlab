%% 01_并行基础.m — 并行计算入门
%  涵盖: parpool, parfor vs for, spmd, 并行池管理
%  需要 Parallel Computing Toolbox

clear; clc; close all;

%% ===== 1. 并行池管理 =====
fprintf('===== 1. 并行池管理 =====\n');

% 查看并行计算环境
try
    pool_size = parpool('local');
    fprintf('并行池已启动: %d 个工作进程\n', pool_size.NumWorkers);
catch
    fprintf('使用本地并行池\n');
    gcp('nocreate');  % 获取当前池
end

fprintf('并行计算环境信息:\n');
try
    c = parcluster('local');
    fprintf('  集群类型: %s\n', c.ClusterType);
    fprintf('  最大工作进程: %d\n', c.NumWorkers);
catch
    fprintf('  无法获取集群信息\n');
end

%% ===== 2. for vs parfor =====
fprintf('\n===== 2. for vs parfor 对比 =====\n');

% 准备计算密集型任务
N = 1000;
n_trials = 100;

% --- 串行 for 循环 ---
tic;
result_serial = zeros(N, 1);
for i = 1:N
    % 模拟计算量
    A = rand(200);
    result_serial(i) = max(eig(A));
end
time_serial = toc;
fprintf('串行 for:  %.3f 秒\n', time_serial);

% --- 并行 parfor 循环 ---
tic;
result_parallel = zeros(N, 1);
parfor i = 1:N
    A = rand(200);
    result_parallel(i) = max(eig(A));
end
time_parallel = toc;
fprintf('并行 parfor: %.3f 秒\n', time_parallel);

% 加速比
speedup = time_serial / time_parallel;
fprintf('加速比: %.2fx\n', speedup);

%% ===== 3. parfor 使用规则 =====
fprintf('\n===== 3. parfor 使用规则 =====\n');

% 规则1: 循环变量必须独立
result = zeros(10, 1);
parfor i = 1:10
    result(i) = i^2;  % 正确: 每个迭代独立
end
fprintf('规则1 - 独立循环变量: 通过\n');

% 规则2: 不能依赖前一次迭代的结果
% parfor i = 2:10
%     result(i) = result(i-1) + i;  % 错误: 依赖前一次结果
% end

% 规则3: 归约变量 (reduction)
total = 0;
parfor i = 1:1000
    total = total + i^2;  % 归约变量: 自动累加
end
fprintf('规则3 - 归约变量: sum = %d (理论值 %d)\n', total, sum((1:1000).^2));

% 规则4: 切片变量 (sliced variable)
data = rand(100, 5);
means = zeros(100, 1);
parfor i = 1:100
    means(i) = mean(data(i, :));  % 每个迭代访问不同行
end
fprintf('规则4 - 切片变量: 均值范围 [%.3f, %.3f]\n', min(means), max(means));

%% ===== 4. spmd (单程序多数据) =====
fprintf('\n===== 4. spmd 并行块 =====\n');

% spmd: 每个工作进程执行相同代码，但有不同的 labindex
spmd
    % 每个 worker 知道自己的编号
    fprintf('我是 Worker %d (共 %d 个)\n', labindex, numlabs);
    
    % 每个 worker 处理不同的数据
    local_data = labindex * ones(1, 5);
    
    % 使用 labSendReceive 进行通信
    if numlabs >= 2
        if labindex == 1
            labSend(local_data, 2);  % 发送给 worker 2
        elseif labindex == 2
            received = labReceive(1);  % 从 worker 1 接收
            fprintf('Worker 2 收到: %s\n', mat2str(received));
        end
    end
end

%% ===== 5. 并行数组操作 =====
fprintf('\n===== 5. 并行数组操作 =====\n');

% distributed 数组: 自动分布到各 worker
try
    N_big = 5000;
    
    tic;
    A = rand(N_big);
    B = rand(N_big);
    C_serial = A * B;
    t_serial = toc;
    fprintf('串行矩阵乘法 (%dx%d): %.3f 秒\n', N_big, N_big, t_serial);
    
    tic;
    A_dist = distributed(rand(N_big));
    B_dist = distributed(rand(N_big));
    C_dist = A_dist * B_dist;
    C_result = gather(C_dist);
    t_parallel = toc;
    fprintf('并行矩阵乘法 (%dx%d): %.3f 秒\n', N_big, N_big, t_parallel);
    
    fprintf('加速比: %.2fx\n', t_serial / t_parallel);
    
catch ME
    fprintf('distributed 数组不可用: %s\n', ME.message);
end

%% ===== 6. 并行 vs 串行性能曲线 =====
fprintf('\n===== 6. 性能对比曲线 =====\n');

sizes = [100, 200, 400, 600, 800, 1000];
t_serial_arr = zeros(size(sizes));
t_parallel_arr = zeros(size(sizes));

for idx = 1:length(sizes)
    n = sizes(idx);
    
    tic;
    A = rand(n);
    B = rand(n);
    C = A * B;
    t_serial_arr(idx) = toc;
    
    try
        tic;
        A_d = distributed(rand(n));
        B_d = distributed(rand(n));
        C_d = A_d * B_d;
        gather(C_d);
        t_parallel_arr(idx) = toc;
    catch
        t_parallel_arr(idx) = NaN;
    end
    
    fprintf('N=%d: 串行=%.3fs, 并行=%.3fs\n', n, t_serial_arr(idx), t_parallel_arr(idx));
end

figure('Name', '并行性能对比', 'Position', [100 100 700 400]);
plot(sizes, t_serial_arr, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
plot(sizes, t_parallel_arr, 'rs-', 'LineWidth', 2, 'MarkerSize', 8);
hold off;
xlabel('矩阵大小 N'); ylabel('时间 (秒)');
title('矩阵乘法: 串行 vs 并行');
legend('串行', '并行 (distributed)', 'Location', 'best');
grid on;

fprintf('\n===== 并行基础模块完成! =====\n');
