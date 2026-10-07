version 16
clear all
set more off
adopath + "."
use "data/qdid_stag_small.dta", clear
qdid y, unit(id) time(t) gvar(g) probs(0.1(0.1)0.9) iters(100) seed(12345)
matrix q = r(qtt)
assert rowsof(q) == 9
assert colsof(q) == 5
forvalues k = 1/9 {
    assert q[`k',4] <= q[`k',2] + 1e-9
    assert q[`k',5] >= q[`k',2] - 1e-9
    assert q[`k',5] > q[`k',4]
}
di as result "QDID STAGGERED CI TEST PASS"
