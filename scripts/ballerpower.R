args = commandArgs(trailingOnly=TRUE)
#neutralB2file <- '../baller/results/neutral_N2k_r1e-8/all_c160000.B2'
#selB2file <- '../baller/results/OD_N2k_r1e-8_grid0.1/all_s0.1-0.1_c160000.B2'
selB2file <- args[1]
neutralB2file <- args[2]

neutralB2 <- read.table(neutralB2file, col.names=c("physPos", "genPos", "LR", "xhat", "Ahat", "numSites"))
selB2 <- read.table(selB2file, col.names=c("physPos", "genPos", "LR", "xhat", "Ahat", "numSites"))

q95 <- quantile(neutralB2$LR, probs=0.95)
q99 <- quantile(neutralB2$LR, probs=0.99)

alpha <- seq(from=0.01, to=0.25, by=0.01)
quants <- quantile(neutralB2$LR, probs=1-alpha)
power <- sapply(quants, function (q) sum(selB2$LR > q)/length(selB2$LR))
png(paste0(selB2file, "_power.png"))
plot(alpha, power)
dev.off()

print(power[c("99%", "95%")])
