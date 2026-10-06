# 研究笔记：R `qte::panel_qtt` 的 `g` 列名碰撞 bug（交错 QTT）

> 日期：2026-10-06
> 发现于 qdid 交错对拍。与 contdid 的 `dvals` bug 同类：**参考实现自身的缺陷**。

## 现象

对同一份交错数据（列名 `g` = 处理时点），

- R `qte::panel_qtt(gname="g", gt_type="qtt")` overall = `0.2116, 0.3830, ...`
- R 把列名改成 `gt` 后（`gname="gt"`） = `0.3123, 0.4978, ...`
- 我们的 Stata `qdid`（not-yet-treated） = `0.3249, 0.4978, ...`

改个列名，R 结果就差 ~0.13；改名后与 Stata 只差 ~0.01。

## 根因

`qte:::three_period_subset` 中：

```r
this.data <- subset(data, G == g | G > tp | G == 0)   # control_group == "notyettreated"
...
this.data$D <- 1L * (this.data$G == g)
```

`subset(data, expr)` 会**先在 `data` 里解析符号**。当 `data` 恰好有一列名为 `g`（用户的分组变量就叫 `g`）时，`expr` 里的 `g` 被解析成**那一列**，而不是函数参数 `g`（当前 cohort）。

于是 `G == g` 变成 `G == data$g`（逐行恒真）→ **控制组筛选失效**，保留了**全部单元**（含已处理 cohort）作为对照。

对照数据：cell (4,5) 的 `three_period_subset` 返回 **1800 行（600 单元）**（应为 not-yet-treated 的 450 单元/1350 行）。
`this.data$D <- ...(this.data$G == g)` 用的是局部参数 `g`，故 `D` 仍正确——所以单元"能算"，但**控制组被污染**。

**触发条件**：`gname` 指定的列名恰好是 `g`（或任何与函数参数 `g`/`tp` 同名的列）。换名（如 `gvar`、`first_treat`）即正常。

## 影响与结论

- **我们的 Stata `qdid` 交错实现是正确的**（对齐"改列名后的 R"，差 ~0.01，与两期同一量级）。
- R 在列名为 `g` 时给出的交错结果是**错的**（控制组未按 not-yet-treated 净化）。
- 建议：使用 R `qte::panel_qtt` 时，**分组变量不要命名为 `g`**。

## 复现

`examples/reference/bugcheck.R`（同一数据、仅改列名，R 结果从 0.2116 变 0.3123）。
