%% Simulink 子系统与封装 (Subsystems & Masking)
% 本脚本演示 Simulink 子系统和模块封装技术
% 需要 Simulink
% 内容: 子系统创建, 封装参数, 条件子系统, 模型引用
clear; clc; close all;

%% === 第一部分: 子系统基础 ===
fprintf('=== Simulink 子系统与封装 ===\n\n');
fprintf('--- 第一部分: 子系统概念 ---\n\n');

fprintf('子系统 (Subsystem) 的作用:\n');
fprintf('  - 将相关模块组织在一起, 简化模型结构\n');
fprintf('  - 实现模块化设计和层次化管理\n');
fprintf('  - 可封装为可复用的组件\n');
fprintf('  - 支持条件执行和函数调用\n\n');

fprintf('创建子系统的方法:\n');
fprintf('  1. 选中模块 → 右键 → Create Subsystem\n');
fprintf('  2. 拖入 Subsystem 模块 → 双击编辑\n');
fprintf('  3. 程序化: add_block + move 命令\n');

try
    model_name = 'subsystem_demo';
    if bdIsLoaded(model_name), close_system(model_name, 0); end
    new_system(model_name);
    open_system(model_name);
    
    % 创建子系统
    add_block('simulink/Ports & Subsystems/Subsystem', [model_name '/MySubsystem']);
    
    % 在子系统内部添加模块
    add_block('simulink/Math Operations/Gain', [model_name '/MySubsystem/Gain1']);
    add_block('simulink/Math Operations/Gain', [model_name '/MySubsystem/Gain2']);
    add_block('simulink/Math Operations/Sum', [model_name '/MySubsystem/Sum1']);
    
    % 子系统内部的 Inport 和 Outport
    add_block('simulink/Sources/In1', [model_name '/MySubsystem/In1']);
    add_block('simulink/Sinks/Out1', [model_name '/MySubsystem/Out1']);
    
    % 内部连接
    add_line(model_name, 'MySubsystem/In1', 'MySubsystem/Gain1/1');
    add_line(model_name, 'MySubsystem/In1', 'MySubsystem/Gain2/1');
    add_line(model_name, 'MySubsystem/Gain1/1', 'MySubsystem/Sum1/1');
    add_line(model_name, 'MySubsystem/Gain2/1', 'MySubsystem/Sum1/2');
    add_line(model_name, 'MySubsystem/Sum1/1', 'MySubsystem/Out1/1');
    
    set_param([model_name '/MySubsystem/Gain1'], 'Gain', '2');
    set_param([model_name '/MySubsystem/Gain2'], 'Gain', '3');
    
    % 外部信号源
    add_block('simulink/Sources/Sine Wave', [model_name '/Input']);
    add_block('simulink/Sinks/Scope', [model_name '/Output']);
    
    add_line(model_name, 'Input/1', 'MySubsystem/1');
    add_line(model_name, 'MySubsystem/1', 'Output/1');
    
    fprintf('子系统创建成功!\n');
    fprintf('  子系统: MySubsystem\n');
    fprintf('  功能: output = 2*x + 3*x = 5*x\n');
    
    save_system(model_name);
    close_system(model_name, 0);
    
catch ME
    fprintf('Simulink 不可用: %s\n', ME.message);
end

%% === 第二部分: 模块封装 (Masking) ===
fprintf('\n--- 第二部分: 模块封装 ---\n\n');

fprintf('封装 (Mask) 的作用:\n');
fprintf('  - 为子系统创建自定义参数对话框\n');
fprintf('  - 隐藏内部实现细节\n');
fprintf('  - 方便参数配置和复用\n\n');

fprintf('封装类型:\n');
fprintf('  1. 参数封装 (Parameter Mask)\n');
fprintf('     - 添加可配置的参数 (数值、字符串、下拉列表)\n');
fprintf('  2. 图标封装 (Icon Mask)\n');
fprintf('     - 自定义模块显示图标\n');
fprintf('  3. 文档封装 (Documentation Mask)\n');
fprintf('     - 添加使用说明和帮助文档\n');

