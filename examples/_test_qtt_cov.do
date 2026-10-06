*! _test_qtt_cov.do - qdid covariates (pscore) vs R qte golden values
version 16
clear all
set more off
adopath + "."

use "data/qdid_cov_sim.dta", clear
qdid y, unit(id) time(t) treat(treat) covariates(x) probs(0.1(0.1)0.9) iters(0)
matrix q = r(qtt)

local ref "0.332265 0.270932 0.402322 0.408343 0.385112 0.428671 0.477755 0.402814 0.499806"
di as text _n "  tau     R_qte    qdid     |diff|"
local k = 0
local maxerr = 0
foreach r of local ref {
    local k = `k' + 1
    local est = q[`k',2]
    local e   = abs(`est' - `r')
    if `e' > `maxerr' local maxerr = `e'
    di as text %6.2f q[`k',1] "  " %8.5f `r' "  " %8.5f `est' "  " %8.5f `e'
}
di as result _n "max|Stata(cov) - R qte(pscore)| = " %8.5f `maxerr'
assert `maxerr' < 0.06
di as result "QDID COVARIATES TEST PASS"
