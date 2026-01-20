ballertable <- read_power_table("../baller/results/power_01.txt", ncd=F)
ncdtable <- read_power_table("../ncd/sel100_w3000.ncd2_power.txt")
ncdtable <- ncdtable[ncdtable$alpha==0.01 & 
                     round(ncdtable$tf, 2) == round(ncdtable$pstar, 2),]
names(ncdtable)[2] <- "ncdpower"
names(ballertable)[2] <- "ballerpower"

mtab <- merge(ballertable, ncdtable,
by=c("seltype", "Ne", "rec", "mut", "s1", "s2", "h", "t"))
