*! qdid_stagdgp_small.do - small staggered panel: T=5, cohorts g=3,4,5 + never, n=600
version 16
clear all
set seed 20261006

set obs 600
gen long id = _n
gen double mu = rnormal(0, 1)
gen byte g = 0
replace g = 3 if _n <= 150
replace g = 4 if _n > 150  & _n <= 300
replace g = 5 if _n > 300  & _n <= 450
gen double tau = rnormal(0.5, 0.5)

forvalues t = 1/5 {
    gen double y`t' = mu + 0.1*`t' + rnormal(0, 1)
    replace y`t' = y`t' + tau if g > 0 & g <= `t'
}

keep id g y1 y2 y3 y4 y5
reshape long y, i(id) j(t)
keep id t y g
order id t y g
sort id t

save "data/qdid_stag_small.dta", replace
export delimited id t y g using "examples/reference/qdid_stag_small.csv", replace
display "wrote data/qdid_stag_small.dta"
