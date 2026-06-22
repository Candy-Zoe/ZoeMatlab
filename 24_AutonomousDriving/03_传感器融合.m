%% ========================================================================
%  传感器融合与定位 - Sensor Fusion & Localization
%  本脚本演示多传感器融合和车辆定位技术
%  内容包括：卡尔曼滤波、扩展卡尔曼滤波、粒子滤波、IMU/GPS融合
%  ========================================================================
clear; clc; close all;

%% === 1. 卡尔曼滤波基础 ===
fprintf('=== 1. 卡尔曼滤波基础 ===\n');

% 一维位置跟踪: 匀加速模型
dt = 0.1;
N = 200;
t = (0:N-1)'*dt;

% 真实轨迹
x_true = 0.01*t.^2 + 2*sin(0.5*t);
v_true = 0.02*t + cos(0.5*t);

% GPS测量 (有噪声)
rng(42);
R_gps = 4;  % GPS测量噪声方差
z_gps = x_true + sqrt(R_gps)*randn(N, 1);

% 卡尔曼滤波器
% 状态: [位置; 速度]
% F = [1 dt; 0 1], H = [1 0]
F = [1 dt; 0 1];
H = [1 0];
Q = [0.1 0; 0 0.5];  % 过程噪声
R = R_gps;            % 测量噪声

% 初始化
x_est = [z_gps(1); 0];
P = eye(2) * 10;

x_history = zeros(N, 2);
P_history = zeros(N, 2);
K_history = zeros(N, 2);

for k = 1:N
    % 预测
    x_pred = F * x_est;
    P_pred = F * P * F' + Q;
    
    % 更新
    S = H * P_pred * H' + R;
    K = P_pred * H' / S;
    innovation = z_gps(k) - H * x_pred;
    x_est = x_pred + K * innovation;
    P = (eye(2) - K * H) * P_pred;
    
    x_history(k,:) = x_est';
    P_history(k,:) = diag(P);
    K_history(k,:) = K';
end

% 误差统计
rmse_raw = sqrt(mean((z_gps - x_true).^2));
rmse_kf = sqrt(mean((x_history(:,1) - x_true).^2));
fprintf('GPS原始RMSE: %.3f m\n', rmse_raw);
fprintf('卡尔曼滤波RMSE: %.3f m\n', rmse_kf);
fprintf('改善: %.1f%%\n', (1-rmse_kf/rmse_raw)*100);

