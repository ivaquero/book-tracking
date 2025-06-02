#import "lib/lib.typ": *
#show: touying-quick.with(
  title: "拉格朗日插值在羊群追踪中的应用",
  subtitle: "目标跟踪系列课程第1讲",
  author-size: 20pt,
  info: slide,
  lang: "zh",
)

= 背景介绍

== 为什么需要插值

#block(
  height: 15em,
  columns()[
    - 羊群跟踪的重要性
      - 监测健康
      - 产量管理
    - 数据采集的挑战
      - 离散数据
      - 数据不均衡
    - 目标跟踪所需的技术
      - *插值（interpolation）*
      - 外推（extrapolation）
    #figure(
      image("slides/grid.png", width: 100%),
      // caption: "动物的运动轨迹",
    )
  ],
)

= 多项式插值

== 待定系数法

给定5个点：$(x_1, y_1), (x_2, y_2), (x_3, y_3), (x_4, y_4), (x_5, y_5)$，有唯一的4次多项式穿过它们。

#block(
  height: 9em,
  columns()[
    利用待定系数法有：

    $ y = a_0 + a_1x + a_2x^2 + a_3x^3 + a_4x^4 $

    其中，$a_0, a_1, a_2, a_3, a_4$ 是待定系数。
    #figure(image("slides/interp-lagrange-5.png", width: 90%), caption: none)
  ],
)

#tip(title: text("辅助软件", fill: black))[
  课程绘图及实验使用 GeoGebra，该软件可从其官网和手机商店中下载安装。
]

== Vandermonde 矩阵

将给定的5个点代入上式，得到一个方程组，将其表示为一个矩阵，即 Vandermonde 矩阵。

#set math.equation(numbering: none)
#let lagrange = csv("slides/lagrange.csv")

#figure(
  tableq(lagrange, 6),
  // caption: "5个点的坐标",
  supplement: [表],
  kind: table,
)

$
  mat(
    delim: "[", -1.0; 1.0; -0.5;
    0.0; 1.5
  ) = mat(
    delim: "[",
    1, - 3, (-3)^2, (-3)^3, (-3)^4;
    1, - 2, (-2)^2, (-2)^3, (-2)^4;
    1, 0, 0^2, 0^3, 0^4;
    1, 1, 1^2, 1^3, 1^4;
    1, 3, 3^2, 3^3, 3^4
  )
  mat(delim: "[", a_0; a_1; a_2; a_3; a_4)
$

#warning(title: text("注意", fill: black))[
  当数据点增多时，Vandermonde 矩阵的行列式会变得非常大，计算量也会增加。
]

= 拉格朗日插值

== 拉格朗日基

拉格朗日将每个基函数看作一个多项式，且只在一个点上为1，其他点上为0。如通过横坐标为$x_0=-3$点，即$(-3, 1)$的基函数为：

$
  l_0 (x) = c(x - x_1)(x - x_2)(x - x_3)(x - x_4)
$

可得，$c = 1 \/l_0(x_0)$，从而有

$
  l_0 (x) = ((x - x_1)(x - x_2)(x - x_3)(x - x_4)) / ((x_0 - x_1)(x_0 - x_2)(x_0 - x_3)(x_0 - x_4))
$

将数据点分别带入，类推得到5个拉格朗日基。

$
  l_0(x) &= ((x + 2)(x)(x - 1)(x - 3)) / ((-3 + 2)(-3)(-3 - 1)(-3 - 3)), quad
  l_1(x) &= ((x + 3)(x)(x - 1)(x - 3)) / ((-2 + 3)(-2)(-2 - 1)(-2 - 3)), quad ...
$

#figure(
  tableq(lagrange, 6),
  // caption: "5个点的坐标",
  supplement: [表],
  kind: table,
)

== 插值多项式

