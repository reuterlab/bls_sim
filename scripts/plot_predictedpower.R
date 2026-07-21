library(ggplot2)
library(cowplot)
pstarfile <- "Predicted_power_plot_data_pstar.csv"
datapstar <- read.csv(pstarfile)
alphafile <- "Predicted_power_plot_data_selalpha.csv"
dataalpha <- read.csv(alphafile)
p <-
    ggplot(datapstar, aes(pstar, pred_power))+
#    geom_vline(xintercept=unique(dataalpha$pstar), color="gray")+
    geom_line(aes(color=factor(selalpha), group=paste(selalpha, seltype_recoded)),
                size=1.5)+
    geom_point(data=datapstar[seq(1, nrow(datapstar), 5),],
               aes(color=factor(selalpha), shape=seltype_recoded),
                stroke=1.5, size=2)+
    xlab(expression(paste("Equilibrium frequency (", hat(p), ")")))+ylab("Predicted power")+
    scale_shape(name="Model of\nselection", solid=FALSE)+
    scale_color_viridis_d(name=expression(paste("Selection\nstrength (", alpha, " )")), option="rocket", end=0.5)+
    ylim(c(0,0.5))+
    theme_classic()
ggsave(paste0(pstarfile, "_plot.png"), h=3.5, w=5)

a <- 
    ggplot(dataalpha, aes(selalpha, pred_power))+
#    geom_vline(xintercept=unique(datapstar$selalpha), color="gray")+
    geom_line(aes(color=factor(pstar), group=paste(pstar, seltype_recoded)),
               size=1)+
    geom_point(data=dataalpha[seq(1, nrow(dataalpha), 10),],
               aes(color=factor(pstar), shape=seltype_recoded),
                stroke=1.5, size=2)+
    xlab(expression(paste("Selection strength (", alpha, " )")))+ylab("Predicted power")+
    scale_shape(name="Model of\nselection", solid=FALSE)+
    scale_color_viridis_d(name=expression(paste("Equilibrium\nfrequency (", hat(p), ")")),
                          option="mako", end=0.8)+
    ylim(c(0,0.5))+
    theme_classic()
ggsave(paste0(alphafile, "_plot.png"), h=3.5, w=5)

g <- plot_grid(p+guides(shape=guide_legend(order=2)), a+guides(shape=guide_legend(order=2))+ylab(""),
          labels=c("A", "B"), ncol=2)
ggsave("../plots/Predicted_power_tf05_pstar_alpha_panels.png", h=3.5, w=10, plot=g)
