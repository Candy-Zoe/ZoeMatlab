%% 路径规划 (Path Planning)
% 需要 Robotics System Toolbox (基础算法可用 MATLAB 实现)
% 内容: A*算法, RRT, 人工势场法, 路径平滑
clear; clc; close all;

%% === 第一部分: A* 路径搜索 ===
fprintf('=== 路径规划 ===\n\n');
fprintf('--- 第一部分: A* 算法 ---\n');

% 创建简单栅格地图 (0=自由, 1=障碍)
map_size = [20, 20];
grid_map = zeros(map_size);

% 添加障碍物
grid_map(5:8, 5:15) = 1;
grid_map(12:15, 8:18) = 1;
grid_map(3:7, 17:19) = 1;
grid_map(16:18, 2:6) = 1;

start_pos = [2, 2];
goal_pos = [18, 18];

% 简化 A* 实现
open_set = {start_pos};
closed_set = {};
g_score = inf(map_size);
g_score(start_pos(1), start_pos(2)) = 0;
f_score = inf(map_size);
f_score(start_pos(1), start_pos(2)) = heuristic(start_pos, goal_pos);
came_from = cell(map_size);
came_from{start_pos(1), start_pos(2)} = [];

max_iter = 1000;
found = false;

for iter = 1:max_iter
    if isempty(open_set), break; end
    
    % 选择 f 最小的节点
    best_f = inf; best_idx = 1;
    for k = 1:length(open_set)
        pos = open_set{k};
        if f_score(pos(1), pos(2)) < best_f
            best_f = f_score(pos(1), pos(2));
            best_idx = k;
        end
    end
    
    current = open_set{best_idx};
    
    if isequal(current, goal_pos)
        found = true;
        break;
    end
    
    open_set(best_idx) = [];
    closed_set{end+1} = current;
    
    % 8-邻域
    neighbors = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
    for n = 1:size(neighbors, 1)
        nb = current + neighbors(n, :);
        if nb(1) < 1 || nb(1) > map_size(1) || nb(2) < 1 || nb(2) > map_size(2)
            continue;
        end
        if grid_map(nb(1), nb(2)) == 1, continue; end
        
        is_closed = false;
        for k = 1:length(closed_set)
            if isequal(closed_set{k}, nb), is_closed = true; break; end
        end
        if is_closed, continue; end
        
        move_cost = sqrt(sum(neighbors(n,:).^2));
        tent_g = g_score(current(1), current(2)) + move_cost;
        
        if tent_g < g_score(nb(1), nb(2))
            came_from{nb(1), nb(2)} = current;
            g_score(nb(1), nb(2)) = tent_g;
            f_score(nb(1), nb(2)) = tent_g + heuristic(nb, goal_pos);
            
            in_open = false;
            for k = 1:length(open_set)
                if isequal(open_set{k}, nb), in_open = true; break; end
            end
            if ~in_open, open_set{end+1} = nb; end
        end
    end
end

if found
    % 回溯路径
    path = {goal_pos};
    current = goal_pos;
    while ~isempty(came_from{current(1), current(2)})
        current = came_from{current(1), current(2)};
        path{end+1} = current;
    end
    path = fliplr(path);
    fprintf('A* 找到路径! 长度: %d 步\n', length(path));
else
    fprintf('A* 未找到路径\n');
    path = {};
end

% 可视化
figure('Name', 'A* 路径规划', 'Position', [100 100 600 500]);
imagesc(grid_map); colormap([1 1 1; 0.2 0.2 0.2]); hold on;

% 画路径
if found
    path_x = zeros(1, length(path));
    path_y = zeros(1, length(path));
    for i = 1:length(path)
        path_x(i) = path{i}(2);
        path_y(i) = path{i}(1);
    end
    plot(path_x, path_y, 'r-', 'LineWidth', 3);
    plot(path_x, path_y, 'y.', 'MarkerSize', 10);
end

