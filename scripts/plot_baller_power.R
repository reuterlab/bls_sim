library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
powerfile <- '../baller/results/allpower.txt'
powerfile <- args[1]

power <- read.table(powerfile, header=T)
power$alpha <- as.numeric(power$alpha)
power$power <- as.numeric(power$power)
head(power)
power$sim <- apply(power, 1, function(x){paste0(x[3:9],collapse="_")})
power$sel <- apply(power, 1, function(x){paste0(x[7:8],collapse="-")})

ggplot(power[power$seltype=="OD",])+
    geom_line(aes(x=alpha, y=power, group=sim, color=t))

ggplot(power[power$seltype=="OD" & power$t=="16000",])+
    geom_line(aes(x=alpha, y=power, group=sim, color=sel))+
    ylim(0,1)
ggplot(power[power$seltype=="OD" & power$t=="32000",])+
    geom_line(aes(x=alpha, y=power, group=sim, color=sel))+
    ylim(0,1)
ggplot(power[power$seltype=="OD" & power$t=="160000",])+
    geom_line(aes(x=alpha, y=power, group=sim, color=sel))+
    ylim(0,1)
ggplot(power[power$seltype=="OD" & power$t=="320000",])+
    geom_line(aes(x=alpha, y=power, group=sim, color=sel))+
    ylim(0,1)
