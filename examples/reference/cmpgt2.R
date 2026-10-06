suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
res <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=seq(0.1,0.9,0.1), gt_type="qtt", pre_copula="long", cband=FALSE, biters=2)
pd <- res$ptep$data
d <- data.frame(id=df$id, period=df$t, G=df$g, Y=df$y, y=df$y, .w=1)

sp <- qte:::three_period_subset(pd, g=4, tp=5, control_group="notyettreated", anticipation=0, pre_copula="long")$gt_data
sd <- qte:::three_period_subset(d,  g=4, tp=5, control_group="notyettreated", anticipation=0, pre_copula="long")$gt_data
cat("cols sp:", paste(colnames(sp), collapse=","), "\n")
cat("cols sd:", paste(colnames(sd), collapse=","), "\n")
a <- sp[order(sp$id, sp$name), c("id","name","Y")]
b <- sd[order(sd$id, sd$name), c("id","name","Y")]
cat("nrow sp=",nrow(a)," nrow sd=",nrow(b),"  max|Y|=", max(abs(a$Y-b$Y)), "\n")
yy <- quantile(df$y, probs=seq(0,1,length.out=1000))
fp <- panel_qtt_gt(sp)$extra_gt_returns
fd <- panel_qtt_gt(sd)$extra_gt_returns
cat("F0med sp=", round(quantile(fp$F0,0.5),4), " sd=", round(quantile(fd$F0,0.5),4), "\n")
cat("F1med sp=", round(quantile(fp$F1,0.5),4), " sd=", round(quantile(fd$F1,0.5),4), "\n")
