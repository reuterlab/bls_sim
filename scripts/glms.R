# source /share/apps/source_files/R/R-4.3.2.source 
library(dplyr)
library(ggplot2)

#########################
# Reference sims power~ #
# Seltype, pstar, alpha #
#########################

infile <- "std_sims_tf0.5.csv"
infile <- "std_sims_tfps.csv"
infile <- "std_sims_balleroptp.csv"
infile <- "std_sims_ballerfixp.csv"

power_dat<-read.csv(infile)
power_dat$seltype_recoded<-relevel(as.factor(power_dat$seltype), ref="OD")
power_dat$detect<-power_dat$power*power_dat$nsim
power_dat$nodetect<-power_dat$nsim-power_dat$detect

model_glm<-glm(cbind(detect, nodetect)~pstar*selalpha*seltype_recoded, data=power_dat, family="binomial")

sink(file=paste0(infile, "_GLMsummary.txt"))
summary(model_glm)
sink()

aa <- anova(model_glm, test="Chisq")
PercDev <- aa$Deviance/aa[1, "Resid. Dev"]
sink(file=paste0(infile, "_GLManovax2.txt"))
aa
sink()

sink(file=paste0(infile, "_GLManovax2_percdev.txt"))
PercDev
sink()

sort(unique(power_dat$pstar))
mean(power_dat$power[power_dat$pstar==0.5])
mean(power_dat$power[power_dat$pstar==0.07])

anova(model_glm, test="Chisq")[-1,2]/anova(model_glm, test="Chisq")[1,4]
#  [1] 0.622810003 0.081789395 0.002940287 0.023406751 0.023476134 0.006689600 0.057282429

power_dat$predicted_power<-predict(model_glm, power_dat[, c('pstar', 'selalpha', 'seltype_recoded')], type="response")

# sanity check: plot actual vs. predicted power for each std sim condition
ggplot(power_dat)+
    geom_point(aes(x=predicted_power, y=power, color=pstar, shape=seltype))
ggsave("../plots/predicted_vs_actual_power.png")

# Make data for plots of predicted power - code for plots in plot_predictedpower.R
# pstar: 0–0.5
# selalpha: 0.05, 0.2, 0.75
pstar_plot_data<-data.frame(pstar=rep((0:50)/100, times=3*3),
                            seltype_recoded=as.factor(rep(c("OD", "AP", "SA"), each=3*51)), 
                            selalpha=rep(rep(c(0.05, 0.2, 0.625), each=51), times=3))
pstar_plot_data<-cbind(pstar_plot_data, predict(model_glm, pstar_plot_data, type="response"))
names(pstar_plot_data)[ncol(pstar_plot_data)]<-"pred_power"
write.csv(pstar_plot_data, file="Predicted_power_plot_data_pstar.csv", row.names=F)

# selalpha: 0–1
# pstar: 0.1, 0.25, 0.5
selalpha_plot_data<-data.frame(pstar=rep(c(0.1, 0.25, 0.5), times=183),
                               seltype_recoded=as.factor(c(rep("OD",303),
                                                         rep("AP",153),
                                                         rep("SA", 93))),
                               selalpha=c(rep(seq(0, 2, length.out=101), each=3),
                                          rep(seq(0, 1.12, length.out=51), each=3),
                                          rep(seq(0, 0.625, length.out=31), each=3)))
selalpha_plot_data<-cbind(selalpha_plot_data,
                          predict(model_glm, selalpha_plot_data, type="response"))
names(selalpha_plot_data)[ncol(selalpha_plot_data)]<-"pred_power"
write.csv(selalpha_plot_data, file="Predicted_power_plot_data_selalpha.csv", row.names=F)

########################### 
#      OD sims only       #
# effect of recombination #
# mutation, selage and Ne #
###########################

run_glm_anova <- function(model_glm){
    b <- model_glm$coefficients
    aa <- anova(model_glm, test="Chisq")
    PercDev <- aa$Deviance/aa[1, "Resid. Dev"]
    aa$PercDev <- round(PercDev*100, 2)
    aa$b <- b
    aa$OR <- round(exp(b), 3)
    print(aa[aa$`Pr(>Chi)`<0.05 & aa$PercDev>1, c("Deviance", "PercDev", "Pr(>Chi)", "b", "OR")])
    return(aa)
}

