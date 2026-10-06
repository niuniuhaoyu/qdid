suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
res <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=seq(0.1,0.9,0.1), gt_type="qtt", pre_copula="long", cband=FALSE, biters=5)
pd <- res$ptep$data
cat("cols of ptep$data:", paste(colnames(pd), collapse=","), "\n")
cat("nrow:", nrow(pd), "\n")
if (".w" %in% colnames(pd)) {
  cat("range(.w):", range(pd$.w), " unique(.w):", paste(head(sort(unique(pd$.w)),5), collapse=","), "\n")
  print(table(pd$.w))
} else cat("no .w column\n")
cat("periods in ptep$data:", paste(sort(unique(pd$period)), collapse=","), "\n")
