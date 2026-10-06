suppressMessages({library(qte); library(haven); library(BMisc)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
probs <- seq(0.1,0.9,0.1)
res <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=probs, gt_type="qtt", pre_copula="long", cband=FALSE, biters=5)

mkcell <- function(g, tp) {
  pre1 <- g-1; pre2 <- 2*g-tp-2
  d <- df[df$g==g | df$g>tp | df$g==0, ]
  d <- d[d$t %in% c(pre2,pre1,tp), ]
  d$name <- ifelse(d$t==tp,"post",ifelse(d$t==pre1,"pre1","pre2"))
  d$D <- as.integer(d$g==g); d$Y <- d$y; d$.w <- 1; d
}
cells <- list(c(3,3),c(4,4),c(4,5),c(5,5))
Fs <- lapply(cells, function(cc) panel_qtt_gt(mkcell(cc[1],cc[2]))$extra_gt_returns)

yy <- quantile(df$y, probs=seq(0,1,length.out=1000))
w <- c(1/3,1/6,1/6,1/3)
F0M <- combine_ecdfs(yy, lapply(Fs, function(e) e$F0), weights=w)
F1M <- combine_ecdfs(yy, lapply(Fs, function(e) e$F1), weights=w)
F0R <- res$F0_overall; F1R <- res$F1_overall

cat("max|F0 mine - F0 R| =", max(abs(F0M(yy) - F0R(yy))), "\n")
cat("max|F1 mine - F1 R| =", max(abs(F1M(yy) - F1R(yy))), "\n")
cat("overall mine:", paste(round(quantile(F1M,probs,type=1)-quantile(F0M,probs,type=1),4),collapse=","), "\n")
cat("overall R   :", paste(round(quantile(F1R,probs,type=1)-quantile(F0R,probs,type=1),4),collapse=","), "\n")

# per-cell QTT of each
for (i in seq_along(Fs)) {
  cat(sprintf("cell(%d,%d) qtt: %s\n", cells[[i]][1], cells[[i]][2],
      paste(round(quantile(Fs[[i]]$F1,probs,type=1)-quantile(Fs[[i]]$F0,probs,type=1),4),collapse=",")))
}
