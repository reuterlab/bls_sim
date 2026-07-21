args = commandArgs(trailingOnly=TRUE)
#neutralNCDfile <- "../ncd/neutralnull_N20k_r1e-8_grid0_m1e-7/all_s0-0_h0_c16000_spl100.ncd2"
#selNCDfile <- "../ncd/OD_N20k_r1e-8_grid0.1_m1e-7/all_s1-1_h0_c160000_spl100.ncd2"
selNCDfile <- args[1]
neutralNCDfile <- args[2]
seltype <- args[3]
Ne <- args[4]
rec <- args[5]
mut <- args[6]
s1 <- args[7]
s2 <- args[8]
h <- args[9]
t <- args[10]

#neutralNCD <- read.table(neutralNCDfile, col.names=c("ncd2", "S", "FD", "IS", "tf", "Win.start", "Win.end", "Win.mid", "rep"))
neutralNCD <- read.table(neutralNCDfile)
neutralNCD <- neutralNCD[,1:8] #to remove rep-number column in early versions of the neutralncd files
colnames(neutralNCD) <- c("ncd2", "S", "FD", "IS", "tf", "Win.start", "Win.end", "Win.mid")
selNCD <- read.table(selNCDfile, col.names=c("ncd2", "S", "FD", "IS", "tf", "Win.start", "Win.end", "Win.mid"))

alpha <- seq(from=0.01, to=0.1, by=0.01)

calc_power <- function(neutral, selected, statistic, alpha){
    quants <- quantile(neutral[[statistic]], probs=alpha)
    pwr <- sapply(quants, function (q) sum(selected[[statistic]] < q)/length(selected[[statistic]]))
    return(pwr)
}

power <- calc_power(neutralNCD, selNCD, "ncd2", alpha)
nsim <- nrow(selNCD)
#png(paste0(selB2file, "_power.png"))
#plot(alpha, power, ylim=c(0,1))
#dev.off()
write.table(cbind(alpha, power, seltype, Ne, rec, mut, s1, s2, h, t, nsim, tf=unique(c(selNCD$tf, neutralNCD$tf))), file=paste0(selNCDfile, "_power.txt"), row.names=F, quote=F)
