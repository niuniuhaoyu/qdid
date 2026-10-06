{smcl}
{* *! version 0.0.1  2026-10-06  Haoyu Niu}

{title:qdid --- Quantile treatment effects in difference-in-differences}

{title:Syntax}

{pstd}
{cmd:qdid} {it:depvar} {ifin}, {cmd:unit(}{it:varname}{cmd:)} {cmd:time(}{it:varname}{cmd:)}
        {cmd:treat(}{it:varname}{cmd:)} {cmd:quantiles(}{it:numlist}{cmd:)}
        {cmdab:cov:ariates(}{it:varlist}{cmd:)} {cmd:reps(#)} {cmd:seed(#)}
        {cmd:cluster(}{it:varname}{cmd:)} {cmd:level(#)} {cmd:cband} {cmd:graph}

{title:Description}

{pstd}
{cmd:qdid} estimates the quantile treatment effect on the treated (QTT) in a
two-period difference-in-differences design following Callaway and Li (2019).

{pstd}
This is a {bf:skeleton} (version 0.0.1); the estimator is not implemented yet.
See {browse "docs/plans/2026-10-06-qdid-plan.md":docs/plans/2026-10-06-qdid-plan.md}.

{title:Options}

{pstd}
{cmd:unit(}{it:varname}{cmd:)}, {cmd:time(}{it:varname}{cmd:)}, {cmd:treat(}{it:varname}{cmd:)}
are required; see the spec for details.

{title:References}

{pstd}
Callaway, B., and T. Li. 2019. Quantile treatment effects in difference in
differences models with panel data. {it:Quantitative Economics} 10(4): 1579-1618.
