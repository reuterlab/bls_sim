args = commandArgs(trailingOnly=TRUE)
#neutralB2file <- '../baller/results/neutral_N2k_r1e-8_fornull/all_c160000.B2'
#selB2file <- '../baller/results/OD_N2k_r1e-8_grid0.1/all_s0.1-0.1_c160000.B2'
selB2file <- args[1]
neutralB2file <- args[2]
seltype <- args[3]
Ne <- args[4]
rec <- args[5]
mut <- args[6]
s1 <- args[7]
s2 <- args[8]
h <- args[9]
t <- args[10]

neutralB2 <- read.table(neutralB2file, col.names=c("physPos", "genPos", "LR", "xhat", "Ahat", "numSites"))
selB2 <- read.table(selB2file, col.names=c("physPos", "genPos", "LR", "xhat", "Ahat", "numSites"))
nsim <- nrow(selB2)

alpha <- seq(from=0.01, to=0.1, by=0.01)
quants <- quantile(neutralB2$LR, probs=1-alpha)
power <- sapply(quants, function (q) sum(selB2$LR > q)/length(selB2$LR))

#png(paste0(selB2file, "_power.png"))
#plot(alpha, power, ylim=c(0,1))
#dev.off()
write.table(cbind(alpha, power, seltype, Ne, rec, mut, s1, s2, h, t, nsim), file=paste0(selB2file, "_power.txt"), row.names=F, quote=F)
