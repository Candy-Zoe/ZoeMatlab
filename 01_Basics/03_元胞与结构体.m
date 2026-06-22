%% =========================================================================
%  元胞数组与结构体
%  学习目标：掌握元胞数组和结构体的创建、访问与常用操作
%% =========================================================================

clear; clc; close all;

%% 1. 元胞数组 (Cell Array) 基础
disp('--- 元胞数组基础 ---');
% 元胞数组可以存储不同类型、不同大小的数据

% 创建元胞数组（花括号 {}）
C = {1, 'hello', [1 2 3; 4 5 6], true};
disp('C ='); disp(C);

% 也可以用 cell 函数预分配
C2 = cell(2, 3);
C2{1,1} = 42;
C2{1,2} = 'MATLAB';
C2{1,3} = [1,2,3];
C2{2,1} = magic(3);
C2{2,2} = pi;
C2{2,3} = false;
disp('C2 ='); disp(C2);

%% 2. 访问元胞数组
disp('--- 访问元胞数组 ---');

C = {10, 'text', [1 2 3]};

% 圆括号 ()：返回元胞本身（仍然是 cell 类型）
cell_item = C(2);
fprintf('C(2) 类型: %s, 内容: %s\n', class(cell_item), class(cell_item{1}));

% 花括号 {}：返回元胞内的内容（取出实际数据）
content = C{2};
fprintf('C{2} 类型: %s, 值: %s\n', class(content), content);

% 访问嵌套内容
mat = C{3};
fprintf('C{3}(1,2) = %d\n', mat(1,2));

% 直接链式访问（R2019b+）
fprintf('C{3}(2) = %d\n', C{3}(2));

%% 3. 修改与删除元胞
disp('--- 修改与删除 ---');

C = {1, 2, 3, 4, 5};
C{3} = 'changed';                 % 修改第3个元胞的内容
disp('修改后:'); disp(C);

C(4) = [];                        % 删除第4个元胞（注意用圆括号）
disp('删除第4个后:'); disp(C);

% 添加新元胞
C{end+1} = 'new item';
disp('添加后:'); disp(C);

%% 4. 元胞数组常用函数
disp('--- 元胞数组常用函数 ---');

C = {1, 'hello', [1 2 3], magic(3)};

% cellfun：对每个元胞应用函数
sizes = cellfun(@size, C, 'UniformOutput', false);
disp('各元胞的大小:'); disp(sizes);

% 数值提取
nums = cellfun(@isnumeric, C);
fprintf('数值类型的元胞: [%s]\n', num2str(find(nums)));

% celldisp：显示所有内容
disp('celldisp 输出:');
celldisp(C);

% num2cell / cell2mat
v = [1, 2, 3, 4, 5];
c_from_v = num2cell(v);
disp('num2cell([1 2 3 4 5]):'); disp(c_from_v);

c_nums = {1, 2, 3, 4, 5};
m_from_c = cell2mat(c_nums);
fprintf('cell2mat: [%s]\n', num2str(m_from_c));

%% 5. 结构体 (Struct) 基础
disp('--- 结构体基础 ---');

% 方式一：逐字段赋值
student.name = '张三';
student.age  = 20;
student.grade = [85, 92, 78];
student.gpa  = 3.5;
disp('student ='); disp(student);

% 方式二：struct 函数
teacher = struct('name', '李四', ...
                 'age',  35, ...
                 'subject', '数学');
disp('teacher ='); disp(teacher);

%% 6. 访问与修改结构体字段
disp('--- 访问与修改字段 ---');

fprintf('student.name  = %s\n', student.name);
fprintf('student.gpa   = %.1f\n', student.gpa);
fprintf('student.grade = [%s]\n', num2str(student.grade));

% 修改字段
student.age = 21;
fprintf('修改后 student.age = %d\n', student.age);

% 添加新字段
student.email = 'zhangsan@example.com';
fprintf('新字段 student.email = %s\n', student.email);

% 删除字段
student = rmfield(student, 'email');
fprintf('字段列表: {%s}\n', strjoin(fieldnames(student), ', '));

%% 7. 结构体数组
disp('--- 结构体数组 ---');

% 创建结构体数组
class_data(1).name = '张三';  class_data(1).score = 85;
class_data(2).name = '李四';  class_data(2).score = 92;
class_data(3).name = '王五';  class_data(3).score = 78;
class_data(4).name = '赵六';  class_data(4).score = 95;

% 访问
fprintf('第2个学生: %s, 分数: %d\n', class_data(2).name, class_data(2).score);

% 提取所有分数
all_scores = [class_data.score];
fprintf('所有分数: [%s]\n', num2str(all_scores));
fprintf('平均分: %.1f\n', mean(all_scores));

% 查找最高分
[max_score, idx] = max(all_scores);
fprintf('最高分: %s (%d分)\n', class_data(idx).name, max_score);

%% 8. 嵌套结构体
disp('--- 嵌套结构体 ---');

person.name = '王五';
person.address.city    = '北京';
person.address.street  = '长安街1号';
person.address.zipcode = '100000';
person.contact.phone = '13800138000';
person.contact.email = 'wangwu@example.com';

fprintf('姓名: %s\n', person.name);
fprintf('城市: %s\n', person.address.city);
fprintf('电话: %s\n', person.contact.phone);

%% 9. 元胞 vs 结构体对比
disp('--- 元胞 vs 结构体 ---');
disp('元胞数组：适合存储不同类型的独立数据，通过索引访问');
disp('结构体：适合存储有命名关系的字段，通过字段名访问');
disp('选择建议：');
disp('  - 数据有明确含义 → 使用结构体');
disp('  - 数据是列表/集合 → 使用元胞数组');

disp('=== 脚本执行完毕 ===');
