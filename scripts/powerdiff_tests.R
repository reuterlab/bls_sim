library(ggplot2)

powerfile="../ncd/OD100_ncd2all_power.txt"

source("read_power_table.R")
pwr <- read_power_table(powerfile)
write.table(pwr, "../ncd/OD100_ncd2all_power_pstaralpha.txt", row.names=F)
#restrict to power at FPR=1%
pwr <- pwr[pwr$alpha==0.01,]

# power diff
test_powerdiff <- function (df1,df2){
    m <- merge(df1, df2, by=c("s1", "s2"))
    powerdiffs <- m$power.y-m$power.x
    binomres <- binom.test(sum(powerdiffs>0), length(powerdiffs), p=0.5)
    tres <- t.test(powerdiffs)
    wilcoxres <- wilcox.test(powerdiffs)
    hist(powerdiffs)
    return(list(binomres, tres, wilcoxres))
}

outpref <- 'tfps_w3000'
std_sims_tfps_w3k <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000 & pwr$seltype=="OD", ]
incr_rec_tfps_w3k <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-7 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000 & pwr$seltype=="OD", ] 
test_powerdiff(std_sims_tfps_w3k, incr_rec_tfps_w3k)

incr_mut_tfps_w3k <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-7 & pwr$t==160000 & pwr$winsize==3000 & pwr$seltype=="OD", ] 
test_powerdiff(std_sims_tfps_w3k, incr_mut_tfps_w3k)

incr_selage_tfps_w3k <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==320000 & pwr$winsize==3000 & pwr$seltype=="OD", ]
test_powerdiff(std_sims_tfps_w3k, incr_selage_tfps_w3k)

########################
##PREVIOUS VERSION
#powerfile <- '../ncd/power_01.txt'
#outpref <- 'tf0.5_w3000'
##powerfile <- '../ncd/power_01_tf0.3_w3000.ncd2.txt'
##outpref <- 'tf0.3_w3000'
##powerfile <- '../ncd/power_01_tf0.5_w1000.ncd2.txt'
##outpref <- 'tf0.5_w1000'
#std_sims <- pwr[pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000,] 
#older_selage <- pwr[pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==320000,] 
#test_powerdiff(std_sims[std_sims$seltype=="OD",], older_selage[older_selage$seltype=="OD",])
#
#smaller_ne <- pwr[pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000,] 
#test_powerdiff(std_sims[std_sims$seltype=="OD",], smaller_ne[smaller_ne$seltype=="OD",])
#
#increase_mu <- pwr[pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-7 & pwr$t==160000,] 
#test_powerdiff(std_sims[std_sims$seltype=="OD",], increase_mu[increase_mu$seltype=="OD",])
#
#incr_rec <- pwr[pwr$Ne==20000 & pwr$rec==1e-7 & pwr$mut==1e-8 & pwr$t==160000,] 
#test_powerdiff(std_sims[std_sims$seltype=="OD",], incr_rec[incr_rec$seltype=="OD",])

