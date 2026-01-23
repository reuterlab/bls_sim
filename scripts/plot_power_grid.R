#source /share/apps/source_files/R/R-4.3.2.source
library(ggplot2)

outdir <- '../grid_plots_ncd/'

#powerfile <- '../ncd/power_01.txt'
#powerfile="../ncd/power_01_OD100_w3000.ncd2.txt"
#powerfile <- '../ncd/power_01_tf0.3_w3000.ncd2.txt'
#outpref <- 'tf0.3_w3000'
#powerfile <- '../ncd/power_01_tf0.5_w1000.ncd2.txt'
#outpref <- 'tf0.5_w1000'

source("read_power_table.R")
#pwr <- read_power_table(powerfile)
#pwr$pstar <- unlist(pwr$pstar)

powerfile="../ncd/sel100_w3000.ncd2_power.txt"
pwr <- read_power_table(powerfile)
pwr <- pwr[pwr$alpha==0.01,]

plot_ap <- function(seltype, h, smin=FALSE,smax=FALSE){
    if(! smin & ! smax){
        toplot <- pwr[pwr$seltype==seltype & pwr$h==h,] 
        outpref <- paste0(outdir, seltype, "_h", h)
        colmax <- 2
    }
    if(smin){
        toplot <- pwr[pwr$seltype==seltype & pwr$h==h & pwr$s1>=smin & pwr$s2>=smin,] 
        outpref <- paste0(outdir, seltype, "_grid0.1_h", h)
        colmax <- 2
    }
    if(smax){
        toplot <- pwr[pwr$seltype==seltype & pwr$h==h & pwr$s1<=smax & pwr$s2<=smax,]
        outpref <- paste0(outdir, seltype, "_grid0.01_h", h)
        colmax <- 0.2
    }
    p <- ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=pstar))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=round(pstar, 2)))+
        scale_fill_viridis_c(name="Equilibrium\nfrequency (p*)", limits=c(0,0.5), option = "mako", begin=0.2)+
        xlab("s2")+ylab("s1")+
        theme_light()
    if(h>0){
        p <- p+labs(title=paste(seltype, "h=",h))
    } else{
        p <- p+labs(title=paste(seltype))
    }
    ggsave(paste0(outpref, "_pstar.png"), h=4, w=5)
    a <- ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=selalpha))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=round(selalpha, 2)))+
        scale_fill_viridis_c(name="Selection\nstrength (alpha)", limits=c(0,colmax), option = "rocket", begin=0.2)+
        xlab("s2")+ylab("s1")+
        theme_light()
    if(h>0){
        a <- a+labs(title=paste(seltype, "h=",h))
    } else{
        a <- a+labs(title=paste(seltype))
    }
    ggsave(paste0(outpref, "_selalpha.png"), h=4, w=5)
    return(list(a,p))
}
od_plots <- plot_ap("OD", 0)
ap.5_plots <- plot_ap("AP", 0.5)
ap.25_plots <- plot_ap("AP", 0.25)
sa.5_plots <- plot_ap("SA", 0.5)
sa.25_plots <- plot_ap("SA", 0.25)

pstarlegend <- get_legend(od_plots[[2]])
pstarplot <- plot_grid(od_plots[[2]]+guides(fill="none"), ap.25_plots[[2]]+guides(fill="none"), sa.25_plots[[2]]+guides(fill="none"),
                       pstarlegend, ap.5_plots[[2]]+guides(fill="none"), sa.5_plots[[2]]+guides(fill="none"),
                       labels=c("A", "B", "C", "", "D", "E"))
pstarplot
ggsave(paste0(outdir, "pstar_all.png"), h=7,  w=10,  plot=pstarplot)

alphalegend <- get_legend(od_plots[[1]])
alphaplot <- plot_grid(od_plots[[1]]+guides(fill="none"), ap.25_plots[[1]]+guides(fill="none"), sa.25_plots[[1]]+guides(fill="none"),
                       alphalegend, ap.5_plots[[1]]+guides(fill="none"), sa.5_plots[[1]]+guides(fill="none"),
                       labels=c("A", "B", "C", "", "D", "E"))
alphaplot
ggsave(paste0(outdir, "alpha_all.png"), h=7,  w=10,  plot=alphaplot)

