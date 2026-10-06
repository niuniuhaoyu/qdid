*! _test_stag.do - qdid staggered runs and returns a sensible QTT curve
version 16
clear all
set more off
adopath + "."

use "data/qdid_stag_sim.dta", clear
qdid y, unit(id) time(t) gvar(g) probs(0.1(0.1)0.9) iters(0)
matrix q = r(qtt)
assert rowsof(q) == 9
* QTT should be positive and roughly increasing in tau
assert q[5,2] > 0
assert q[9,2] > q[1,2]
di as result "median QTT = " %6.3f q[5,2]
di as result "QDID STAGGERED TEST PASS"
