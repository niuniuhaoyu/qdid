suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
res <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=seq(0.1,0.9,0.1), gt_type="qtt", pre_copula="long", cband=FALSE, biters=5)
pd <- res$ptep$data
cat("unique(g):", paste(sort(unique(pd$g)), collapse=","), "\n")
cat("unique(G):", paste(sort(unique(pd$G)), collapse=","), "\n")
cat("unique(period):", paste(sort(unique(pd$period)), collapse=","), "\n")
cat("glist:", paste(res$ptep$glist, collapse=","), " tlist:", paste(res$ptep$tlist, collapse=","), "\n")
# map g <-> G
print(unique(pd[, c("g","G")]))