## plot power in a grid
plot_powergrid <- function(pwr, seltype, ne, rec, mut, h, t, smin=FALSE,smax=FALSE, colmax=1){
    if(! smin & ! smax){
        toplot <- pwr[pwr$seltype==seltype & pwr$Ne==ne & pwr$rec==rec & pwr$mut==mut & pwr$h==h & pwr$t==t,] 
        outsubdir <- paste0(outdir, seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_combgrid/")
    }
    if(smin){
        toplot <- pwr[pwr$seltype==seltype & pwr$Ne==ne & pwr$rec==rec & pwr$mut==mut & pwr$h==h & pwr$t==t, pwr$s1>=smin & pwr$s2>=smin,] 
        outsubdir <- paste0(outdir, seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.1/")
    }
    if(smax){
        toplot <- pwr[pwr$seltype==seltype & pwr$Ne==ne & pwr$rec==rec & pwr$mut==mut & pwr$h==h & pwr$t==t & pwr$s1<=smax & pwr$s2<=smax,] 
        outsubdir <- paste0(outdir, seltype, "_N", ne/1000, "k_r", gsub("0", "", as.character(rec)), "_grid0.01/")
    }
    ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=power))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=round(power, 2)), color="white")+
        scale_fill_continuous(name="Power", limits=c(0,colmax), type = "viridis")+
        xlab("s2")+ylab("s1")+
        labs(title=paste0(seltype, " h=", h, " m=", mut, " r=", rec, " Ne=", ne/1000, "k t=", t/1000, "k"))+
        theme_light()
    ggsave(paste0(outsubdir, "power_", outpref, "_m", gsub("0", "", as.character(mut)), "_h", h,  "_t", t/1000, "k.png"), h=4, w=5)
}

# human-like; recent selection (8Ne)
outpref <- "tf0.5_w3000_"
plot_powergrid(pwr[pwr$tf==0.5,], seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=160000)
outpref <- "tfpstar_w3000"
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=160000, colmax=0.6)
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),],seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000, colmax=0.6)
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),],seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000, colmax=0.6)
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),],seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000, colmax=0.6)
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),],seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000, colmax=0.6)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000)
# increase recombination
outpref <- "tf0.5_w3000_"
plot_powergrid(pwr[pwr$tf==0.5,], seltype="OD", ne=20000, rec=1e-7, mut=1e-8, h=0, t=160000)
outpref <- "tfpstar_w3000_"
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], seltype="OD", ne=20000, rec=1e-7, mut=1e-8, h=0, t=160000)
plot_powergrid(seltype="OD", ne=20000, rec=1e-7, mut=1e-8, h=0, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-8, h=0.5, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-8, h=0.5, t=160000)
# increase mutation
outpref <- "tf0.5_w3000_"
plot_powergrid(pwr[pwr$tf==0.5,], seltype="OD", ne=20000, rec=1e-8, mut=1e-7, h=0, t=160000)
outpref <- "tfpstar_w3000_"
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], seltype="OD", ne=20000, rec=1e-8, mut=1e-7, h=0, t=160000)
plot_powergrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-7, h=0, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-7, h=0.25, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-7, h=0.5, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-7, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-7, h=0.5, t=160000)
# increase both
outpref <- "tf0.5_w3000_"
plot_powergrid(pwr[pwr$tf==0.5,], seltype="OD", ne=20000, rec=1e-7, mut=1e-7, h=0, t=160000)
outpref <- "tfpstar_w3000_"
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], seltype="OD", ne=20000, rec=1e-7, mut=1e-7, h=0, t=160000)
plot_powergrid(seltype="OD", ne=20000, rec=1e-7, mut=1e-7, h=0, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-7, h=0.25, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-7, h=0.5, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-7, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-7, h=0.5, t=160000)
# decrease Ne; selage=8Ne [to do]
outpref <- "tf0.5_w3000_"
plot_powergrid(pwr[pwr$tf==0.5,], seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=16000)
outpref <- "tfpstar_w3000_"
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=16000)
plot_powergrid(seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=16000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=16000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=16000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=16000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=16000)
# decrease Ne; selage=80Ne
outpref <- "tf0.5_w3000_"
plot_powergrid(pwr[pwr$tf==0.5,], seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=160000)
outpref <- "tfpstar_w3000_"
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=160000)
plot_powergrid(seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=160000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=160000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=160000)
# decrease Ne; selage=8Ne; increase m and r
outpref <- "tf0.5_w3000_"
plot_powergrid(pwr[pwr$tf==0.5,], seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=16000)
outpref <- "tfpstar_w3000_"
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=16000)
plot_powergrid(seltype="OD", ne=2000, rec=1e-7, mut=1e-7, h=0, t=16000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-7, mut=1e-7, h=0.25, t=16000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-7, mut=1e-7, h=0.5, t=16000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-7, mut=1e-7, h=0.25, t=16000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-7, mut=1e-7, h=0.5, t=16000)
# increase selage=16Ne
outpref <- "tf0.5_w3000_"
plot_powergrid(pwr[pwr$tf==0.5,], seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=320000)
outpref <- "tfpstar_w3000_"
plot_powergrid(pwr[round(pwr$tf,2)==round(pwr$pstar,2),], seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=320000)
plot_powergrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=320000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=320000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=320000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=320000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=320000)

