{smcl}
{* *! version 0.0.1  2026-10-06  Haoyu Niu}

{title:qdid --- Quantile treatment effects in difference-in-differences}

{title:Syntax}

{pstd}
{cmd:qdid} {it:depvar} {ifin}, {cmd:unit(}{it:varname}{cmd:)} {cmd:time(}{it:varname}{cmd:)}
        {cmd:treat(}{it:varname}{cmd:)} {cmd:probs(}{it:numlist}{cmd:)}
        {cmd:seed(#)} {cmd:graph}

{title:Description}

{pstd}
{cmd:qdid} estimates the quantile treatment effect on the treated (QTT) in a
difference-in-differences design with panel data, following Callaway and Li
(2019). It requires {bf:three periods} ({it:tmin2}, {it:tmin1}, {it:post}) and
constructs the treated group's untreated counterfactual post outcome via the
copula stability assumption.

{pstd}
The counterfactual is {cmd:kcf = L + C}, where {cmd:L} maps each treated unit's
rank in the pre2 outcome to the pre1 outcome distribution, and {cmd:C} maps its
rank in the treated pre-period change to the untreated post-period change
distribution. Then {cmd:QTT(tau) = Q_{Y_post|D=1}(tau) - Q_{kcf}(tau)}.

{pstd}
Version 0.1.0 implements this core estimator; bootstrap standard errors,
confidence bands, covariates, and staggered adoption are planned. See
{browse "docs/research-notes.md":docs/research-notes.md}.

{title:Options}

{pstd}
{cmd:unit(}{it:varname}{cmd:)}, {cmd:time(}{it:varname}{cmd:)}, {cmd:treat(}{it:varname}{cmd:)}
are required; see the spec for details.

{title:References}

{pstd}
Callaway, B., and T. Li. 2019. Quantile treatment effects in difference in
differences models with panel data. {it:Quantitative Economics} 10(4): 1579-1618.
