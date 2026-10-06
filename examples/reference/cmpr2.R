suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
d <- data.frame(id=df$id, period=df$t, G=df$g, Y=df$y, y=df$y)

g <- 4; tp <- 5
sub <- qte:::three_period_subset(d, g=g, tp=tp, control_group="notyettreated",
                                 anticipation=0, pre_copula="long")$gt_data
mk <- local({
  pre1 <- g-1; pre2 <- 2*g-tp-2
  dd <- df[df$g==g | df$g>tp | df$g==0, ]
  dd <- dd[dd$t %in% c(pre2,pre1,tp), ]
  dd$name <- ifelse(dd$t==tp,"post",ifelse(dd$t==pre1,"pre1","pre2"))
  dd$D <- as.integer(dd$g==g); dd$Y <- dd$y; dd$.w <- 1; dd
})
yy <- quantile(df$y, probs=seq(0,1,length.out=1000))
r1 <- panel_qtt_gt(sub)$extra_gt_returns
r2 <- panel_qtt_gt(mk)$extra_gt_returns
cat("max|F0 sub - F0 mk| =", max(abs(r1$F0(yy) - r2$F0(yy))), "\n")
cat("max|F1 sub - F1 mk| =", max(abs(r1$F1(yy) - r2$F1(yy))), "\n")
cat("sub F0med=", quantile(r1$F0,0.5), " mk F0med=", quantile(r2$F0,0.5), "\n")
cat("names(sub):", paste(names(sub), collapse=","), "\n")
cat("names(mk):", paste(names(mk), collapse=","), "\n")
