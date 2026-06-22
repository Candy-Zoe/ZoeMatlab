%% ========================================================================
%  自动驾驶决策与规划 - Autonomous Driving Planning & Decision
%  本脚本演示路径规划和决策算法
%  内容包括：A*路径规划、行为决策、ACC自适应巡航、V2X概念
%  ========================================================================
clear; clc; close all;

%% === 1. 路径规划 - 栅格地图A*算法 ===
fprintf('=== 1. 路径规划 ===\n');

% 创建栅格地图 (0=自由, 1=障碍)
map_size = 50;
map = zeros(map_size);

% 障碍物
map(10:15, 5:25) = 1;
map(20:25, 15:40) = 1;
map(30:45, 5:15) = 1;
map(35:40, 25:45) = 1;
map(5:8, 35:48) = 1;

start_node = [3, 3];
goal_node = [45, 45];

fprintf('地图大小: %dx%d\n', map_size, map_size);
fprintf('起点: (%d, %d)\n', start_node(1), start_node(2));
fprintf('终点: (%d, %d)\n', goal_node(1), goal_node(2));
fprintf('障碍物占比: %.1f%%\n', sum(map(:))/map_size^2*100);

% A*算法
[path_a, cost_a, explored] = astar_grid(map, start_node, goal_node);
fprintf('A*路径长度: %.1f (步数: %d)\n', cost_a, length(path_a));

% 路径平滑 (简单移动平均)
path_smooth = path_a;
for iter = 1:5
    for i = 2:length(path_smooth)-1
        new_pt = (path_smooth(i-1,:) + path_smooth(i,:) + path_smooth(i+1,:)) / 3;
        r = round(new_pt(1)); c = round(new_pt(2));
        if r>=1 && r<=map_size && c>=1 && c<=map_size && map(r,c)==0
            path_smooth(i,:) = new_pt;
        end
    end
end

figure('Name', '路径规划', 'Position', [100 100 1000 500]);
subplot(1,2,1);
imagesc(map); colormap([1 1 1; 0.3 0.3 0.3]);
hold on;
plot(explored(:,2), explored(:,1), 'c.', 'MarkerSize', 2);
plot(path_a(:,2), path_a(:,1), 'r-', 'LineWidth', 2);
plot(path_smooth(:,2), path_smooth(:,1), 'g-', 'LineWidth', 2);
scatter(start_node(2), start_node(1), 150, 'g', 's', 'filled');
scatter(goal_node(2), goal_node(1), 150, 'r', 'p', 'filled');
title('A*路径规划');
axis equal; axis ij;

%% === 2. 行为决策 - 状态机 ===
fprintf('\n=== 2. 行为决策 (有限状态机) ===\n');

% 定义状态
states = {'巡航','跟车','变道','减速','停车'};
% 状态转移条件
transitions = {
    '巡航->跟车: 前方有车且距离<50m';
    '跟车->巡航: 前方无车或距离>80m';
    '跟车->变道: 跟车时间>5s且相邻车道空闲';
    '变道->巡航: 变道完成';
    '任意->减速: 前方距离<20m';
    '减速->停车: 距离<5m';
    '停车->巡航: 前方清空';
};

fprintf('行为状态机:\n');
for i = 1:length(transitions)
    fprintf('  %s\n', transitions{i});
end

% 模拟ACC自适应巡航
subplot(1,2,2);

dt_acc = 0.1;
T_acc = 60;
N_acc = round(T_acc/dt_acc);

% 自车
x_ego = zeros(N_acc, 1);
v_ego = zeros(N_acc, 1);
v_ego(1) = 20;  % 20 m/s = 72 km/h

% 前车
x_lead = zeros(N_acc, 1);
v_lead = zeros(N_acc, 1);
x_lead(1) = 40;  % 前方40m
v_lead(1) = 18;

% ACC参数
desired_gap = 30;  % 期望间距 (m)
Kp = 0.5;
Kd = 0.8;
a_max = 3;
a_min = -5;

state_hist = zeros(N_acc, 1);  % 1=巡航, 2=跟车, 3=减速

for k = 1:N_acc-1
    % 前车运动 (周期性减速)
    v_lead(k) = 18 + 4*sin(2*pi*k*dt_acc/30);
    x_lead(k+1) = x_lead(k) + v_lead(k)*dt_acc;
    
    % 间距和相对速度
    gap = x_lead(k) - x_ego(k);
    dv = v_lead(k) - v_ego(k);
    
    % 状态判断
    if gap < 15
        state_hist(k) = 3;  % 减速
    elseif gap < desired_gap + 20
        state_hist(k) = 2;  % 跟车
    else
        state_hist(k) = 1;  % 巡航
    end
    
    % ACC控制
    if state_hist(k) == 1  % 巡航: 保持速度
        a_cmd = Kp * (20 - v_ego(k));
    elseif state_hist(k) == 2  % 跟车: 保持间距
        a_cmd = Kp*(gap - desired_gap) + Kd*dv;
    else  % 减速
        a_cmd = Kp*(gap - 10) + Kd*dv;
    end
    
    a_cmd = max(min(a_cmd, a_max), a_min);
    v_ego(k+1) = max(0, v_ego(k) + a_cmd*dt_acc);
    x_ego(k+1) = x_ego(k) + v_ego(k+1)*dt_acc;
