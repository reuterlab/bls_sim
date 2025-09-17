read_power_table <- function(powerfile){
    power <- read.table(powerfile, header=T)

#    png("../plots/nsim_hist.png")
#    hist(power$nsim[power$nsim>0], breaks=75, main="Simulations where polymorphism was maintained",
#    xlab="Number of simulations")
#    dev.off()

    # remove lines with fewer than 44 bls sims
    power <- power[power$nsim>44,]

    power$tf <- round(power$tf, 6)
    # label for each unique set of simulation params
    power$sim <- apply(power, 1, function(x){paste0(x[c(1, 3:10,12:13)],collapse="_")})

    # remove one of the duplicated simulations with s0.1-0.1 (one was done in the small s grid, another in the large s grid)
    duplicated_sim <- power$sim[duplicated(power$sim)]

    torm <- c()
#    diffs <- c()
    for(s in duplicated_sim){
        idxs <- which(power$sim==s)
#        diffs <- c(diffs, abs(power$power[idxs[1]] - power$power[idxs[2]]))
        # keep only the one with the highest nsim
        torm <- c(torm, idxs[which.min(power$nsim[idxs])])
    }
#    hist(diffs, main="Histogram of difference in power between duplicated sims")
    power <- power[-torm,]

    # remove s=0.09 and s=0.9
    #power <- power[-which (power$s1 %in% c(0.09, 0.9) | power$s2 %in% c(0.09,0.9)),]

    #calculate alphas and pstars
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
    power$selalpha[power$seltype=="SA"] <- ((power_sa$s1 + power_sa$s2)/2)*(1-2*power_sa$h)+2*power_sa$s1*power_sa$s2*power_sa$h^2

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

    power$pstar <- unlist(power$pstar)
    return(power)
}
