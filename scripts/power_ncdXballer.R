#source /share/apps/source_files/R/R-4.3.2.source
library(cowplot)
library(ggplot2)
library(ggpubr) 
source("read_power_table.R")

ballertable_optX <- read_power_table("../baller/results/power_01.txt", ncd=F)
ballertable_fixX <- read_power_table("../baller/results/power_fixpstar_01.txt", ncd=F)

powerfile="../ncd/sel100_w3000.ncd2_power2.txt" # with all fix tf=0.5
ncdtable <- read_power_table(powerfile)
ncdtable_tfps <- ncdtable[ncdtable$alpha==0.01 & 
                     round(ncdtable$tf, 2) == round(ncdtable$pstar, 2),]
ncdtable_tf05 <- ncdtable[ncdtable$alpha==0.01 & 
                     round(ncdtable$tf, 1) == 0.5,]
names(ncdtable_tfps)[2] <- "ncdpower_tfps"
names(ncdtable_tf05)[2] <- "ncdpower_tf05"
names(ballertable_optX)[2] <- "ballerpower_optX"
names(ballertable_fixX)[2] <- "ballerpower_fixX"

tmp <- merge(ballertable_fixX[,-12], ballertable_optX[,-12],
by=c("alpha", "seltype", "Ne", "rec", "mut", "s1", "s2", "h", "t","t_ne", "selalpha", "pstar"))

tmp2 <- merge(tmp, ncdtable_tfps[,-13], 
by=c("alpha", "seltype", "Ne", "rec", "mut", "s1", "s2", "h", "t","t_ne", "selalpha", "pstar"))

mtab <- merge(tmp2, ncdtable_tf05[,-13], 
by=c("alpha", "seltype", "Ne", "rec", "mut", "s1", "s2", "h", "t","t_ne", "selalpha", "pstar"))

mtab <- mtab[,c("seltype", "Ne", "rec","mut","t","pstar","selalpha","ballerpower_fixX","ballerpower_optX","ncdpower_tfps","ncdpower_tf05")]

stdsim <- mtab$Ne==20000 & mtab$rec==1e-8 & mtab$mut==1e-8 & mtab$t==160000
increc <- mtab$seltype=="OD" & mtab$Ne==20000 & mtab$rec==1e-7 & mtab$mut==1e-8 & mtab$t==160000
incmut <- mtab$seltype=="OD" & mtab$Ne==20000 & mtab$rec==1e-8 & mtab$mut==1e-7 & mtab$t==160000
inct <- mtab$seltype=="OD" & mtab$Ne==20000 & mtab$rec==1e-8 & mtab$mut==1e-8 & mtab$t==320000
redne <- mtab$seltype=="OD" & mtab$Ne==2000 & mtab$rec==1e-8 & mtab$mut==1e-8 & mtab$t==16000

mtab_sub <- mtab[stdsim|increc|incmut|inct|redne, ]
mtab_sub$sim <- ""
mtab_sub$sim[stdsim] <- "Ref"
mtab_sub$sim[increc] <- "+rec"
mtab_sub$sim[incmut] <- "+mut"
mtab_sub$sim[inct] <- "+t"
mtab_sub$sim[redne] <- "-Ne"
cor(mtab_sub$ncdpower_tf05, mtab_sub$ballerpower_optX)
cor(mtab_sub$ncdpower_tfps, mtab_sub$ballerpower_fixX)
cor(mtab_sub$ballerpower_optX, mtab_sub$ballerpower_fixX)
cor(mtab_sub$ncdpower_tf05, mtab_sub$ncdpower_tfps)

real <- ggplot(mtab_sub, aes(ncdpower_tf05, ballerpower_optX))+
    geom_point(aes(color=pstar, shape=sim))+
    scale_color_continuous(name = "phat")+
    scale_shape_manual(values=c(Ref = 16, "+rec"=2, "+mut"=4,"+t"=22,"-Ne"=10))+
    geom_abline(slope=1)+
    xlab("NCD power (tf=0.5)")+
    ylab("BalLeRMix power (opt. X)")+
    xlim(0, 0.75)+
    ylim(0, 0.75)+
    stat_cor(method="pearson")+
    ggtitle("Unknown equilibrium frequency")
ggsave("../plots/power_ncdXballer_real.png", h=4, w=6)

fixp <- ggplot(mtab_sub, aes(ncdpower_tfps, ballerpower_fixX))+
    geom_point(aes(color=pstar, shape=sim))+
    scale_color_continuous(name = "phat")+
    scale_shape_manual(values=c(Ref = 16, "+rec"=2, "+mut"=4,"+t"=22,"-Ne"=10))+
    geom_abline(slope=1)+
    xlab("NCD power (tf=phat)")+
    ylab("BalLeRMix power (X=phat)")+
    xlim(0, 0.75)+
    ylim(0, 0.75)+
    stat_cor(method="pearson")+
    ggtitle("True equilibrium freq. provided")
ggsave("../plots/power_ncdXballer_fixp.png", h=4, w=6)

fig <- plot_grid(real+guides(shape="none", color="none"), fixp,
          labels=c("A", "B"), ncol=2, rel_widths = c(1, 1.2))
legend <- get_legend(real)
# add the legend to the row we made earlier. Give it one-third of 
# the width of one plot (via rel_widths).
final <- plot_grid(fig, legend, rel_widths = c(2, 0.2))
ggsave(paste0("../plots/power_ncdXballer_panels.png"), h=4, w=8, plot=fig)
