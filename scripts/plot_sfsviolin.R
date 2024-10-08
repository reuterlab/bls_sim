#Rscript plot_sfsviolin.R ../baller/infiles_testing/OD_N20k_r1e-8_grid0.1/ output_s1-1_r.*c160000_.*.balmixder 100 ../plots/violin_w100_OD_N20k_r1e-8_m1e-8_c160000.png

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
inpath <- args[1]
inpattern <- args[2]
winsize <- as.numeric(args[3])
plotfname <- args[4]

#inpath <- "../baller/infiles_testing/OD_N20k_r1e-7_grid0.1_m1e-7/"
#inpattern <- "output_s1-1_h0_r.*_c160000_spl100.balmixder"
#inpath <- "../baller/infiles_testing/OD_N20k_r1e-8_grid0.1/"
#inpattern <- "output_s1-1_r.*_c160000_mut1e-8_spl100.balmixder"
infiles <- list.files(path=inpath, pattern=inpattern)

dat <- read.table (paste0(inpath, infiles[1]), header=T)
for (infile in infiles[2:length(infiles)]){
tmp <- read.table (paste0(inpath, infile), header=T)
dat <- rbind(dat,tmp)
}
midpos <- 4999

dat$distance <- abs(dat$physPos-midpos)
#ggplot(dat)+
#    geom_point(aes(x=distance, y=x/n))
#ggsave("freq_dist.png")
#
#dat$maf <- dat$x/dat$n
#dat$maf[dat$maf>0.5] <- 1-dat$maf[dat$maf>0.5]
#ggplot(dat)+
#    geom_point(aes(x=distance, y=maf))

plotviolins <- function (dat, winsize=100, plotfname="violin_windows.png"){
    s <- 0
    e <- s+winsize
    dat$win[dat$distance==0] <- 0
    winlabels <- c("0")
    i <- 0
    while (i < 10){
        i  <- i+1
        dat$win[ dat$distance > s & dat$distance <= e ] <- i
        winlabels <- c(winlabels, paste(s,e, sep="-"))
        s <- s + winsize
        e <- s + winsize
    }
    if (e < 5000){
        i <- i+1
        s <- 5000-winsize
        e <- 5000
        dat$win [ dat$distance > s & dat$distance <= e]  <- i
        winlabels <- c(winlabels, paste(s,e, sep="-"))
    }
    toplot <- dat[!is.na(dat$win),]
    toplot$win <- factor(toplot$win, levels = 0:i, labels=winlabels) 
    ggplot(toplot)+
        geom_jitter(aes(x=win, y=x/n))+
        geom_violin(aes(x=win, y=x/n))+
        xlab("Distance from selected site")+
        ylab("Derived allele frequency")
    ggsave(plotfname, w=6, h=3)
}
plotviolins(dat, winsize=winsize, plotfname=plotfname)
