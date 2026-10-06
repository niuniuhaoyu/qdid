suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
res <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=seq(0.1,0.9,0.1), gt_type="qtt", pre_copula="long", cband=FALSE, biters=2)
pd <- res$ptep$data
cat("nrow(df)=", nrow(df), " nrow(pd)=", nrow(pd), "\n")
print(head(pd[, c("id","t","y","Y","period","g","G")], 8))
cat("\nunique(pd$t):", paste(sort(unique(pd$t)), collapse=","), "\n")
cat("unique(pd$period):", paste(sort(unique(pd$period)), collapse=","), "\n")
cat("max|pd$y - pd$Y| =", max(abs(pd$y - pd$Y)), "\n")
# align by id, period
a <- pd[order(pd$id, pd$period), c("id","period","Y")]
b <- df[order(df$id, df$t), c("id","t","y")]
names(b) <- c("id","period","y")
cat("max|pd$Y - df$y| (aligned) =", max(abs(a$Y - b$y)), "\n")
# is pd$t == pd$period?
cat("max|pd$t - pd$period| =", max(abs(pd$t - pd$period)), "\n")
