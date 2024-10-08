library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
powerfile <- args[1]
powerfile <- '../baller/results/power_01.txt'

power <- read.table(powerfile, header=T) 
power$alpha <- as.numeric(power$alpha)
power$power <- as.numeric(power$power)
power$s1 <- as.numeric(power$s1)
power$s2 <- as.numeric(power$s2)
power$h <- as.numeric(power$h)
power$t <- as.numeric(power$t)
power$t_ne <- power$t/power$Ne
#power$t <- factor(power$t, levels=sort(unique(power$t), decreasing=T)) 

# calculate selection strength (alpha), and pstar, with corresponding formulas for each selection type
power$selalpha <- NA
power$pstar <- NA
power_od <- power[power$seltype=="OD",]
power_ap <- power[power$seltype=="AP",]
power_sa <- power[power$seltype=="SA",]

## alpha
power$selalpha[power$seltype=="OD"] <- power_od$s1 + power_od$s2
power$selalpha[power$seltype=="AP"] <- (power_ap$s1 + power_ap$s2)*(1-2*power_ap$h)+2*power_ap$s1*power_ap$s2*power_ap$h^2
power$selalpha[power$seltype=="SA"] <- ((power_sa$s1+power_sa$s2)/2)*(1-2*power_sa$h)+2*power_sa$s1*power_sa$s2*power_sa$h^2

## pstar - OD
power$pstar[power$seltype=="OD"] <- sapply(power_od$s2/(power_od$s1+power_od$s2), function(x){min(x, 1-x)}) # using MAF because I didn't save which one was the invading allele in each simulation

## pstar - AP
### conditions for pstar under AP
valid_pstar_ap <- power_ap$s2*power_ap$h/(1-power_ap$h+power_ap$s2*power_ap$h^2) < power_ap$s1 & power_ap$s1 < power_ap$s2*(1-power_ap$h)/(power_ap$h*(1-power_ap$s2*power_ap$h))
### calculate pstar
all_pstars_ap <- (power_ap$s1*(1-power_ap$h) - (power_ap$s2*power_ap$h) + (power_ap$s1*power_ap$s2*power_ap$h^2)) / ((power_ap$s1+power_ap$s2) * (1-2*power_ap$h) + (2*power_ap$s1*power_ap$s2*power_ap$h^2))
### fill in valid pstars only, converting to MAF
power_ap$pstar[valid_pstar_ap] <- sapply(all_pstars_ap[valid_pstar_ap], function(x){min(x, 1-x)})
power$pstar[power$seltype=="AP"] <- power_ap$pstar

## pstar - SA
### conditions for pstar under SA
valid_pstars_sa <- power_sa$s1*power_sa$h/(1-power_sa$h+power_sa$s1*power_sa$h) < power_sa$s2 & power_sa$s2 < power_sa$s1*(1-power_sa$h)/(power_sa$h*(1-power_sa$s1))
### calculate pstar for codominant SA
codom_pstars_sa <- (power_sa$s2 - power_sa$s1 + power_sa$s1*power_sa$s2) / (2*power_sa$s1*power_sa$s2)
### calculate pstar for SA with dominance reversal
dom_pstars_sa <- (power_sa$s2 * (1-power_sa$h) - power_sa$s1*power_sa$h) / ((power_sa$s1 + power_sa$s2) * (1-2*power_sa$h))
### fill in valid pstars for each case
power_sa$pstar[valid_pstars_sa & power_sa$h==0.5] <- codom_pstars_sa[valid_pstars_sa & power_sa$h==0.5]
power_sa$pstar[valid_pstars_sa & power_sa$h<0.5] <- dom_pstars_sa[valid_pstars_sa & power_sa$h<0.5]
power$pstar[power$seltype=="SA"] <- sapply(power_sa$pstar, function(x){min(x, 1-x)})

power$sim <- apply(power, 1, function(x){paste0(x[3:10],collapse="_")})
head(power)
dim(power)

# 1 filter for a minimum nsim
hist (power$nsim )
png("maintenance_hist.png")
hist (power$nsim[power$nsim>0], breaks=75)
dev.off()
pwr <- power[power$nsim>44,]

## plot power in a grid
plot_topgrid <- function(seltype, ne, rec, mut, h, t, smin=0.1, colmax=0.3){
    toplot <- pwr[pwr$seltype==seltype & pwr$Ne==ne & pwr$rec==rec & pwr$mut==mut & pwr$h==h & pwr$t==t & pwr$s1>=smin & pwr$s2>=smin,] 
#    ggplot(toplot)+
#        geom_point(aes(x=factor(s2), y=factor(s1), color=power, size=nsim))+
#        scale_color_continuous(limits=c(0,colmax), type = "viridis")+
#        scale_size_continuous(limits=c(44,100), breaks=c(44,70,100))+
#        xlab("s2")+ylab("s1")
#    ggsave(paste0("../grid_plots/", seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.1/power_m", gsub("0", "", as.character(mut)), "_h", h,  "_t", t/1000, "k.png"), h=4, w=5)
    ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=nsim))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=nsim))+
        scale_fill_continuous(name="Polymorphism\nmaintained (%)", limits=c(0,100), type = "viridis")+
        xlab("s2")+ylab("s1")+
        theme_light()
    ggsave(paste0("../grid_plots/", seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.1/maintenance_m", gsub("0", "", as.character(mut)), "_h", h,  "_t", t/1000, "k.png"), h=4, w=5)
    ggplot(toplot)+
        #geom_point(aes(x=factor(s2), y=factor(s1), color=power*nsim/100, size=nsim))+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=power*nsim/100))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=round(power*nsim/100, 2)))+
        scale_fill_continuous(name="Polymorphism\ndetected (%)", limits=c(0,colmax), type = "viridis")+
        #scale_size_continuous(limits=c(44,100), breaks=c(44,70,100))+
        xlab("s2")+ylab("s1")+
        theme_light()
    ggsave(paste0("../grid_plots/", seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.1/detection_m", gsub("0", "", as.character(mut)), "_h", h,  "_t", t/1000, "k.png"), h=4, w=5)
    ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=power))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=round(power, 2)))+
        scale_fill_continuous(name="Power", limits=c(0,colmax), type = "viridis")+
        xlab("s2")+ylab("s1")+
        theme_light()
    ggsave(paste0("../grid_plots/", seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.1/power_m", gsub("0", "", as.character(mut)), "_h", h,  "_t", t/1000, "k.png"), h=4, w=5)
}

plot_topgrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=160000)
plot_topgrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_topgrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000)
plot_topgrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_topgrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000)

