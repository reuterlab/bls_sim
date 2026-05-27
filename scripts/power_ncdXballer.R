library(ggplot2)
library(ggpubr) 
source("read_power_table.R")

ballertable <- read_power_table("../baller/results/power_01.txt", ncd=F)
ncdtable <- read_power_table("../ncd/sel100_w3000.ncd2_power.txt")
ncdtable <- ncdtable[ncdtable$alpha==0.01 & 
                     round(ncdtable$tf, 2) == round(ncdtable$pstar, 2),]
names(ncdtable)[2] <- "ncdpower"
names(ballertable)[2] <- "ballerpower"

mtab <- merge(ballertable, ncdtable,
by=c("alpha", "seltype", "Ne", "rec", "mut", "s1", "s2", "h", "t","t_ne", "selalpha", "pstar"))

stdsim <- mtab$Ne==20000 & mtab$rec==1e-8 & mtab$mu==1e-8 & mtab$t==160000
increc <- mtab$seltype=="OD" & mtab$Ne==20000 & mtab$rec==1e-7 & mtab$mu==1e-8 & mtab$t==160000
incmut <- mtab$seltype=="OD" & mtab$Ne==20000 & mtab$rec==1e-8 & mtab$mu==1e-7 & mtab$t==160000
inct <- mtab$seltype=="OD" & mtab$Ne==20000 & mtab$rec==1e-8 & mtab$mu==1e-8 & mtab$t==320000
redne <- mtab$seltype=="OD" & mtab$Ne==2000 & mtab$rec==1e-8 & mtab$mu==1e-8 & mtab$t==16000

mtab_sub <- mtab[stdsim|increc|incmut|inct|redne, ]
cor(mtab_sub$ncdpower, mtab_sub$ballerpower)

ggplot(mtab_sub, aes(ncdpower, ballerpower))+
    geom_point()+
    #geom_point(aes(color=pstar, shape=factor(rec/mut)))+
    geom_abline(slope=1)+
    ylab("BalLeRMix power")+ xlab("NCD power")+
    stat_cor(method="pearson")
ggsave("../plots/power_ncdXballer.png", h=4, w=6)
