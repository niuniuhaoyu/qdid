*! qdid: Quantile Treatment Effects in Difference-in-Differences
*! version 0.1.0  2026-10-06  Haoyu Niu
*! Two-pre-period panel QTT via copula stability (Callaway & Li 2019).

program define qdid, rclass
    version 16

    syntax varlist(max=1 numeric) [if] [in], ///
        unit(varname numeric) ///            individual id
        time(varname numeric) ///            time (three periods: tmin2, tmin1, post)
        treat(varname numeric) ///           binary group indicator (1 = treated)
        [probs(numlist) ///                  quantile grid (default 0.05(0.05)0.95)
         seed(integer 12345) ///             RNG seed
         GRaph]                              // QTT plot

    local depvar `varlist'
    marksample touse
    preserve
    qui keep if `touse'

    * ---------- validation ----------
    qui levelsof `time', local(tvals)
    local T : word count `tvals'
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

    * ---------- estimate ----------
    mata: _qdid_run("`yvars'", "`treat'", "_probs")

    matrix _qtt = qttmat
    matrix colnames _qtt = prob QTT
    matrix drop qttmat

    di as text _n "Quantile treatment effect on the treated (QTT)"
    di as text    "Callaway & Li (2019), copula stability; three periods"
    matlist _qtt, border(rows) format(%9.4f)

    if "`graph'" != "" {
        qui clear
        qui set obs `: rowsof(_qtt)'
        gen double prob = .
        gen double qtt  = .
        forvalues k = 1/`: rowsof(_qtt)' {
            qui replace prob = _qtt[`k',1] in `k'
            qui replace qtt  = _qtt[`k',2] in `k'
        }
        twoway (connected qtt prob, lcolor(navy) mcolor(navy)), ///
            title("Quantile treatment effect on the treated") ///
            xtitle("Quantile") ytitle("QTT") yline(0, lpattern(dash))
    }

    return matrix qtt = _qtt
    restore
end
