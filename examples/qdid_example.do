*! qdid_example.do - one-click example: QTT with uniform band + plot
version 16
clear all
set more off
adopath + "."

use "data/qdid_sim.dta", clear
qdid y, unit(id) time(t) treat(treat) probs(0.1(0.1)0.9) iters(300) seed(12345) cband graph
graph export "examples/qdid_qtt.png", width(1200) replace
di as result "wrote examples/qdid_qtt.png"
