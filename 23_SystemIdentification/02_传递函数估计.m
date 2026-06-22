%% ========================================================================
%  传递函数估计 - Transfer Function Estimation
%  本脚本演示各种传递函数估计方法
%  内容包括：频域方法、tfest、阶数选择、模型比较
%  ========================================================================
clear; clc; close all;

%% === 1. 生成多输入多输出数据 ===
fprintf('=== 1. 生成实验数据 ===\n');

Ts = 0.1;
N = 1000;
t = (0:N-1)' * Ts;

% 真实系统: 三阶系统 + 零点
sys_true = tf([2 1], [1 3 4 2]);
sys_d = c2d(sys_true, Ts);
fprintf('真实系统传递函数:\n');
disp(sys_true);

% 输入: PRBS (伪随机二进制序列)
rng(42);
u = sign(randn(N, 1));  % 简化PRBS
% 平滑输入
u = filter(ones(1,3)/3, 1, u);

% 系统响应
y_clean = lsim(sys_d, u, t);
y = y_clean + 0.2*randn(N, 1);

fprintf('数据点数: %d\n', N);
fprintf('SNR: %.1f dB\n', 10*log10(var(y_clean)/0.04));

%% === 2. 频域辨识方法 ===
fprintf('\n=== 2. 频域辨识 ===\n');

% 经验传递函数 (ETFE) - 通过FFT
Nfft = 256;
U = fft(u, Nfft);
Y = fft(y, Nfft);
freq = (0:Nfft/2-1) / (Nfft*Ts);

% 平滑: H1估计 (加窗)
window_len = 32;
H1 = zeros(Nfft/2, 1);
for k = 1:Nfft/2
    k_start = max(1, k-floor(window_len/2));
    k_end = min(Nfft/2, k+floor(window_len/2));
    Suu = mean(abs(U(k_start:k_end)).^2);
    Syu = mean(conj(U(k_start:k_end)) .* Y(k_start:k_end));
    H1(k) = Syu / Suu;
end

% 经验频率响应
figure('Name', '频域辨识', 'Position', [100 100 1000 600]);
subplot(2,2,1);
semilogx(freq, 20*log10(abs(H1)), 'b', 'LineWidth', 1.5); hold on;

% 真实系统频率响应
w = 2*pi*freq;
H_true = freqresp(sys_true, w);
semilogx(freq, 20*log10(abs(H_true(:))), 'r--', 'LineWidth', 2);
xlabel('频率 (Hz)');
ylabel('幅值 (dB)');
title('幅频特性');
legend('H1估计','真实系统');
grid on;

subplot(2,2,2);
semilogx(freq, unwrap(angle(H1))*180/pi, 'b', 'LineWidth', 1.5); hold on;
semilogx(freq, unwrap(angle(H_true(:)))*180/pi, 'r--', 'LineWidth', 2);
xlabel('频率 (Hz)');
ylabel('相位 (度)');
title('相频特性');
legend('H1估计','真实系统');
grid on;

%% === 3. 不同阶数模型比较 ===
fprintf('\n=== 3. 模型阶数选择 ===\n');

% 使用最小二乘法辨识不同阶数的ARX模型
max_order = 6;
fit_train = zeros(max_order, 1);
fit_test = zeros(max_order, 1);
aicc = zeros(max_order, 1);

N_train = round(0.7*N);
u_train = u(1:N_train);
y_train = y(1:N_train);
u_test = u(N_train+1:end);
y_test = y(N_train+1:end);
t_train = t(1:N_train);
t_test = t(N_train+1:end);

for order = 1:max_order
    na = order;
    nb = order;
    nk = 1;
    
    % 构建回归矩阵
    n_reg = N_train - max(na, nb+nk-1);
    Phi = zeros(n_reg, na+nb);
    for i = 1:n_reg
        idx = i + max(na, nb+nk-1);
        for j = 1:na
            Phi(i,j) = -y_train(idx-j);
        end
        for j = 1:nb
            Phi(i,na+j) = u_train(idx-nk-j+1);
        end
    end
    Y_reg = y_train(max(na,nb+nk-1)+1:N_train);
    
    % 求解
    theta = (Phi'*Phi) \ (Phi'*Y_reg);
    
    % 构建模型
    num_id = theta(na+1:end)';
    den_id = [1, -theta(1:na)'];
    sys_model = tf(num_id, den_id, Ts);
    
    % 训练集拟合度
    y_fit = lsim(sys_model, u_train, t_train);
    fit_train(order) = (1 - norm(y_train-y_fit)/norm(y_train-mean(y_train))) * 100;
    
    % 测试集拟合度
    y_pred = lsim(sys_model, u_test, t_test);
    fit_test(order) = (1 - norm(y_test-y_pred)/norm(y_test-mean(y_test))) * 100;
    
    % AIC准则 (简化)
    residuals = Y_reg - Phi*theta;
    sigma2 = mean(residuals.^2);
    k_param = na + nb;
    aicc(order) = n_reg*log(sigma2) + 2*k_param + 2*k_param*(k_param+1)/(n_reg-k_param-1);
    
    fprintf('阶数 %d: 训练拟合度=%.1f%%, 测试拟合度=%.1f%%, AICc=%.2f\n', ...
            order, fit_train(order), fit_test(order), aicc(order));
end

% 最优阶数
[~, best_order] = min(aicc);
fprintf('\nAIC推荐阶数: %d\n', best_order);

% 可视化
figure('Name', '阶数选择', 'Position', [100 100 1000 500]);
subplot(1,3,1);
plot(1:max_order, fit_train, 'bo-', 1:max_order, fit_test, 'rs-', 'LineWidth', 2);
xlabel('模型阶数');
ylabel('拟合度 (%)');
title('拟合度 vs 阶数');
legend('训练集','测试集');
grid on;

subplot(1,3,2);
plot(1:max_order, aicc, 'go-', 'LineWidth', 2);
hold on;
stem(best_order, aicc(best_order), 'r', 'filled', 'LineWidth', 2);
xlabel('模型阶数');
ylabel('AICc');
title(sprintf('AIC准则 (最优=%d)', best_order));
grid on;

subplot(1,3,3);
% 最佳模型的阶跃响应
na = best_order; nb = best_order; nk = 1;
n_reg = N_train - max(na, nb+nk-1);
Phi = zeros(n_reg, na+nb);
for i = 1:n_reg
    idx = i + max(na, nb+nk-1);
    for j = 1:na
        Phi(i,j) = -y_train(idx-j);
    end
    for j = 1:nb
        Phi(i,na+j) = u_train(idx-nk-j+1);
    end
end
Y_reg = y_train(max(na,nb+nk-1)+1:N_train);
theta = (Phi'*Phi) \ (Phi'*Y_reg);
sys_best = tf(theta(na+1:end)', [1 -theta(1:na)'], Ts);

step(sys_true, 'b', sys_best, 'r--');
legend('真实系统','辨识模型');
title(sprintf('最佳模型阶跃响应 (阶数=%d)', best_order));
grid on;

%% === 总结 ===
fprintf('\n=== 传递函数估计总结 ===\n');
fprintf('1. 频域方法: ETFE、H1估计、加窗平滑\n');
fprintf('2. 阶数选择: AIC/AICc准则、训练/测试拟合度\n');
fprintf('3. 模型验证: 阶跃响应、频率响应、残差分析\n');
