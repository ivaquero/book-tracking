#import "lib/lib.typ": *
#show: chapter-style.with(title: "传感融合", info: info)
#import "@local/consketcher:0.1.0": *

= 铺垫

== Gaussian 积分布

#theorem[
  对$n$个 Gaussian 分布，其积分布的参数如下
  $
    σ_(N)^2 = frac(1, sum_(i=1)^n 1 / σ_i^2)\
    μ_(N) = sum_(i=1)^n μ_i / σ_i^2 σ_(N)^2
  $
]

#figure(
  image("images/gaussian-prod.png", width: 40%),
  caption: "Gaussian 分布之积分布",
)

#theorem[
  $k$元 Gaussian 分布的 PDF 为
  $
    p(𝒙) = 1 / sqrt((2π)^k |𝜮|) exp((- 1 / 2 (𝒙 - 𝝁))^T 𝜮^(-1) (𝒙 - 𝝁))
  $
  其中，
  - $𝝁$为量测向量
  - $𝜮$为量测协方差
]

#theorem[
  $n$个$k$元 Gaussian 分布的积分布的参数为
  $
    & 𝜮_(N)^(-1) = sum_(i=1)^n 𝜮_i^(-1) \
    & 𝝁_(N) = 𝜮 sum_(i=1)^n (𝜮_i^(-1) 𝝁_i)
  $
]

#figure(
  image("images/fusion-radar.png", width: 40%),
  caption: "两站雷达融合",
)

= 常用策略

== 策略1：量测融合

量测融合是最常用的数据融合方法。通常，它由配备多个传感器的系统使用。

#let fusion_measure = diagram(
  spacing: (2em, 2em),
  node-stroke: 0.7pt,
  mark-scale: 90%,
  let line = 0,
  let line2 = -1,
  let start = 0,
  let (predict, delay, update, fusion) = (
    (start, line),
    (start + 2, line),
    (start + 4, line),
    (start + 4, line2),
  ),
  let (output, output2) = (
    (start + 5.5, line),
    (start + 4.8, line),
  ),
  let (input1, input2) = (
    (start + 3, line2),
    (start + 5, line2),
  ),
  rnode(predict, text("Predict", size: 0.9em)),
  rnode(delay, text("Unit Delay", size: 0.9em)),
  rnode(update, text("Update", size: 0.9em)),
  rnode(fusion, text("Fusion", size: 0.9em)),
  node(input1, $𝒛_k^1$, stroke: 0pt),
  node(input2, $𝒛_k^2$, stroke: 0pt),

  arrow(predict, delay, $hat(𝒙)_(k+1|k)$),
  arrow(delay, update, $hat(𝒙)_(k|k-1)$),
  arrow(fusion, update, $𝒛_k$),
  arrow(update, output, $hat(𝒙)_k$),
  uturn2(output2, predict, "", height: 1),
  arrow(input1, fusion, ""),
  arrow(input2, fusion, ""),
)

#figure(fusion_measure, caption: "量测融合")

对$𝒛_k^1, ..., 𝒛_k^k$有协方差$𝑹_k^1, ..., 𝑹_k^k$。假设正态分布的量测值 PDF，可以计算联合 PDF

$
  𝑹_k^(-1) = sum_(i=1)^k 𝑹_i^(-1) \
  𝒛_k = 𝑹_(n) sum_(i=1)^k (𝑹_k^((i)-1) 𝒛_k^((i)))
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

#let fusion_status = diagram(
  spacing: (2em, 2em),
  node-stroke: 0.7pt,
  mark-scale: 90%,
  let line = 0,
  let line2 = 1.6,
  let line1 = (line + line2) / 2,
  let start = 0,
  let (predict, delay, update) = (
    (start, line),
    (start + 2, line),
    (start + 4, line),
  ),
  let (O, O1) = (
    (start + 4.8, line),
    (start + 5.5, line),
  ),
  let (predict2, delay2, update2) = (
    (start + 0, line2),
    (start + 2, line2),
    (start + 4, line2),
  ),
  let (O2, O12) = (
    (start + 4.8, line2),
    (start + 5.5, line2),
  ),
  let (input1, input2) = (
    (start + 3.5, line1 - 0.1),
    (start + 4.5, line1 + 0.1),
  ),
  let (fusion_status, fusion) = (
    (start + 6, line1),
    (start + 7, line1),
  ),

  rnode(predict, text("Predict", size: 0.9em)),
  rnode(delay, text("Unit Delay", size: 0.6em)),
  rnode(update, text("Update", size: 0.9em)),
  rnode(delay2, text("Unit Delay", size: 0.6em)),
  rnode(predict2, text("Predict", size: 0.9em)),
  rnode(update2, text("Update", size: 0.9em)),
  node(input1, $𝒛_k^1$, stroke: 0pt),
  node(input2, $𝒛_k^2$, stroke: 0pt),
  arrow(predict, delay, $hat(𝒙)_(k+1|k)$),
  arrow(delay, update, $hat(𝒙)_(k|k-1)^1$),
  segment(update, O1, $hat(𝒙)_k^1$, label-side: right),
  uturn2(O, predict, "", height: -1),
  arrow(input1, update, "", corner: left),
  arrow(predict2, delay2, $hat(𝒙)_(k+1|k)$),
  arrow(delay2, update2, $hat(𝒙)_(k|k-1)$),
  segment(update2, O12, $hat(𝒙)_k^2$),
  uturn2(O2, predict2, "", height: 1),
  arrow(input2, update2, "", corner: left),
  node(fusion_status, text($⊕$, size: 1.5em), stroke: 0pt),
  arrow(O1, fusion_status, "", corner: right),
  arrow(O12, fusion_status, "", corner: left),
  arrow(fusion_status, fusion, $hat(𝒙)_k$),
)

#figure(fusion_status, caption: "状态融合")

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
  𝑷_(k)^((12)) = & (𝑰 - 𝑲_n^(1) 𝑯^(1)) 𝑭 𝑷_(k|k-1)^(12) 𝑭^T (𝑰 - 𝑲_n^(2) 𝑯^(2))^T \
               + & (𝑰 - 𝑲_n^(1) 𝑯^(1)) 𝑮 𝑸 𝑮^T (𝑰 - 𝑲_n^(2) 𝑯^(2))^T
$

有研究表明@bar-shalomEffectCommonProcess1986，当考虑到这种依赖性时，不确定性椭圆的面积会减少 70%，而独立噪声假设正确时只会减少 50%。

#bibliography("lib/track.bib", title: "参考文献", style: "future-science")
