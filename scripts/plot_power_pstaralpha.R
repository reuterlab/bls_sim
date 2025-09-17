# MODIFIED FROM overall_power.R
# cd ~/Dropbox/private/projects/uclpostdoc/bls_sim/ncd
# head -n1 OD100_w3000.ncd2_power.txt > sel100_w3000.ncd2_power.txt
# for seltype in OD AP SA; do tail -n +2 ${seltype}100_w3000.ncd2_power.txt >> sel100_w3000.ncd2_power.txt ;done

library(ggplot2)
library(cowplot)

powerfile="../ncd/sel100_w3000.ncd2_power.txt"

source("read_power_table.R")
pwr <- read_power_table(powerfile)

#restrict to power at FPR=1%
pwr <- pwr[pwr$alpha==0.01,]

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
        geom_jitter(aes(color=pstar, shape=seltype),
                    width=0.02, stroke=1.5, size=1.5)+
        xlab(expression(paste("Equilibrium frequency (", hat(p), ")")))+ylab("Power")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        scale_color_viridis_c(name=expression(paste("Equilibrium\nfrequency (", hat(p), ")")), option="mako", end=0.8)+
        geom_smooth(method='lm', formula=y~x, color="gray20")+
        theme_classic()
    ggsave(paste0("../plots/", pref,"_pstar_power.png"), h=3.5, w=5)
    a <- ggplot(df, aes(selalpha, power))+
        geom_smooth(aes(color=pstar, group=round(pstar, 2)), alpha=0.5, linewidth=0.5, se=FALSE, method='lm', formula=y~x)+
        geom_point(aes(color=pstar, shape=seltype),
                   stroke=1.5, size=1.5)+
        xlab(expression(paste("Selection strength (", alpha, " )")))+ylab("Power")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        scale_color_viridis_c(name=expression(paste("Equilibrium\nfrequency (", hat(p), ")")), option="mako", end=0.8)+
        theme_classic()
    ggsave(paste0("../plots/", pref,"_selalpha_power.png"), h=3.5, w=5)
    t <-ggplot(df, aes(seltype, power))+
        geom_jitter(aes(color=pstar,  shape=seltype),
                   width=0.1, stroke=1.5, size=1.5)+
        xlab("Model of selection")+ylab("Power")+
        scale_shape(name="Model of\nselection", solid=FALSE)+
        scale_color_viridis_c(name=expression(paste("Equilibrium\nfrequency (", hat(p), ")")), option="mako", end=0.8)+
        theme_classic()
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
    g <- plot_grid(p+guides(color="none", shape="none"), a+guides(color="none", shape="none")+ylab(""), t+ylab(""),
              labels=c("A", "B", "C"), ncol=3)
    ggsave(paste0("../plots/", pref,"_pstar_selalpha_power_all.png"), h=3.5, w=12, plot=g)
}

std_sims_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000 , ]
std_sims_tfps$pstar <- round(std_sims_tfps$pstar, 2)
plot_pstar_alpha(std_sims_tfps, "stdsim_tfps")

write.csv(std_sims_tfps, "std_sims_tfps.csv")
summary(lm(power~pstar*selalpha*seltype, data=std_sims_tfps))

sort(std_sims_tfps$pstar)
mean(std_sims_tfps$power[std_sims_tfps$pstar==0.5])
mean(std_sims_tfps$power[std_sims_tfps$pstar==0.07])

sort(std_sims_tfps$selalpha)
mean(std_sims_tfps$power[round(std_sims_tfps$selalpha,3)==0.001])
mean(std_sims_tfps$power[round(std_sims_tfps$selalpha,3)==2])

pwr[ pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$s1==0.1 &  pwr$s2==0.1 & pwr$Ne==20000 & pwr$t==160000,]


######################################################
#other plots for Max's presentation in Edinburgh
ggplot(std_sims_tfps, aes(pstar, power))+
        geom_jitter(width=0.005, stroke=1.5, size=1.5)+
        xlab("Equilibrium frequency (p*)")+ylab("Power")+
        geom_smooth(method='lm', formula=y~x)
ggsave("../plots/stdsims_tfps_pstar_power_nocolor.png", h=3.5, w=5)
std_sims_tfps$pstar <- round(std_sims_tfps$pstar, 3)
mean(std_sims_tfps$power[std_sims_tfps$pstar==0.091])
mean(std_sims_tfps$power[std_sims_tfps$pstar==0.500])
minmaxalpha <- range(std_sims_tfps$selalpha[std_sims_tfps$seltype=="OD"])
std_sims_tfps$power[std_sims_tfps$seltype=="OD" & std_sims_tfps$selalpha==minmaxalpha[1]]
std_sims_tfps$power[std_sims_tfps$seltype=="OD" & std_sims_tfps$selalpha==minmaxalpha[2]]

ggplot(std_sims_tfps, aes(selalpha, power))+
        geom_jitter(width=0.005, stroke=1.5, size=1.5)+
        xlab("Selection strength (alpha)")+ylab("Power")+
        geom_smooth(method='lm', formula=y~x)
ggsave("../plots/stdsims_tfps_alpha_power_nocolor.png", h=3.5, w=5)


plot_pstar_alpha(std_sims, "stdsim")
plot_pstar_alpha(std_sims_tf05, "stdsim_tf05")
plot_pstar_alpha(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], "allsim_tfps")

#df <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$t_ne>=8,]
df <- pwr[pwr$tf==0.5 & pwr$t_ne>=8,]
ggplot(df, aes(pstar, power))+
    geom_jitter(aes(color=factor(t), shape=factor(Ne)),
                width=0.02, stroke=1.5, size=1.5)+
    xlab("Equilibrium frequency (p*)")+ylab("Power")+
    scale_shape(name="Ne", solid=FALSE)+
    scale_color_viridis_d(name="Selection\nonset time", option="mako", end=0.8)+
    geom_smooth(method='lm', formula=y~x)
#ggsave(paste0("../plots/", "OD100_tfps","_pstar_power.png"), h=3.5, w=5)
ggsave(paste0("../plots/", "OD100_tf05","_pstar_power.png"), h=3.5, w=5)

ggplot(df, aes(selalpha, power))+ 
    geom_point(aes(color=factor(t), shape=factor(Ne)),
               stroke=1.5, size=1.5)+
    xlab("Selection strength (alpha)")+ylab("Power")+
    scale_shape(name="Ne", solid=FALSE)+
    scale_color_viridis_d(name="Selection\nonset time", option="mako", end=0.8)+
    geom_smooth(method='lm', formula=y~x)
#ggsave(paste0("../plots/", "OD100_tfps","_selalpha_power.png"), h=3.5, w=5)
ggsave(paste0("../plots/", "OD100_tf05","_selalpha_power.png"), h=3.5, w=5)

