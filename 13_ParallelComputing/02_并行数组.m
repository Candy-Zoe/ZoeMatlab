%% 02_并行数组.m — distributed 数组与 gpuArray
%  涵盖: distributed 数组, gpuArray, gather, GPU 运算
%  需要 Parallel Computing Toolbox

clear; clc; close all;

%% ===== 1. distributed 数组 =====
fprintf('===== 1. distributed 数组 =====\n');

% 创建 distributed 数组
try
    % 方法1: 直接创建
    A = distributed(rand(1000, 1000));
    fprintf('distributed 数组: %dx%d\n', size(A,1), size(A,2));
    fprintf('底层类: %s\n', underlyingType(A));
    
    % 方法2: 从现有数组
    B_local = randn(500, 3);
    B = distributed(B_local);
    
    % 方法3: zeros/ones
    C = distributed(zeros(100, 100));
    D = distributed(ones(50, 50));
    
    fprintf('B: %dx%d, C: %dx%d, D: %dx%d\n', ...
        size(B), size(C), size(D));
    
    % 基本运算
    result = A * A';
    fprintf('A*A'' 完成: %dx%d\n', size(result));
    
    % gather: 将结果收集回本地
    result_local = gather(result);
    fprintf('gather 后类型: %s\n', class(result_local));
    
catch ME
    fprintf('distributed 不可用: %s\n', ME.message);
end

%% ===== 2. gpuArray =====
fprintf('\n===== 2. gpuArray (GPU 计算) =====\n');

try
    % 检查 GPU 可用性
    if gpuDeviceCount > 0
        gpu = gpuDevice(1);
        fprintf('GPU 设备: %s\n', gpu.Name);
        fprintf('计算能力: %d.%d\n', gpu.ComputeCapability(1), gpu.ComputeCapability(2));
        fprintf('内存: %.1f GB\n', gpu.TotalMemory / 1e9);
        
        % 创建 gpuArray
        A_gpu = gpuArray(rand(1000));
        B_gpu = gpuArray(rand(1000));
        
        tic;
        C_gpu = A_gpu * B_gpu;
        wait(gpu);
        t_gpu = toc;
        fprintf('GPU 矩阵乘法: %.4f 秒\n', t_gpu);
        
        % 对比 CPU
        A_cpu = rand(1000);
        B_cpu = rand(1000);
        tic;
        C_cpu = A_cpu * B_cpu;
        t_cpu = toc;
        fprintf('CPU 矩阵乘法: %.4f 秒\n', t_cpu);
        
        % gather 回 CPU
        C_back = gather(C_gpu);
        fprintf('结果一致性: %s\n', mat2str(isequal(class(C_back), 'double')));
    else
        fprintf('无可用 GPU 设备\n');
    end
catch ME
    fprintf('GPU 计算不可用: %s\n', ME.message);
end

%% ===== 3. GPU 元素级运算 =====
fprintf('\n===== 3. GPU 元素级运算 =====\n');

try
    if gpuDeviceCount > 0
        N = 1e7;
        x = gpuArray(randn(N, 1));
        
        tic;
        y = sin(x).^2 + cos(x).^2;
        wait(gpuDevice(1));
        t1 = toc;
        fprintf('GPU: sin^2+cos^2 (%d 元素): %.4f 秒\n', N, t1);
        
        % 验证结果 (sin^2 + cos^2 = 1)
        y_local = gather(y);
        fprintf('验证 sin^2+cos^2=1: 误差 = %.2e\n', max(abs(y_local - 1)));
        
        tic;
        x_cpu = randn(N, 1);
        y_cpu = sin(x_cpu).^2 + cos(x_cpu).^2;
        t2 = toc;
        fprintf('CPU: sin^2+cos^2 (%d 元素): %.4f 秒\n', N, t2);
        fprintf('GPU 加速比: %.1fx\n', t2/t1);
    end
catch ME
    fprintf('GPU 不可用: %s\n', ME.message);
end

%% ===== 4. 自定义 GPU 函数 =====
fprintf('\n===== 4. 自定义 GPU 函数 =====\n');

try
    if gpuDeviceCount > 0
        % arrayfun: 在 GPU 上逐元素执行
        x_gpu = gpuArray(linspace(0, 2*pi, 1e6));
        y_gpu = arrayfun(@(x) exp(-x) * sin(3*x), x_gpu);
        wait(gpuDevice(1));
        
        x_local = gather(x_gpu);
        y_local = gather(y_gpu);
        
        figure('Name', 'GPU 计算结果', 'Position', [100 100 700 400]);
        plot(x_local, y_local, 'b-', 'LineWidth', 1);
        title('GPU arrayfun: f(x) = exp(-x) * sin(3x)');
        xlabel('x'); ylabel('f(x)');
        grid on;
    end
catch ME
    fprintf('GPU 不可用: %s\n', ME.message);
end

fprintf('\n===== 并行数组模块完成! =====\n');
