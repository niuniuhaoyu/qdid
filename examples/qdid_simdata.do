*! qdid_simdata.do - three-period panel DGP, known QTT(tau) = 0.5 + 0.5*invnormal(tau)
*! Run from the qdid/ package root.

version 16
clear all
set seed 20261006

set obs 2000
gen long id = _n
gen byte D = (_n <= 1000)                 // 1 = treated group
gen double mu = rnormal(0, 1)

* untreated potential outcomes: Y_it(0) = mu_i + a_t + e_it, e iid N(0,1)
gen double y1 = mu + 0.0 + rnormal(0, 1)
gen double y2 = mu + 0.2 + rnormal(0, 1)
gen double y3 = mu + 0.4 + rnormal(0, 1)

* individual treatment effect at t=3 for treated: tau ~ N(0.5, 0.5)
gen double tau = rnormal(0.5, 0.5)
replace y3 = y3 + tau if D == 1

keep id D y1 y2 y3
reshape long y, i(id) j(t)
gen byte treat = D
keep id t y treat
order id t y treat
sort id t

save "data/qdid_sim.dta", replace
export delimited id t y treat using "examples/reference/qdid_sim.csv", replace
display "wrote data/qdid_sim.dta and examples/reference/qdid_sim.csv"
