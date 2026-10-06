suppressMessages({library(qte); library(haven); library(ptetools)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
probs <- seq(0.1,0.9,0.1)

myagg <- function(attgt.list, ptep, extra_gt_returns) {
  cell_g <- sapply(attgt.list, function(r) r$group)
  cell_tp <- sapply(attgt.list, function(r) r$time.period)
  data <- ptep$data
  original_tp <- sort(unique(data[, ptep$tname]))
  is_post <- (cell_tp - cell_g) >= 0
  pre2_long <- 2*cell_g - cell_tp - 2
  is_valid <- ifelse(is_post, pre2_long %in% original_tp, TRUE)
  valid_post <- is_valid & is_post
  surviving_g <- unique(cell_g[valid_post])
  n_group <- sapply(ptep$glist, function(gg) nrow(subset(data, data[,ptep$gname]==gg & data[,ptep$tname]==original_tp[1])))
  names(n_group) <- as.character(ptep$glist)
  pg <- n_group[as.character(surviving_g)]; pg <- pg/sum(pg)
  nvalid <- sapply(as.character(surviving_g), function(g) sum(valid_post & as.character(cell_g)==g))
  ow <- rep(0, length(attgt.list))
  for (i in seq_along(surviving_g)) { g <- surviving_g[i]; idx <- which(valid_post & cell_g==g); ow[idx] <- pg[i]/nvalid[i] }
  cat("=== R cells (g, tp, weight) and per-cell F0 median / QTT@0.5 ===\n")
  for (k in which(ow > 0)) {
    egr <- extra_gt_returns[[k]]$extra_gt_returns
    cat(sprintf("  (%d,%d) w=%.4f  F0med=%.4f F1med=%.4f qtt@.5=%.4f\n",
                cell_g[k], cell_tp[k], ow[k], quantile(egr$F0,0.5), quantile(egr$F1,0.5),
                quantile(egr$F1,0.5)-quantile(egr$F0,0.5)))
  }
  qte:::panel_qtt_long_agg(attgt.list, ptep, extra_gt_returns)
}

res <- ptetools::pte(yname="y", gname="g", tname="t", idname="id", data=df, panel=TRUE,
  setup_pte_fun=ptetools::setup_pte, subset_fun=qte:::three_period_subset,
  attgt_fun=qte:::panel_qtt_gt, aggte_fun=myagg, control_group="notyettreated",
  anticipation=0, cband=FALSE, boot_type="empirical", biters=5, cl=1,
  gt_type="qtt", probs=probs, pre_copula="long", required_pre_periods=2L)
