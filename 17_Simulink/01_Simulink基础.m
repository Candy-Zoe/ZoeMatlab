%% Simulink 基础入门 (Simulink Basics)
% 本脚本介绍 Simulink 的基本概念和程序化建模方法
% 需要 Simulink
% 内容: Simulink 概述, 程序化建模, 仿真参数, 模型操作
clear; clc; close all;

%% === 第一部分: Simulink 概述 ===
fprintf('=== Simulink 基础入门 ===\n\n');
fprintf('--- 第一部分: Simulink 概述 ---\n\n');

fprintf('Simulink 是 MATLAB 的可视化仿真环境:\n');
fprintf('  - 基于框图的动态系统建模与仿真\n');
fprintf('  - 支持连续、离散和混合系统\n');
fprintf('  - 丰富的预建模块库\n');
fprintf('  - 支持代码生成和硬件部署\n\n');

fprintf('常用模块库:\n');
fprintf('  Sources:    Sine Wave, Step, Constant, From Workspace\n');
fprintf('  Sinks:      Scope, To Workspace, Display\n');
fprintf('  Math:       Gain, Sum, Product, Math Function\n');
fprintf('  Continuous: Integrator, Transfer Fcn, State-Space\n');
fprintf('  Discrete:   Unit Delay, Discrete Transfer Fcn, ZOH\n');
fprintf('  Signals:    Mux, Demux, Switch, Selector\n');

%% === 第二部分: 程序化创建 Simulink 模型 ===
fprintf('\n--- 第二部分: 程序化创建模型 ---\n');

try
    % 创建新模型
    model_name = 'my_first_model';
    
    % 检查是否已存在
    if bdIsLoaded(model_name)
        close_system(model_name, 0);
    end
    
    % 检查 Simulink 是否可用
    new_system(model_name);
    open_system(model_name);
    
    fprintf('成功创建模型: %s\n', model_name);
    
    % 添加模块
    % 信号源: 正弦波
    add_block('simulink/Sources/Sine Wave', [model_name '/SineWave']);
    set_param([model_name '/SineWave'], 'Amplitude', '2', 'Frequency', '2*pi*1');
    
    % 信号源: 阶跃信号
    add_block('simulink/Sources/Step', [model_name '/Step']);
    set_param([model_name '/Step'], 'StepTime', '0.5', 'Before', '0', 'After', '1');
    
    % 求和器
    add_block('simulink/Math Operations/Sum', [model_name '/Sum']);
    set_param([model_name '/Sum'], 'Inputs', '++');
    
    % 传递函数: 1/(s+1)
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/Plant']);
    set_param([model_name '/Plant'], 'Numerator', '[1]', 'Denominator', '[1 1]');
    
    % 增益
    add_block('simulink/Math Operations/Gain', [model_name '/Gain']);
    set_param([model_name '/Gain'], 'Gain', '5');
    
    % 示波器
    add_block('simulink/Sinks/Scope', [model_name '/Scope']);
    
    % To Workspace (保存数据到工作空间)
    add_block('simulink/Sinks/To Workspace', [model_name '/ToWS']);
    set_param([model_name '/ToWS'], 'VariableName', 'sim_output');
    
    fprintf('已添加模块:\n');
    blocks = find_system(model_name, 'SearchDepth', 1, 'Type', 'Block');
    for i = 1:length(blocks)
        block_name = get_param(blocks{i}, 'Name');
        block_type = get_param(blocks{i}, 'BlockType');
        fprintf('  %s (%s)\n', block_name, block_type);
    end
    
    % 连接模块
    add_line(model_name, 'SineWave/1', 'Sum/1');
    add_line(model_name, 'Step/1', 'Sum/2');
    add_line(model_name, 'Sum/1', 'Gain/1');
    add_line(model_name, 'Gain/1', 'Plant/1');
    add_line(model_name, 'Plant/1', 'Scope/1');
    add_line(model_name, 'Plant/1', 'ToWS/1');
    
    fprintf('\n模块连接完成!\n');
    
    % 设置仿真参数
    set_param(model_name, 'StopTime', '10');
    set_param(model_name, 'Solver', 'ode45');
    set_param(model_name, 'MaxStep', '0.01');
    
    fprintf('仿真参数:\n');
    fprintf('  停止时间: %s s\n', get_param(model_name, 'StopTime'));
    fprintf('  求解器:   %s\n', get_param(model_name, 'Solver'));
    fprintf('  最大步长: %s\n', get_param(model_name, 'MaxStep'));
    
    % 运行仿真
    fprintf('\n正在运行仿真...\n');
    sim(model_name);
    fprintf('仿真完成!\n');
    
    % 可视化结果
    if exist('sim_output', 'var')
        figure('Name', 'Simulink 仿真结果', 'Position', [100 100 800 400]);
        plot(sim_output.time, sim_output.signals.values, 'b-', 'LineWidth', 2);
        xlabel('时间 (s)');
        ylabel('输出');
        title('Simulink 仿真: 传递函数 1/(s+1) 的响应');
        grid on;
    end
    
    % 保存并关闭模型
    save_system(model_name);
    close_system(model_name, 0);
    fprintf('模型已保存并关闭\n');
    
