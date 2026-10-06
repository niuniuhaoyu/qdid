# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added (v0.4.0)
- `gvar(varname)` option: staggered adoption (multiple treatment cohorts). Uses
  the two-pre-period copula-stability cell for each (g, t) with not-yet-treated
  controls, aggregated by cohort size. **Aggregation is an approximation of R
  `qte::panel_qtt_long_agg`** (which aggregates the F0/F1 distributions); here
  the cell QTT curves are averaged. Exact R parity for the staggered aggregation
  is future work.
- KNOWN ISSUE (staggered): the aggregation now follows R's method (combining the
  cell F0/F1 distributions), but the result is systematically ~0.13 higher than
  R `qte::panel_qtt(gt_type="qtt")` on the same small DGP; exact parity is an open
  item (see `examples/_test_stag_r.do`).

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
