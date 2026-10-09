# qdid

[English](README.md) | [简体中文](README_zh.md)

**Quantile treatment effects in difference-in-differences, for Stata**

[![Stata 16+](https://img.shields.io/badge/Stata-16%2B-blue.svg)](https://www.stata.com/)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

> Status: **v0.4.2** (2026-10-07) — two-pre-period QTT via copula stability,
> bootstrap pointwise intervals, a uniform confidence band (`cband`), conditional
> QTT (`covariates()`), and staggered adoption (`gvar()`). Cross-validated
> against R `qte` (core ≈ 0.01; covariates ≈ 0.01; staggered ≈ 0.03).
> Design: [`docs/specs/2026-10-06-qdid-design.md`](docs/specs/2026-10-06-qdid-design.md)
> Plan: [`docs/plans/2026-10-06-qdid-plan.md`](docs/plans/2026-10-06-qdid-plan.md)
> Notes: [`docs/research-notes.md`](docs/research-notes.md)

`qdid` implements the **quantile treatment effect on the treated (QTT)** of
Callaway & Li (2019), *Quantile treatment effects in difference in differences
models with panel data*, Quantitative Economics 10(4): 1579-1618.

Average DiD gives one number; `qdid` gives an effect for each quantile of the
treated outcome distribution. Stata ships general-purpose quantile tools
(`ivqte`, `qte`, `rifhdreg`) but no modern, unified DiD-QTT command.

## Installation

```stata
net install qdid, from("https://raw.githubusercontent.com/niuniuhaoyu/qdid/main/") replace
```

## Syntax

```stata
qdid y, unit(id) time(t) treat(d) [probs(0.1(0.1)0.9) iters(200) level(95) ///
    seed(12345) cband graph]

* conditional QTT with covariates (propensity-score reweighting)
qdid y, unit(id) time(t) treat(d) covariates(x1 x2) probs(0.1(0.1)0.9)

* staggered adoption (g = first treatment period, 0 = never treated)
qdid y, unit(id) time(t) gvar(g) probs(0.1(0.1)0.9)
```

Requires **three periods** (`tmin2`, `tmin1`, `post`); `treat` is the group
indicator (1 = treated).

## Features

- **QTT(τ)**: counterfactual post outcome `kcf = L + C` via copula stability,
  then `QTT(τ) = Q_{Y_post|D=1}(τ) − Q_{kcf}(τ)`; selectable quantile grid.
- **Inference**: cluster-bootstrap pointwise intervals and a uniform confidence
  band (`cband`, sup-t over quantiles) via multiplier bootstrap.
- **Conditional QTT**: `covariates()` — conditional distributional parallel
  trends via propensity-score reweighting (Callaway & Li, Proposition 1).
- **Staggered adoption**: `gvar()` — multiple treatment cohorts aggregated as in
  R `qte::panel_qtt_long_agg` (not-yet-treated controls), with bootstrap
  standard errors and percentile intervals.
- **Graph**: `graph` draws the QTT(τ) curve.

## Verification (against R `qte`)

| Design | max &#124;diff&#124; vs R `qte` |
|---|---|
| Core QTT (two pre-periods) | 0.0095 |
| Conditional QTT (`covariates()`, pscore) | 0.0105 |
| Staggered (per-cell) | ≈ 0.012 |
| Staggered (aggregated, after renaming R's `g` column) | ≈ 0.03 |

The apparent staggered gap vs R was traced to a **bug in R `qte`**
(`qte:::three_period_subset`'s `subset(data, G == g | ...)` resolves `g` to a
data column named `g`, so the not-yet-treated control filter silently breaks).
See [`docs/research-notes-r-bug-gsubset.md`](docs/research-notes-r-bug-gsubset.md).

## Citation

Method:

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

## License

AGPL-3.0
