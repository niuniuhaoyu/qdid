suppressMessages({library(qte); library(haven)})
df <- as.data.frame(haven::read_dta("D:/OpenCode/qdid/data/qdid_stag_small.dta"))
names(df) <- c("id","t","y","g")
d <- data.frame(id=df$id, period=df$t, G=df$g, Y=df$y, y=df$y)

g <- 4; tp <- 5
sub <- qte:::three_period_subset(d, g=g, tp=tp, control_group="notyettreated",
                                 anticipation=0, pre_copula="long")$gt_data
cat("R subset periods by name:\n"); print(table(sub$name, sub$period))

mk <- local({
  pre1 <- g-1; pre2 <- 2*g-tp-2
  dd <- df[df$g==g | df$g>tp | df$g==0, ]
  dd <- dd[dd$t %in% c(pre2,pre1,tp), ]
  dd$name <- ifelse(dd$t==tp,"post",ifelse(dd$t==pre1,"pre1","pre2"))
  dd$D <- as.integer(dd$g==g); dd$Y <- dd$y; dd$.w <- 1; dd
})
cat("mine periods by name:\n"); print(table(mk$name, mk$t))

cat("\nR pre2_treated period values:", paste(sort(unique(sub$period[sub$name=="pre2" & sub$D==1])),collapse=","), "\n")
cat("mine pre2_treated period values:", paste(sort(unique(mk$t[mk$name=="pre2" & mk$D==1])),collapse=","), "\n")
cat("R pre1_treated period:", paste(sort(unique(sub$period[sub$name=="pre1" & sub$D==1])),collapse=","), "\n")
cat("mine pre1_treated period:", paste(sort(unique(mk$t[mk$name=="pre1" & mk$D==1])),collapse=","), "\n")
