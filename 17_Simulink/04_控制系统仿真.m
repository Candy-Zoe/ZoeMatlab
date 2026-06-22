%% Simulink 控制系统仿真 (Control System Simulation)
% 本脚本使用 Simulink 仿真典型控制系统
% 需要 Simulink + Control System Toolbox
% 内容: PID控制, 反馈系统, 参数扫描, 状态空间模型
clear; clc; close all;

%% === 第一部分: PID 控制系统仿真 ===
fprintf('=== Simulink 控制系统仿真 ===\n\n');
fprintf('--- 第一部分: PID 控制系统 ---\n\n');

try
    model_name = 'pid_control_demo';
    if bdIsLoaded(model_name), close_system(model_name, 0); end
    new_system(model_name);
    
    % 被控对象: 二阶系统 G(s) = 1/(s^2 + 2s + 1)
    % PID 控制器: C(s) = Kp + Ki/s + Kd*s
    % 单位反馈
    
    % 添加模块
    add_block('simulink/Sources/Step', [model_name '/Reference']);
    set_param([model_name '/Reference'], 'StepTime', '1');
    
    add_block('simulink/Math Operations/Sum', [model_name '/Error']);
    set_param([model_name '/Error'], 'Inputs', '+-');
    
    add_block('simulink/Continuous/PID Controller', [model_name '/PID']);
    set_param([model_name '/PID'], 'P', '10', 'I', '5', 'D', '1');
    
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/Plant']);
    set_param([model_name '/Plant'], 'Numerator', '[1]', 'Denominator', '[1 2 1]');
    
    add_block('simulink/Sinks/Scope', [model_name '/Scope']);
    add_block('simulink/Sinks/To Workspace', [model_name '/Output']);
    set_param([model_name '/Output'], 'VariableName', 'pid_output');
    
    add_block('simulink/Math Operations/Sum', [model_name '/Feedback']);
    set_param([model_name '/Feedback'], 'Inputs', '+-');
    
    % 连接
    add_line(model_name, 'Reference/1', 'Error/1');
    add_line(model_name, 'Error/1', 'PID/1');
    add_line(model_name, 'PID/1', 'Plant/1');
    add_line(model_name, 'Plant/1', 'Scope/1');
    add_line(model_name, 'Plant/1', 'Output/1');
    add_line(model_name, 'Plant/1', 'Feedback/1');
    
    set_param(model_name, 'StopTime', '10');
    set_param(model_name, 'Solver', 'ode45');
    
    % 仿真: 不同 PID 参数
    Kp_values = [5, 10, 20];
    
    figure('Name', 'PID 参数调节', 'Position', [100 100 800 500]);
    
    for i = 1:length(Kp_values)
        set_param([model_name '/PID'], 'P', num2str(Kp_values(i)));
        sim(model_name);
        
        subplot(2,1,1);
        plot(pid_output.time, pid_output.signals.values, ...
            'LineWidth', 1.5, 'DisplayName', sprintf('Kp=%d', Kp_values(i)));
        hold on;
    end
    
    yline(1, 'k--', 'LineWidth', 1);
    xlabel('时间 (s)'); ylabel('输出');
    title('PID 控制: 不同 Kp 值的阶跃响应');
    legend('Location', 'best');
    grid on;
    
    % PID 参数对系统性能的影响
    subplot(2,1,2);
    
    Kp_range = 1:2:30;
    overshoot = zeros(size(Kp_range));
    rise_time = zeros(size(Kp_range));
    
    for i = 1:length(Kp_range)
        set_param([model_name '/PID'], 'P', num2str(Kp_range(i)));
        sim(model_name);
        
        y = pid_output.signals.values;
        t = pid_output.time;
        
        % 超调量
        y_ss = y(end);
        overshoot(i) = (max(y) - y_ss) / y_ss * 100;
        
        % 上升时间 (10% to 90%)
        idx10 = find(y >= 0.1*y_ss, 1);
        idx90 = find(y >= 0.9*y_ss, 1);
        if ~isempty(idx10) && ~isempty(idx90)
            rise_time(i) = t(idx90) - t(idx10);
        end
    end
    
    yyaxis left;
    plot(Kp_range, overshoot, 'b-o', 'LineWidth', 1.5);
    ylabel('超调量 (%)');
    
    yyaxis right;
    plot(Kp_range, rise_time, 'r-s', 'LineWidth', 1.5);
    ylabel('上升时间 (s)');
    
    xlabel('Kp');
    title('Kp 对系统性能的影响');
    legend('超调量', '上升时间', 'Location', 'best');
    grid on;
    
    save_system(model_name);
    close_system(model_name, 0);
    
