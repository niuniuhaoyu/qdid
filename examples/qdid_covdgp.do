*! qdid_covdgp.do - three-period panel DGP WITH a covariate x (selection on x)
version 16
clear all
set seed 20261006

set obs 2000
gen long id = _n
gen double x = rnormal(0, 1)
gen double pD = invlogit(0.5 * x)
gen byte D = runiform() < pD
gen double mu = rnormal(0, 1)

gen double y1 = mu + 0.0 + rnormal(0, 1)
gen double y2 = mu + 0.2 + rnormal(0, 1)
gen double y3 = mu + 0.4 + rnormal(0, 1)
gen double tau = rnormal(0.5, 0.5)
replace y3 = y3 + tau if D == 1

keep id D x y1 y2 y3
reshape long y, i(id) j(t)
gen byte treat = D
keep id t y treat x
order id t y treat x
sort id t

save "data/qdid_cov_sim.dta", replace
export delimited id t y treat x using "examples/reference/qdid_cov_sim.csv", replace
display "wrote data/qdid_cov_sim.dta"
