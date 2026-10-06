*! qdid_stagdgp.do - staggered 4-period panel, cohorts g=3, g=4, and never-treated
version 16
clear all
set seed 20261006

set obs 2000
gen long id = _n
gen double mu = rnormal(0, 1)
gen byte g = 0
replace g = 3 if _n <= 700
replace g = 4 if _n > 700 & _n <= 1400
gen double tau = rnormal(0.5, 0.5)

gen double y1 = mu + 0.0 + rnormal(0, 1)
gen double y2 = mu + 0.2 + rnormal(0, 1)
gen double y3 = mu + 0.4 + rnormal(0, 1)
gen double y4 = mu + 0.6 + rnormal(0, 1)
replace y3 = y3 + tau if g > 0 & g <= 3
replace y4 = y4 + tau if g > 0 & g <= 4

keep id g y1 y2 y3 y4
reshape long y, i(id) j(t)
keep id t y g
order id t y g
sort id t

save "data/qdid_stag_sim.dta", replace
display "wrote data/qdid_stag_sim.dta"
