suppressMessages({library(qte); library(haven); library(BMisc)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id", "t", "y", "g")
res <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=seq(0.1,0.9,0.1), gt_type="qtt", pre_copula="long", cband=FALSE, biters=5)
cat("names(res):", paste(names(res), collapse=", "), "\n")
cat("class F0_overall:", class(res$F0_overall), "\n")
cat("glist:", paste(res$ptep$glist, collapse=","), " tlist:", paste(res$ptep$tlist, collapse=","), "\n")
cat("control_group:", res$ptep$control_group, "\n")
# F0_overall/F1_overall are distributions; evaluate on a grid to compute overall QTT
yy <- quantile(df$y, probs=seq(0,1,length.out=1000))
F0 <- res$F0_overall(yy); F1 <- res$F1_overall(yy)
qtt <- quantile(res$F1_overall, probs=seq(0.1,0.9,0.1), type=1) -
       quantile(res$F0_overall, probs=seq(0.1,0.9,0.1), type=1)
cat("overall from res F0/F1:", paste(round(qtt,4), collapse=","), "\n")
# per-cohort
cat("\n--- group (per-cohort) QTT ---\n"); print(res$group)
