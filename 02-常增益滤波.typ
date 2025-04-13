#import "@local/qooklet:0.1.0": *
#show: qooklet.with(
  title: "常增益滤波",
  author: "Yāng Xīnbīn",
  footer-cap: "Yāng Xīnbīn",
  header-cap: "目标追踪",
  lang: "zh",
)

= 铺垫与术语
<铺垫与术语>

== 系统状态

若一个模型可以被视为一个系统，那么根据其观测值（输入）的性质，可被划分为以下两类

- 静态系统（static system）：当前的输入与时间无关。如短时间内，一块金条的重量，一栋建筑的高度
- 动态系统（dynamic system）：当前的输出与时间有关，取决于系统过去时刻的状态（输入和输出）

为了描述一个动态系统，我们往往需要建立一个动态模型（dynamic model），如使用雷达对一架飞机的位置进行测距，可得

$
  cases(
    x = x_0 + v_(x 0) Δ t + 1/2 a_x Δ t^2\
    y = y_0 + v_(y 0) Δ t + 1/2 a_y Δ t^2\
    z = z_0 + v_(z 0) Δ t + 1/2 a_z Δ t^2
  )
$

其中，参数$[x, y, z, v_x, v_y, v_z, a_x, a_y, a_z]$被称系统状态（system state）。故这样的模型又被称为状态空间模型（state space model）。

== 状态更新方程


对一个人的身高，进行多次量测，可写成递归形式

$
  hat(x)_(k)
  &= 1 / k (z_(1) + z_(2) + … + z_(k-1) + z_(k))\
  &= (k-1) / k (#pin("s1")1#pin("s2")) / (#pin("s3")k-1#pin("s4")) #pin("s5")∑_(i=1)^(k-1) z_(i)#pin("s6") + 1 / k z_(k)\
  &= (k-1) / k #pin(7)hat(x)_(k|k-1)#pin(8) + 1 / k z_(k)\
  &= hat(x)_(k|k-1) + 1 / k (z_(k) - hat(x)_(k|k-1))
$

#let color_stats = rgb(0, 180, 255, 50)
#let font_size_annot = 8pt
#let color_cond = rgb(150, 90, 170, 50)
#pinit-highlight("s1", "s2", "s3", "s4", "s5", "s6", fill: color_stats)
#pinit-place("s4", dx: -15pt, dy: 6pt)[#text("统计形式", font: "Kaiti SC", size: font_size_annot)]
#pinit-highlight(7, 8, fill: color_cond)
#pinit-place(7, dx: -2pt, dy: 6pt)[#text("条件形式", font: "Kaiti SC", size: font_size_annot)]

此方程被称为状态更新方程（state update equation）。这里，我们约定

- $x$：真实值
- $z_(k)$：第$k$次量测值
- $macron(z)_(k)$：前$k$次量测均值
- $hat(x)_(k|k-1)$：第$k$次的预测值
- $hat(x)_(k)$：第$k$次的估计值

#tip[
  显然，对静态系统，$hat(x)_(k|k-1) = hat(x)_(k)$，$hat(x)_(k)$也不依赖$hat(x)_(k|k-1)$。
]

由上，状态更新方程可描述为

#align(center, text("当前估计 = 预测 + 增益 × 新息", font: "Kaiti SC", size: 12pt))

需要强调的是，估计值，又称滤波值，永远介于预测值和量测值之间，可以看着是一种利用加权平均的对量测进行平滑的手段。而这里的新息（innovation）即当前测量的残差，有时会使用$y$表示，即

$ y_(k) = z_(k) - hat(x)_(k|k-1) $

不难看出，随着量测次数$k$的增大，当前估计会越来越接近先验估计，这里即前$k$次量测的均值。在实际应用中，增益因子$1/k$往往用更一般的$K_(k) ∈ [0,1]$代替，$K$即是 Kalman 增益。为了不显得那么急功近利，我们暂时用$α_(k)$ 来表示

$ hat(x)_(k) = hat(x)_(k|k-1) + α_(k) (z_(k) - hat(x)_(k|k-1)) $

= 匀速模型
<匀速模型>

== 状态外推方程

对一个匀速（constant velocity，CV）航行的飞行器，雷达以恒定频率向目标发射追踪波束，周期为$Δ t$，则飞行器距离雷达的距离$x$可表示为

$
  hat(x)_(k) &= hat(x)_(k-1) + Δ t hat(dot(x))_(k-1)\
  hat(dot(x))_(k) &= hat(dot(x))_(k-1)
$

上述方程被称为状态外推方程（state extrapolation equation）或预测方程。又由于动态（时变）过程必然带来噪声，即过程噪声（process noise）。引入过程噪声后，上述两式表示为

