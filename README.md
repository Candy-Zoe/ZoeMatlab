# ZoeMatlab - MATLAB 学习集

> 按模块组织的 MATLAB 学习集，包含中文注释和可运行示例。

---

## 目录结构

### 01_Basics（基础与数据类型）
| 文件 | 内容 |
|------|------|
| `01_变量与类型.m` | 变量定义、数据类型转换 |
| `02_数组与矩阵.m` | 数组创建、索引、切片 |
| `03_元胞与结构体.m` | 元胞数组、结构体 |
| `04_运算符.m` | 算术、关系、逻辑运算符 |
| `05_字符串处理.m` | 字符串操作与处理 |

### 02_Visualization（可视化与图形）
| 文件 | 内容 |
|------|------|
| `01_二维绘图.m` | plot、scatter、bar 等二维图 |
| `02_三维绘图.m` | plot3、surf、mesh 等三维图 |
| `03_子图与布局.m` | 子图、图形布局 |
| `04_图形定制.m` | 颜色、线型、标注、图例 |
| `05_图像显示.m` | 图像显示与基本处理 |

### 03_LinearAlgebra（线性代数）
| 文件 | 内容 |
|------|------|
| `01_矩阵运算.m` | 矩阵创建、转置、逆、行列式 |
| `02_线性方程组.m` | 线性方程组求解 |
| `03_特征值与特征向量.m` | 特征值与特征向量 |
| `04_矩阵分解.m` | LU、QR、SVD 分解 |

### 04_Programming（编程基础）
| 文件 | 内容 |
|------|------|
| `01_流程控制.m` | if / switch / for / while |
| `02_函数.m` | 函数定义、匿名函数、句柄 |
| `03_文件读写.m` | 文件读写操作 |
| `04_错误处理.m` | try / catch 错误处理 |
| `05_面向对象.m` | 面向对象编程基础 |

### 05_Symbolic（符号计算与微积分）
| 文件 | 内容 |
|------|------|
| `01_符号表达式.m` | sym/syms 创建、简化、展开、因式分解 |
| `02_微积分.m` | diff, int, 定积分/不定积分, 极限, 级数 |
| `03_微分方程.m` | dsolve 符号求解 ODE |
| `04_变换.m` | 傅里叶变换, 拉普拉斯变换 |

> 需要 Symbolic Math Toolbox

### 06_Statistics（概率统计）
| 文件 | 内容 |
|------|------|
| `01_随机数与分布.m` | rand/randn/randi, 常见分布, 概率密度 |
| `02_描述统计.m` | mean, std, var, skewness, 箱线图 |
| `03_假设检验.m` | ttest, ztest, chi2gof |
| `04_回归分析.m` | 线性回归, 多项式回归, fitlm |

> 需要 Statistics and Machine Learning Toolbox

### 07_SignalProcessing（信号处理）
| 文件 | 内容 |
|------|------|
| `01_信号生成.m` | 正弦波, 方波, 锯齿波, 噪声信号 |
| `02_滤波.m` | FIR/IIR 滤波器设计, filter, filtfilt |
| `03_FFT频谱分析.m` | fft, 功率谱, 频谱图 |
| `04_卷积与相关.m` | conv, xcorr, 互相关/自相关 |

> 需要 Signal Processing Toolbox

### 08_Numerical（数值计算与优化）
| 文件 | 内容 |
|------|------|
| `01_插值.m` | interp1, interp2, spline, 样条插值 |
| `02_曲线拟合.m` | polyfit, polyval, fit, cftool |
| `03_数值积分.m` | integral, integral2, trapz, cumtrapz |
| `04_优化.m` | fminsearch, fminunc, linprog, 最小二乘优化 |

### 09_ImageProcessing（图像处理）
| 文件 | 内容 |
|------|------|
| `01_图像读取与显示.m` | imread, imshow, imwrite, 图像基本信息, 灰度/RGB 转换 |
| `02_图像滤波.m` | imfilter, 均值/中值/高斯滤波, 锐化 (fspecial, medfilt2) |
| `03_边缘检测.m` | edge (Sobel/Canny/Prewitt), Hough 变换, bwboundaries |
| `04_形态学与颜色.m` | 膨胀/腐蚀/开闭运算 (imdilate/imerode), RGB/HSV/灰度转换 |

> 需要 Image Processing Toolbox

