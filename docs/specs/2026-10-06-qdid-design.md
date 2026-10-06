# qdid — 分位数/分布型 DiD 的 Stata 实现（Spec）

> 日期：2026-10-06
> 状态：待用户审阅（Draft）
> 作者：Haoyu Niu
> 定位：Quantile Treatment Effect on the Treated (QTT) in Difference-in-Differences，Stata 实现
> 方法依据：Callaway & Li (2019), *Quantile treatment effects in difference in differences models with panel data*, Quantitative Economics 10(4): 1579–1618

---

## 1. 背景与目标

**缺口**：平均 DiD（ATT）只给一个数，掩盖了"政策对分布不同位置的人效果不同"。分位数处理效应 QTT(q) 把效应画成关于分位 q 的曲线。Stata 侧目前只有通用分位工具（`ivqte`、`qte`/`cide`、`rifhdreg`），**没有一个现代的、双重稳健的 DiD-QTT 命令**把 Callaway–Li 的识别、估计、按分位数聚合成一站。

**目标**：实现一个正确、可用、有文档、可复现的 Stata 包 `qdid`，填补该缺口，作为作者 GitHub 作品集第三个核心包（与 `contdid`、`didc` 同一条"前沿因果推断 → Stata"主线）。

**作者能力对齐**：作者已在 `contdid` 中实现过**聚类自助 + uniform confidence band（sup-t）**，本包可大量复用该能力栈（分位数曲线的统一带）。

---

## 2. 方法概述（高层）

- 设定：两期面板（或重复截面），处理组 / 对照组，处理变量 `treat`。
- 目标参数：**QTT(q)**——处理组分位 q 处的分位数处理效应。
- 识别：**分布型平行趋势**（distributional DID assumption），是均值平行趋势的分位数扩展。**注意**：QTT 的识别比 ATT 复杂，依赖未处理反事实分布的分位数（不可直接观测），需按论文的识别步骤构造。
- 估计：按论文（Callaway & Li 2019）的估计量；支持**条件于协变量**的版本（论文 Proposition 1）。
- 推断：分位数曲线的逐点 CI + **跨分位数的 uniform 置信带**（sup-t，复用 contdid 的 multiplier bootstrap 思路）。

> 精确识别/估计公式以论文原文为准；实现前先精读，产出 `research-notes.md`，禁止凭印象硬编。

---

## 3. 范围

### 做（v1）

- 两期面板 / 重复截面，二值处理
- QTT(q) 点估计（给定 `quantiles(numlist)`）
- 逐点置信区间 + 跨分位数**统一置信带**
- 可选协变量（条件分布型平行趋势，论文 Prop 1）
- 输出：QTT(q) 数值表 + 分位数效应图
- 配套：模拟数据（已知真实 QTT(q)）、英文 README、sthlp、LICENSE、CHANGELOG

### 不做（v2+）

- 交错处理 / 多期（two-way FE 的分布型 DiD，如 Callaway–Li–Oka 2024）
- 反事实分布的整体估计与展示（v1 只出 QTT 曲线）
- 分位数 ACRT 之类的扩展

---

## 4. 命令语法（设计）

```
qdid depvar [if] [in], unit(varname) time(varname) treat(varname) quantiles(numlist) ///
      [covariates(varlist) reps(#) seed(#) cluster(varname) level(#) cband graph]
```

| 项 | 说明 |
|---|---|
| `depvar` | 结局变量 |
| `unit(varname)` | 面板个体 id |
| `time(varname)` | 时间变量，两期（0=处理前 / 1=处理后） |
| `treat(varname)` | 二值处理指示（1=处理组） |
| `quantiles(numlist)` | 要估计的分位数，如 `0.1(0.1)0.9` |

| 选项 | 默认 | 说明 |
|---|---|---|
| `covariates(varlist)` | 无 | 条件分布型平行趋势 |
| `reps(#)` | 999 | 自助法重复次数 |
| `seed(#)` | 固定默认 | 随机种子（保证可复现） |
| `cluster(varname)` | `unit()` | 聚类变量 |
| `level(#)` | 95 | 置信水平 |
| `cband` | off | 跨分位数的统一置信带（sup-t） |
| `graph` | off | 画 QTT(q) vs q |

---

## 5. 估计量与推断

- 按 Callaway & Li (2019) 的 QTT 识别与估计步骤实现（含未处理反事实分布分位数的构造）。
- 协变量版本按论文 Proposition 1。
- 点对点 CI：按 `unit()`（默认）聚类自助（或按论文建议）；固定默认种子保证可复现。
- `cband`：multiplier bootstrap 求 sup-t 临界值，使整条 QTT(q) 曲线同时被覆盖（对齐 contdid 的影响函数+乘子思路，但 IF 结构按本方法重新推导）。

> 上述为高层直觉；精确公式、反事实分布构造、影响函数，**以论文 §2–§4 为准**，落进 `research-notes.md`。

---

## 6. 包结构

```
qdid/
├── README.md              # 英文
├── LICENSE                # AGPL-3.0（与作者既有包一致）
├── CHANGELOG.md
├── qdid.pkg               # SSC 包元数据
├── stata.toc
├── qdid.ado               # 主命令
├── qdid.sthlp             # 帮助文件
├── examples/
│   ├── qdid_simdata.do    # 模拟数据生成
│   └── qdid_example.do    # 一键复现
├── data/
│   └── qdid_sim.dta
└── docs/
    ├── specs/2026-10-06-qdid-design.md
    ├── plans/2026-10-06-qdid-plan.md
    └── research-notes.md
```

> 布局对齐 contdid：**扁平**（.ado/.sthlp/.mata 在根目录），支持 `net install`。

---

## 7. 验证方案

1. 用固定种子 DGP 生成两期面板，**已知真实 QTT(q) 曲线**。
2. 估计 QTT(q)，检查恢复真值（误差随 N 收敛）。
3. 若可装 R，与 R 侧分位数 DiD 实现（如 `qte` 包中 DiD 相关估计量）对拍；否则以模拟自洽 + 覆盖率检验为主。
4. Monte Carlo 覆盖检验：逐点 CI 覆盖接近名义；`cband` 统一带覆盖 ≥ 名义。

---

## 8. 交付物与验收标准

- [ ] `qdid.ado` + `qdid.sthlp` 可安装、可运行
- [ ] 模拟数据可生成，`examples/qdid_example.do` 一键复现
- [ ] 已知 DGP 下恢复真实 QTT(q)（模拟证据）
- [ ] `cband` 统一带覆盖 ≥ 名义水平
- [ ] 英文 README 完整（安装 / 快速上手 / 方法 / 引用 / 许可证）
- [ ] LICENSE（AGPL-3.0）+ CHANGELOG
- [ ] 上传 GitHub 仓库 `niuniuhaoyu/qdid`

---

## 9. 边界与未来（YAGNI）

- ❌ v1 不做交错 / 多期 / two-way FE 分布型 DiD
- ✅ v2 候选：交错处理（Callaway–Li–Oka 2024）、反事实分布估计、与其他 DiD 估计量的分位数版本
- ✅ 与作者"现代 DiD → Stata"作品集定位一致，为第三个核心包

---

## 10. 实施顺序

1. 精读论文（识别、反事实分布构造、影响函数）→ `research-notes.md`
2. 搭包骨架（目录 + 权限/元数据文件 + 文档占位）
3. 模拟数据 DGP（已知 QTT）
4. 实现 `qdid.ado`（QTT 点估计 + 聚类自助逐点 CI）
5. 实现 `cband` 统一带
6. 加协变量版本
7. 文档 + 测试 + push
