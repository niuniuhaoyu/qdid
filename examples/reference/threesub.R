suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
probs <- seq(0.1,0.9,0.1)

# Build the pte-style long data (columns G, period) expected by three_period_subset
d <- data.frame(id=df$id, period=df$t, G=df$g, y=df$y)

tsub <- qte:::three_period_subset
for (cell in list(c(4,4), c(3,3))) {
  g <- cell[1]; tp <- cell[2]
  sub <- tsub(d, g=g, tp=tp, control_group="notyettreated", anticipation=0, pre_copula="long")
  gd <- sub$gt_data
  cat(sprintf("=== R three_period_subset (g=%d,tp=%d): n=%d ===\n", g, tp, nrow(gd)))
  cat("names(gd):", paste(names(gd), collapse=","), "\n")
  cat("periods present:", paste(sort(unique(gd$period)), collapse=","), "\n")
  cat("table(D):", paste(names(table(gd$D)), table(gd$D), collapse=" "), "\n")
  cat("controls (D==0) cohort values:", paste(sort(unique(gd$G[gd$D==0])), collapse=","), "\n")
  cat("treated (D==1) cohort values:", paste(sort(unique(gd$G[gd$D==1])), collapse=","), "\n\n")
}
