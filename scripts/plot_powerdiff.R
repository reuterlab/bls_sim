#source /share/apps/source_files/R/R-4.3.2.source

# MODIFIED FROM overall_power.R
library(ggplot2)
library(cowplot)

source("read_power_table.R")

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
        ylab("Power") + xlab(xlab) + theme_classic(base_size=15)
#    ggsave(paste0("../plots/", suffix, "_powerdiff.png"), h=3.5, w=5)
}

###########
#   NCD   #
###########

# NCD power file
powerfile="../ncd/OD100_ncd2all_power.txt"
pwr <- read_power_table(powerfile)
#restrict to power at FPR=1%
pwr <- pwr[pwr$alpha==0.01,]

#...........# 
# NCDtf=0.5 #
#...........# 
inc_rec <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
recplot <- plot_powerdiff(inc_rec, "rec", xlab="Recombination\nrate")

mean(inc_rec[inc_rec$rec==1e-8, "power"])/
mean(inc_rec[inc_rec$rec==1e-7, "power"])

inc_mut <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
mutplot <- plot_powerdiff(inc_mut, "mut", xlab="Mutation\nrate")

inc_selage <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t>=160000 & pwr$winsize==3000, ]
selageplot <- plot_powerdiff(inc_selage, "t", xlab="Selection onset\n(generations ago)")

std_sims <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
red_ne <- pwr[pwr$tf==0.5 & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000 & pwr$winsize==3000, ]
neplot <- plot_powerdiff(rbind(std_sims, red_ne), "Ne", xlab="Effective\npopulation size")

red_ne_t16 <- pwr[pwr$tf==0.5 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t_ne==16 & pwr$winsize==3000, ]
neplot2 <- plot_powerdiff(red_ne_t16, "Ne", xlab="Effective\npopulation size")
ggsave("../plots/ncdtf05_t_ne_powerdiff.png", h=3.5, w=5, plot=neplot2)

g <- plot_grid(recplot+guides(color="none"), mutplot+guides(color="none")+ylab(""), selageplot+guides(color="none")+ylab(""), neplot+guides(color="none")+ylab(""),
          labels=c("A", "B", "C", "D"), ncol=4)
# extract the legend from one of the plots
legend <- get_legend(recplot)
# add the legend to the row we made earlier. Give it one-third of 
# the width of one plot (via rel_widths).
final <- plot_grid(g, legend, rel_widths = c(4, 0.8))
ggsave("../plots/ncdtf05_rec_mut_t_ne_powerdiff.png", h=3.5, w=12, plot=final)

#...........# 
# NCDtf=ps  #
#...........# 
inc_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
recplot <- plot_powerdiff(inc_rec_tfps, "rec", xlab="Recombination\nrate")

inc_mut_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
mutplot <- plot_powerdiff(inc_mut_tfps, "mut", xlab="Mutation\nrate")

inc_selage_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t>=160000 & pwr$winsize==3000, ]
selageplot <- plot_powerdiff(inc_selage_tfps, "t", xlab="Selection onset\n(generations ago)")

std_sims_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==3000, ]
red_ne_tfps <- pwr[round(pwr$tf, 2)==round(pwr$pstar, 2) & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000 & pwr$winsize==3000, ]
neplot <- plot_powerdiff(rbind(std_sims_tfps, red_ne_tfps), "Ne", xlab="Effective\npopulation size")

g <- plot_grid(recplot+guides(color="none"), mutplot+guides(color="none")+ylab(""), selageplot+guides(color="none")+ylab(""), neplot+guides(color="none")+ylab(""),
          labels=c("A", "B", "C", "D"), ncol=4)
# extract the legend from one of the plots
legend <- get_legend(recplot)
# add the legend to the row we made earlier. Give it one-third of 
# the width of one plot (via rel_widths).
final <- plot_grid(g, legend, rel_widths = c(4, 0.8))
ggsave("../plots/ncdtfps_rec_mut_t_ne_powerdiff.png", h=3.5, w=12, plot=final)

