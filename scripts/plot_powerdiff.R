# MODIFIED FROM overall_power.R
library(ggplot2)
library(cowplot)

powerfile="../ncd/OD100_ncd2all_power.txt"

source("read_power_table.R")
pwr <- read_power_table(powerfile)

#restrict to power at FPR=1%
pwr <- pwr[pwr$alpha==0.01,]

###############

plot_powerdiff <- function(toplot, col, colfactor=FALSE, suffix="diff", xlab="param"){
    toplot$ss <- paste(toplot$s1, toplot$s2, toplot$seltype, toplot$h)
    #colname=sym(col) # then aes(factor(!!colname),...)
    if (any(colfactor)){
        toplot[[col]] <- factor(toplot[[col]], levels=colfactor)
    }
    else{
        toplot[[col]] <- factor(toplot[[col]])
    }
    ggplot(toplot)+
        geom_point(aes(!!sym(col), power, color=round(pstar,2)))+
        geom_line(aes(!!sym(col), power, group=ss, color=round(pstar,2)))+
        scale_color_viridis_c(name=expression(paste("Equilibrium\nfrequency (", hat(p), ")")), option="mako", end=0.8)+
        ylim(c(0, 0.75))+
        ylab("Power") + xlab(xlab) + theme_classic()
#    ggsave(paste0("../plots/", suffix, "_powerdiff.png"), h=3.5, w=5)
}

inc_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
recplot <- plot_powerdiff(inc_rec_tfps, "rec", xlab="Recombination rate")+theme_classic()

inc_mut_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
mutplot <- plot_powerdiff(inc_mut_tfps, "mut", xlab="Mutation rate")+theme_classic()

inc_selage_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t>=160000 & pwr$winsize==3000, ]
selageplot <- plot_powerdiff(inc_selage_tfps, "t", xlab="Selection onset (generations ago)")+theme_classic()

std_sims_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
red_ne_tfps <- pwr[round(pwr$tf, 2)==round(pwr$pstar, 2) & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000 & pwr$winsize==3000, ]
neplot <- plot_powerdiff(rbind(std_sims_tfps, red_ne_tfps), "Ne", xlab="Effective population size")

g <- plot_grid(recplot+guides(color="none"), mutplot+guides(color="none")+ylab(""), selageplot+guides(color="none")+ylab(""), neplot+guides(color="none")+ylab(""),
          labels=c("A", "B", "C", "D"), ncol=4)
# extract the legend from one of the plots
legend <- get_legend(recplot)
# add the legend to the row we made earlier. Give it one-third of 
# the width of one plot (via rel_widths).
final <- plot_grid(g, legend, rel_widths = c(4, .4))
ggsave("../plots/rec_mut_t_ne_powerdiff.png", h=3.5, w=12, plot=final)

# compare power with different window sizes in standard simulations
std_sims_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
plot_powerdiff(std_sims_tfps, "winsize", suffix="OD_std_tfps-winsize", xlab="NCD window size")
std_sims_tf05 <- pwr[round(pwr$tf,2)==0.50 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
plot_powerdiff(std_sims_tf05, "winsize", suffix="OD_std_tf05-winsize", xlab="NCD window size")

# compare power with increased recombination and reduced window size
inc_rec_tfps_redwin <- rbind(std_sims_tfps_w3k,
                             pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-7 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==300, ])
plot_powerdiff(inc_rec_tfps_redwin, "rec", xlab="Recombination rate")+theme_classic()

mean(inc_rec_tfps[inc_rec_tfps$rec==1e-8, "power"])/
mean(inc_rec_tfps[inc_rec_tfps$rec==1e-7, "power"])



############################
# PREVIOUS VERSIONS
# compare power with different window sizes in increc simulations
inc_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-7 & pwr$mut==1e-8 & pwr$t==160000 , ]
plot_powerdiff(inc_rec_tfps, "winsize", suffix="OD_increc_tfps-winsize", xlab="NCD window size")

inc_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000, ]
plot_powerdiff(rbind(std_sims_tfps[std_sims_tfps$winsize==30000,] ,
                     inc_rec_tfps[inc_rec_tfps$winsize==300,]),"rec", suffix="OD_tfps_increc_decwin", xlab="Recombination rate")

