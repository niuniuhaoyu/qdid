*! _test_qtt_ci.do - qdid point estimate + bootstrap CI runs and covers point est
version 16
clear all
set more off
adopath + "."

use "data/qdid_sim.dta", clear
qdid y, unit(id) time(t) treat(treat) probs(0.1(0.1)0.9) iters(200) seed(12345)
matrix q = r(qtt)

assert rowsof(q) == 9
assert colsof(q) == 5
* CI must contain the point estimate
forvalues k = 1/9 {
    assert q[`k',4] <= q[`k',2] + 1e-9
    assert q[`k',5] >= q[`k',2] - 1e-9
    assert q[`k',5] > q[`k',4]
    assert q[`k',3] > 0
}
* point estimate still matches R qte
assert abs(q[1,2] - 0.184393) < 0.05
di as result "QDID CI TEST PASS"