#############
# Ballermix #
#############

#......................# 
# Ballermix fix p=phat #
#......................# 
powerfile="../baller/results/power_fixpstar_01.txt"
pwr <- read_power_table(powerfile, ncd=F)
inc_rec_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000, ]
recplot <- plot_powerdiff(inc_rec_tfps, "rec", xlab="Recombination\nrate")

inc_mut_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$t==160000, ]
mutplot <- plot_powerdiff(inc_mut_tfps, "mut", xlab="Mutation\nrate")

inc_selage_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t>=160000, ]
selageplot <- plot_powerdiff(inc_selage_tfps, "t", xlab="Selection onset\n(generations ago)")

std_sims_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000, ]
red_ne_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000, ]
neplot <- plot_powerdiff(rbind(std_sims_tfps, red_ne_tfps), "Ne", xlab="Effective\npopulation size")

g <- plot_grid(recplot+guides(color="none"), mutplot+guides(color="none")+ylab(""), selageplot+guides(color="none")+ylab(""), neplot+guides(color="none")+ylab(""),
          labels=c("A", "B", "C", "D"), ncol=4)
# extract the legend from one of the plots
legend <- get_legend(recplot)
# add the legend to the row we made earlier. Give it one-third of 
# the width of one plot (via rel_widths).
final <- plot_grid(g, legend, rel_widths = c(4, 0.8))
ggsave("../plots/ballerfixX_rec_mut_t_ne_powerdiff.png", h=3.5, w=12, plot=final)

#......................# 
# Ballermix optimize p #
#......................# 
powerfile="../baller/results/power_optp_01.txt"
pwr <- read_power_table(powerfile, ncd=F)
inc_rec_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==20000 & pwr$mut==1e-8 & pwr$t==160000, ]
recplot <- plot_powerdiff(inc_rec_tfps, "rec", xlab="Recombination\nrate")

inc_mut_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$t==160000, ]
mutplot <- plot_powerdiff(inc_mut_tfps, "mut", xlab="Mutation\nrate")

inc_selage_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t>=160000, ]
selageplot <- plot_powerdiff(inc_selage_tfps, "t", xlab="Selection onset\n(generations ago)")

std_sims_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000, ]
red_ne_tfps <- pwr[pwr$seltype=="OD" & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000, ]
neplot <- plot_powerdiff(rbind(std_sims_tfps, red_ne_tfps), "Ne", xlab="Effective\npopulation size")

g <- plot_grid(recplot+guides(color="none"), mutplot+guides(color="none")+ylab(""), selageplot+guides(color="none")+ylab(""), neplot+guides(color="none")+ylab(""),
          labels=c("A", "B", "C", "D"), ncol=4)
# extract the legend from one of the plots
legend <- get_legend(recplot)
# add the legend to the row we made earlier. Give it one-third of 
# the width of one plot (via rel_widths).
final <- plot_grid(g, legend, rel_widths = c(4, 0.8))
ggsave("../plots/balleroptp_rec_mut_t_ne_powerdiff.png", h=3.5, w=12, plot=final)


############################################################

# compare NCD power with different window sizes in standard simulations
std_sims_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
plot_powerdiff(std_sims_tfps, "winsize", suffix="OD_std_tfps-winsize", xlab="NCD window size")

std_sims_tf05 <- pwr[round(pwr$tf,2)==0.50 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
plot_powerdiff(std_sims_tf05, "winsize", suffix="OD_std_tf05-winsize", xlab="NCD window size")

# compare power with increased recombination and reduced window size
inc_rec_tfps_redwin <- rbind(std_sims_tfps_w3k,
                             pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-7 & pwr$mut==1e-8 & pwr$t==160000 & pwr$winsize==300, ])
plot_powerdiff(inc_rec_tfps_redwin, "rec", xlab="Recombination rate")+theme_classic()
