%% =========================================================================
%  文件读写操作
%  学习目标：掌握 MATLAB 中的文件 I/O 方法
%% =========================================================================

clear; clc; close all;

%% 1. 文本文件写入
disp('--- 文本文件写入 ---');

% 使用 fprintf 写入
fid = fopen('test_output.txt', 'w');
if fid ~= -1
    fprintf(fid, 'MATLAB 文件 I/O 示例\n');
    fprintf(fid, '========================\n');
    fprintf(fid, '日期: %s\n', datestr(now));
    fprintf(fid, 'pi = %.10f\n', pi);
    fclose(fid);
    disp('已写入 test_output.txt');
else
    disp('无法创建文件');
end

% 使用 writematrix（R2019a+）
data = [1, 2, 3; 4, 5, 6; 7, 8, 9];
writematrix(data, 'test_matrix.txt');
disp('已写入 test_matrix.txt');

% 使用 writetable
T = table({'张三';'李四';'王五'}, [85;92;78], [90;88;95], ...
          'VariableNames', {'姓名', '数学', '英语'});
writetable(T, 'test_table.csv');
disp('已写入 test_table.csv');

%% 2. 文本文件读取
disp('--- 文本文件读取 ---');

% 读取文本文件
if exist('test_output.txt', 'file')
    content = fileread('test_output.txt');
    disp('文件内容:');
    disp(content);
end

% 读取矩阵
if exist('test_matrix.txt', 'file')
    M = readmatrix('test_matrix.txt');
    disp('读取的矩阵:'); disp(M);
end

% 读取表格
if exist('test_table.csv', 'file')
    T_read = readtable('test_table.csv');
    disp('读取的表格:'); disp(T_read);
end

%% 3. 逐行读取
disp('--- 逐行读取 ---');

% 创建多行文件
fid = fopen('test_lines.txt', 'w');
for i = 1:5
    fprintf(fid, '第 %d 行: Hello MATLAB\n', i);
end
fclose(fid);

% 逐行读取
fid = fopen('test_lines.txt', 'r');
line_num = 0;
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line)
        line_num = line_num + 1;
        fprintf('读取: %s\n', line);
    end
end
fclose(fid);
fprintf('共 %d 行\n', line_num);

%% 4. 二进制文件
disp('--- 二进制文件 ---');

% 写入二进制
data_bin = rand(3, 4);
fid = fopen('test_binary.dat', 'wb');
fwrite(fid, data_bin, 'double');
fclose(fid);
disp('已写入 test_binary.dat');

% 读取二进制
fid = fopen('test_binary.dat', 'rb');
data_read = fread(fid, [4, 3], 'double');    % 注意行列互换
fclose(fid);
data_read = data_read';                      % 转置恢复

fprintf('原始数据:\n'); disp(data_bin);
fprintf('读取数据:\n'); disp(data_read);
fprintf('误差: %.2e\n', norm(data_bin - data_read));

%% 5. MAT 文件（MATLAB 专用）
disp('--- MAT 文件 ---');

% 保存变量到 MAT 文件
x = linspace(0, 2*pi, 100);
y = sin(x);
config = struct('name', '实验一', 'date', datestr(now), 'version', 1.0);

save('test_data.mat', 'x', 'y', 'config');
disp('已保存 test_data.mat');

% 清除变量后重新加载
clear x y config;
fprintf('清除后: exist(''x'') = %d\n', exist('x', 'var'));

load('test_data.mat');
fprintf('加载后: exist(''x'') = %d\n', exist('x', 'var'));
fprintf('config.name = %s\n', config.name);
fprintf('x 长度: %d\n', length(x));

% 只加载部分变量
clear x y config;
load('test_data.mat', 'config');     % 只加载 config
fprintf('部分加载: exist(''config'') = %d, exist(''x'') = %d\n', ...
        exist('config', 'var'), exist('x', 'var'));

%% 6. Excel 文件（如果可用）
disp('--- Excel 文件 ---');
disp('写入 Excel:');
disp('  writematrix(data, ''file.xlsx'', ''Sheet'', 1)');
disp('  writetable(T, ''file.xlsx'', ''Sheet'', ''成绩表'')');
disp('');
disp('读取 Excel:');
disp('  data = readmatrix(''file.xlsx'')');
disp('  T = readtable(''file.xlsx'', ''Sheet'', ''成绩表'')');

%% 7. 目录与文件操作
disp('--- 目录与文件操作 ---');

fprintf('当前目录: %s\n', pwd);

% 列出文件
files = dir('*.txt');
fprintf('当前目录下的 .txt 文件:\n');
for k = 1:length(files)
    fprintf('  %s (%d bytes)\n', files(k).name, files(k).bytes);
end

% 文件存在性检查
fprintf('test_output.txt 存在: %d\n', exist('test_output.txt', 'file'));
fprintf('nonexist.txt 存在: %d\n', exist('nonexist.txt', 'file'));

%% 8. 清理临时文件
disp('--- 清理 ---');
files_to_clean = {'test_output.txt', 'test_matrix.txt', 'test_table.csv', ...
                  'test_lines.txt', 'test_binary.dat', 'test_data.mat'};
for k = 1:length(files_to_clean)
    if exist(files_to_clean{k}, 'file')
        delete(files_to_clean{k});
        fprintf('已删除: %s\n', files_to_clean{k});
    end
end

disp('=== 脚本执行完毕 ===');

