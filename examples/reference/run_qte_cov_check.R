# R qte reference WITH covariate: method="pscore"
suppressMessages(library(qte))
df <- read.csv("D:/OpenCode/qdid/examples/reference/qdid_cov_sim.csv", header = TRUE)
cat("rows:", nrow(df), " ids:", length(unique(df$id)), "\n")
res <- tryCatch(
  panel.qtet(y ~ treat, xformla = ~x, t = 3, tmin1 = 2, tmin2 = 1, tname = "t",
             data = df, idname = "id", probs = seq(0.1, 0.9, 0.1),
             method = "pscore", se = FALSE),
  error = function(e) { cat("ERR:", conditionMessage(e), "\n"); NULL })
if (!is.null(res)) {
  cat("--- R qte panel.qtet pscore, xformla=~x ---\n")
  print(round(res$qte, 6))
}
