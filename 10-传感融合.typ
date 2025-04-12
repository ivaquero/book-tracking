<<<<<<< HEAD
#import "@local/scibook:0.1.0": *
#show: doc => conf(
||||||| 9cf44cf
#import "lib/scibook.typ": *
#show: doc => conf(
=======
#import "@local/qooklet:0.1.0": *
#show: qooklet.with(
>>>>>>> fa5790de72ff5f3d54d572f1f713992b86ae0d18
  title: "传感融合",
  author: "Yāng Xīnbīn",
  footer-cap: "Yāng Xīnbīn",
  header-cap: "目标追踪",
  lang: "zh",
)

= 铺垫

== Gaussian 积分布

#theorem[
  对$n$个 Gaussian 分布，其积分布的参数如下
  $
    σ_(N)^2 = frac(1, ∑_(i=1)^n 1/σ_i^2)\
    μ_(N) = ∑_(i=1)^n μ_i / σ_i^2 σ_(N)^2
  $
]

#figure(
  image("images/gaussian-prod.png", width: 40%),
  caption: "Gaussian 分布之积分布",
  supplement: "图",
)

#theorem[
  $k$元 Gaussian 分布的 PDF 为
  $
    p(𝒙) = 1 / sqrt((2π)^k |𝜮|) exp((- 1/2 (𝒙 - 𝝁))^T 𝜮^(-1) (𝒙 - 𝝁))
  $
  其中，
  - $𝝁$为量测向量
  - $𝜮$为量测协方差
]

#theorem[
  $n$个$k$元 Gaussian 分布的积分布的参数为
  $
    & 𝜮_(N)^(-1) = ∑_(i=1)^n 𝜮_i^(-1)\
    & 𝝁_(N) = 𝜮 ∑_(i=1)^n (𝜮_i^(-1) 𝝁_i)
  $
]

#figure(
  image("images/fusion-radar.png", width: 40%),
  caption: "两站雷达融合",
  supplement: "图",
)

= 常用策略

== 策略1：量测融合

量测融合是最常用的数据融合方法。通常，它由配备多个传感器的系统使用。

#figure(
  diagram(
    spacing: (2em, 2em),
    node-stroke: 0.7pt,
    mark-scale: 90%,
    let (PD, UD, UP, FS) = ((0, 0), (2.3, 0), (4, 0), (4, -1)),
    let (O, O1, M, I) = ((4.8, 0), (5.5, 0), (2.3, 1), (-1, 0)),
    let (Z1, Z2) = ((3, -1), (5, -1)),
    node(
      PD,
      text("Predict", size: 0.9em),
      shape: rect,
      corner-radius: 3pt,
    ),
    node(
      UD,
      text("Unit Delay", size: 0.6em),
      shape: rect,
      corner-radius: 3pt,
    ),
    node(
      UP,
      text("Update", size: 0.9em),
      shape: rect,
      corner-radius: 3pt,
    ),
    node(
      FS,
      text("Fusion", size: 0.9em),
      shape: rect,
      corner-radius: 3pt,
    ),
    node(Z1, $𝒛_k^1$, stroke: 0pt),
    node(Z2, $𝒛_k^2$, stroke: 0pt),
    edge(PD, UD, "->", $hat(𝒙)_(k+1|k)$),
    edge(UD, UP, "->", $hat(𝒙)_(k|k-1)$),
    edge(FS, UP, "->", $𝒛_k$),
    edge(UP, O1, "->", $hat(𝒙)_k$),
    edge(
      O,
      M,
      corner: right,
    ),
    edge(M, I, "-", corner: right),
    edge(I, PD, "->"),
    edge(Z1, FS, "->"),
    edge(Z2, FS, "->"),
  ),
  supplement: "图",
  caption: "量测融合",
)

对$𝒛_k^1, ..., 𝒛_k^k$有协方差$𝑹_k^1, ..., 𝑹_k^k$。假设正态分布的量测值 PDF，可以计算联合 PDF

$
  𝑹_k^(-1) = ∑_(i=1)^k 𝑹_i^(-1) \
  𝒛_k = 𝑹_(n) ∑_(i=1)^k (𝑹_k^((i)-1) 𝒛_k^((i)))
$

传统的 Kalman 过滤接收统一的量测$(𝒛_k, 𝑹_(n))$。在文献中，双传感器的$𝒛_k$计算如下

$
  𝒛_k = 𝒛_k^((1)) + 𝑹_k^((1)) (𝑹_k^((1)) + 𝑹_k^((2)))^(- 1) (𝒛_k^((1)) - 𝒛_k^((2)))
$

== 策略2：状态融合

某些应用程序涉及执行相同任务的不同传感器系统。如几个地理分布的雷达可以跟踪相同的目标。

- 每个雷达都使用 Kalman 过滤创建一个单独的目标轨道。
- 外部系统可以接收雷达的轨道，并计算具有更高位置精度的统一轨道。
状态融合也称航迹融合（track-to-track fusion）。