catch ME
    fprintf('Simulink 不可用: %s\n', ME.message);
    fprintf('\n使用 MATLAB 脚本模拟 PID 控制...\n');
    
    % 纯 MATLAB 版本的 PID 仿真
    % 被控对象: G(s) = 1/(s^2+2s+1)
    
    num = 1;
    den = [1 2 1];
    t = 0:0.01:10;
    
    figure('Name', 'PID 控制 (MATLAB版)', 'Position', [100 100 800 500]);
    
    Kp_vals = [5, 10, 20];
    Ki = 5; Kd = 1;
    
    for i = 1:length(Kp_vals)
        % PID 控制器传递函数
        pid_num = [Kd, Kp_vals(i), Ki];
        pid_den = [1, 0];
        
        % 开环传递函数
        [ol_num, ol_den] = series(pid_num, pid_den, num, den);
        
        % 闭环传递函数
        [cl_num, cl_den] = cloop(ol_num, ol_den);
        
        % 阶跃响应
        [y, t_out] = step(cl_num, cl_den, t);
        
        subplot(2,1,1);
        plot(t_out, y, 'LineWidth', 1.5, ...
            'DisplayName', sprintf('Kp=%d', Kp_vals(i)));
        hold on;
    end
    
    yline(1, 'k--');
    xlabel('时间 (s)'); ylabel('输出');
    title('PID 控制阶跃响应');
    legend('Location', 'best');
    grid on;
end

%% === 第二部分: 状态空间模型仿真 ===
fprintf('\n--- 第二部分: 状态空间模型 ---\n\n');

fprintf('状态空间模型:\n');
fprintf('  dx/dt = A*x + B*u  (状态方程)\n');
fprintf('  y     = C*x + D*u  (输出方程)\n\n');

