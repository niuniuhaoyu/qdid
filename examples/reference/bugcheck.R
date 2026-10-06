suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
probs <- seq(0.1,0.9,0.1)

r_g <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=probs, gt_type="qtt", pre_copula="long", cband=FALSE, biters=5)

df2 <- df; names(df2)[names(df2)=="g"] <- "gt"
r_gt <- panel_qtt(yname="y", gname="gt", tname="t", idname="id", data=df2,
                  probs=probs, gt_type="qtt", pre_copula="long", cband=FALSE, biters=5)

cat("R overall with gname='g'  :", paste(round(r_g$overall$qtt,4), collapse=","), "\n")
cat("R overall with gname='gt' :", paste(round(r_gt$overall$qtt,4), collapse=","), "\n")
cat("Stata qdid (not-yet-treated): 0.3249,0.4978,0.5153,0.5687,0.6353,0.6378,0.6855,0.6569,0.6509\n")
