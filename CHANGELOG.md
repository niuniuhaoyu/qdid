# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

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
