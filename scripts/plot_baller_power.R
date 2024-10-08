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
hist (power$nsim[power$nsim>0], breaks=75)
pwr <- power[power$nsim>44,]

# 1. effect of compare mutation / recombination rates on power

## keep only simulations that have the equivalent set of params in mu=1e-8 and mu=1e-7
toplot_mr <- pwr[0,]
seltype="OD"
for (Ne in c(2000,20000)){
for(rec in c(1e-7,1e-8)){
for(s1 in seq(0.01, 0.1, 0.01)){
for(s2 in seq(0.01, 0.1, 0.01)){
for(t_ne in c(0.8, 1.6, 8, 16, 80, 160)){
    selectlines <- pwr$Ne==Ne & pwr$seltype==seltype & pwr$rec==rec & pwr$s1==s1 & pwr$s2==s2 & pwr$t_ne==t_ne
    if (sum(selectlines) == 2){
        toplot_mr <- rbind(toplot_mr, pwr[selectlines,])
    }
}}}}}
for (seltype in c("AP", "SA")){
for (Ne in c(2000,20000)){
for(rec in c(1e-7,1e-8)){
for(s1 in seq(0.01, 0.1, 0.01)){
for(s2 in seq(0.01, 0.1, 0.01)){
for(h in c(0.25, 0.5)){
for(t_ne in c(0.8, 1.6, 8, 16, 80, 160)){
    selectlines <- pwr$Ne==Ne & pwr$seltype==seltype & pwr$rec==rec & pwr$s1==s1 & pwr$s2==s2 & pwr$h==h & pwr$t_ne==t_ne
    if (sum(selectlines) ==2){
        toplot_mr <- rbind(toplot_mr, pwr[selectlines,])
    }
}}}}}}}

toplot_mr$mrratio <- factor(paste(toplot_mr$mut, toplot_mr$rec, sep="/"), levels=c("1e-07/1e-08", "1e-08/1e-08", "1e-07/1e-07", "1e-08/1e-07"))
ggplot(toplot_mr[toplot_mr$t_ne>=8 & toplot_mr$t_ne<=16,], aes(x=paste(mut/rec, mrratio, sep="\n"), y=power))+
    geom_boxplot(aes(color=factor(t_ne)))+
    geom_jitter(aes(color=factor(t_ne)))+
    labs(color="Selection start\ntime\n(Ne\ngenerations)",
         shape="Ne")+
    xlab("Mutation rate/recombination rate")+
    ylab("Power at alpha=0.01")
ggsave("power_mr.png", w=6, h=4.5)

# 2. effect of Ne on power

## keep only simulations that have the equivalent set of params in Ne=2k and Ne=20k
toplot_ne <- pwr[0,]
seltype="OD"
for(rec in c(1e-7,1e-8)){
for(mut in c(1e-7,1e-8)){
for(s1 in seq(0.01, 0.1, 0.01)){
for(s2 in seq(0.01, 0.1, 0.01)){
for(t_ne in c(0.8, 1.6, 8, 16, 80, 160)){
    selectlines <- pwr$seltype==seltype & pwr$rec==rec & pwr$mut==mut & pwr$s1==s1 & pwr$s2==s2 & pwr$t_ne==t_ne
    if (sum(selectlines) == 2){
        toplot_ne <- rbind(toplot_ne, pwr[selectlines,])
    }
}}}}}
for (seltype in c("AP", "SA")){
for(rec in c(1e-7,1e-8)){
for(mut in c(1e-7,1e-8)){
for(s1 in seq(0.01, 0.1, 0.01)){
for(s2 in seq(0.01, 0.1, 0.01)){
for(h in c(0.25, 0.5)){
for(t_ne in c(0.8, 1.6, 8, 16, 80, 160)){
    selectlines <- pwr$seltype==seltype & pwr$rec==rec & pwr$mut==mut & pwr$s1==s1 & pwr$s2==s2 & pwr$h==h & pwr$t_ne==t_ne
    if (sum(selectlines) ==2){
        toplot_ne <- rbind(toplot_ne, pwr[selectlines,])
    }
}}}}}}}

ggplot(toplot_ne, aes(x=factor(paste(Ne, "\n")), y=power))+
    geom_boxplot()+
    geom_jitter()+
    labs(color="Selection age\n(in Ne generations)")+
    xlab("Ne")+
    ylab("Power at alpha=0.01")
ggsave("power_ne.png", h=4.5, w=1.5)

ggplot(toplot_ne, aes(x=factor(paste(Ne, paste(mut, rec, sep="/"), sep="\n")), y=power))+
    geom_boxplot(aes(color=factor(t_ne)))+
    geom_jitter(aes(color=factor(t_ne)))+
    labs(color="Selection age\n(in Ne generations)",
         shape="Ne")+
    xlab("Ne\nMutation rate/recombination rate")+
    ylab("Power at alpha=0.01")
ggsave("power_ne_mr.png")

ggplot(toplot_ne, aes(x=factor(paste(Ne, paste(mut, rec, sep="/"), sep="\n")), y=power))+
    geom_boxplot(aes(color=factor(t)))+
    geom_jitter(aes(color=factor(t)))+
    labs(color="Selection age\n(in generations)",
         shape="Ne")+
    xlab("Ne\nMutation/recombination rate")+
    ylab("Power")


ggplot(pwr,aes(x=pstar , y=power, color=factor(t_ne)))+
    geom_point()+
   geom_smooth(method=lm)
ggplot(pwr,aes(x=selalpha , y=power, color=factor(t_ne)))+
    geom_point()+
   geom_smooth(method=lm)

ggplot(pwr,aes(x=factor(paste(mut,Ne)), y=power))+
    geom_jitter(aes(color=factor(t_ne), size=nsim))

ggplot(pwr,aes(x=factor(paste(mut,Ne)), y=power))+
    geom_boxplot(aes(color=factor(t_ne), size=nsim))
