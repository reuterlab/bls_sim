# source /share/apps/source_files/R/R-4.3.2.source 

library(ggplot2)
library(cowplot)
source("read_power_table.R")

###############
plot_pstar_alpha <- function(df, pref="df"){
    pa <- ggplot(df)+
       geom_jitter(aes(pstar, selalpha, color=power, shape=seltype), 
                   width=0.02, stroke=1.5, size=1.5)+
        xlab("p*")+ylab("alpha")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        scale_color_viridis_c(name="Power")+
        theme_classic()
    ggsave(paste0("../plots/", pref, "_pstar_selalpha_power.png"), h=3.5, w=5)
    p <- ggplot(df, aes(pstar, power))+
        geom_jitter(aes(color=selalpha, shape=seltype),
                    width=0.02, stroke=1.5, size=1.5)+
        xlab(expression(paste("Equilibrium frequency (", hat(p), ")")))+ylab("Power")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        scale_color_viridis_c(name=expression(paste("Selection\nstrength (", alpha, " )")), option="rocket")+
#        geom_smooth(method='lm', formula=y~x, color="gray20")+
        theme_classic(base_size=15)
    ggsave(paste0("../plots/", pref,"_pstar_power.png"), h=3.5, w=5)
    a <- 
        ggplot(df, aes(selalpha, power))+
 #       geom_smooth(aes(color=pstar, group=pstar), alpha=0.5, linewidth=0.5, se=FALSE, method='lm', formula=y~x)+
        geom_point(aes(color=pstar, shape=seltype),
                   stroke=1.5, size=1.5)+
        xlab(expression(paste("Selection strength (", alpha, " )")))+ylab("Power")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        scale_color_viridis_c(name=expression(paste("Equilibrium\nfrequency (", hat(p), ")")), option="mako", end=0.8)+
        theme_classic(base_size=15)
    ggsave(paste0("../plots/", pref,"_selalpha_power.png"), h=3.5, w=5)
    t <-ggplot(df, aes(seltype, power))+
        geom_jitter(aes(color=pstar,  shape=seltype),
                   width=0.1, stroke=1.5, size=1.5)+
        xlab("Model of selection")+ylab("Power")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        scale_color_viridis_c(name=expression(paste("Equilibrium\nfrequency (", hat(p), ")")), option="mako", end=0.8)+
        theme_classic(base_size=15)
    ggsave(paste0("../plots/", pref,"_seltype_power.png"), h=3.5, w=5)
    ggplot(df, aes(pstar, seltype))+
        geom_jitter(aes(shape=seltype), height=0.1, stroke=1.5, size=1.5)+
        xlab(expression(paste("Equilibrium frequency (", hat(p), ")")))+
        ylab("Model of selection")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        theme_classic()
    ggsave(paste0("../plots/", pref,"_pstar_seltype.png"), h=3.5, w=5)
    ggplot(df, aes(selalpha, seltype))+
        geom_jitter(aes(shape=seltype),height=0.1,  stroke=1.5, size=1.5)+
        xlab(expression(paste("Selection strength (", alpha, " )")))+
        ylab("Model of selection")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        theme_classic()
    ggsave(paste0("../plots/", pref,"_selalpha_seltype.png"), h=3.5, w=5)
    #ga <- ggplotGrob(a+guides(colour="none", shape="none"))
    #gp <- ggplotGrob(p+guides(colour="none", shape="none")+ylab(""))
    #gt <- ggplotGrob(t+ylab(""))
    #g <- cbind(ga,gp,gt)
    g <- plot_grid(p+guides(shape="none"), a+guides(shape="none")+ylab(""), t+guides(color="none")+ylab(""),
              labels=c("A", "B", "C"), ncol=3)
    ggsave(paste0("../plots/", pref,"_pstar_selalpha_power_all.png"), h=3, w=12, plot=g)
}

powerfile="../ncd/sel100_w3000.ncd2_power2.txt" # with all fix tf=0.5
pwr <- read_power_table(powerfile)

#restrict to power at FPR=1%
pwr <- pwr[pwr$alpha==0.01,]

std_sims_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
std_sims_tfps$pstar <- round(std_sims_tfps$pstar, 2)
plot_pstar_alpha(std_sims_tfps, "stdsim_tfps")
write.csv(std_sims_tfps, "std_sims_tfps.csv")

std_sims_tf0.5 <- pwr[round(pwr$tf,1)==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
std_sims_tf0.5$pstar <- round(std_sims_tf0.5$pstar, 2)
plot_pstar_alpha(std_sims_tf0.5, "stdsim_tf0.5")
write.csv(std_sims_tf0.5, "std_sims_tf0.5.csv")

#----------- for Ballermix with fixed pstar
powerfile="../baller/results/power_fixpstar_01.txt"
pwr <- read_power_table(powerfile, ncd=F)

std_sims_fixps <- pwr[pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
std_sims_fixps$pstar <- round(std_sims_fixps$pstar, 2)
plot_pstar_alpha(std_sims_fixps, "stdsim_ballerfixps")
write.csv(std_sims_fixps, "std_sims_ballerfixp.csv")

#----------- for Ballermix with optim pstar
powerfile="../baller/results/power_01.txt"
pwr <- read_power_table(powerfile, ncd=F)

std_sims_optps <- pwr[pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
std_sims_optps$pstar <- round(std_sims_optps$pstar, 2)
plot_pstar_alpha(std_sims_optps, "stdsim_balleroptps")
write.csv(std_sims_optps, "std_sims_balleroptp.csv")