end

t_acc = (0:N_acc-1)'*dt_acc;
plot(t_acc, v_ego*3.6, 'b-', 'LineWidth', 1.5); hold on;
plot(t_acc, v_lead*3.6, 'r--', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('速度 (km/h)');
title('ACC自适应巡航');
legend('自车','前车');
grid on;

%% === 3. 安全距离模型 ===
fprintf('\n=== 3. 安全距离模型 ===\n');

% 制动距离计算
v_range = linspace(0, 40, 100);  % 0-40 m/s (0-144 km/h)
reaction_time = 1.0;  % 反应时间 (s)
mu = 0.8;  % 路面摩擦系数
g = 9.81;

d_reaction = v_range * reaction_time;
d_braking = v_range.^2 / (2 * mu * g);
d_total = d_reaction + d_braking;

figure('Name', '安全距离分析', 'Position', [100 100 800 500]);
subplot(1,2,1);
plot(v_range*3.6, d_reaction, 'b-', 'LineWidth', 2); hold on;
plot(v_range*3.6, d_braking, 'r-', 'LineWidth', 2);
plot(v_range*3.6, d_total, 'k-', 'LineWidth', 2);
xlabel('速度 (km/h)'); ylabel('距离 (m)');
title('制动距离分析');
legend('反应距离','制动距离','总停车距离');
grid on;

% 不同路面条件
mu_values = [0.8, 0.5, 0.3];
mu_labels = {'干燥沥青','湿滑','冰雪'};
subplot(1,2,2);
for i = 1:length(mu_values)
    d_total_i = v_range*reaction_time + v_range.^2/(2*mu_values(i)*g);
    plot(v_range*3.6, d_total_i, 'LineWidth', 2); hold on;
end
xlabel('速度 (km/h)'); ylabel('停车距离 (m)');
title('不同路面停车距离');
legend(mu_labels);
grid on;

fprintf('100 km/h 制动距离:\n');
v100 = 100/3.6;
for i = 1:length(mu_values)
    d100 = v100*reaction_time + v100^2/(2*mu_values(i)*g);
    fprintf('  %s: %.1f m\n', mu_labels{i}, d100);
end

%% === 总结 ===
fprintf('\n=== 自动驾驶决策总结 ===\n');
fprintf('1. 路径规划: A*算法、路径平滑\n');
fprintf('2. 行为决策: 有限状态机、ACC自适应巡航\n');
fprintf('3. 安全模型: 制动距离、安全间距\n');
fprintf('\n推荐工具箱: Automated Driving Toolbox, Navigation Toolbox\n');
fprintf('         ROS集成: ROS Toolbox\n');

%% === 辅助函数 ===
function [path, cost, explored] = astar_grid(map, start, goal)
    [rows, cols] = size(map);
    
    % 开放和关闭列表
    open_set = containers.Map('KeyType', 'int64', 'ValueType', 'any');
    closed_set = false(rows, cols);
    
    g_score = inf(rows, cols);
    f_score = inf(rows, cols);
    parent = zeros(rows, cols, 2);
    
    g_score(start(1), start(2)) = 0;
    f_score(start(1), start(2)) = heuristic(start, goal);
    
    key = start(1)*cols + start(2);
    open_set(key) = start;
    
    explored = [];
    directions = [-1,0; 1,0; 0,-1; 0,1; -1,-1; -1,1; 1,-1; 1,1];
    
    while open_set.Count > 0
        % 找最小f
        min_f = inf;
        best_key = -1;
        for k = keys(open_set)
            pos = open_set(k{1});
            if f_score(pos(1), pos(2)) < min_f
                min_f = f_score(pos(1), pos(2));
                best_key = k{1};
            end
        end
        
        current = open_set(best_key);
        open_set.remove(best_key);
        closed_set(current(1), current(2)) = true;
        explored = [explored; current];
        
        if isequal(current, goal)
            % 回溯路径
            path = goal;
            pos = goal;
            while ~isequal(pos, start)
                pos = parent(pos(1), pos(2), :);
                pos = squeeze(pos);
                path = [pos; path];
            end
            cost = g_score(goal(1), goal(2));
            return;
        end
        
        for d = 1:size(directions, 1)
            neighbor = current + directions(d,:);
            nr = neighbor(1); nc = neighbor(2);
            
            if nr<1 || nr>rows || nc<1 || nc>cols
                continue;
            end
            if closed_set(nr, nc) || map(nr, nc) == 1
                continue;
            end
            
            move_cost = sqrt(sum(directions(d,:).^2));
            tentative_g = g_score(current(1), current(2)) + move_cost;
            
            if tentative_g < g_score(nr, nc)
                parent(nr, nc, :) = current;
                g_score(nr, nc) = tentative_g;
                f_score(nr, nc) = tentative_g + heuristic(neighbor, goal);
                
                nkey = nr*cols + nc;
                open_set(nkey) = neighbor;
            end
        end
    end
    
    path = [];
    cost = inf;
end

function h = heuristic(a, b)
    h = sqrt(sum((a-b).^2));
end
