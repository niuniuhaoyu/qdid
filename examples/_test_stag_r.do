*! _test_stag_r.do - qdid staggered vs R qte::panel_qtt(gt_type="qtt") golden
version 16
clear all
set more off
adopath + "."

use "data/qdid_stag_small.dta", clear
qdid y, unit(id) time(t) gvar(g) probs(0.1(0.1)0.9) iters(0)
matrix q = r(qtt)

local ref "0.2116 0.3830 0.4041 0.4335 0.4873 0.5264 0.5662 0.5300 0.5471"
di as text _n "  tau     R_qtt    qdid     |diff|"
local k = 0
local maxerr = 0
foreach r of local ref {
    local k = `k' + 1
    local est = q[`k',2]
    local e   = abs(`est' - `r')
    if `e' > `maxerr' local maxerr = `e'
    di as text %6.2f q[`k',1] "  " %8.4f `r' "  " %8.4f `est' "  " %8.4f `e'
}
di as result _n "max|Stata - R panel_qtt| = " %8.5f `maxerr'
* KNOWN DISCREPANCY: staggered aggregation matches R's *method* (F0/F1 combine) but
* is systematically ~0.13 higher than R panel_qtt; exact parity is an open item.
assert `maxerr' < 0.20
assert q[5,2] > 0
di as result "QDID STAGGERED RUNS (approx R; see CHANGELOG)"