### 10_MachineLearning（机器学习基础）
| 文件 | 内容 |
|------|------|
| `01_数据预处理.m` | zscore, normalize, cvpartition, 特征选择基础 |
| `02_分类算法.m` | fitcknn, fitcsvm, fitctree, fitcensemble, confusionmat |
| `03_聚类算法.m` | kmeans, linkage/dendrogram, silhouette, evalclusters |
| `04_降维与可视化.m` | pca, tsne, 散点图矩阵 |

> 需要 Statistics and Machine Learning Toolbox

### 11_ControlSystems（控制系统）
| 文件 | 内容 |
|------|------|
| `01_传递函数.m` | tf, zpk, 零极点图, 传递函数运算 (series/parallel/feedback) |
| `02_时域分析.m` | step, impulse, lsim, 阶跃响应指标 (stepinfo) |
| `03_频域分析.m` | bode, nyquist, nichols, margin |
| `04_PID控制器.m` | pid, pidtune, 闭环控制仿真, 参数调节 |

> 需要 Control System Toolbox

### 12_GuiAppDesign（GUI/App 设计）
| 文件 | 内容 |
|------|------|
| `01_基础控件.m` | uifigure, uibutton, uitextfield, uislider, uidropdown, 回调 |
| `02_布局管理.m` | uigridlayout, uipanel, 响应式布局设计 |
| `03_绘图与交互.m` | uiaxes, 实时数据更新, 鼠标/键盘回调 |
| `04_完整应用示例.m` | 综合小工具 (统计分析工具) |

> 基础 MATLAB 即可

### 13_ParallelComputing（并行计算）
| 文件 | 内容 |
|------|------|
| `01_并行基础.m` | parpool, parfor vs for, spmd, 并行池管理 |
| `02_并行数组.m` | distributed 数组, gpuArray, gather, gpu 运算 |
| `03_性能分析.m` | tic/toc 对比, 加速比, Amdahl 定律, 适用场景 |
| `04_并行应用.m` | 蒙特卡洛并行, 矩阵运算加速, 图像处理并行 |

> 需要 Parallel Computing Toolbox

### 14_TimeSeries（时间序列）
| 文件 | 内容 |
|------|------|
| `01_时间序列基础.m` | timeseries, datetime, 重采样, 缺失值处理 |
| `02_趋势与分解.m` | movmean, detrend, 季节性分解, STL 概念 |
| `03_自相关与谱分析.m` | autocorr, parcorr, periodogram, 频谱分析 |
| `04_ARIMA与预测.m` | arima 模型, estimate, forecast, 置信区间可视化 |

> 需要 Econometrics Toolbox（部分功能基础 MATLAB 可用）

### 15_Communications（通信系统）
| 文件 | 内容 |
|------|------|
| `01_模拟调制.m` | ammod, fmmod, pmmod, 调制信号可视化 |
| `02_数字调制.m` | pskmod, qammod, 星座图 |
| `03_信道编码.m` | encode/decode, 汉明码, CRC, 卷积码概念 |
| `04_通信系统仿真.m` | awgn, 误码率 BER, 完整通信链路仿真 |

> 需要 Communications Toolbox

### 16_DeepLearning（深度学习入门）
| 文件 | 内容 |
|------|------|
| `01_神经网络基础.m` | patternnet, feedforwardnet, 训练与预测 |
| `02_CNN架构.m` | imageInputLayer, convolution2dLayer, maxPooling2dLayer, fullyConnectedLayer |
| `03_训练与评估.m` | trainNetwork, trainingOptions, 训练曲线, confusionchart |
| `04_迁移学习.m` | 预训练网络, 微调, 特征提取, 分类新数据 |

> 需要 Deep Learning Toolbox

---

## 使用方法

1. 用 MATLAB 打开对应模块目录
2. 按文件名顺序依次运行 `.m` 脚本
3. 每个脚本使用 `%%` 分节，可逐节执行（Ctrl+Enter）

---

## 环境要求

- MATLAB R2018b 或更高版本（推荐 R2021a+）
- 模块 01-04, 12: 基础 MATLAB 即可
- 模块 05: Symbolic Math Toolbox
- 模块 06, 10: Statistics and Machine Learning Toolbox
- 模块 07: Signal Processing Toolbox
- 模块 08: Optimization Toolbox
- 模块 09: Image Processing Toolbox
- 模块 11: Control System Toolbox
- 模块 13: Parallel Computing Toolbox
- 模块 14: Econometrics Toolbox
- 模块 15: Communications Toolbox
- 模块 16: Deep Learning Toolbox

> 缺少工具箱时，脚本会使用 try-catch 提供简化版本的演示。