#sgrid(
  figure(
    image("slides/interp-lagrange-51.png", width: 100%),
    caption: "拉格朗日基1",
  ),
  figure(
    image("slides/interp-lagrange-52.png", width: 100%),
    caption: "拉格朗日基2",
  ),
  figure(
    image("slides/interp-lagrange-53.png", width: 100%),
    caption: "拉格朗日基3",
  ),
  columns: (200pt,) * 3,
  gutter: 10pt,
  // caption: "插值多项式",
)

#sgrid(
  figure(
    image("slides/interp-lagrange-54.png", width: 100%),
    caption: "拉格朗日基4",
  ),
  figure(
    image("slides/interp-lagrange-55.png", width: 100%),
    caption: "拉格朗日基5",
  ),
  columns: (200pt,) * 2,
  gutter: 10pt,
  // caption: "插值多项式",
)

== 拉格朗日插值公式

将5个拉格朗日基与数据点相乘，得到插值多项式，即

$
  p(x) = sum_(j = 0)^n y_j l_j (x), quad l_j (x) = (∏_(k = 0, k ≠ j)^n (x - x_k)) / (∏_(k = 0, k ≠ j)^n (x_j - x_k))
$

其中，$y_j$ 是数据点的纵坐标。而 $l_j (x)$ 是拉格朗日基，即

#sgrid(
  figure(
    image("slides/interp-lagrange-5x1.png", width: 100%),
    caption: "基函数1+2",
  ),
  figure(
    image("slides/interp-lagrange-5x2.png", width: 100%),
    caption: "基函数1+2+3+4",
  ),
  figure(
    image("slides/interp-lagrange-5y.png", width: 100%),
    caption: "插值多项式",
  ),
  columns: (240pt,) * 3,
  gutter: 20pt,
  // caption: "插值多项式",
)

== 改进

Lagrange 插值基本公式有 2 个缺点

+ 加法和乘法的复杂度为$O(n^2)$
+ 加入新点时需要重新计算\

这里引入节点函数

$
  l(x) = ∏_(i=0)^n (x - x_i) = ∏_(i=0,i≠j)^n (x - x_i) ⋅ (x - x_j)
$ <node>

又，此前的约束条件为

$
  sum_(i=0)^n ℓ_i (x) = 1
$ <constrain>

== 质心公式

联合之前的两个公式@node 和@constrain，可得

$
  P_n (x) = l(x) sum_(j=0)^n y_j frac(w_j, x-x_j) = frac(l(x) sum_(j=0)^n y_j frac(w_j, x-x_j), sum_(j=0)^n ℓ_j (x)) = frac(l(x) sum_(j=0)^n y_j frac(w_j, x-x_j), sum_(j=0)^n w_j frac(l(x), x-x_j))
$

化简得

$
  P_n (x) = frac(sum_(j=0)^n frac(w_j, x-x_j) y_j, sum_(j=0)^n frac(w_j, x-x_j))
$

此公式被称为质心公式（barycentic formula）。其中，$w_j$不再随$x$变化，只算一次即可。即

$
  w_j = frac(1, ∏_(k=0,k≠j)^n (x_j - x_k))
$

= 课程小结

== 主要流程

#block(
  height: 15em,
  columns()[
    *主要流程*
    + 构建网格，得到各数据点坐标$(x_i, y_i)$
    + 利用公式，构造拉格朗日基函数
    + 代入数据点横坐标$x_i$，计算各基函数权重$l_j$
    + 代入数据点纵坐标$y_i$，计算插值多项式

    #figure(image("slides/interp-lagrange-5yy.png", width: 100%), caption: none)
  ],
)

== 主要意义

#block(
  height: 18em,
  columns()[
    *主要意义*·
    - 可以得到过程中任意点的坐标
    - 平滑数据，更好地展示实际情况
    \

    *后续课程*
    - Lagrange 插值法代码实现
    - 常见问题与解决方案
    \

    #figure(image("slides/py.png", width: 90%), caption: none)
  ],
)