plot_topgrid(seltype="OD", ne=20000, rec=1e-7, mut=1e-8, h=0, t=160000)
plot_topgrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-8, h=0.25, t=160000)
plot_topgrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-8, h=0.5, t=160000)
plot_topgrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-8, h=0.25, t=160000)
plot_topgrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-8, h=0.5, t=160000)

plot_topgrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-7, h=0, t=160000)
plot_topgrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-7, h=0.25, t=160000)
plot_topgrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-7, h=0.5, t=160000)
plot_topgrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-7, h=0.25, t=160000)
plot_topgrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-7, h=0.5, t=160000)

plot_topgrid(seltype="OD", ne=20000, rec=1e-7, mut=1e-7, h=0, t=160000)
plot_topgrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-7, h=0.25, t=160000)
plot_topgrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-7, h=0.5, t=160000)
plot_topgrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-7, h=0.25, t=160000)
plot_topgrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-7, h=0.5, t=160000)

plot_topgrid(seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=16000)
plot_topgrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=16000)
plot_topgrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=16000)
plot_topgrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=16000)
plot_topgrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=16000)
plot_topgrid(seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=160000, colmax=0.7)
plot_topgrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=160000, colmax=0.7)
plot_topgrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=160000, colmax=0.7)
plot_topgrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=160000, colmax=0.7)
plot_topgrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=160000, colmax=0.7)

plot_topgrid(seltype="OD", ne=2000, rec=1e-7, mut=1e-7, h=0, t=16000)
plot_topgrid(seltype="SA", ne=2000, rec=1e-7, mut=1e-7, h=0.25, t=16000)
plot_topgrid(seltype="SA", ne=2000, rec=1e-7, mut=1e-7, h=0.5, t=16000)
plot_topgrid(seltype="AP", ne=2000, rec=1e-7, mut=1e-7, h=0.25, t=16000)
plot_topgrid(seltype="AP", ne=2000, rec=1e-7, mut=1e-7, h=0.5, t=16000)

plot_botgrid <- function(seltype, ne, rec, mut, h, t, smax=0.1, colmax=0.3){
    toplot <- pwr[pwr$seltype==seltype & pwr$Ne==ne & pwr$rec==rec & pwr$mut==mut & pwr$h==h & pwr$t==t & pwr$s1<=smax & pwr$s2<=smax,] 
    ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=nsim))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=nsim))+
        scale_fill_continuous(name="Polymorphism\nmaintained (%)", limits=c(0,100), type = "viridis")+
        xlab("s2")+ylab("s1")+
        theme_light()
    ggsave(paste0("../grid_plots/", seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.01/maintenance_m", gsub("0", "", as.character(mut)), "_h", h,  "_t", t/1000, "k.png"), h=4, w=5)
    ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=power*nsim/100))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=round(power*nsim/100, 2)))+
        scale_fill_continuous(name="Polymorphism\ndetected (%)", limits=c(0,colmax), type = "viridis")+
        xlab("s2")+ylab("s1")+
        theme_light()
    ggsave(paste0("../grid_plots/", seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.01/detection_m", gsub("0", "", as.character(mut)), "_h", h,  "_t", t/1000, "k.png"), h=4, w=5)
    ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=power))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=round(power, 2)))+
        scale_fill_continuous(name="Power", limits=c(0,colmax), type = "viridis")+
        xlab("s2")+ylab("s1")+
        theme_light()
    ggsave(paste0("../grid_plots/", seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.01/power_m", gsub("0", "", as.character(mut)), "_h", h,  "_t", t/1000, "k.png"), h=4, w=5)
}

plot_botgrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=160000)
plot_botgrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_botgrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000)
plot_botgrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_botgrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000)

plot_botgrid(seltype="OD", ne=20000, rec=1e-7, mut=1e-8, h=0, t=160000)
plot_botgrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-8, h=0.25, t=160000)
plot_botgrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-8, h=0.5, t=160000)
plot_botgrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-8, h=0.25, t=160000)
plot_botgrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-8, h=0.5, t=160000)

plot_botgrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-7, h=0, t=160000)
plot_botgrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-7, h=0.25, t=160000)
plot_botgrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-7, h=0.5, t=160000)
plot_botgrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-7, h=0.25, t=160000)
plot_botgrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-7, h=0.5, t=160000)

plot_botgrid(seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=16000)
plot_botgrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=16000)
plot_botgrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=16000)
plot_botgrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=16000)
plot_botgrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=16000)