# plot power diff

plot_powerdiffgrid <- function(df1=std_sims, df2, suffix="diff", diflabel=""){
    seltype="OD"
    df1_OD <- df1[df1$seltype==seltype,]
    df2_OD <- df2[df2$seltype==seltype,]
    toplot <- merge(df1_OD, df2_OD, by=c("s1", "s2"))
    ggplot(toplot)+
        geom_tile(aes(x=factor(s2), y=factor(s1), fill=power.y-power.x))+
        geom_text(aes(x=factor(s2), y=factor(s1), label=round(power.y-power.x, 2)), color="white")+
        scale_fill_gradient2(name=paste0("Power difference\n", diflabel),low="blue",high="red",mid="grey", limits=c(-0.4, 0.4))+
        xlab("s2")+ylab("s1")+
        theme_light()+
        labs(title=paste(seltype))
    ggsave(paste0(outdir, seltype, "_", suffix, ".png"), h=3.5, w=5)
    for (seltype in c("AP", "SA")){
        for (h in c(0.25, 0.5)){
            df1_sub <- df1[df1$seltype==seltype & df1$h==h,]
            df2_sub <- df2[df2$seltype==seltype & df2$h==h,]
            toplot <- merge(df1_sub, df2_sub, by=c("s1", "s2"))
            ggplot(toplot)+
            geom_tile(aes(x=factor(s2), y=factor(s1), fill=power.y-power.x))+
            geom_text(aes(x=factor(s2), y=factor(s1), label=round(power.y-power.x, 2)), color="white")+
            scale_fill_gradient2(name=paste0("Power difference\n",diflabel),low="blue",high="red",mid="grey", limits=c(-0.4, 0.4))+
            xlab("s2")+ylab("s1")+
            theme_light()+
            labs(title=paste(seltype, "h=",h))
            ggsave(paste0(outdir, seltype,"_h", h, "_", suffix, ".png"), h=3.5, w=5)
        }
    }
}

std_sims_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000,] 
incr_rec_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-7 & pwr$mut==1e-8 & pwr$t==160000,] 
plot_powerdiffgrid(std_sims_tf05, incr_rec_tf05, suffix="increc_tf0.5", diflabel="increasing\nrecombination\nrate")

std_sims_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000,] 
incr_rec_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-7 & pwr$mut==1e-8 & pwr$t==160000,] 
plot_powerdiffgrid(std_sims_tfps, incr_rec_tfps, suffix="increc_tfps", diflabel="increasing\nrecombination\nrate")

older_selage_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==320000,] 
plot_powerdiffgrid(std_sims_tf05, older_selage_tf05, suffix="incselage_tf05", diflabel="increasing\nselection\nonset time")
older_selage_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==320000,] 
plot_powerdiffgrid(std_sims_tfps, older_selage_tfps, suffix="incselage_tfps", diflabel="increasing\nselection\nonset time")

smaller_ne_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000,] 
plot_powerdiffgrid(std_sims_tf05, smaller_ne_tf05, suffix="rednet160_tf05", diflabel="with smaller Ne")
smaller_ne_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar, 2) & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==160000,] 
plot_powerdiffgrid(std_sims_tfps, smaller_ne_tfps, suffix="rednet160_tfps", diflabel="with smaller Ne")

smaller_ne_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000,] 
plot_powerdiffgrid(std_sims_tf05, smaller_ne_tf05, suffix="rednet16_tf05", diflabel="with smaller Ne")
smaller_ne_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar, 2) & pwr$Ne==2000 & pwr$rec==1e-8 & pwr$mut==1e-8 & pwr$t==16000,] 
plot_powerdiffgrid(std_sims_tfps, smaller_ne_tfps, suffix="rednet16_tfps", diflabel="with smaller Ne")

increase_mu_tf05 <- pwr[pwr$tf==0.5 & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-7 & pwr$t==160000,] 
increase_mu_tfps <- pwr[round(pwr$tf,2)==round(pwr$pstar,2) & pwr$Ne==20000 & pwr$rec==1e-8 & pwr$mut==1e-7 & pwr$t==160000,] 
plot_powerdiffgrid(std_sims_tf05, increase_mu_tf05, suffix="incmu_tf05", diflabel="increasing\nmutation rate")
plot_powerdiffgrid(std_sims_tfps, increase_mu_tfps, suffix="incmu_tfps", diflabel="increasing\nmutation rate")
