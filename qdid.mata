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
end
