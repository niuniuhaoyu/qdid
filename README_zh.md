# qdid

[English](README.md) | [简体中文](README_zh.md)

**面向 Stata 的双重差分分位数处理效应**

[![Stata 16+](https://img.shields.io/badge/Stata-16%2B-blue.svg)](https://www.stata.com/)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

> 状态：**v0.4.2**（2026-10-07）——两期基期的 QTT（copula stability）、bootstrap
> 逐点置信区间、统一置信带（`cband`）、条件 QTT（`covariates()`）与交错采纳
> （`gvar()`）。已与 R `qte` 对拍（核心 ≈ 0.01；协变量 ≈ 0.01；交错 ≈ 0.03）。
> 设计：[`docs/specs/2026-10-06-qdid-design.md`](docs/specs/2026-10-06-qdid-design.md)
> 计划：[`docs/plans/2026-10-06-qdid-plan.md`](docs/plans/2026-10-06-qdid-plan.md)
> 笔记：[`docs/research-notes.md`](docs/research-notes.md)

`qdid` 实现 Callaway & Li (2019)《Quantile treatment effects in difference in
differences models with panel data》（*Quantitative Economics* 10(4): 1579–1618）
中的**处理组分位数处理效应（QTT）**。

平均 DiD 只给一个数字；`qdid` 给出处理组结果分布上**每个分位点**的效应。Stata
自带通用分位数工具（`ivqte`、`qte`、`rifhdreg`），但缺少现代、统一的 DiD-QTT 命令。

## 安装

```stata
net install qdid, from("https://raw.githubusercontent.com/niuniuhaoyu/qdid/main/") replace
```

## 语法

```stata
qdid y, unit(id) time(t) treat(d) [probs(0.1(0.1)0.9) iters(200) level(95) ///
    seed(12345) cband graph]

* 带协变量的条件 QTT（倾向得分重加权）
qdid y, unit(id) time(t) treat(d) covariates(x1 x2) probs(0.1(0.1)0.9)

* 交错采纳（g = 首次受处理期，0 = 从未受处理）
qdid y, unit(id) time(t) gvar(g) probs(0.1(0.1)0.9)
```

需要**三期**（`tmin2`、`tmin1`、`post`）；`treat` 为组别指示变量（1 = 处理组）。

## 功能

- **QTT(τ)**：以 copula stability 构造反事实处理后结果 `kcf = L + C`，再取
  `QTT(τ) = Q_{Y_post|D=1}(τ) − Q_{kcf}(τ)`；分位点网格可选。
- **推断**：聚类自助法逐点置信区间，以及跨分位数的统一置信带
  （`cband`，sup-t，multiplier bootstrap）。
- **条件 QTT**：`covariates()`——基于倾向得分重加权的条件分布平行趋势
  （Callaway & Li，命题 1）。
- **交错采纳**：`gvar()`——多处理组聚合，与 R `qte::panel_qtt_long_agg` 同法
  （not-yet-treated 作对照），并给出 bootstrap 标准误与百分位区间。
- **作图**：`graph` 绘制 QTT(τ) 曲线。

## 验证（对拍 R `qte`）

| 设定 | 与 R `qte` 的最大 &#124;差&#124; |
|---|---|
| 核心 QTT（两期基期） | 0.0095 |
| 条件 QTT（`covariates()`，pscore） | 0.0105 |
| 交错（逐单元） | ≈ 0.012 |
| 交错（聚合，重命名 R 的 `g` 列后） | ≈ 0.03 |

交错那一处与 R 的差，最终定位为 **R `qte` 自身的 bug**
（`qte:::three_period_subset` 的 `subset(data, G == g | ...)` 在数据含名为 `g`
的列时把 `g` 解析成该列，导致 not-yet-treated 对照筛选静默失效）。
见 [`docs/research-notes-r-bug-gsubset.md`](docs/research-notes-r-bug-gsubset.md)。

## 引用

方法：

```bibtex
@article{callaway2019quantile,
  title   = {Quantile treatment effects in difference in differences models with panel data},
  author  = {Callaway, Brantly and Li, Tong},
  journal = {Quantitative Economics},
  volume  = {10},
  number  = {4},
  pages   = {1579--1618},
  year    = {2019}
}
```

## 许可

AGPL-3.0

---

[English](README.md) | [简体中文](README_zh.md)
