suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
probs <- seq(0.1,0.9,0.1)
d <- data.frame(id=df$id, period=df$t, G=df$g, y=df$y)

sub <- qte:::three_period_subset(d, g=4, tp=4, control_group="notyettreated",
                                 anticipation=0, pre_copula="long")$gt_data
r1 <- panel_qtt_gt(sub)$extra_gt_returns

mk <- function(g, tp) {
  pre1 <- g-1; pre2 <- 2*g-tp-2
  dd <- df[df$g==g | df$g>tp | df$g==0, ]
  dd <- dd[dd$t %in% c(pre2,pre1,tp), ]
  dd$name <- ifelse(dd$t==tp,"post",ifelse(dd$t==pre1,"pre1","pre2"))
  dd$D <- as.integer(dd$g==g); dd$Y <- dd$y; dd$.w <- 1; dd
}
r2 <- panel_qtt_gt(mk(4,4))$extra_gt_returns

yy <- quantile(df$y, probs=seq(0,1,length.out=1000))
cat("cell(4,4) max|F0 R - F0 mine| =", max(abs(r1$F0(yy) - r2$F0(yy))), "\n")
cat("cell(4,4) max|F1 R - F1 mine| =", max(abs(r1$F1(yy) - r2$F1(yy))), "\n")
cat("R   qtt:", paste(round(quantile(r1$F1,probs,type=1)-quantile(r1$F0,probs,type=1),4),collapse=","), "\n")
cat("mine qtt:", paste(round(quantile(r2$F1,probs,type=1)-quantile(r2$F0,probs,type=1),4),collapse=","), "\n")
cat("n rows R:", nrow(sub), " mine:", nrow(mk(4,4)), "\n")
cat("R median kcf:", round(quantile(r1$F0, 0.5),4), "  mine:", round(quantile(r2$F0, 0.5),4), "\n")