try
    model_name = 'ss_demo';
    if bdIsLoaded(model_name), close_system(model_name, 0); end
    new_system(model_name);
    
    % 弹簧-质量-阻尼系统
    % m*x'' + c*x' + k*x = f
    % 状态: [x; x'], 输入: f
    m = 1; c = 0.5; k = 4;
    
    A = [0 1; -k/m -c/m];
    B = [0; 1/m];
    C = [1 0];   % 输出位移
    D = 0;
    
    fprintf('系统参数:\n');
    fprintf('  质量 m = %g kg\n', m);
    fprintf('  阻尼 c = %g N·s/m\n', c);
    fprintf('  刚度 k = %g N/m\n', k);
    fprintf('  固有频率: %.2f rad/s\n', sqrt(k/m));
    fprintf('  阻尼比: %.3f\n', c/(2*sqrt(k*m)));
    
    % 添加 State-Space 模块
    add_block('simulink/Continuous/State-Space', [model_name '/System']);
    set_param([model_name '/System'], ...
        'A', mat2str(A), 'B', mat2str(B), ...
        'C', mat2str(C), 'D', mat2str(D));
    
    add_block('simulink/Sources/Step', [model_name '/Force']);
    set_param([model_name '/Force'], 'StepTime', '0.5');
    
    add_block('simulink/Sinks/Scope', [model_name '/Scope']);
    add_block('simulink/Sinks/To Workspace', [model_name '/Out']);
    set_param([model_name '/Out'], 'VariableName', 'ss_output');
    
    add_line(model_name, 'Force/1', 'System/1');
    add_line(model_name, 'System/1', 'Scope/1');
    add_line(model_name, 'System/1', 'Out/1');
    
    set_param(model_name, 'StopTime', '15');
    
    sim(model_name);
    
    figure('Name', '状态空间仿真', 'Position', [100 100 800 400]);
    plot(ss_output.time, ss_output.signals.values, 'b-', 'LineWidth', 2);
    xlabel('时间 (s)');
    ylabel('位移 (m)');
    title('弹簧-质量-阻尼系统阶跃响应');
    grid on;
    
    save_system(model_name);
    close_system(model_name, 0);
    
catch ME
    fprintf('Simulink 不可用: %s\n', ME.message);
    
    % MATLAB 版本
    m = 1; c = 0.5; k = 4;
    A = [0 1; -k/m -c/m];
    B = [0; 1/m]; C = [1 0]; D = 0;
    
    sys = ss(A, B, C, D);
    figure;
    step(sys, 15);
    title('弹簧-质量-阻尼系统阶跃响应');
end

%% === 第三部分: 参数扫描与优化 ===
fprintf('\n--- 第三部分: 参数扫描 ---\n\n');

fprintf('Simulink 参数扫描方法:\n');
fprintf('  1. 使用 for 循环改变模型参数, 多次仿真\n');
fprintf('  2. Simulation Data Inspector 比较结果\n');
fprintf('  3. Simulink Design Optimization 自动优化\n');
fprintf('  4. Signal Editor 管理多组输入信号\n\n');

% 参数扫描示例 (使用 ode45 纯 MATLAB 方式)
fprintf('参数扫描示例: 阻尼比对系统响应的影响\n');

zeta_values = [0, 0.1, 0.3, 0.5, 0.7, 1.0, 1.5];
wn = 10;   % 固有频率

figure('Name', '参数扫描: 阻尼比', 'Position', [100 100 800 500]);
t_span = [0 3];

for i = 1:length(zeta_values)
    zeta = zeta_values(i);
    
    A = [0 1; -wn^2 -2*zeta*wn];
    B = [0; wn^2];
    C = [1 0]; D = 0;
    
    sys = ss(A, B, C, D);
    [y, t] = step(sys, t_span);
    
    plot(t, y, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('\\zeta = %.1f', zeta));
    hold on;
end

yline(1, 'k--', 'LineWidth', 0.5);
xlabel('时间 (s)');
ylabel('输出');
title('二阶系统: 阻尼比 \\zeta 对阶跃响应的影响');
legend('Location', 'east');
grid on;

%% === 第四部分: Stateflow 状态机 ===
fprintf('\n--- 第四部分: Stateflow 状态机简介 ---\n\n');

fprintf('Stateflow 是 Simulink 中的状态机/流程图建模工具:\n\n');

fprintf('Stateflow 元素:\n');
fprintf('  - State (状态): 系统的工作模式\n');
fprintf('  - Transition (转移): 状态间的切换条件\n');
fprintf('  - Junction (汇合点): 多路分支的汇合\n');
fprintf('  - Chart (图): 顶层状态机容器\n\n');

fprintf('应用场景:\n');
fprintf('  - 自动变速器换挡逻辑\n');
fprintf('  - 电机启动/停止/故障状态管理\n');
fprintf('  - 飞行模式切换 (起飞/巡航/着陆)\n');
fprintf('  - 协议状态机 (TCP连接管理)\n\n');

% 状态机概念图
figure('Name', '状态机概念', 'Position', [100 100 700 300]);
axes('Position', [0.05 0.05 0.9 0.9]);
hold on; axis off;

% 绘制状态机
rectangle('Position', [0.05 0.5 0.2 0.3], 'Curvature', [0.3 0.3], ...
    'FaceColor', [0.8 0.9 1], 'EdgeColor', 'k', 'LineWidth', 2);
text(0.15, 0.65, '空闲', 'HorizontalAlignment', 'center', 'FontSize', 11);

rectangle('Position', [0.35 0.5 0.2 0.3], 'Curvature', [0.3 0.3], ...
    'FaceColor', [0.8 1 0.8], 'EdgeColor', 'k', 'LineWidth', 2);
text(0.45, 0.65, '运行', 'HorizontalAlignment', 'center', 'FontSize', 11);

rectangle('Position', [0.65 0.5 0.2 0.3], 'Curvature', [0.3 0.3], ...
    'FaceColor', [1 0.85 0.8], 'EdgeColor', 'k', 'LineWidth', 2);
text(0.75, 0.65, '故障', 'HorizontalAlignment', 'center', 'FontSize', 11);

% 箭头 (用 annotation)
annotation('textarrow', [0.25 0.35], [0.7 0.7], 'String', '启动', 'FontSize', 9);
annotation('textarrow', [0.55 0.65], [0.7 0.7], 'String', '检测异常', 'FontSize', 9);
annotation('textarrow', [0.75 0.15], [0.5 0.5], 'String', '复位', 'FontSize', 9);

title('简单状态机示例', 'FontSize', 13);

%% === 总结 ===
fprintf('\n=== 控制系统仿真总结 ===\n');
fprintf('1. PID 控制器是最常用的反馈控制结构\n');
fprintf('2. 状态空间模型适用于多输入多输出系统\n');
fprintf('3. 参数扫描帮助理解参数对系统性能的影响\n');
fprintf('4. Stateflow 状态机用于管理离散事件逻辑\n');
fprintf('5. Simulink 提供从建模到代码生成的完整工作流\n');