#figure(
  diagram(
    spacing: (2em, 2em),
    node-stroke: 0.7pt,
    mark-scale: 90%,
    let (PD, UD, UP) = ((0, 0), (2.3, 0), (4, 0)),
    let (O, O1, M, I) = ((4.8, 0), (5.5, 0), (2.3, -1), (-1, 0)),
    let (PD2, UD2, UP2) = ((0, 2), (2.3, 2), (4, 2)),
    let (O2, O12, M2, I2) = ((4.8, 2), (5.5, 2), (2.3, 3), (-1, 2)),
    let (Z1, Z2) = ((4, 0.8), (4, 1.2)),
    node(
      PD,
      text("Predict", size: 0.9em),
      height: 2em,
      width: 4em,
      corner-radius: 3pt,
    ),
    node(
      UD,
      text("Unit Delay", size: 0.6em),
      corner-radius: 1pt,
    ),
    node(
      UP,
      text("Update", size: 0.9em),
      shape: rect,
      corner-radius: 3pt,
    ),
    node(Z1, $𝒛_k^1$, stroke: 0pt),
    node(Z2, $𝒛_k^2$, stroke: 0pt),
    node(
      PD2,
      text("Predict", size: 0.9em),
      shape: rect,
      corner-radius: 3pt,
    ),
    node(
      UD2,
      text("Unit Delay", size: 0.6em),
      shape: rect,
      corner-radius: 3pt,
    ),
    node(
      UP2,
      text("Update", size: 0.9em),
      shape: rect,
      corner-radius: 3pt,
    ),
    edge(PD, UD, "->", $hat(𝒙)_(k+1|k)$),
    edge(UD, UP, "->", $hat(𝒙)_(k|k-1)^1$),
    edge(UP, O1, "-", $hat(𝒙)_k^1$, label-side: right),
    edge(
      O,
      M,
      corner: left,
    ),
    edge(M, I, "-", corner: left),
    edge(I, PD, "->"),
    edge(Z1, UP, "->"),
    edge(PD2, UD2, "->", $hat(𝒙)_(k+1|k)$),
    edge(UD2, UP2, "->", $hat(𝒙)_(k|k-1)$),
    edge(UP2, O12, "-", $hat(𝒙)_k^2$),
    edge(
      O2,
      M2,
      corner: right,
    ),
    edge(M2, I2, "-", corner: right),
    edge(I2, PD2, "->"),
    edge(Z2, UP2, "->"),
    let (FS, FSF) = ((6, 1), (7, 1)),
    node(FS, text($⊕$, size: 1.5em), stroke: 0pt),
    edge(O1, FS, "->", corner: right),
    edge(O12, FS, "->", corner: left),
    edge(FS, FSF, "->", $hat(𝒙)_k$),
  ),
  supplement: "图",
  caption: "状态融合",
)

当两个轨迹估计之间的互协方差可以忽略时，状态融合涉及两个随机变量$hat(𝒙)_k^1$和$hat(𝒙)_k^2$的简单融合，其对应的协方差矩阵是

$
  hat(𝒙)_k = hat(𝒙)_k^((1)) + 𝑷_k^((1)) (𝑷_k^((1)) + 𝑷_k^((2)))^(- 1) (𝒙_k^((1)) - 𝒙_k^((2)))
$
联合状态$hat(𝒙)_k$的协方差矩阵有

$
  𝑷_k^(-1) = 𝑷_k^((1)-1) + 𝑷_k^((2)-1)
$

来自两个传感器轨迹的量测不必是独立的，并且由于共同的过程噪声，两个轨迹可以相关。在组合状态估计时必须考虑相关估计误差。否则，系统跟踪中的目标状态估计可能会降低。

相关状态融合参考 Chang 等的方法@changOptimalTracktoTrackFusion1997，即

$
  hat(𝒙)_k = hat(𝒙)_k^((1)) + (𝑷_k^((1)) - 𝑷_k^((12))) (𝑷_k^((1)) + 𝑷_k^((2)) - 𝑷_k^((12)) - 𝑷_k^((21)))^(- 1) ( 𝒙_k^((1)) - 𝒙_k^((2)) )
$

其中，$𝑷_k^((12)) = (𝑷_k^((21)))^⊤$为$hat(𝒙)_k^1$和$hat(𝒙)_k^2$间的协方差，其计算公式为

$
  𝑷_(k)^((12)) = &(𝑰 - 𝑲_n^(1) 𝑯^(1)) 𝑭 𝑷_(k|k-1)^(12) 𝑭^T (𝑰 - 𝑲_n^(2) 𝑯^(2))^T\
  + &(𝑰 - 𝑲_n^(1) 𝑯^(1)) 𝑮 𝑸 𝑮^T (𝑰 - 𝑲_n^(2) 𝑯^(2))^T
$

有研究表明@bar-shalomEffectCommonProcess1986，当考虑到这种依赖性时，不确定性椭圆的面积会减少 70%，而独立噪声假设正确时只会减少 50%。

#bibliography("data/track.bib", title: "参考文献", style: "future-science")
