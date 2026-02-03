#import "lib/lib.typ": *
#show: appendix-style.with(title: "微积分技术", info: info)

= 插值

== Lagrange 插值

=== 基本公式

已知函数$y = f(x)$在$n+1$个不同的点$x_0, x_1,… , x_2$上的函数值分别为$y_0, y_1, …, y_n$。则$n$次 Lagrange 插值多项式为

$
  P_n (x) = y_0 underbrace(ℓ_0 (x), ℓ_0 (x_0) = 1) + y_1 underbrace(ℓ_1 (x), ℓ_1 (x_1) = 1) + ⋯ + y_n underbrace(ℓ_n (x), ℓ_n (x_n) = 1)
$

也就是令$ℓ_i$在$x_i$处为$1$，其余为$0$。可以归纳出，$n$次 Lagrange 基函数$ℓ_i$为

$
  ℓ_i (x) = product_(i=0,i≠j)^n frac(x - x_i, x_i - x_j) = frac((x - x_0) ⋯ (x - x_(j-1))(x - x_(j+1)) ⋯ (x - x_n), (x_i - x_0) ⋯ (x_i - x_(j-1))(x_i - x_(j+1)) ⋯ (x_i - x_n))
$

同时满足

$
  sum_(i=0)^n ℓ_i (x) = 1
$ <lag_sum>

=== 算法改进

Lagrange 插值基本公式有 2 个缺点

+ 加法和乘法的复杂度为$O(n^2)$
+ 加入新点时需要重新计算

这里引入节点函数

$
  l(x) = product_(i=0)^n (x - x_i) = product_(i=0,i≠j)^n (x - x_i) ⋅ (x - x_j)
$ <lag_node>

联合@lag_sum 和@lag_node，可得

$
  P_n (x) = l(x) sum_(j=0)^n y_j frac(w_j, x-x_j) = frac(l(x) sum_(j=0)^n y_j frac(w_j, x-x_j), sum_(j=0)^n ℓ_j (x)) = frac(l(x) sum_(j=0)^n y_j frac(w_j, x-x_j), sum_(j=0)^n w_j frac(l(x), x-x_j))
$

化简得

$
  P_n (x) = frac(sum_(j=0)^n frac(w_j, x-x_j) y_j, sum_(j=0)^n frac(w_j, x-x_j))
$

此公式被称为质心公式（barycentic formula）。其中，$w_j$不再随$x$变化，只算一次即可。即

$
  w_j = frac(1, product_(k=0,k≠j)^n (x_j - x_k))
$

=== 误差分析

假设$f(x)$有$n+1$阶连续导数，可令 Lagrange 插值多项式的误差为

$
  f(x) - P_n (x) = frac(f^(n + 1) (xi), (n + 1)!) l(x)a
$

选取 Chebyshev 节点节点使如下公式的值尽可能小

$
  |l(x)| = |(x - x_0) ⋯ (x - x_n)|
$

=== Hermite 积分公式

将权重写为如下形式

$ w_j = frac(1, l'(x_j)) $

利用留数定理可得

$
  l_i (x) & = frac(l(x), l'(x_i)(x - x_j)) \
          & = l(x) "Res"(frac(1, l(t)(x - t)); t = x_i) \
          & = frac(1, 2pi i) ∫_(Γ_j) frac(1, l(t)(x - t)) dd(t)
$

其中，$Γ_j$为只包围节点$x_j$的正向闭合曲线。进而有

$
  p(x) = frac(1, 2pi i) ∫_(Γ'_j) underbrace(frac(l(x), l(t)(x - t)), #ctext("节点的积分")) underbrace(frac(f(t), (1)), #ctext("节点的函数值")) dd(t)
$

其中，$Γ'$为只包围了节点$x_0, x_1, ⋯ , x_n$的正向闭合曲线。又

$ "Res"(frac(l(x) f(t), l(t)(x - t)); t = x) = - f(x) $

于是可得，Hermite 积分公式

$
  f(x) - p(x) = frac(1, 2pi i) ∫_(Γ_j) frac(l(x)f(t), l(t)(t - x)) dd(t)
$ <hermite_int>

这里的$Γ$在$Γ'$的基础上，还包括了待估计点$x$。其告诉我们，$f(x)$的解析区域越大，插值收敛越快。

== 插值点选择

=== Runge 现象

Runge 现象是指多项式插值在区间端点处发散的现象，具备这样性质的函数又被称为 Runge 函数。考虑 Runge 函数

$
  f(x) = frac(1, 1 + 25x^2)
$

若使用$n$阶多项式$P_n(x)$在$[-1, 1]$上按照，

$ x_i = -1 + (i - 1)frac(2, n),quad i ∈ {1, 2, ⋯ , n+1} $

进行等距插值，则$P_n(x)$在$x = ±1$处发散。

=== 收敛性分析

为确定函数的收敛性，根据@hermite_int，我们只需要关心式中唯一随$x$变化的因子

$
  frac(l(x), l(t)) & = lr(|frac((x - x_0) ⋯ (x - x_n), (t - x_0) ⋯ (t - x_n))|) \
                   & = (frac(root(n + 1, |x - x_0| ⋯ |x - x_n|), root(n + 1, |t - x_0| ⋯ |t - x_n|)))^(n + 1) \
                   & = frac(x ctext("到各节点的几何平均距离"), t #ctext("到各节点的几何平均距离"))
$

当$Γ$的解析区域足够大，则可使$t$比$x$均值离节点更远，从而使上述等式以指数级递减，并趋于$0$，即$P_n(x)$收至$f(x)$。

对上述等式取对数，可得

$
  frac(1, n + 1) sum_(j = 0)^n ln |t - x_j| > frac(1, n + 1) sum_(j = 0)^n ln |x - x_j|
$

简记为$u(t) > u(x)$。其中

$ u(z) = frac(1, n + 1) sum_(j = 0)^n ln |z - x_j| $

取极限，得

$
  lim_(n arrow.r infinity) frac(1, n + 1) sum_(j = 0)^n ln lr(|z - x_j|)
  &= frac(1, 2) ∫_(-1)^1 ln|z - x|dd(x) \
  &= frac(1, 4) ∫_(-1)^1 ln(z - x) + ln(overline(z - x)) dd(x) \
  &= 1 / 2 "Re" ∫_(-1)^1 ln(z - x)
$

= 辅助定理

#theorem(title: ctext("Weierstrass 逼近定理"))[
  $[a, b]$上的任何连续函数都可以通过有限次多项式逼近。
]

#theorem(title: ctext("留数定理"))[
  $
    "Res"(frac(1, g(x)); x_0) = frac(1, g'(x_0))
  $
]
