# qdid

**Quantile treatment effects in difference-in-differences, for Stata**

> Status: **v0.1.0** — core two-pre-period QTT (copula stability) implemented and
> matched to R `qte::panel.qtet` (max |diff| ≈ 0.01); bootstrap/CIs pending.
> Design: [`docs/specs/2026-10-06-qdid-design.md`](docs/specs/2026-10-06-qdid-design.md)
> Plan: [`docs/plans/2026-10-06-qdid-plan.md`](docs/plans/2026-10-06-qdid-plan.md)
> Notes: [`docs/research-notes.md`](docs/research-notes.md)

`qdid` implements the **quantile treatment effect on the treated (QTT)** of
Callaway & Li (2019), *Quantile treatment effects in difference in differences
models with panel data*, Quantitative Economics 10(4): 1579-1618.

Average DiD gives one number; `qdid` gives an effect for each quantile of the
treated outcome distribution. Stata currently ships general-purpose quantile
tools (`ivqte`, `qte`, `rifhdreg`) but no modern, unified DiD-QTT command.

## Installation

```stata
net install qdid, from("https://raw.githubusercontent.com/niuniuhaoyu/qdid/main/") replace
```

(Repository not published yet — for now, add the local folder to `adopath`.)

## Syntax

```stata
qdid y, unit(id) time(t) treat(d) probs(0.1(0.1)0.9) iters(200) cband graph

* conditional QTT with covariates (via propensity-score reweighting)
qdid y, unit(id) time(t) treat(d) covariates(x1 x2) probs(0.1(0.1)0.9)
```

Requires **three periods** (`tmin2`, `tmin1`, `post`); `treat` is the group
indicator (1 = treated). Implemented estimator: counterfactual post outcome
`kcf = L + C` via copula stability, then `QTT(τ) = Q_{Y_post|D=1}(τ) − Q_{kcf}(τ)`.

## Plan

See [`docs/plans/2026-10-06-qdid-plan.md`](docs/plans/2026-10-06-qdid-plan.md):
research → DGP → QTT point estimate + bootstrap CI → uniform band → covariates
→ docs/release.

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
