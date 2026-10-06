*! _test_qtt_recover.do - qdid vs R qte::panel.qtet (Callaway-Li) golden values
*! R golden from examples/reference/run_qte_check.R
version 16
clear all
set more off
adopath + "."

use "data/qdid_sim.dta", clear
qdid y, unit(id) time(t) treat(treat) probs(0.1(0.1)0.9)
matrix q = r(qtt)

local ref "0.184393 0.289571 0.472557 0.486753 0.475279 0.605136 0.663548 0.692485 0.757531"
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
di as result _n "max|Stata - R qte| = " %8.5f `maxerr'
assert `maxerr' < 0.05
di as result "QDID vs R qte TEST PASS"
