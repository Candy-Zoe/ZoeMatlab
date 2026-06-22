%% =========================================================================
%  错误处理
%  学习目标：掌握 try/catch、错误标识符、自定义异常
%% =========================================================================

clear; clc; close all;

%% 1. 基本 try-catch
disp('--- 基本 try-catch ---');

try
    result = 10 / 0;
    fprintf('结果: %s\n', num2str(result));   % inf，不会报错
catch ME
    fprintf('捕获错误: %s\n', ME.message);
end

% 真正会报错的操作
try
    A = [1, 2; 3, 4];
    B = A(5, 5);                              % 索引越界
catch ME
    fprintf('捕获错误: %s\n', ME.message);
    fprintf('错误标识符: %s\n', ME.identifier);
end

%% 2. 详细的错误信息
disp('--- 错误信息 ---');

try
    x = [1, 2, 3];
    y = [1, 2];
    z = x + y;                                % 维度不匹配
catch ME
    fprintf('消息: %s\n', ME.message);
    fprintf('标识符: %s\n', ME.identifier);
    fprintf('原因:\n');
    for k = 1:length(ME.cause)
        fprintf('  [%d] %s: %s\n', k, ME.cause(k).identifier, ME.cause(k).message);
    end
    fprintf('调用栈:\n');
    for k = 1:length(ME.stack)
        fprintf('  %s (第 %d 行)\n', ME.stack(k).name, ME.stack(k).line);
    end
end

%% 3. 按错误类型处理
disp('--- 按类型处理 ---');

% 模拟不同错误
operations = {'除以零', '索引越界', '正常运算'};
for k = 1:3
    fprintf('\n操作 %d: %s\n', k, operations{k});
    try
        switch k
            case 1
                r = 1 / (k - 1);               % 1/0 → inf
                fprintf('  结果: %s\n', num2str(r));
            case 2
                A = magic(3);
                r = A(10, 10);                  % 越界
            case 3
                r = sqrt(16);
                fprintf('  结果: %.1f\n', r);
        end
    catch ME
        switch ME.identifier
            case 'MATLAB:badsubscript'
                fprintf('  → 索引越界错误，请检查索引范围\n');
            otherwise
                fprintf('  → 未知错误: %s\n', ME.message);
        end
    end
end

%% 4. finally 模式（清理资源）
disp('--- 资源清理模式 ---');

fid = -1;
try
    fid = fopen('error_test_temp.txt', 'w');
    if fid == -1
        error('无法打开文件');
    end
    fprintf(fid, '测试数据\n');
    disp('文件写入成功');
    
    % 模拟后续操作出错
    % error('模拟后续错误');
catch ME
    fprintf('发生错误: %s\n', ME.message);
end

% 无论如何都关闭文件（类似 finally）
if fid ~= -1
    fclose(fid);
    disp('文件已关闭');
    if exist('error_test_temp.txt', 'file')
        delete('error_test_temp.txt');
    end
end

%% 5. 自定义错误
disp('--- 自定义错误 ---');

% 使用 error 抛出错误
try
    validate_age(25);
    validate_age(-5);
catch ME
    fprintf('验证失败: [%s] %s\n', ME.identifier, ME.message);
end

% 使用 warning 发出警告
warning('ZoeMatlab:deprecated', '此功能已弃用，请使用新版本');
disp('（warning 不会中断程序）');

% 关闭特定警告
warning('off', 'ZoeMatlab:deprecated');
warning('ZoeMatlab:deprecated', '这条警告已被关闭');

%% 6. assert 断言
disp('--- assert 断言 ---');

% 用于调试，检查条件是否满足
try
    x = 5;
    assert(x > 0, 'MyApp:invalidInput', 'x 必须为正数，当前值: %d', x);
    disp('assert 通过');
    
    x = -3;
    assert(x > 0, 'MyApp:invalidInput', 'x 必须为正数，当前值: %d', x);
catch ME
    fprintf('assert 失败: %s\n', ME.message);
end

%% 7. 嵌套 try-catch
disp('--- 嵌套 try-catch ---');

try
    fprintf('外层 try...\n');
    try
        fprintf('  内层 try...\n');
        error('内层错误');
    catch ME_inner
        fprintf('  内层捕获: %s\n', ME_inner.message);
        fprintf('  重新抛出...\n');
        rethrow(ME_inner);                      % 重新抛给外层
    end
catch ME_outer
    fprintf('外层捕获: %s\n', ME_outer.message);
end

%% 8. 错误处理最佳实践
disp('--- 最佳实践 ---');
disp('1. 使用 try-catch 保护可能出错的操作（文件I/O、网络等）');
disp('2. 始终在 catch 中记录/显示错误信息');
disp('3. 使用 error() 抛出自定义错误，包含标识符');
disp('4. 使用 onCleanup 确保资源被释放:');
disp('   cleanupObj = onCleanup(@() fclose(fid));');
disp('5. 使用 assert 进行前置条件检查');
disp('6. 用 warning 代替非致命错误的 error');

%% 9. onCleanup 示例
disp('--- onCleanup ---');

% 即使出错或出错都会执行
try
    cleanupObj = onCleanup(@() disp('  [onCleanup] 资源已清理'));
    disp('  正在执行操作...');
    % 如果这里有错误，onCleanup 仍然会执行
catch
end
disp('（onCleanup 在函数退出时自动调用）');

disp('=== 脚本执行完毕 ===');

%% 局部函数
function validate_age(age)
    if age < 0 || age > 150
        error('MyApp:invalidAge', '年龄 %d 无效，应在 0-150 之间', age);
    end
    fprintf('年龄 %d 验证通过\n', age);
end
