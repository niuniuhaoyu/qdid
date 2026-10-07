*! qdid: Quantile Treatment Effects in Difference-in-Differences
*! version 0.2.0  2026-10-06  Haoyu Niu
*! Two-pre-period panel QTT via copula stability (Callaway & Li 2019).

program define qdid, rclass
    version 16

    syntax varlist(max=1 numeric) [if] [in], ///
        unit(varname numeric) ///            individual id
        time(varname numeric) ///            time (three periods: tmin2, tmin1, post)
        [treat(varname numeric) ///          binary group indicator (1 = treated)
         gvar(varname numeric) ///           first treatment period (0=never); enables staggered
         covariates(varlist) ///             covariates (conditional, via propensity score)
         probs(numlist) ///                  quantile grid (default 0.05(0.05)0.95)
         iters(integer 100) ///              bootstrap replications (0 = none)
         level(real 95) ///                  confidence level (%)
         seed(integer 12345) ///             RNG seed
         cband ///                            uniform confidence band (sup-t)
         GRaph]                              // QTT plot

    local depvar `varlist'
    marksample touse
    preserve
    qui keep if `touse'

    * ---------- validation ----------
    qui levelsof `time', local(tvals)
    local T : word count `tvals'
    if "`gvar'" == "" {
        if "`treat'" == "" {
            di as error "qdid: treat() is required for the two-period design"
            exit 198
        }
        if `T' != 3 {
            di as error "qdid: requires exactly three periods (tmin2, tmin1, post); found `T'"
            exit 198
        }
        qui count if `treat' != 0 & `treat' != 1
        if r(N) > 0 {
            di as error "qdid: treat() must be binary (0/1)"
            exit 198
        }
        qui levelsof `treat', local(dvals)
        if `: word count `dvals'' != 2 {
            di as error "qdid: treat() must take both 0 and 1"
            exit 198
        }
    }
    else {
        if "`covariates'" != "" {
            di as error "qdid: covariates() with gvar() (staggered) is not supported"
            exit 198
        }
        qui count if `gvar' < 0
        if r(N) > 0 {
            di as error "qdid: gvar() must be >= 0 (0 = never treated)"
            exit 198
        }
    }

    if "`probs'" == "" local probs "0.05(0.05)0.95"
    local probs_list ""
    foreach p of numlist `probs' {
        local probs_list "`probs_list' `p'"
    }
    local np : word count `probs_list'
    matrix _probs = J(1, `np', .)
    local ip = 0
    foreach p of local probs_list {
        local ip = `ip' + 1
        matrix _probs[1,`ip'] = `p'
    }

    * ---------- staggered adoption path ----------
    if "`gvar'" != "" {
        local Tn : word count `tvals'
        matrix _tvals = J(1, `Tn', .)
        local it = 0
        foreach tv of numlist `tvals' {
            local it = `it' + 1
            matrix _tvals[1,`it'] = `tv'
        }
        qui reshape wide `depvar', i(`unit') j(`time')
        local yvars ""
        foreach tv of local tvals {
            local yvars "`yvars' `depvar'`tv'"
        }
        capture mata: _qdid_ecdf(J(2,1,0), J(1,1,0))
        if _rc {
            findfile "qdid.mata"
            qui do "`r(fn)'"
        }
        mata: _qdid_stag_run("`yvars'", "`gvar'", "_tvals", "_probs")
        matrix _qtt = qttmat
        matrix _full = J(`np', 5, .)
        forvalues k = 1/`np' {
            matrix _full[`k',1] = _qtt[`k',1]
            matrix _full[`k',2] = _qtt[`k',2]
        }
        if `iters' > 0 {
            tempfile est
            qui save `est'
            matrix boot = J(`iters', `np', .)
            set seed `seed'
            forvalues b = 1/`iters' {
                qui use `est', clear
                qui bsample
                mata: _qdid_stag_run("`yvars'", "`gvar'", "_tvals", "_probs")
                matrix _qb = qttmat
                forvalues k = 1/`np' {
                    matrix boot[`b',`k'] = _qb[`k',2]
                }
            }
            qui use `est', clear
            local plo = (100 - `level') / 2
            local phi = 100 - `plo'
            svmat boot, names(bb_)
            forvalues k = 1/`np' {
                qui summarize bb_`k'
                matrix _full[`k',3] = r(sd)
                qui centile bb_`k', centile(`plo' `phi')
                matrix _full[`k',4] = r(c_1)
                matrix _full[`k',5] = r(c_2)
            }
        }
        matrix colnames _full = prob QTT se lb ub
        di as text _n "Quantile treatment effect on the treated (QTT), staggered"
        if `iters' > 0 di as text "bootstrap: `iters' reps, `level'% percentile CI"
        matlist _full, border(rows) format(%9.4f)
        return matrix qtt = _full
        restore
        exit
    }

    if "`covariates'" != "" {
        local tmin2 : word 1 of `tvals'
        qui logit `treat' `covariates' if `time' == `tmin2'
        qui predict double _pscore
    }

    qui reshape wide `depvar', i(`unit') j(`time')
    local yvars ""
    foreach tv of local tvals {
        local yvars "`yvars' `depvar'`tv'"
    }

    * ---------- load Mata ----------
    capture mata: _qdid_ecdf(J(2,1,0), J(1,1,0))
    if _rc {
        findfile "qdid.mata"
        qui do "`r(fn)'"
    }

    * ---------- point estimate ----------
    if "`covariates'" == "" {
        mata: _qdid_run("`yvars'", "`treat'", "_probs")
    }
    else {
        mata: _qdid_run_cov("`yvars'", "`treat'", "_probs")
    }
    matrix _qtt = qttmat

    * ---------- bootstrap (resample units) ----------
    matrix _full = J(`np', 5, .)
    forvalues k = 1/`np' {
        matrix _full[`k',1] = _qtt[`k',1]
        matrix _full[`k',2] = _qtt[`k',2]
    }
    if `iters' > 0 {
        tempfile est
        qui save `est'
        matrix boot = J(`iters', `np', .)
        set seed `seed'
        forvalues b = 1/`iters' {
            qui use `est', clear
            qui bsample
            if "`covariates'" == "" {
                mata: _qdid_run("`yvars'", "`treat'", "_probs")
            }
            else {
                mata: _qdid_run_cov("`yvars'", "`treat'", "_probs")
            }
            matrix _qb = qttmat
            forvalues k = 1/`np' {
                matrix boot[`b',`k'] = _qb[`k',2]
            }
        }
        qui use `est', clear
        local plo = (100 - `level') / 2
        local phi = 100 - `plo'
        svmat boot, names(bb_)
        forvalues k = 1/`np' {
            qui summarize bb_`k'
            matrix _full[`k',3] = r(sd)
            qui centile bb_`k', centile(`plo' `phi')
            matrix _full[`k',4] = r(c_1)
            matrix _full[`k',5] = r(c_2)
        }
    }

    matrix colnames _full = prob QTT se lb ub

    * ---------- uniform confidence band (sup-t) ----------
    if "`cband'" != "" {
        if `iters' == 0 {
            di as error "qdid: cband requires iters() > 0"
            exit 198
        }
        matrix _sup = J(`iters', 1, .)
        forvalues b = 1/`iters' {
            local mx = 0
            forvalues k = 1/`np' {
                local t = (boot[`b',`k'] - _full[`k',2]) / _full[`k',3]
                if abs(`t') > `mx' local mx = abs(`t')
            }
            matrix _sup[`b',1] = `mx'
        }
        svmat _sup, names(sup_)
        qui centile sup_1, centile(`level')
        local crit = r(c_1)
        matrix _cb = J(`np', 4, .)
        forvalues k = 1/`np' {
            matrix _cb[`k',1] = _full[`k',1]
            matrix _cb[`k',2] = _full[`k',2]
            matrix _cb[`k',3] = _full[`k',2] - `crit' * _full[`k',3]
            matrix _cb[`k',4] = _full[`k',2] + `crit' * _full[`k',3]
        }
        matrix colnames _cb = prob QTT cb_lb cb_ub
        di as text _n "Uniform confidence band (sup-t): crit = " %6.4f `crit'
        matlist _cb, border(rows) format(%9.4f)
        return matrix cb = _cb
        return scalar crit = `crit'
    }

    di as text _n "Quantile treatment effect on the treated (QTT)"
    di as text    "Callaway & Li (2019), copula stability; three periods"
    if `iters' > 0 {
        di as text "bootstrap: `iters' reps, `level'% percentile CI"
    }
    matlist _full, border(rows) format(%9.4f)

    * ---------- graph ----------
    if "`graph'" != "" {
        qui clear
        qui set obs `np'
        gen double prob = .
        gen double qtt  = .
        gen double lb   = .
        gen double ub   = .
        forvalues k = 1/`np' {
            qui replace prob = _full[`k',1] in `k'
            qui replace qtt  = _full[`k',2] in `k'
            qui replace lb   = _full[`k',4] in `k'
            qui replace ub   = _full[`k',5] in `k'
        }
        twoway (rarea lb ub prob, color(gs13)) ///
               (connected qtt prob, lcolor(navy) mcolor(navy)), ///
            title("Quantile treatment effect on the treated") ///
            xtitle("Quantile") ytitle("QTT") yline(0, lpattern(dash))
    }

    return matrix qtt = _full
    restore
end