$
  hat(x)_(k) &= hat(x)_(k-1) + Δ t hat(dot(x))_(k-1) \
  hat(dot(x))_(k) &= hat(dot(x))_(k-1)
$

== α-β 滤波

由于仅依赖状态外推方程并不能得到准确的$hat(x)$，此时还需要位置和速度的状态更新方程，分别对$hat(x)$和$hat(dot(x))$进行校正，即

$
  hat(x)_(k) &= hat(x)_(k|k-1) + α (z_(k) - hat(x)_(k|k-1))\
  hat(dot(x))_(k) &= hat(dot(x))_(k-1) + β (frac(z_(k) - hat(x)_(k|k-1), Δ t))
$

此即是 α-β 滤波，又称 g-h 滤波。

#figure(
  image("images/gh-cv.png", width: 70%),
  caption: "匀速模型",
  supplement: "图",
)

== 噪声与增益

由于采样间隔$Δ t$相对于目标跟踪的时间往往很小，故每个采样周期内的$v_x$可近似常数。若再假设过程噪声在各个采样周期之间相互独立，当过程噪声为白噪声（white noise）时，定义机动目标指数$λ$为

$ λ = frac(Δ t σ_v, σ_w) $

其中，$σ_v$和$σ_w$分别为过程噪声和量测噪声（measurement noise）的标准差。前者又称模型噪声，表示动态模型的不确定性，后者表示测定方法的不确定性。可得常系数滤波增益为@bar-shalomTrackingDataAssociation1987

$
  α = -frac(λ^2 + 8λ- (λ+4)sqrt(λ^2+8λ), 8)\
  β = frac(λ^2 + 4λ - λ sqrt(λ^2+8λ), 4)
$

通常，$σ_w$是已知的，而$σ_v$较难获得，当后者误差较大时，α-β 滤波会失效。工程上常绕过$σ_v$直接采用如下经验值

$
  α = frac(2(2k-1), k(k-1))\
  β = frac(6, k(k+1))
$

其中，$α$和$β$分别从$k=1$和$k=2$开始计算，滤波从$k=3$开始工作。

#align(
  center,
  stack(
    dir: ltr,
    spacing: -2em,
    figure(
      image("images/gh-g.png", width: 60%),
      caption: "变化的 α（g）",
      supplement: "图",
    ),
    figure(
      image("images/gh-h.png", width: 60%),
      caption: "变化的 β（h）",
      supplement: "图",
    ),
  ),
)

由上不难看出，$α$控制着滤波的精度，$β$控制着滤波响应时间，后者与雷达精度呈正相关。

= 匀加速模型
<匀加速模型>

== α-β-γ 滤波

对一个匀加速（constant acceleration，CA）航行的飞行器，类比 CV 模型，有

$
  hat(x)_(k|k-1)
  &= hat(x)_(k) + hat(dot(x))_(k) Δ t + hat(dot.double(x))_(k) frac(Δ t^2, 2)\
  hat(dot(x))_(k|k-1)
  &= hat(dot(x))_(k) + hat(dot.double(x))_(k) Δ t\
  hat(dot.double(x))_(k|k-1)
  &= hat(dot.double(x))_(k)
$

化为递归形式，可得

$
  hat(x)_(k)
  &= hat(x)_(k|k-1) + α (z_(k) - hat(x)_(k|k-1))\
  hat(dot(x))_(k)
  &= hat(dot(x))_(k-1) + β (frac(z_(k) - hat(x)_(k|k-1), Δ t))\
  hat(dot.double(x))_(k)
  &= hat(dot.double(x))_(k-1) + γ (frac(z_(k) - hat(x)_(k|k-1), 0.5 Δ t^2))
$

此即是 α-β-γ 滤波，又称 g-h-k 滤波。其中，其增益和机动目标指数的关系为

$
  frac(γ^2, 4(1-α)) = λ^2\
  β = 2(2-α) - 4 sqrt(1-α) \
  γ = β^2 / α
$

类似α-β 滤波，α-β-γ 滤波的增益经验值为

$
  α = frac(3(3k^2 - 3k + 2), k(k+1)(k+2))\
  β = frac(8(2k-1), k(k+1)(k+2)) \
  γ = frac(60, k(k+1)(k+2))
$

= 辅助知识
<辅助知识>

== 信号处理

#definition[
  信号在各个频段上的功率谱密度是一样的，由于白光是由各种频率（颜色）的单色光混合而成，因而此信号的这种具有平坦功率谱的性质被称作是"白色的"，此信号也因此被称作白噪声。相对的，其他不具有这一性质的噪声信号被称为有色噪声。
]

#bibliography("data/track.bib", title: "参考文献", style: "future-science")
