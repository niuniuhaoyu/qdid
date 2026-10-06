// qdid.mata - Callaway & Li (2019) panel QTT via copula stability
// Reference: R qte::compute.panel.qtet / qte::panel_qtt_gt / qte::panel_qtt_long_agg.
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

// quantile of the ECDF of v at probabilities p (type 1: smallest v with F(v) >= p)
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

// type-7 quantile (R default) of v at probabilities p
real colvector _qdid_q7(real colvector v, real colvector p)
{
    real scalar n, i, h, lo, hi, gg
    real colvector vs, out
    vs = sort(v, 1)
    n = rows(vs)
    out = J(rows(p), 1, 0)
    for (i = 1; i <= rows(p); i++) {
        h = (n - 1) * p[i] + 1
        lo = floor(h)
        hi = lo + 1
        if (hi > n) out[i] = vs[n]
        else {
            gg = h - lo
            out[i] = (1 - gg) * vs[lo] + gg * vs[hi]
        }
    }
    return(out)
}

// quantile (type 1) of a CDF given as (grid ys, values F)
real colvector _qdid_qcdf(real colvector ys, real colvector F, real colvector p)
{
    real scalar n, np, i, j
    real colvector out
    n = rows(ys); np = rows(p)
    out = J(np, 1, 0)
    for (i = 1; i <= np; i++) {
        out[i] = ys[n]
        for (j = 1; j <= n; j++) {
            if (F[j] >= p[i]) {
                out[i] = ys[j]
                break
            }
        }
    }
    return(out)
}

// core (unconditional): counterfactual Ypost(0) = kcf = L + C
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

// cell helper: return counterfactual kcf and treated post y3
void _qdid_cell(real colvector y1t, real colvector y2t, real colvector y3t,
                real colvector y2c, real colvector y3c,
                real colvector kcf, real colvector y3o)
{
    real colvector u, L, dYtrt, v, dYctrl, C
    u = _qdid_ecdf(y1t, y1t)
    L = _qdid_quantile(y2t, u)
    dYtrt = y2t - y1t
    v = _qdid_ecdf(dYtrt, dYtrt)
    dYctrl = y3c - y2c
    C = _qdid_quantile(dYctrl, v)
    kcf = L + C
    y3o = y3t
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
void _qdid_core_cov(real colvector y1, real colvector y2, real colvector y3,
                    real colvector D, real colvector ps, real colvector probs,
                    real colvector qtt)
{
    real colvector idx1, idx0, y1t, y2t, y3t
    real colvector u, L, dYtrt, v, dy_all, w_all, C, kcf
    real scalar nt, n0, pD1
    idx1 = selectindex(D :== 1)
    idx0 = selectindex(D :== 0)
    y1t = y1[idx1]; y2t = y2[idx1]; y3t = y3[idx1]
    nt = rows(y1t); n0 = rows(idx0)
    pD1 = nt / n0
    u = _qdid_ecdf(y1t, y1t)
    L = _qdid_quantile(y2t, u)
    dYtrt = y2t - y1t
    v = _qdid_ecdf(dYtrt, dYtrt)
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

// staggered adoption: aggregate the cell counterfactual distributions F0/F1 exactly
// as R qte::panel_qtt_long_agg (combine_ecdfs with cohort-size weights).
void _qdid_stag_run(string scalar yvars, string scalar gvname, string scalar tvalsname,
                    string scalar probsname)
{
    real matrix Y, out
    real colvector g, tvals, probs, cohorts, subidx, D, kcf, y3o
    real colvector y1, y2, y3, ip2, ip1, seqp, yseq, F0tot, F1tot, F0c, F1c, q0, q1
    real colvector ncells, ngsz, i1, i0
    real scalar n, T, np, c, ti, gg, p0, wi, i, ngrid
    Y = st_data(., yvars)
    g = st_data(., gvname)
    tvals = st_matrix(tvalsname)'
    probs = st_matrix(probsname)'
    n = rows(g); T = rows(tvals); np = rows(probs)

    // outcome grid: 1000 type-7 quantiles of all outcomes (as R)
    real colvector Yflat
    Yflat = vec(Y)
    Yflat = select(Yflat, Yflat :< .)
    seqp = J(1000, 1, 0)
    for (i = 1; i <= 1000; i++) seqp[i] = (i - 1) / 999
    yseq = _qdid_q7(Yflat, seqp)
    ngrid = rows(yseq)

    cohorts = uniqrows(select(g, g :> 0))
    ncells = J(rows(cohorts), 1, 0)
    ngsz = J(rows(cohorts), 1, 0)

    // pass 1: cohort sizes and valid-post-cell counts
    for (c = 1; c <= rows(cohorts); c++) {
        gg = cohorts[c]
        ngsz[c] = sum(g :== gg)
        for (ti = 1; ti <= T; ti++) {
            if (tvals[ti] < gg) continue
            ip2 = selectindex(tvals :== (2 * gg - tvals[ti] - 2))
            ip1 = selectindex(tvals :== (gg - 1))
            if (rows(ip2) == 0 | rows(ip1) == 0) continue
            subidx = selectindex((g :== gg) :| (g :> tvals[ti]) :| (g :== 0))
            D = (g[subidx] :== gg)
            if (sum(D) == 0 | sum(D :== 0) == 0) continue
            ncells[c] = ncells[c] + 1
        }
    }

    p0 = sum(select(ngsz, ncells :> 0))
    if (p0 == 0) {
        errprintf("qdid: no valid staggered (g,t) cells (need >=2 pre-periods)\n")
        _error(198)
    }

    F0tot = J(ngrid, 1, 0)
    F1tot = J(ngrid, 1, 0)
    for (c = 1; c <= rows(cohorts); c++) {
        if (ncells[c] == 0) continue
        wi = ngsz[c] / p0 / ncells[c]
        gg = cohorts[c]
        for (ti = 1; ti <= T; ti++) {
            if (tvals[ti] < gg) continue
            ip2 = selectindex(tvals :== (2 * gg - tvals[ti] - 2))
            ip1 = selectindex(tvals :== (gg - 1))
            if (rows(ip2) == 0 | rows(ip1) == 0) continue
            subidx = selectindex((g :== gg) :| (g :> tvals[ti]) :| (g :== 0))
            y1 = Y[subidx, ip2[1]]
            y2 = Y[subidx, ip1[1]]
            y3 = Y[subidx, ti]
            D = (g[subidx] :== gg)
            if (sum(D) == 0 | sum(D :== 0) == 0) continue
            i1 = selectindex(D :== 1)
            i0 = selectindex(D :== 0)
            _qdid_cell(y1[i1], y2[i1], y3[i1], y2[i0], y3[i0], kcf, y3o)
            F0c = _qdid_ecdf(kcf, yseq)
            F1c = _qdid_ecdf(y3o, yseq)
            F0tot = F0tot + wi * F0c
            F1tot = F1tot + wi * F1c
        }
    }
    q0 = _qdid_qcdf(yseq, F0tot, probs)
    q1 = _qdid_qcdf(yseq, F1tot, probs)
    out = J(np, 2, .)
    for (i = 1; i <= np; i++) {
        out[i,1] = probs[i]
        out[i,2] = q1[i] - q0[i]
    }
    st_matrix("qttmat", out)
}
end