all_glms <- function(power_dat_OD, powerfile=powerfile, pref=pref){

    power_dat_OD$detect<-power_dat_OD$power*power_dat_OD$nsim
    power_dat_OD$nodetect<-power_dat_OD$nsim-power_dat_OD$detect
    power_dat_OD$rec_recoded<-log10(power_dat_OD$rec)
    power_dat_OD$mut_recoded<-log10(power_dat_OD$mut)
    power_dat_OD$tK<-power_dat_OD$t/1000
    power_dat_OD$NeK<-power_dat_OD$Ne/1000

    print("Recombination rate")

    model_glm <- glm(cbind(detect, nodetect)~pstar*selalpha*rec_recoded, data=power_dat_OD, subset = mut==1e-08 & Ne==20000 & t==160000, family="binomial")

    aa <- run_glm_anova(model_glm)
    write.csv(aa, file=paste0(powerfile, "_",pref, "_rec_GLManovax2.csv"))

    print("Mutation rate")

    model_glm <- glm(cbind(detect, nodetect)~pstar*selalpha*mut_recoded, data=power_dat_OD, subset = rec==1e-08 & Ne==20000 & t==160000, family="binomial")

    aa <- run_glm_anova(model_glm)
    write.csv(aa, file=paste0(powerfile, "_",pref, "_mut_GLManovax2.csv"))

    print("Age of polymorphism")

    model_glm <- glm(cbind(detect, nodetect)~pstar*selalpha*tK, data=power_dat_OD, subset = mut==1e-08 & rec==1e-08 & Ne==20000, family="binomial")
    aa <- run_glm_anova(model_glm)
    write.csv(aa, file=paste0(powerfile, "_",pref, "_tK_GLManovax2.csv"))

    model_glm <- glm(cbind(detect, nodetect)~pstar*selalpha*t_ne, data=power_dat_OD, subset = mut==1e-08 & rec==1e-08 & Ne==20000, family="binomial")
    aa <- run_glm_anova(model_glm)
    write.csv(aa, file=paste0(powerfile, "_",pref, "_tNe_GLManovax2.csv"))

    print("Effective population size")

    model_glm <- glm(cbind(detect, nodetect)~pstar*selalpha*NeK, data=power_dat_OD, subset = mut==1e-08 & rec==1e-08 & t_ne==8, family="binomial")
    #model_glm <- glm(cbind(detect, nodetect)~pstar*selalpha*NeK, data=power_dat_OD, subset = mut==1e-08 & rec==1e-08 & t_ne==16, family="binomial")

    aa <- run_glm_anova(model_glm)
    write.csv(aa, file=paste0(powerfile, "_",pref, "_NeK_GLManovax2.csv"))
}

source("read_power_table.R")

# NCD power file
powerfile="../ncd/sel100_w3000.ncd2_power2.txt"
power_dat_OD <- read_power_table(powerfile)

# NCD with tf=ps
pref <- "tfps"
power_dat_OD_ncdtfps<-power_dat_OD[power_dat_OD$seltype=="OD" & power_dat_OD$alpha==0.01 & abs(power_dat_OD$tf-power_dat_OD$pstar)<0.01,]
all_glms(power_dat_OD_ncdtfps, powerfile, pref)

# NCD with tf=0.5
pref <- "tf05"
power_dat_OD_ncdtf05<-power_dat_OD[power_dat_OD$seltype=="OD" & power_dat_OD$alpha==0.01 & power_dat_OD$tf==0.5,]
all_glms(power_dat_OD_ncdtf05, powerfile, pref)

# Ballermix power file fixpstar
powerfile="../baller/results/power_fixpstar_01.txt"
power_dat <- read_power_table(powerfile, ncd=F)
power_dat_OD_balfixp<-power_dat[power_dat$seltype=="OD" & power_dat$alpha==0.01,]
pref <- "fixps"
all_glms(power_dat_OD_balfixp, powerfile, pref)

# Ballermix power file optp
powerfile="../baller/results/power_optp_01.txt"
power_dat <- read_power_table(powerfile, ncd=F)
power_dat_OD_baloptp<-power_dat[power_dat$seltype=="OD" & power_dat$alpha==0.01,]
pref <- "optp"
all_glms(power_dat_OD_baloptp, powerfile, pref)
