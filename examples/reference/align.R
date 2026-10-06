suppressMessages({library(qte); library(haven); library(ptetools)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
probs <- seq(0.1,0.9,0.1)

myagg <- function(attgt.list, ptep, extra_gt_returns) {
  cat("=== alignment check: attgt.list vs extra_gt_returns ===\n")
  for (k in seq_along(attgt.list)) {
    g <- attgt.list[[k]]$group; tp <- attgt.list[[k]]$time.period
    att <- attgt.list[[k]]$att
    eg <- extra_gt_returns[[k]]$extra_gt_returns
    mf <- if (!is.null(eg$F0)) mean(eg$F1) - mean(eg$F0) else NA
    cat(sprintf("k=%d (g=%d,tp=%d) att=%s  mean(F1-F0)=%s  F0med=%s\n",
        k, g, tp, round(att,4), round(mf,4),
        ifelse(is.null(eg$F0), NA, round(quantile(eg$F0,0.5),4))))
  }
  qte:::panel_qtt_long_agg(attgt.list, ptep, extra_gt_returns)
}
res <- ptetools::pte(yname="y", gname="g", tname="t", idname="id", data=df, panel=TRUE,
  setup_pte_fun=ptetools::setup_pte, subset_fun=qte:::three_period_subset,
  attgt_fun=qte:::panel_qtt_gt, aggte_fun=myagg, control_group="notyettreated",
  anticipation=0, cband=FALSE, boot_type="empirical", biters=1, cl=1,
  gt_type="qtt", probs=probs, pre_copula="long", required_pre_periods=2L)
