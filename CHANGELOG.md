# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added (v0.4.0)
- `gvar(varname)` option: staggered adoption (multiple treatment cohorts). Uses
  the two-pre-period copula-stability cell for each (g, t) with not-yet-treated
  controls, aggregating the cell counterfactual distributions F0/F1 exactly as R
  `qte::panel_qtt_long_agg` (cohort-size weights).
- RESOLVED: an earlier apparent ~0.13 gap vs R `panel_qtt` turned out to be a
  **bug in R** — `qte:::three_period_subset` calls
  `subset(data, G == g | G > tp | G == 0)`; when the data has a column literally
  named `g`, `subset` resolves `g` to that column, so the not-yet-treated control
  filter silently breaks (all units become controls). Renaming the column (e.g.
  `gt`) makes R match Stata to ~0.03 (`examples/_test_stag_r.do`). See
  `docs/research-notes-r-bug-gsubset.md`.

### Added (v0.3.0)
- `covariates(varlist)` option: conditional QTT via propensity-score reweighting
  of the untreated change distribution (Callaway & Li 2019; matches R
  `qte::panel.qtet(method="pscore", xformla=~x)`, max |diff| ≈ 0.01).

### Added (v0.2.0)
- Bootstrap standard errors and percentile confidence intervals (`iters()`,
  `level()`), resampling units.
- Uniform confidence band (`cband`, sup-t over quantiles) via the bootstrap draws.

### Added (v0.1.0)
- `qdid` command: two-pre-period panel QTT via **copula stability** (Callaway &
  Li 2019). Counterfactual post outcome `kcf = L + C`; `QTT(τ) = Q_{Y_post|D=1}(τ)
  − Q_{kcf}(τ)`. Implemented in Mata (`qdid.mata`).
- Matched against R `qte::panel.qtet` on a three-period DGP (max |diff| ≈ 0.01;
  `examples/_test_qtt_recover.do`).
- Not yet: bootstrap/standard errors, uniform band, covariates, graphical plot
  polish, staggered adoption.

## [0.0.1]

### Added
- Repository skeleton and design spec / implementation plan.
