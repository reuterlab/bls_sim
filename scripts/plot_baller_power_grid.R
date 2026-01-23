#source /share/apps/source_files/R/R-4.3.2.source
library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
powerfile <- args[1]
powerfile <- '../baller/results/power_01.txt'
source("read_power_table.R")
pwr <- read_power_table(powerfile, ncd=F)

outdir <- '../grid_plots_baller/'
outpref <- 'baller'

plot_powergrid <- function(seltype, ne, rec, mut, h, t, smin=FALSE,smax=FALSE, colmax=1){
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
plot_powergrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=160000, colmax=0.6)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000, colmax=0.6)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000, colmax=0.6)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=160000, colmax=0.6)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=160000, colmax=0.6)
# increase recombination
plot_powergrid(seltype="OD", ne=20000, rec=1e-7, mut=1e-8, h=0, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-8, h=0.5, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-8, h=0.5, t=160000)
# increase mutation
plot_powergrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-7, h=0, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-7, h=0.25, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-7, h=0.5, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-7, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-7, h=0.5, t=160000)
# increase both
plot_powergrid(seltype="OD", ne=20000, rec=1e-7, mut=1e-7, h=0, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-7, h=0.25, t=160000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-7, mut=1e-7, h=0.5, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-7, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-7, mut=1e-7, h=0.5, t=160000)
# decrease Ne; selage=8Ne
plot_powergrid(seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=16000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=16000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=16000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=16000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=16000)
# decrease Ne; selage=80Ne
plot_powergrid(seltype="OD", ne=2000, rec=1e-8, mut=1e-8, h=0, t=160000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=160000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.25, t=160000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-8, mut=1e-8, h=0.5, t=160000)
# decrease Ne; selage=8Ne; increase m and r
plot_powergrid(seltype="OD", ne=2000, rec=1e-7, mut=1e-7, h=0, t=16000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-7, mut=1e-7, h=0.25, t=16000)
plot_powergrid(seltype="SA", ne=2000, rec=1e-7, mut=1e-7, h=0.5, t=16000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-7, mut=1e-7, h=0.25, t=16000)
plot_powergrid(seltype="AP", ne=2000, rec=1e-7, mut=1e-7, h=0.5, t=16000)
# increase selage=16Ne
plot_powergrid(seltype="OD", ne=20000, rec=1e-8, mut=1e-8, h=0, t=320000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=320000)
plot_powergrid(seltype="SA", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=320000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.25, t=320000)
plot_powergrid(seltype="AP", ne=20000, rec=1e-8, mut=1e-8, h=0.5, t=320000)