catch ME
    fprintf('Simulink 不可用: %s\n', ME.message);
    fprintf('\n以下是程序化建模的关键命令:\n');
    fprintf('  new_system(''modelName'')     - 创建新模型\n');
    fprintf('  add_block(''lib/block'', path) - 添加模块\n');
    fprintf('  set_param(path, param, val)  - 设置参数\n');
    fprintf('  add_line(model, src, dst)    - 连接模块\n');
    fprintf('  sim(''modelName'')            - 运行仿真\n');
    fprintf('  save_system(''modelName'')    - 保存模型\n');
end

%% === 第三部分: Simulink 常用模块参数 ===
fprintf('\n--- 第三部分: 常用模块参数设置 ---\n');

fprintf('\n正弦波 (Sine Wave):\n');
fprintf('  Amplitude  = 幅值 (默认 1)\n');
fprintf('  Frequency  = 频率 (rad/s, 默认 1)\n');
fprintf('  Phase      = 相位 (rad, 默认 0)\n');
fprintf('  SampleTime = 采样时间 (0=连续)\n');

fprintf('\n阶跃信号 (Step):\n');
fprintf('  StepTime = 阶跃时间\n');
fprintf('  Before   = 初始值\n');
fprintf('  After    = 最终值\n');

fprintf('\n传递函数 (Transfer Fcn):\n');
fprintf('  Numerator   = 分子多项式系数 [1 2] 表示 s+2\n');
fprintf('  Denominator = 分母多项式系数 [1 3 2] 表示 s^2+3s+2\n');

fprintf('\n积分器 (Integrator):\n');
fprintf('  InitialCondition = 初始条件\n');
fprintf('  ExternalReset    = 外部复位\n');
fprintf('  UpperSaturationLimit = 上限\n');
fprintf('  LowerSaturationLimit = 下限\n');

fprintf('\n示波器 (Scope):\n');
fprintf('  TimeSpan = 时间范围\n');
fprintf('  YMin/YMax = Y轴范围\n');

%% === 第四部分: 仿真求解器选择 ===
fprintf('\n--- 第四部分: 求解器选择指南 ---\n');

solvers = {
    'ode45',   'Dormand-Prince (RK45)',   '非刚性系统, 首选';
    'ode23',   'Bogacki-Shampine (RK23)', '非刚性, 中等精度';
    'ode113',  'Adams-Bashforth',         '非刚性, 高精度';
    'ode15s',  'Gear 方法 (隐式)',        '刚性系统';
    'ode23s',  '改进 Rosenbrock',         '刚性系统, 低精度';
    'ode23t',  '梯形法则',               '适度刚性';
    'discrete', '离散求解器',             '纯离散系统';
};

fprintf('求解器对比:\n');
fprintf('%-10s | %-25s | %s\n', '求解器', '方法', '适用场景');
fprintf('-----------|---------------------------|------------------\n');
for i = 1:size(solvers, 1)
    fprintf('%-10s | %-25s | %s\n', solvers{i,:});
end

% 演示不同求解器的效果
fprintf('\n求解器选择建议:\n');
fprintf('  1. 默认使用 ode45 (适用于大多数问题)\n');
fprintf('  2. 如果仿真很慢或不稳定, 尝试 ode15s (刚性求解器)\n');
fprintf('  3. 纯离散系统使用 discrete\n');
fprintf('  4. 需要高精度时使用 ode113\n');

%% === 总结 ===
fprintf('\n=== Simulink 基础总结 ===\n');
fprintf('1. Simulink 提供可视化建模环境, 支持拖拽和程序化操作\n');
fprintf('2. 模型文件扩展名为 .slx (新版) 或 .mdl (旧版)\n');
fprintf('3. 可通过 MATLAB 脚本程序化创建和操作模型\n');
fprintf('4. 选择合适的求解器对仿真精度和速度至关重要\n');
fprintf('5. To Workspace 模块可将仿真数据传回 MATLAB 工作空间\n');