figure('Name', '卡尔曼滤波', 'Position', [100 100 1000 600]);
subplot(2,2,1);
plot(t, x_true, 'k-', 'LineWidth', 2); hold on;
plot(t, z_gps, 'b.', 'MarkerSize', 3);
plot(t, x_history(:,1), 'r-', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('位置 (m)');
title('位置估计');
legend('真实','GPS测量','卡尔曼滤波');

subplot(2,2,2);
plot(t, v_true, 'k-', 'LineWidth', 2); hold on;
plot(t, x_history(:,2), 'r-', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('速度 (m/s)');
title('速度估计 (GPS不直接测量速度)');
legend('真实','卡尔曼估计');

subplot(2,2,3);
plot(t, sqrt(P_history(:,1)), 'b', 'LineWidth', 1.5); hold on;
plot(t, sqrt(P_history(:,2)), 'r', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('标准差');
title('估计不确定性 (1-sigma)');
legend('位置','速度');

subplot(2,2,4);
plot(t, K_history(:,1), 'b', t, K_history(:,2), 'r', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('卡尔曼增益');
title('卡尔曼增益收敛');
legend('K1(位置)','K2(速度)');

%% === 2. IMU/GPS融合 (扩展卡尔曼滤波) ===
fprintf('\n=== 2. IMU/GPS融合 ===\n');

% 2D车辆跟踪
N2 = 500;
dt2 = 0.05;
t2 = (0:N2-1)'*dt2;

% 真实轨迹 (圆形 + 直线)
x2_true = zeros(N2, 4);  % [x, y, vx, vy]
for k = 1:N2
    if t2(k) < 5
        % 直线加速
        x2_true(k,:) = [0.5*t2(k)^2, 2*t2(k), t2(k), 2];
    elseif t2(k) < 15
        % 圆弧
        tau = t2(k) - 5;
        r_circle = 20;
        x2_true(k,:) = [12.5 + r_circle*sin(tau/r_circle), ...
                        10 + r_circle*(1-cos(tau/r_circle)), ...
                        cos(tau/r_circle), sin(tau/r_circle)];
    else
        % 直线
        tau = t2(k) - 15;
        x2_true(k,:) = [12.5 + 20*sin(1) + tau*cos(1), ...
                        10 + 20*(1-cos(1)) + tau*sin(1), ...
                        cos(1), sin(1)];
    end
end

% GPS测量 (5Hz, 低精度)
gps_rate = 5;  % 每5个IMU采样一次GPS
R_gps2 = diag([9, 9]);  % GPS噪声 (3m std)
z_gps2 = x2_true(1:gps_rate:end, 1:2) + mvnrnd([0 0], R_gps2, round(N2/gps_rate));

% IMU测量 (20Hz, 有偏置和噪声)
imu_noise = [0.5, 0.5];  % 加速度噪声
acc_meas = zeros(N2, 2);
for k = 1:N2
    if k == 1
        acc_meas(k,:) = [0, 0];
    else
        ax = (x2_true(k,3) - x2_true(k-1,3)) / dt2;
        ay = (x2_true(k,4) - x2_true(k-1,4)) / dt2;
        acc_meas(k,:) = [ax, ay] + imu_noise*randn(1,2);
    end
end

% EKF融合
x_ekf = [z_gps2(1,1); z_gps2(1,2); 0; 0];  % [x;y;vx;vy]
P_ekf = diag([10, 10, 5, 5]);
Q_ekf = diag([0.5, 0.5, 2, 2]);

x_ekf_hist = zeros(N2, 4);
gps_counter = 0;

F_ekf = [1 0 dt2 0; 0 1 0 dt2; 0 0 1 0; 0 0 0 1];
H_gps2 = [1 0 0 0; 0 1 0 0];

for k = 1:N2
    % IMU预测 (每步)
    x_ekf = F_ekf * x_ekf + [0;0;dt2;0]*acc_meas(k,1) + [0;0;0;dt2]*acc_meas(k,2);
    P_ekf = F_ekf * P_ekf * F_ekf' + Q_ekf * dt2;
    
    % GPS更新 (每gps_rate步)
    if mod(k-1, gps_rate) == 0 && gps_counter < size(z_gps2, 1)
        gps_counter = gps_counter + 1;
        z_k = z_gps2(gps_counter, :)';
        S = H_gps2 * P_ekf * H_gps2' + R_gps2;
        K = P_ekf * H_gps2' / S;
        x_ekf = x_ekf + K * (z_k - H_gps2 * x_ekf);
        P_ekf = (eye(4) - K * H_gps2) * P_ekf;
    end
    
    x_ekf_hist(k,:) = x_ekf';
end

rmse_gps2 = sqrt(mean(sum((z_gps2 - x2_true(1:gps_rate:end, 1:2)).^2, 2)));
rmse_ekf2 = sqrt(mean(sum((x_ekf_hist(:,1:2) - x2_true(:,1:2)).^2, 2)));
fprintf('GPS RMSE: %.2f m\n', rmse_gps2);
fprintf('EKF融合RMSE: %.2f m\n', rmse_ekf2);
fprintf('改善: %.1f%%\n', (1-rmse_ekf2/rmse_gps2)*100);

figure('Name', 'IMU/GPS融合', 'Position', [100 100 1000 500]);
subplot(1,2,1);
plot(x2_true(:,1), x2_true(:,2), 'k-', 'LineWidth', 2); hold on;
scatter(z_gps2(:,1), z_gps2(:,2), 10, 'b', 'filled');
plot(x_ekf_hist(:,1), x_ekf_hist(:,2), 'r-', 'LineWidth', 1.5);
scatter(0, 0, 100, 'g', 's', 'filled');
xlabel('X (m)'); ylabel('Y (m)');
title('2D轨迹');
legend('真实','GPS','EKF融合','起点');
axis equal; grid on;

subplot(1,2,2);
plot(t2, x2_true(:,3), 'k-', 'LineWidth', 2); hold on;
plot(t2, x_ekf_hist(:,3), 'r-', 'LineWidth', 1);
xlabel('时间 (s)'); ylabel('Vx (m/s)');
title('速度估计 (IMU不直接给出速度)');
legend('真实','EKF估计');
grid on;

%% === 总结 ===
fprintf('\n=== 传感器融合总结 ===\n');
fprintf('1. 卡尔曼滤波: 最优线性估计、预测-更新框架\n');
fprintf('2. EKF: 非线性系统的线性化卡尔曼滤波\n');
fprintf('3. IMU/GPS: 高频率IMU + 低频率GPS互补融合\n');
fprintf('4. 推荐: 粒子滤波适用于强非线性场景\n');
