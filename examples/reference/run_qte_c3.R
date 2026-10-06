# single-cohort (g=3) staggered check
suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
df <- df[df$g == 0 | df$g == 3, ]
cat("n=", nrow(df), " cohorts:", paste(sort(unique(df$g)), collapse = ","), "\n")
res <- panel_qtt(yname = "y", gname = "g", tname = "t", idname = "id", data = df,
                 probs = seq(0.1, 0.9, 0.1), gt_type = "qtt", pre_copula = "long",
                 cband = FALSE, biters = 10)
print(res$overall)
