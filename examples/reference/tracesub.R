suppressMessages({library(qte); library(haven); library(ptetools)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")

mysub <- function(data, g, tp, ...) {
  cat(sprintf("subset called: g=%s tp=%s\n", g, tp))
  qte:::three_period_subset(data, g, tp, ...)
}
res <- ptetools::pte(yname="y", gname="g", tname="t", idname="id", data=df, panel=TRUE,
  setup_pte_fun=ptetools::setup_pte, subset_fun=mysub,
  attgt_fun=qte:::panel_qtt_gt, aggte_fun=qte:::panel_qtt_long_agg,
  control_group="notyettreated", anticipation=0, cband=FALSE, boot_type="empirical",
  biters=1, cl=1, gt_type="qtt", probs=seq(0.1,0.9,0.1), pre_copula="long",
  required_pre_periods=2L)
