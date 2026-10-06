*! _test_qtt_cband.do - qdid uniform confidence band (sup-t)
version 16
clear all
set more off
adopath + "."

use "data/qdid_sim.dta", clear
qdid y, unit(id) time(t) treat(treat) probs(0.1(0.1)0.9) iters(200) seed(12345) cband
matrix cb = r(cb)
assert rowsof(cb) == 9
forvalues k = 1/9 {
    assert cb[`k',3] <= cb[`k',2] + 1e-9
    assert cb[`k',4] >= cb[`k',2] - 1e-9
    assert cb[`k',4] > cb[`k',3]
}
di as result "crit_att = " %6.4f r(crit)
di as result "QDID CBAND TEST PASS"