inc_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
plot_powerdiff(inc_rec_tfps, "rec", suffix="OD_increc_tfps_w3k", xlab="Recombination rate")
inc_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==1000, ]
plot_powerdiff(inc_rec_tfps, "rec", suffix="OD_increc_tfps_w1k", xlab="Recombination rate")
inc_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==300, ]
plot_powerdiff(inc_rec_tfps, "rec", suffix="OD_increc_tfps_w300", xlab="Recombination rate")
inc_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==100, ]
plot_powerdiff(inc_rec_tfps, "rec", suffix="OD_increc_tfps_w100", xlab="Recombination rate")

inc_selage_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==320000, ]
inc_selage_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==320000, ]
plot_powerdiff(std_sims_tf05, inc_selage_tf05, "t", suffix="incselage_tf05", xlab="Selection onset (generations ago)")
plot_powerdiff(std_sims_tfps, inc_selage_tfps, "t", suffix="incselage_tfps", xlab="Selection onset (generations ago)")
plot_powerdiff(std_sims[std_sims$seltype=="OD",], inc_selage[inc_selage$seltype=="OD",], "t", suffix="incselage_OD", xlab="Selection onset (generations ago)")
plot_powerdiff(std_sims[std_sims$seltype=="AP",], inc_selage[inc_selage$seltype=="AP",], "t", suffix="incselage_AP", xlab="Selection onset (generations ago)")
plot_powerdiff(std_sims[std_sims$seltype=="SA",], inc_selage[inc_selage$seltype=="SA",], "t", suffix="incselage_SA", xlab="Selection onset (generations ago)")

red_ne_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000, ]
red_ne_tfps <- pwr[round(pwr$tf, 2)==round(pwr$pstar, 2) & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000, ]
plot_powerdiff(std_sims_tf05, red_ne_tf05, "Ne", suffix="rednet16_tf05", xlab="Effective population size")
plot_powerdiff(std_sims_tfps, red_ne_tfps, "Ne", suffix="rednet16_tfps", xlab="Effective population size")
red_ne_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000, ]
red_ne_tfps <- pwr[round(pwr$tf, 2)==round(pwr$pstar, 2) & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000, ]
plot_powerdiff(std_sims_tf05, red_ne_tf05, "Ne", suffix="rednet160_tf05", xlab="Effective population size")
plot_powerdiff(std_sims_tfps, red_ne_tfps, "Ne", suffix="rednet160_tfps", xlab="Effective population size")
plot_powerdiff(std_sims, red_ne, "Ne", suffix="redne", xlab="Effective population size")
plot_powerdiff(std_sims[std_sims$seltype=="OD",], red_ne[red_ne$seltype=="OD",], "Ne", suffix="redne_OD", xlab="Effective population size", colfactor=c(20000,2000))
plot_powerdiff(std_sims[std_sims$seltype=="AP",], red_ne[red_ne$seltype=="AP",], "Ne", suffix="redne_AP", xlab="Effective population size", colfactor=c(20000,2000))
plot_powerdiff(std_sims[std_sims$seltype=="SA",], red_ne[red_ne$seltype=="SA",], "Ne", suffix="redne_SA", xlab="Effective population size", colfactor=c(20000,2000))

inc_mu_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-7 & pwr$t==160000, ]
inc_mu_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-7 & pwr$t==160000, ]
plot_powerdiff(std_sims_tf05, inc_mu_tf05, "mut", suffix="incmu_tf05", xlab="Mutation rate")
plot_powerdiff(std_sims_tfps, inc_mu_tfps, "mut", suffix="incmu_tfps", xlab="Mutation rate")
plot_powerdiff(std_sims, inc_mu, "mut", suffix="incmu", xlab="Mutation rate")
plot_powerdiff(std_sims[std_sims$seltype=="OD",], inc_mu[inc_mu$seltype=="OD",], "mut", suffix="incmu_OD", xlab="Mutation rate")
plot_powerdiff(std_sims[std_sims$seltype=="AP",], inc_mu[inc_mu$seltype=="AP",], "mut", suffix="incmu_AP", xlab="Mutation rate")
plot_powerdiff(std_sims[std_sims$seltype=="SA",], inc_mu[inc_mu$seltype=="SA",], "mut", suffix="incmu_SA", xlab="Mutation rate")

