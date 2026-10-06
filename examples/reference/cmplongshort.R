suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")

mkcell <- function(g, tp, mode) {
  pre1 <- g-1
  pre2 <- if (mode=="long") 2*g-tp-2 else g-2
  dd <- df[df$g==g | df$g>tp | df$g==0, ]
  dd <- dd[dd$t %in% c(pre2,pre1,tp), ]
  dd$name <- ifelse(dd$t==tp,"post",ifelse(dd$t==pre1,"pre1","pre2"))
  dd$D <- as.integer(dd$g==g); dd$Y <- dd$y; dd$.w <- 1; dd
}
Rtarget <- c("0.2679","0.3238","0.6164","0.6818")
cells <- list(c(3,3),c(4,4),c(4,5),c(5,5))
for (mode in c("long","short")) {
  cat("=== pre_copula =", mode, "===\n")
  for (i in seq_along(cells)) {
    egr <- tryCatch(panel_qtt_gt(mkcell(cells[[i]][1], cells[[i]][2], mode))$extra_gt_returns,
                    error=function(e) NULL)
    fm <- if (is.null(egr)) NA else round(quantile(egr$F0,0.5),4)
    cat(sprintf("  (%d,%d) F0med=%s   (R=%s)\n", cells[[i]][1], cells[[i]][2],
                ifelse(is.na(fm),"NA",fm), Rtarget[i]))
  }
}
