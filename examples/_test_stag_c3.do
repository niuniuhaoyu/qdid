version 16
clear all
set more off
adopath + "."
use "data/qdid_stag_small.dta", clear
keep if g == 0 | g == 3
qdid y, unit(id) time(t) gvar(g) probs(0.1(0.1)0.9) iters(0)
matrix q = r(qtt)
local ref "0.3859 0.3514 0.5897 0.6694 0.5952 0.7272 0.4845 0.5012 0.4043"
di as text _n "  tau     R_c3     qdid     |diff|"
local k = 0
local maxerr = 0
foreach r of local ref {
    local k = `k' + 1
    local e = abs(q[`k',2] - `r')
    if `e' > `maxerr' local maxerr = `e'
    di as text %6.2f q[`k',1] "  " %8.4f `r' "  " %8.4f q[`k',2] "  " %8.4f `e'
}
di as result _n "single-cohort max|diff| = " %8.5f `maxerr'
