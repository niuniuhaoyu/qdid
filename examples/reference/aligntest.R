suppressMessages({library(qte); library(haven); library(ptetools)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")

myagg <- function(attgt.list, ptep, extra_gt_returns) {
  data <- ptep$data
  yy <- quantile(data$y, probs=seq(0,1,length.out=1000))
  cat("k  (g,tp)  max|F0_extra - F0_rerun|   extra F0med / rerun F0med\n")
  for (k in seq_along(attgt.list)) {
    g <- attgt.list[[k]]$group; tp <- attgt.list[[k]]$time.period
    eg <- extra_gt_returns[[k]]$extra_gt_returns
    if (is.null(eg$F0)) next
    sub <- qte:::three_period_subset(data, g=g, tp=tp, control_group="notyettreated",
                                     anticipation=0, pre_copula="long")$gt_data
    rr <- tryCatch(qte:::panel_qtt_gt(sub)$extra_gt_returns, error=function(e) NULL)
    if (is.null(rr)) next
    d <- max(abs(eg$F0(yy) - rr$F0(yy)))
    cat(sprintf("%d  (%d,%d)   %.5f      %.4f / %.4f\n", k, g, tp, d,
                quantile(eg$F0,0.5), quantile(rr$F0,0.5)))
  }
  qte:::panel_qtt_long_agg(attgt.list, ptep, extra_gt_returns)
}
res <- ptetools::pte(yname="y", gname="g", tname="t", idname="id", data=df, panel=TRUE,
  setup_pte_fun=ptetools::setup_pte, subset_fun=qte:::three_period_subset,
  attgt_fun=qte:::panel_qtt_gt, aggte_fun=myagg, control_group="notyettreated",
  anticipation=0, cband=FALSE, boot_type="empirical", biters=1, cl=1,
  gt_type="qtt", probs=seq(0.1,0.9,0.1), pre_copula="long", required_pre_periods=2L)
