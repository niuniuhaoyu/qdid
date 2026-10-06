suppressMessages({library(qte); library(haven); library(BMisc)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id", "t", "y", "g")
probs <- seq(0.1, 0.9, 0.1)

mkcell <- function(g, tp) {
  pre1 <- g - 1; pre2 <- 2 * g - tp - 2
  d <- df[df$g == g | df$g > tp | df$g == 0, ]
  d <- d[d$t %in% c(pre2, pre1, tp), ]
  d$name <- ifelse(d$t == tp, "post", ifelse(d$t == pre1, "pre1", "pre2"))
  d$D <- as.integer(d$g == g); d$Y <- d$y; d$.w <- 1
  d
}
cells <- list(c(3,3), c(4,4), c(4,5), c(5,5))
Fs <- lapply(cells, function(cc) panel_qtt_gt(mkcell(cc[1], cc[2]))$extra_gt_returns)

yseq <- quantile(df$y, probs = seq(0, 1, length.out = 1000))
w <- c(1/3, 1/6, 1/6, 1/3)   # pg/n_valid_post_g
F0 <- combine_ecdfs(yseq, lapply(Fs, function(e) e$F0), weights = w)
F1 <- combine_ecdfs(yseq, lapply(Fs, function(e) e$F1), weights = w)
ov_combine <- quantile(F1, probs, type = 1) - quantile(F0, probs, type = 1)
cat("overall by combining F0/F1:\n"); print(round(ov_combine, 4))

qtts <- sapply(Fs, function(e) quantile(e$F1, probs, type=1) - quantile(e$F0, probs, type=1))
ov_avg <- as.numeric(qtts %*% w)
cat("overall by averaging cell QTT curves:\n"); print(round(ov_avg, 4))

res <- panel_qtt(yname="y", gname="g", tname="t", idname="id", data=df,
                 probs=probs, gt_type="qtt", pre_copula="long", cband=FALSE, biters=5)
cat("R panel_qtt overall (truth):\n"); print(round(res$overall$qtt, 4))
