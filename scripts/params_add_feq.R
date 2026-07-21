#params <- read.table("params.txt")
#params <- read.table("params_reps_extras2.txt")
#params <- read.table("params_extras.txt", colClasses=c(rep("character", 5), rep("numeric", 5)))
#params <- read.table("params_extras2.txt", colClasses=c(rep("character", 5), rep("numeric", 5)))
#params <- read.table("params_extras_APSA.txt", colClasses=c(rep("character", 5), rep("numeric", 5)))
#params <- read.table("params_extras_APcont.txt", colClasses=c(rep("character", 5), rep("numeric", 5)))

args <- commandArgs(trailingOnly=TRUE)
paramsfile <- args[1]
params <- read.table(paramsfile,  colClasses=c(rep("character", 5), rep("numeric", 5)))

colnames(params) <- c("seltype", "Ne","rec","mut","selage","h","grid","s1","s2","rep")

# calculate pstar, with corresponding formulas for each selection type
params$pstar <- NA
params_od <- params[params$seltype=="OD",]
params_ap <- params[params$seltype=="AP",]
params_sa <- params[params$seltype=="SA",]

## pstar - OD
if(any (params$seltype=="OD")){
params$pstar[params$seltype=="OD"] <- sapply(params_od$s2/(params_od$s1+params_od$s2), function(x){min(x, 1-x)}) # using MAF because I didn't save which one was the invading allele in each simulation
}
## pstar - AP
if(any (params$seltype=="AP")){
### conditions for pstar under AP
valid_pstar_ap <- params_ap$s2*params_ap$h/(1-params_ap$h+params_ap$s2*params_ap$h^2) < params_ap$s1 & params_ap$s1 < params_ap$s2*(1-params_ap$h)/(params_ap$h*(1-params_ap$s2*params_ap$h))
### calculate pstar
all_pstars_ap <- (params_ap$s1*(1-params_ap$h) - (params_ap$s2*params_ap$h) + (params_ap$s1*params_ap$s2*params_ap$h^2)) / ((params_ap$s1+params_ap$s2) * (1-2*params_ap$h) + (2*params_ap$s1*params_ap$s2*params_ap$h^2))
### fill in valid pstars only, converting to MAF
params_ap$pstar[valid_pstar_ap] <- sapply(all_pstars_ap[valid_pstar_ap], function(x){min(x, 1-x)})
params$pstar[params$seltype=="AP"] <- params_ap$pstar
}

## pstar - SA
if(any(params$seltype=="SA")){
### conditions for pstar under SA
valid_pstars_sa <- params_sa$s1*params_sa$h/(1-params_sa$h+params_sa$s1*params_sa$h) < params_sa$s2 & params_sa$s2 < params_sa$s1*(1-params_sa$h)/(params_sa$h*(1-params_sa$s1))
### calculate pstar for codominant SA
codom_pstars_sa <- (params_sa$s2 - params_sa$s1 + params_sa$s1*params_sa$s2) / (2*params_sa$s1*params_sa$s2)
### calculate pstar for SA with dominance reversal
dom_pstars_sa <- (params_sa$s2 * (1-params_sa$h) - params_sa$s1*params_sa$h) / ((params_sa$s1 + params_sa$s2) * (1-2*params_sa$h))
### fill in valid pstars for each case
params_sa$pstar[valid_pstars_sa & params_sa$h==0.5] <- codom_pstars_sa[valid_pstars_sa & params_sa$h==0.5]
params_sa$pstar[valid_pstars_sa & params_sa$h<0.5] <- dom_pstars_sa[valid_pstars_sa & params_sa$h<0.5]
params$pstar[params$seltype=="SA"] <- sapply(params_sa$pstar, function(x){min(x, 1-x)})
}

params$pstar <- round(as.numeric(params$pstar), 6)
#write.table(params, "params_feq.txt", quote=F, row.names=F, col.names=F)
#write.table(params, "params_reps_extras2_feq.txt", quote=F, row.names=F, col.names=F)
#write.table(params, "params_extras_feq.txt", quote=F, row.names=F, col.names=F)
#write.table(params, "params_extras2_feq.txt", quote=F, row.names=F, col.names=F)
#write.table(params, "params_extras_APSA_feq.txt", quote=F, row.names=F, col.names=F)
#write.table(params, "params_extras_APcont_feq.txt", quote=F, row.names=F, col.names=F)

outparamsfile <- paste0(strsplit(paramsfile,".txt")[[1]][1], "_feq.txt")
write.table(params, outparamsfile, quote=F, row.names=F, col.names=F)
