# 研究笔记 qdid：Callaway–Li (2019) 分位数 DiD / QTT

> 日期：2026-10-06
> 目的：为 `qdid` 定死识别与估计；找到对拍基准。

## 1. 方法

Callaway, B., & Li, T. (2019). Quantile treatment effects in difference in
differences models with panel data. *Quantitative Economics* 10(4): 1579–1618.

- 目标参数：**QTT(τ)** = 处理组分位数 τ 处的分位数处理效应。
- 均值 DiD 的分布型扩展：**distributional parallel trends / distributional DiD**。
- 难点：QTT 依赖处理组**未处理反事实分布** `F_{Y2(0)|D=1}`，而它不可观测，且依赖
  `Y1` 与 `ΔY(0)` 之间**未知的相依结构（copula）**。
- 关键识别假设：**Copula Stability Assumption**——该相依（copula）随时间不变，
  于是可以用**可观测**的处理前 copula 替代缺失的 copula，从而识别 QTT。

> 识别与估计的**精确步骤**（论文的三步/分位回归构造）**以实现前精读论文 + R `qte` 源码为准**，
> 本节只记框架，禁止凭印象硬编。

## 2. 对拍基准（关键）

- 作者 R 包 **`qte`**（`bcallaway11/qte`），其中包含 **"Panel QTT (copula stability)"**
  （Callaway and Li 2019）的实现。
- 本机已装 `qte`（见 SOP 环境节）；`qdid` 数值应与 R `qte` 的 Panel QTT 对齐。

## 3. 估计量设计（待精读后定稿，候选框架）

- 常见做法：分步估计
  1. 用分位回归估计处理组处理前 `Y1` 的条件分位数；
  2. 用分位回归估计控制组 `ΔY` 的条件分位数；
  3. 借助 copula stability 把两者组合出 `F_{Y2(0)|D=1}`，再取分位数。
- 需要定死：用哪些协变量、分位回归的设定、以及分位数的网格。
- 推断：分位数曲线的逐点 CI + 跨分位数统一带（sup-t），可复用 contdid 的 multiplier bootstrap 思路。

## 4. 验证方案

1. **模拟 DGP**（`examples/qdid_simdata.do`）：两期面板，已知真实 QTT(τ)；需满足
   distributional DiD + copula stability。
2. **与 R `qte` 对拍**：同一数据、同一分位数网格，逐点比较（目标 ≤1e-6）。
3. 覆盖率检验：逐点 CI 覆盖接近名义；`cband` 统一带覆盖 ≥ 名义。

## 5. 参考

- Callaway & Li (2019), QE 10(4):1579–1618（Copula Stability）。
- R `qte` 包（`bcallaway11/qte`）：Panel QTT via copula stability。
- 相关：arXiv:2408.01208（分布型 DiD 多期版本，用 copula invariance）。

## 6. R `qte` 的参考算法（已抠源码，作为移植基准）

来源：`qte::panel_qtt` → `ptetools::pte(..., attgt_fun = panel_qtt_gt, required_pre_periods = 2L)`。

**重要**：R 实现用**三段子样本**（`pre2, pre1, post`），即需要**两个处理前时期**。两期设计（仅 1 个 pre）不能直接套用 → qdid 设定需相应调整为「2 pre + 1 post」或通用面板。

`panel_qtt_gt`（组-时 QTT，无协变量分支）核心：

```
dY_trt   = Y_pre1_trt - Y_pre2_trt          # 处理组处理前差分（学 copula 用）
dY_ctrl  = Y_post_ctrl - Y_pre1_ctrl        # 控制组差分（未处理变化分布）
u        = F_{Y_pre2|D=1}(Y_pre2_trt)        # pre2 水平的秩
L        = Q_{Y_pre1|D=1}(u)                 # 按同秩映射到 pre1 水平
v        = F_{dY_trt|D=1}(dY_trt)            # 处理前差分的秩
C        = Q_{dY_ctrl}(v)                    # 按同秩映射到控制组差分
kcf      = L + C                             # 处理组未处理反事实 Y_post(0)
ATT      = mean(Y_post_trt) - mean(kcf)
F0       = ECDF(kcf); F1 = ECDF(Y_post_trt); Fte = ECDF(Y_post_trt - kcf)
QTT(τ)   = Q_{F1}(τ) - Q_{F0}(τ)
```

- `wquant(y,w,probs)`：加权分位数（按 `cumsum(w)>=p` 取）。
- 秩 `u,v` 用加权 ECDF 计算。
- 有协变量时（`xformula` 非空）：用 `quantreg::rq` 在 `u_seq=seq(0.01,0.99,0.01)` 上做分位回归，取 `Fhat/Qhat` 构造 `u, L, v, C`（见源码第 57–90 行）。
- 默认 `pre_copula="long"`，聚合用 `panel_qtt_long_agg`；`cband` 用 empirical bootstrap（`biters`）。

> 移植到 Stata 时：需实现加权 ECDF、加权分位数、秩映射；协变量分支需分位回归。**先用无协变量、无 bootstrap 的核心对拍 R `qte`，再加噪。**

