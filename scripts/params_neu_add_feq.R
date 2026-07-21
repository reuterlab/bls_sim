#params_sel <- read.table("params_extras2_feq.txt", colClasses="character")
params_sel <- read.table("params_all100_feq.txt", colClasses="character")
colnames(params_sel) <- c("seltype", "Ne","rec","mut","selage","h","grid","s1","s2","rep", "pstar")
params_sel$pstar <- round(as.numeric(params_sel$pstar), 6)

params_neu <- read.table("params_neutralnull.txt", colClasses="character")
colnames(params_neu) <- c("seltype", "Ne","rec","mut","selage","h","grid","s1","s2","rep")

params_neu_pstar <- unique(
                           merge(params_neu, params_sel[,c("Ne", "rec", "mut", "selage", "pstar")], 
                                 by.x=c("Ne", "rec", "mut", "selage"), 
                                 by.y=c("Ne", "rec", "mut", "selage"),
                           all.y=T)
                           )
#reorder cols
params_neu_pstar <- params_neu_pstar[,c(5, 1:4, 6:11)]

#write.table(params_neu_pstar, "params_neutralnull_feq.txt", quote=F, col.names=F, row.names=F)
write.table(params_neu_pstar, "params_neutralnull_all100_feq.txt", quote=F, col.names=F, row.names=F)
