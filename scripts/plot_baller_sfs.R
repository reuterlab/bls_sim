args = commandArgs(trailingOnly=TRUE)

sfsfile=args[1]

sfstab=read.table(sfsfile)

png(paste0(sfsfile, "_SFS.png"))
plot(sfstab[,1], sfstab[,3])
dev.off()


