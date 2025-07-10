#import "../lib/lib.typ": *
#show: touying-quick.with(
  title: "常增益滤波",
  subtitle: "Kalman 滤波系列课程第1讲",
  info: slide,
  lang: "zh",
)

= 铺垫与术语

== 系统状态

若一个模型可以被视为一个系统，那么根据其观测值（输入）的性质，可被划分为以下两类

- 静态系统（static system）：当前的输入与时间无关。如短时间内，一块金条的重量，一栋建筑的高度
- 动态系统（dynamic system）：当前的输出与时间有关，取决于系统过去时刻的状态（输入和输出）

== 状态空间模型

为了描述一个动态系统，我们往往需要建立一个动态模型（dynamic model），如使用雷达对一架飞机的位置进行测距，可得

$
  cases(
    x = x_0 + v_(x 0) Δ t + 1 / 2 a_x Δ t^2\
    y = y_0 + v_(y 0) Δ t + 1 / 2 a_y Δ t^2\
    z = z_0 + v_(z 0) Δ t + 1 / 2 a_z Δ t^2
  )
$

其中，参数$[x, y, z, v_x, v_y, v_z, a_x, a_y, a_z]$被称系统状态（system state）。故这样的模型又被称为状态空间模型（state space model）。

== 状态更新方程

对一个人的身高，进行多次量测，可写成递归形式

$
  hat(x)_(k)
  &= 1 / k (z_(1) + z_(2) + … + z_(k-1) + z_(k))\
  &= (k-1) / k (#pin("s1")1#pin("s2")) / (#pin("s3")k-1#pin("s4")) #pin("s5")sum_(i=1)^(k-1) z_(i)#pin("s6") + 1 / k z_(k)\
  &= (k-1) / k #pin(7)hat(x)_(k|k-1)#pin(8) + 1 / k z_(k)\
  &= hat(x)_(k|k-1) + 1 / k (z_(k) - hat(x)_(k|k-1))
$

#let color_stats = rgb(0, 180, 255, 50)
#let font_size_annot = 8pt
#let color_cond = rgb(150, 90, 170, 50)
#pinit-highlight("s1", "s2", "s3", "s4", "s5", "s6", fill: color_stats)
#pinit-place("s4", dx: -15pt, dy: 6pt)[]
#pinit-highlight(7, 8, fill: color_cond)
#pinit-place(7, dx: -2pt, dy: 6pt)[]

此方程被称为状态更新方程（state update equation）。于是，状态更新方程可描述为

#align(center, text(
  "当前估计 = 预测 + 增益 × 新息",
  font: "Kaiti SC",
  size: 20pt,
))

需要强调的是，估计值，又称滤波值，永远介于预测值和量测值之间，可以看着是一种利用加权平均的对量测进行平滑的手段。而这里的新息（innovation）即当前测量的残差，有时会使用$y$表示，即

$ y_(k) = z_(k) - hat(x)_(k|k-1) $

不难看出，随着量测次数$k$的增大，当前估计会越来越接近先验估计，这里即前$k$次量测的均值。在实际应用中，增益因子$1 / k$往往用更一般的$K_(k) ∈ [0,1]$代替，$K$即是 Kalman 增益。为了不显得那么急功近利，我们暂时用$α_(k)$ 来表示

$ hat(x)_(k) = hat(x)_(k|k-1) + α_(k) (z_(k) - hat(x)_(k|k-1)) $

= 匀速模型

== 状态外推方程

对一个匀速（constant velocity，CV）航行的飞行器，雷达以恒定频率向目标发射追踪波束，周期为$Δ t$，则飞行器距离雷达的距离$x$可表示为

$
       hat(x)_(k) & = hat(x)_(k-1) + Δ t hat(dot(x))_(k-1) \
  hat(dot(x))_(k) & = hat(dot(x))_(k-1)
$

上述方程被称为状态外推方程（state extrapolation equation）或预测方程。又由于动态（时变）过程必然带来噪声，即过程噪声（process noise）。引入过程噪声后，上述两式表示为

$
       hat(x)_(k) & = hat(x)_(k-1) + Δ t hat(dot(x))_(k-1) \
  hat(dot(x))_(k) & = hat(dot(x))_(k-1)
$

== α-β 滤波

由于仅依赖状态外推方程并不能得到准确的$hat(x)$，此时还需要位置和速度的状态更新方程，分别对$hat(x)$和$hat(dot(x))$进行校正，即

$
       hat(x)_(k) & = hat(x)_(k|k-1) + α (z_(k) - hat(x)_(k|k-1))               \
  hat(dot(x))_(k) & = hat(dot(x))_(k-1) + β (frac(z_(k) - hat(x)_(k|k-1), Δ t))
$

此即是 α-β 滤波，又称 g-h 滤波。

#figure(image("../images/gh-cv.png", width: 65%), caption: "α-β 滤波")

== 增益的影响

#align(center, stack(
  dir: ltr,
  spacing: 2em,
  figure(image("../images/gh-g.png", width: 50%), caption: "变化的 α（g）"),
  figure(image("../images/gh-h.png", width: 50%), caption: "变化的 β（h）"),
))

由上不难看出，$α$控制着滤波的精度，$β$控制着滤波响应时间，后者与雷达精度呈正相关。

== α-β 滤波

#block(height: 16em, columns()[
  #theorem[
    设$X_1 ∼ 𝒩(μ_1, σ_1^2), X_2 ∼ 𝒩(μ_2, σ_2^2)$，且$X_1$和$X_2$相互独立，则 Gaussian 积分布的参数为

    $ μ_x = frac(σ_1^2 μ_2 + σ_2^1 μ_1, σ_1^2 + σ_2^2)\
    σ_x = frac(1, 1 / σ_1^2 + 1 / σ_2^2) $
  ],
  #figure(
    image("../images/gaussian-prod.png", width: 100%),
    caption: "Gaussian 分布的积",
  )
])

= 课程小结

== Kalman 滤波流程

#set list(indent: -1.2em)
#block(height: 15em, width: 90%, columns(3)[
  - 初始化
    + 获取
      - 初始估计状态：$hat(x)_0$
      - 初始状态方差：$p_0$
      - 量测：$z_k$
      - 量测方差：$r_k$
    + 状态预测
      - 预测：$hat(x)_(k|k-1)$
      - 预测方差：$p_(k|k-1)$

  - 状态更新
    + 获取
      - 量测及其方差：$z_k$
      - 量测方差：$r_k$
      - 预测：$hat(x)_(k|k-1)$
      - 预测方差：$p_(k|k-1)$
    + 状态预测
      - 估计：$hat(x)_k$
      - 估计方差：$p_k$

  #image("img/kalman.drawio.png", width: 160%)
])

== 后续

#block(height: 9em, columns(gutter: .1em)[
  - Kalman 滤波的多维推广
  - Kalman 滤波代码实现
  链接: https://ivaquero.github.io/blog-filters

  #image("img/tut.png", height: 125%, width: 100%)
])
