// qdid.mata - Callaway & Li (2019) panel QTT via copula stability
// Reference: R qte::compute.panel.qtet (method="pscore", x=NULL).
mata:

// ECDF of v evaluated at each x
real colvector _qdid_ecdf(real colvector v, real colvector x)
{
    real scalar n, i
    real colvector out
    n = rows(v)
    out = J(rows(x), 1, 0)
    for (i = 1; i <= rows(x); i++) out[i] = sum(v :<= x[i]) / n
    return(out)
}

// quantile of the ECDF of v at probabilities p (unweighted)
real colvector _qdid_quantile(real colvector v, real colvector p)
{
    real scalar n, i, j
    real colvector vs, Fj, out
    vs = sort(v, 1)
    n = rows(vs)
    Fj = J(n, 1, 0)
    for (j = 1; j <= n; j++) Fj[j] = sum(v :<= vs[j]) / n
    out = J(rows(p), 1, 0)
    for (i = 1; i <= rows(p); i++) {
        out[i] = vs[n]
        for (j = 1; j <= n; j++) {
            if (Fj[j] >= p[i]) {
                out[i] = vs[j]
                break
            }
        }
    }
    return(out)
}

// core: QTT(probs) with a counterfactual Ypost(0) = kcf = L + C
void _qdid_core(real colvector y1t, real colvector y2t, real colvector y3t,
                real colvector y2c, real colvector y3c, real colvector probs,
                real colvector qtt)
{
    real colvector u, L, dYtrt, v, dYctrl, C, kcf
    u = _qdid_ecdf(y1t, y1t)
    L = _qdid_quantile(y2t, u)
    dYtrt = y2t - y1t
    v = _qdid_ecdf(dYtrt, dYtrt)
    dYctrl = y3c - y2c
    C = _qdid_quantile(dYctrl, v)
    kcf = L + C
    qtt = _qdid_quantile(y3t, probs) - _qdid_quantile(kcf, probs)
}

void _qdid_run(string scalar yvars, string scalar treatname, string scalar probsname)
{
    real matrix Yw, probsm, out
    real colvector D, y1, y2, y3, probs, idx1, idx0, qtt, y1t, y2t, y3t, y2c, y3c
    real scalar m, i
    Yw = st_data(., yvars)
    D = st_data(., treatname)
    probs = st_matrix(probsname)'
    y1 = Yw[.,1]; y2 = Yw[.,2]; y3 = Yw[.,3]
    idx1 = selectindex(D :== 1)
    idx0 = selectindex(D :== 0)
    y1t = y1[idx1]; y2t = y2[idx1]; y3t = y3[idx1]
    y2c = y2[idx0]; y3c = y3[idx0]
    _qdid_core(y1t, y2t, y3t, y2c, y3c, probs, qtt)
    m = rows(probs)
    out = J(m, 2, .)
    for (i = 1; i <= m; i++) {
        out[i,1] = probs[i]
        out[i,2] = qtt[i]
    }
    st_matrix("qttmat", out)
}

// weighted quantile of a weighted distribution (values vals, weights w) at probs p
real colvector _qdid_wquantile(real colvector vals, real colvector w, real colvector p)
{
    real scalar n, i, j, cw
    real matrix M
    real colvector out, vs, ws, cdf
    n = rows(vals)
    M = sort((vals, w), 1)
    vs = M[.,1]; ws = M[.,2]
    cdf = J(n, 1, 0)
    cw = 0
    for (j = 1; j <= n; j++) {
        cw = cw + ws[j]
        cdf[j] = cw
    }
    cdf = cdf / cw
    out = J(rows(p), 1, 0)
    for (i = 1; i <= rows(p); i++) {
        out[i] = vs[n]
        for (j = 1; j <= n; j++) {
            if (cdf[j] >= p[i]) {
                out[i] = vs[j]
                break
            }
        }
    }
    return(out)
}