fprintf('\n常用 Mask 命令:\n');
fprintf('  Simulink.Mask.create     - 创建封装\n');
fprintf('  mask.addParameter        - 添加参数\n');
fprintf('  mask.setPortLabels       - 设置端口标签\n');
fprintf('  mask.setIcon             - 设置图标\n');

%% === 第三部分: 条件子系统 ===
fprintf('\n--- 第三部分: 条件子系统 ---\n\n');

fprintf('条件子系统类型:\n');
fprintf('  1. Enable 子系统\n');
fprintf('     - 当 Enable 端口信号 > 0 时执行\n');
fprintf('     - 用于事件触发型逻辑\n\n');
fprintf('  2. Triggered 子系统\n');
fprintf('     - 在触发信号上升/下降沿执行\n');
fprintf('     - 用于采样和触发型系统\n\n');
fprintf('  3. Function-Call 子系统\n');
fprintf('     - 被 Function-Call Generator 调用\n');
fprintf('     - 用于状态机 (Stateflow) 集成\n\n');
fprintf('  4. If/Else 子系统\n');
fprintf('     - 根据条件选择执行哪个子系统\n');
fprintf('     - 类似 if-else 逻辑\n');

% 条件子系统示例图
figure('Name', '条件子系统概念', 'Position', [100 100 900 300]);

subplot(1,3,1);
text(0.5, 0.8, 'Enable 子系统', 'HorizontalAlignment', 'center', ...
    'FontSize', 12, 'FontWeight', 'bold');
text(0.5, 0.5, 'Enable > 0 时执行', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.8 0.9 1]);
text(0.5, 0.2, '适用: 事件触发', 'HorizontalAlignment', 'center', ...
    'FontSize', 9);
axis off;

subplot(1,3,2);
text(0.5, 0.8, 'Triggered 子系统', 'HorizontalAlignment', 'center', ...
    'FontSize', 12, 'FontWeight', 'bold');
text(0.5, 0.5, '信号边沿触发执行', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.9 1 0.8]);
text(0.5, 0.2, '适用: 采样系统', 'HorizontalAlignment', 'center', ...
    'FontSize', 9);
axis off;

subplot(1,3,3);
text(0.5, 0.8, 'If/Else 子系统', 'HorizontalAlignment', 'center', ...
    'FontSize', 12, 'FontWeight', 'bold');
text(0.5, 0.5, '条件分支执行', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [1 0.9 0.8]);
text(0.5, 0.2, '适用: 逻辑分支', 'HorizontalAlignment', 'center', ...
    'FontSize', 9);
axis off;
sgtitle('Simulink 条件子系统', 'FontSize', 14);

%% === 第四部分: 模型引用与库 ===
fprintf('\n--- 第四部分: 模型引用与库 ---\n\n');

fprintf('Model Reference (模型引用):\n');
fprintf('  - 在一个模型中引用另一个模型作为子系统\n');
fprintf('  - 支持独立开发和测试\n');
fprintf('  - 模块: Model Reference block\n');
fprintf('  - 参数: Model name, Parameter arguments\n\n');

fprintf('Simulink Library (模型库):\n');
fprintf('  - 创建可复用的模块库\n');
fprintf('  - 库中的模块可在多个模型中共享\n');
fprintf('  - 修改库会自动更新所有引用\n');
fprintf('  - 创建: slLibraryBrowser → New Library\n\n');

fprintf('模块化设计最佳实践:\n');
fprintf('  1. 每个子系统应有明确的输入/输出接口\n');
fprintf('  2. 使用封装提供清晰的参数配置\n');
fprintf('  3. 添加文档说明子系统的功能和限制\n');
fprintf('  4. 使用 Model Reference 实现跨项目复用\n');
fprintf('  5. 合理分层, 避免单层过于复杂\n');

%% === 总结 ===
fprintf('\n=== 子系统与封装总结 ===\n');
fprintf('1. 子系统实现模块化设计, 简化复杂模型\n');
fprintf('2. 封装提供自定义参数界面, 增强复用性\n');
fprintf('3. 条件子系统支持事件驱动和逻辑分支\n');
fprintf('4. Model Reference 实现跨模型组件共享\n');
