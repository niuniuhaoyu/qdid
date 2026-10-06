suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
res <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=seq(0.1,0.9,0.1), gt_type="qtt", pre_copula="long", cband=FALSE, biters=10)
cat("names(res$ptep):", paste(names(res$ptep), collapse=", "), "\n")
al <- res$ptep$attgt.list
cat("n cells:", length(al), "\n")
for (i in seq_along(al)) {
  r <- al[[i]]
  egr <- r$extra_gt_returns
  qtt <- NULL
  if (!is.null(egr) && !is.null(egr$F0) && !is.null(egr$F1)) {
    qtt <- round(quantile(egr$F1, probs=seq(0.1,0.9,0.1), type=1) -
                 quantile(egr$F0, probs=seq(0.1,0.9,0.1), type=1), 4)
  }
  cat(sprintf("cell g=%s t=%s att=%.4f  qtt=%s\n", r$group, r$time.period,
              ifelse(is.null(r$att), NA, r$att), paste(qtt, collapse=",")))
}
