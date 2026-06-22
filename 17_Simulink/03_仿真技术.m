%% Simulink 仿真技术 (Simulation Techniques)
% 本脚本演示 Simulink 仿真的各种技术和高级功能
% 需要 Simulink
% 内容: 多域仿真, S-Function, 模型加速, 代码生成
clear; clc; close all;

%% === 第一部分: 多域仿真 ===
fprintf('=== Simulink 仿真技术 ===\n\n');
fprintf('--- 第一部分: 多域仿真 ---\n\n');

fprintf('Simulink 支持的仿真域:\n');
fprintf('  1. 连续时间系统 (Continuous)\n');
fprintf('     - 微分方程描述的系统\n');
fprintf('     - 使用 Integrator 模块\n');
fprintf('     - 求解器: ode45, ode15s 等\n\n');
fprintf('  2. 离散时间系统 (Discrete)\n');
fprintf('     - 差分方程描述的系统\n');
fprintf('     - 使用 Unit Delay, Discrete Transfer Fcn\n');
fprintf('     - 固定采样时间\n\n');
fprintf('  3. 混合系统 (Hybrid)\n');
fprintf('     - 同时包含连续和离散部分\n');
fprintf('     - 通过 Rate Transition 模块连接\n\n');
fprintf('  4. 事件驱动系统 (Event-Driven)\n');
fprintf('     - Stateflow 状态机\n');
fprintf('     - Triggered 子系统\n');

%% === 第二部分: MATLAB Function 模块 ===
fprintf('\n--- 第二部分: MATLAB Function 模块 ---\n\n');

fprintf('MATLAB Function 模块允许在 Simulink 中使用 MATLAB 代码:\n\n');
fprintf('基本语法:\n');
fprintf('  function y = fcn(u)\n');
fprintf('      % 输入 u, 输出 y\n');
fprintf('      y = u^2 + sin(u);\n');
fprintf('  end\n\n');

fprintf('特点:\n');
fprintf('  - 支持大部分 MATLAB 函数\n');
fprintf('  - 自动推断数据类型和维度\n');
fprintf('  - 可定义持久变量 (persistent)\n');
fprintf('  - 支持结构体和数组输入/输出\n\n');

fprintf('限制:\n');
fprintf('  - 不支持 figure, plot 等图形函数\n');
fprintf('  - 部分函数需要 coder.extrinsic 声明\n');
fprintf('  - 动态数组大小可能受限\n\n');

fprintf('示例代码:\n');
fprintf('  function [mag, phase] = fcn(real_part, imag_part)\n');
fprintf('      mag = sqrt(real_part^2 + imag_part^2);\n');
fprintf('      phase = atan2(imag_part, real_part);\n');
fprintf('  end\n');

%% === 第三部分: S-Function ===
fprintf('\n--- 第三部分: S-Function ---\n\n');

fprintf('S-Function (System Function) 是 Simulink 的核心扩展机制:\n\n');

fprintf('S-Function 类型:\n');
fprintf('  1. Level-1 MATLAB S-Function\n');
fprintf('     - 简单的回调接口\n');
fprintf('     - 单输入单输出\n\n');
fprintf('  2. Level-2 MATLAB S-Function\n');
fprintf('     - 现代化面向对象接口\n');
fprintf('     - 支持多端口, 复杂数据类型\n\n');
fprintf('  3. C/C++ S-Function\n');
fprintf('     - 高性能, 可生成代码\n');
fprintf('     - 用于硬件部署\n\n');

fprintf('S-Function 回调方法:\n');
fprintf('  InitializeConditions - 初始化状态\n');
fprintf('  Start               - 仿真开始时调用\n');
fprintf('  Outputs             - 计算输出\n');
fprintf('  Update              - 更新离散状态\n');
fprintf('  Derivatives         - 计算连续状态导数\n');
fprintf('  Terminate           - 仿真结束时调用\n');

% S-Function 结构示例
fprintf('\nLevel-2 MATLAB S-Function 模板:\n');
fprintf('  function my_sfcn(block)\n');
fprintf('      setup(block);\n');
fprintf('  function setup(block)\n');
fprintf('      block.NumInputPorts  = 1;\n');
fprintf('      block.NumOutputPorts = 1;\n');
fprintf('      block.SetPreCompInpPortInfoToDynamic;\n');
fprintf('      block.RegBlockMethod(''Outputs'', @Outputs);\n');
fprintf('  function Outputs(block)\n');
fprintf('      block.OutputPort(1).Data = block.InputPort(1).Data * 2;\n');

%% === 第四部分: 模型加速与代码生成 ===
fprintf('\n--- 第四部分: 模型加速与代码生成 ---\n\n');

fprintf('仿真加速技巧:\n');
fprintf('  1. 选择合适的求解器和步长\n');
fprintf('  2. 使用 Accelerator 模式 (Simulation → Accelerator)\n');
fprintf('  3. 减少 Scope 和 Display 的使用\n');
fprintf('  4. 避免使用 MATLAB Function 中的 extrinsic 函数\n');
fprintf('  5. 使用 Simulink Fast Restart 跳过编译\n\n');

fprintf('代码生成 (Simulink Coder):\n');
fprintf('  - 将 Simulink 模型自动生成 C/C++ 代码\n');
fprintf('  - 用于嵌入式系统和实时仿真\n');
fprintf('  - 步骤:\n');
fprintf('    1. 确保模型使用代码兼容的模块\n');
fprintf('    2. 配置: Simulation → Configuration Parameters\n');
fprintf('       - Solver: 固定步长 (如 ode4/ode3)\n');
fprintf('       - Code Generation → System target file: grt.tlc\n');
fprintf('    3. Ctrl+B 或 Build 生成代码\n');
fprintf('    4. 生成的 .c/.h 文件可部署到目标硬件\n\n');

fprintf('Hardware Support Packages:\n');
fprintf('  - Arduino: 直接部署到 Arduino 板\n');
fprintf('  - Raspberry Pi: Linux 目标\n');
fprintf('  - NVIDIA Jetson: GPU 加速\n');
fprintf('  - 自定义: 通过 Custom Target 支持\n');

% 仿真模式对比
figure('Name', '仿真模式对比', 'Position', [100 100 700 400]);

modes = {'Normal', 'Accelerator', 'Rapid Accelerator', 'External'};
speeds = [1, 5, 50, 100];
colors = [0.3 0.6 0.9; 0.3 0.8 0.5; 0.9 0.6 0.2; 0.8 0.3 0.3];

b = bar(speeds, 'horizontal');
b.FaceColor = 'flat';
for i = 1:length(modes)
    b.CData(i,:) = colors(i,:);
end
set(gca, 'YTick', 1:4, 'YTickLabel', modes);
xlabel('相对仿真速度');
title('Simulink 仿真模式速度对比');
grid on;

fprintf('\n仿真模式说明:\n');
fprintf('  Normal:          解释执行, 调试方便\n');
fprintf('  Accelerator:     编译加速, 推荐日常使用\n');
fprintf('  Rapid Accelerator: 最大加速, 用于参数扫描\n');
fprintf('  External:        连接外部硬件, 用于 HIL 测试\n');

%% === 总结 ===
fprintf('\n=== 仿真技术总结 ===\n');
fprintf('1. MATLAB Function 模块在 Simulink 中嵌入 MATLAB 代码\n');
fprintf('2. S-Function 提供最大的自定义灵活性\n');
fprintf('3. Accelerator 模式可显著加速仿真\n');
fprintf('4. Simulink Coder 实现从模型到嵌入式代码的自动转换\n');
