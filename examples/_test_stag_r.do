*! _test_stag_r.do - qdid staggered vs R qte::panel_qtt (gname renamed to 'gt'
*! to avoid the R g-column-collision bug; see docs/research-notes-r-bug-gsubset.md)
version 16
clear all
set more off
adopath + "."

use "data/qdid_stag_small.dta", clear
qdid y, unit(id) time(t) gvar(g) probs(0.1(0.1)0.9) iters(0)
matrix q = r(qtt)

* R golden with gname='gt' (bug avoided)
local ref "0.3123 0.4978 0.4985 0.5651 0.5992 0.6262 0.6819 0.6438 0.6294"
di as text _n "  tau     R(gt)    qdid     |diff|"
local k = 0
local maxerr = 0
foreach r of local ref {
    local k = `k' + 1
    local est = q[`k',2]
    local e   = abs(`est' - `r')
    if `e' > `maxerr' local maxerr = `e'
    di as text %6.2f q[`k',1] "  " %8.4f `r' "  " %8.4f `est' "  " %8.4f `e'
}
di as result _n "max|Stata - R(gt)| = " %8.5f `maxerr'
assert `maxerr' < 0.05
di as result "QDID STAGGERED vs R TEST PASS"
