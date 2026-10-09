{smcl}
{* *! version 0.4.2  07oct2026}{...}
{hline}
{p 4 8 2}{bf:qdid} —— 双重差分中的分位数处理效应{right:版本 0.4.2}
{hline}

{p 4 4 2}{it:英文帮助：} {help qdid}

{title:标题}

{p 4 4 2}
{cmd:qdid} —— 在面板数据双重差分（DiD）中估计{bf:处理组分位数处理效应}（QTT），
基于 Callaway 与 Li (2019)。

{title:语法}

{p 8 12 2}
{cmd:qdid} {it:depvar} {ifin}, {cmd:unit(}{it:varname}{cmd:)} {cmd:time(}{it:varname}{cmd:)}
        {cmd:treat(}{it:varname}{cmd:)} {cmd:probs(}{it:numlist}{cmd:)}
        {cmd:covariates(}{it:varlist}{cmd:)} {cmd:gvar(}{it:varname}{cmd:)}
        {cmd:iters(#)} {cmd:level(#)} {cmd:seed(#)} {cmd:cband} {cmd:graph}

{title:描述}

{pstd}
{cmd:qdid} 估计面板数据双重差分下的处理组分位数处理效应（QTT），遵循 Callaway 与 Li
(2019)。它需要{bf:三期}（{it:tmin2}、{it:tmin1}、{it:post}），并用 copula stability
假设构造处理组的反事实处理后结果分布。

{pstd}
反事实为 {cmd:kcf = L + C}：{cmd:L} 把每个处理单位在 pre2 期结果的秩映射到 pre1 期结果
分布，{cmd:C} 把其在处理组前一期变化中的秩映射到未处理组后一期变化分布。于是
{cmd:QTT(tau) = Q_{Y_post|D=1}(tau) - Q_{kcf}(tau)}。

{pstd}
版本 0.4.2 实现了核心 QTT 估计量、bootstrap 标准误与百分位置信区间、统一置信带
（{cmd:cband}，跨分位数 sup-t）、经由 {cmd:covariates()} 的条件 QTT、以及经由
{cmd:gvar()} 的交错采纳。

{title:选项}

{p 4 8 2}{cmd:unit(}{it:varname}{cmd:)} 面板单位标识（必填）。
{p 4 8 2}{cmd:time(}{it:varname}{cmd:)} 时间变量，恰好三期（必填）。
{p 4 8 2}{cmd:treat(}{it:varname}{cmd:)} 组别指示变量（1 = 处理组）；两期设计时必填。
{p 4 8 2}{cmd:probs(}{it:numlist}{cmd:)} 分位点网格（默认 0.05(0.05)0.95）。
{p 4 8 2}{cmd:covariates(}{it:varlist}{cmd:)} 条件分布平行趋势（倾向得分重加权）。
{p 4 8 2}{cmd:gvar(}{it:varname}{cmd:)} 首次受处理期（0 = 从未受处理）；启用交错采纳。
{p 4 8 2}{cmd:iters(#)} bootstrap 重复次数（默认 100；0 = 不做）。
{p 4 8 2}{cmd:level(#)} 置信水平（%），默认 95。
{p 4 8 2}{cmd:seed(#)} 随机种子（默认 12345）。
{p 4 8 2}{cmd:cband} 统一置信带（跨分位数 sup-t）。
{p 4 8 2}{cmd:graph} 绘制 QTT(τ) 曲线。

{title:示例}

{p 4 4 2}
{p 8 8 2}{cmd:. qdid y, unit(id) time(t) treat(d) probs(0.1(0.1)0.9) iters(200) cband graph}
{p 4 4 2}
带协变量的条件 QTT：
{p 8 8 2}{cmd:. qdid y, unit(id) time(t) treat(d) covariates(x1 x2) probs(0.1(0.1)0.9)}
{p 4 4 2}
交错采纳：
{p 8 8 2}{cmd:. qdid y, unit(id) time(t) gvar(g) probs(0.1(0.1)0.9)}

{title:参考文献}

{pstd}
Callaway, B., and T. Li. 2019. Quantile treatment effects in difference in
differences models with panel data. {it:Quantitative Economics} 10(4): 1579-1618.

{title:另见}

{p 4 4 2}
英文帮助：{help qdid}；仓库 README：{browse "https://github.com/niuniuhaoyu/qdid":github.com/niuniuhaoyu/qdid}
