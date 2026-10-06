# R qte panel_qtt reference (staggered) for qdid
suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_sim.dta"))
cat("rows:", nrow(df), " ids:", length(unique(df$id)), " cohorts:", paste(sort(unique(df$g)), collapse=","), "\n")
res <- tryCatch(
  panel_qtt(yname = "y", gname = "g", tname = "t", idname = "id", data = df,
            probs = seq(0.1, 0.9, 0.1), cband = FALSE, biters = 50),
  error = function(e) { cat("ERR:", conditionMessage(e), "\n"); NULL })
if (!is.null(res)) {
  cat("--- R panel_qtt overall_results$qtt ---\n")
  print(round(res$overall_results$qtt, 6))
}
