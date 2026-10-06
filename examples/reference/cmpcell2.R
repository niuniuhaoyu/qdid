suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")

mkcell <- function(g, tp) {
  pre1 <- g-1; pre2 <- 2*g-tp-2
  dd <- df[df$g==g | df$g>tp | df$g==0, ]
  dd <- dd[dd$t %in% c(pre2,pre1,tp), ]
  dd$name <- ifelse(dd$t==tp,"post",ifelse(dd$t==pre1,"pre1","pre2"))
  dd$D <- as.integer(dd$g==g); dd$Y <- dd$y; dd$.w <- 1
  dd
}
for (cc in list(c(3,3),c(4,4),c(4,5),c(5,5))) {
  egr <- panel_qtt_gt(mkcell(cc[1],cc[2]))$extra_gt_returns
  cat(sprintf("mine (%d,%d): F0med=%.4f F1med=%.4f qtt@.5=%.4f\n",
      cc[1], cc[2], quantile(egr$F0,0.5), quantile(egr$F1,0.5),
      quantile(egr$F1,0.5)-quantile(egr$F0,0.5)))
}
cat("R block1: (3,3) 0.2679/0.8110 ; (4,4) 0.3238/0.8895 ; (4,5) 0.6164/1.0540 ; (5,5) 0.6818/1.0114\n")