plot(start_pos(2), start_pos(1), 'gs', 'MarkerSize', 15, 'MarkerFaceColor', 'g');
plot(goal_pos(2), goal_pos(1), 'rs', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
title(sprintf('A* 路径规划 (%d 步)', length(path)));
xlabel('X'); ylabel('Y');

%% === 第二部分: RRT 算法 ===
fprintf('\n--- 第二部分: RRT (快速随机树) ---\n\n');

fprintf('RRT 算法步骤:\n');
fprintf('  1. 在空间中随机采样一个点\n');
fprintf('  2. 找到树中最近的节点\n');
fprintf('  3. 向随机点方向扩展一步\n');
fprintf('  4. 检查碰撞, 无碰撞则添加新节点\n');
fprintf('  5. 重复直到到达目标\n\n');

% 简单 RRT 演示
rng(42);
rrt_nodes = [start_pos];  % [x, y; parent_idx]
rrt_parents = [0];
step_size = 1.5;
max_rrt_iter = 500;

for i = 1:max_rrt_iter
    if mod(i, 50) == 0 && rand() < 0.3
        rand_point = goal_pos;  % 偏向目标
    else
        rand_point = [randi([1 map_size(1)]), randi([1 map_size(2)])];
    end
    
    % 找最近节点
    dists = sqrt(sum((rrt_nodes - rand_point).^2, 2));
    [~, near_idx] = min(dists);
    near_node = rrt_nodes(near_idx, :);
    
    % 向随机点方向扩展
    direction = rand_point - near_node;
    d = norm(direction);
    if d < eps, continue; end
    new_node = near_node + direction / d * min(step_size, d);
    new_node = round(new_node);
    
    % 边界检查
    if new_node(1) < 1 || new_node(1) > map_size(1) || new_node(2) < 1 || new_node(2) > map_size(2)
        continue;
    end
    if grid_map(new_node(1), new_node(2)) == 1, continue; end
    
    rrt_nodes = [rrt_nodes; new_node];
    rrt_parents = [rrt_parents; near_idx];
    
    if norm(new_node - goal_pos) < step_size
        rrt_nodes = [rrt_nodes; goal_pos];
        rrt_parents = [rrt_parents; size(rrt_nodes,1)-1];
        fprintf('RRT 在 %d 次迭代后找到路径!\n', i);
        break;
    end
end

figure('Name', 'RRT 路径规划', 'Position', [100 100 600 500]);
imagesc(grid_map); colormap([1 1 1; 0.2 0.2 0.2]); hold on;

% 画树
for i = 2:size(rrt_nodes, 1)
    parent = rrt_nodes(rrt_parents(i), :);
    plot([parent(2) rrt_nodes(i,2)], [parent(1) rrt_nodes(i,1)], 'b-', 'LineWidth', 0.5);
end

plot(start_pos(2), start_pos(1), 'gs', 'MarkerSize', 15, 'MarkerFaceColor', 'g');
plot(goal_pos(2), goal_pos(1), 'rs', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
title(sprintf('RRT 树 (%d 个节点)', size(rrt_nodes, 1)));
xlabel('X'); ylabel('Y');

%% === 第三部分: 路径平滑 ===
fprintf('\n--- 第三部分: 路径平滑 ---\n');

if found
    figure('Name', '路径平滑', 'Position', [100 100 800 350]);
    
    subplot(1,2,1);
    plot(path_x, path_y, 'r-o', 'LineWidth', 2);
    title('原始路径'); grid on; axis equal;
    xlim([0 21]); ylim([0 21]);
    
    % 移动平均平滑
    smoothed = path_x;
    smoothed_y = path_y;
    for iter = 1:20
        for i = 2:length(smoothed)-1
            smoothed(i) = smoothed(i) + 0.3*(smoothed(i-1) + smoothed(i+1) - 2*smoothed(i));
            smoothed_y(i) = smoothed_y(i) + 0.3*(smoothed_y(i-1) + smoothed_y(i+1) - 2*smoothed_y(i));
        end
    end
    
    subplot(1,2,2);
    plot(smoothed, smoothed_y, 'b-s', 'LineWidth', 2);
    title('平滑路径'); grid on; axis equal;
    xlim([0 21]); ylim([0 21]);
    
    fprintf('路径长度 (原始): %.1f\n', sum(sqrt(diff(path_x).^2 + diff(path_y).^2)));
    fprintf('路径长度 (平滑): %.1f\n', sum(sqrt(diff(smoothed).^2 + diff(smoothed_y).^2)));
end

%% === 总结 ===
fprintf('\n=== 路径规划总结 ===\n');
fprintf('1. A*: 基于启发式搜索, 保证最优 (需合适启发函数)\n');
fprintf('2. RRT: 概率采样, 适合高维空间, 不保证最优\n');
fprintf('3. 人工势场法: 简单快速, 但可能陷入局部最小值\n');
fprintf('4. 路径平滑可改善路径质量, 适合实际执行\n');

%% === 辅助函数 ===
function h = heuristic(a, b)
    h = sqrt(sum((a - b).^2));  % 欧氏距离
end
