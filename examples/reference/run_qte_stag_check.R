# R qte panel_qtt (staggered, QTT) reference on the small DGP
suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
res <- panel_qtt(yname = "y", gname = "g", tname = "t", idname = "id", data = df,
                 probs = seq(0.1, 0.9, 0.1), gt_type = "qtt", pre_copula = "long",
                 cband = FALSE, biters = 10)
cat("=== R panel_qtt overall QTT ===\n")
print(res$overall_results)
cat("\n=== per-cell QTT (group, time.period, qtt by prob) ===\n")
print(res$attgt_results)