// core with covariates (R qte::compute.panel.qtet, method="pscore", x != NULL)
// C is drawn from the IPW-weighted untreated post-change distribution.
void _qdid_core_cov(real colvector y1, real colvector y2, real colvector y3,
                    real colvector D, real colvector ps, real colvector probs,
                    real colvector qtt)
{
    real colvector idx1, idx0, y1t, y2t, y3t, y2c, y3c
    real colvector u, L, dYtrt, v, dy_all, w_all, C, kcf
    real scalar nt, n0, pD1
    idx1 = selectindex(D :== 1)
    idx0 = selectindex(D :== 0)
    y1t = y1[idx1]; y2t = y2[idx1]; y3t = y3[idx1]
    nt = rows(y1t); n0 = rows(idx0)
    pD1 = nt / n0

    // L = quantile of treated pre1 at rank of treated pre2
    u = _qdid_ecdf(y1t, y1t)
    L = _qdid_quantile(y2t, u)
    // v = rank of treated pre-change
    dYtrt = y2t - y1t
    v = _qdid_ecdf(dYtrt, dYtrt)
    // IPW-weighted untreated post-change distribution
    dy_all = y3 - y2
    w_all = (1 :- D) :* ps :/ ((1 :- ps) :* pD1)
    C = _qdid_wquantile(dy_all, w_all, v)
    kcf = L + C
    qtt = _qdid_quantile(y3t, probs) - _qdid_quantile(kcf, probs)
}

void _qdid_run_cov(string scalar yvars, string scalar treatname, string scalar probsname)
{
    real matrix Yw, probsm, out
    real colvector D, y1, y2, y3, ps, probs, qtt
    real scalar m, i
    Yw = st_data(., yvars)
    D = st_data(., treatname)
    ps = st_data(., "_pscore")
    probs = st_matrix(probsname)'
    y1 = Yw[.,1]; y2 = Yw[.,2]; y3 = Yw[.,3]
    _qdid_core_cov(y1, y2, y3, D, ps, probs, qtt)
    m = rows(probs)
    out = J(m, 2, .)
    for (i = 1; i <= m; i++) {
        out[i,1] = probs[i]
        out[i,2] = qtt[i]
    }
    st_matrix("qttmat", out)
}

// staggered adoption: group-time QTT cells (copula stability) + cohort-size-weighted aggregation.
// NOTE: this aggregation is an approximation of R qte::panel_qtt_long_agg (which aggregates
// the counterfactual distributions F0/F1); here we average the cell QTT curves.
void _qdid_stag_run(string scalar yvars, string scalar gvname, string scalar tvalsname,
                    string scalar probsname)
{
    real matrix Y, out
    real colvector g, tvals, probs, cohorts, subidx, D, qtt_agg, qtt_cell, idx1, idx0
    real colvector y1, y2, y3, y1t, y2t, y3t, y2c, y3c
    real scalar n, T, np, c, ti, gg, pre1, pre2, wi, wsum
    real colvector ip2, ip1
    Y = st_data(., yvars)
    g = st_data(., gvname)
    tvals = st_matrix(tvalsname)'
    probs = st_matrix(probsname)'
    n = rows(g); T = rows(tvals); np = rows(probs)
    qtt_agg = J(np, 1, 0)
    wsum = 0
    cohorts = uniqrows(select(g, g :> 0))
    for (c = 1; c <= rows(cohorts); c++) {
        gg = cohorts[c]
        for (ti = 1; ti <= T; ti++) {
            if (tvals[ti] < gg) continue
            pre1 = gg - 1
            pre2 = 2 * gg - tvals[ti] - 2
            ip2 = selectindex(tvals :== pre2)
            ip1 = selectindex(tvals :== pre1)
            if (rows(ip2) == 0 | rows(ip1) == 0) continue
            subidx = selectindex((g :== gg) :| (g :> tvals[ti]) :| (g :== 0))
            y1 = Y[subidx, ip2[1]]
            y2 = Y[subidx, ip1[1]]
            y3 = Y[subidx, ti]
            D = (g[subidx] :== gg)
            idx1 = selectindex(D :== 1)
            idx0 = selectindex(D :== 0)
            if (rows(idx1) == 0 | rows(idx0) == 0) continue
            y1t = y1[idx1]; y2t = y2[idx1]; y3t = y3[idx1]
            y2c = y2[idx0]; y3c = y3[idx0]
            _qdid_core(y1t, y2t, y3t, y2c, y3c, probs, qtt_cell)
            wi = sum(g :== gg)
            qtt_agg = qtt_agg + wi * qtt_cell
            wsum = wsum + wi
        }
    }
    if (wsum == 0) {
        errprintf("qdid: no valid staggered (g,t) cells (need >=2 pre-periods)\n")
        _error(198)
    }
    qtt_agg = qtt_agg / wsum
    out = J(np, 2, .)
    for (c = 1; c <= np; c++) {
        out[c,1] = probs[c]
        out[c,2] = qtt_agg[c]
    }
    st_matrix("qttmat", out)
}
end
