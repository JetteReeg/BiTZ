#' ####################################################################### #
#' PROJECT: Reeg, J.; Strigl, L.; Jeltsch, F. (submitted) Agricultural buffer 
#'                   zone thresholds to safeguard functional bee diversity:  
#'                   Insights from a community modelling approach
#' CONTENTS: 
#'  - This code is implemented to generate the figure 2 of the main manuscript
#'  DEPENDENCIES:
#'  - The code needs aggregated simulation output
#'  
#' AUTHOR: Jette Reeg
#' ####################################################################### #
## required packages ===========================================================
require(ggplot2)
library(RColorBrewer)
require(ggthemes)
require(data.table)
require(vegan)
## Functions ===================================================================
#####
# Multiple plot function
#####
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
#####
## DATA =======================================================================
# Make sure to be in the correct working directory
# read in files
pop.all.land <- fread("pop.all.land.txt", sep="\t")
NFT.all.land <- fread("NFT.all.land.txt", sep="\t")
# FIGURES ====================================================================
#####
# Figure 1: Flowchart
#####

# Figure 1 is the flowchart of the model and was generated using Inkscape

#####
# Figure 2a
# Number of functional types with population size > 0 over amount of TZ
#####
# mean per Cluster
Cluster_NFT0_all <- NFT.all.land[,.(mean=mean(FT), sd=sd(FT)), by=.(TZ, Year, Cluster)]
# mean per Agroscape
Agroscape_NFT0_all <- NFT.all.land[,.(mean=mean(FT), sd=sd(FT)), by=.(TZ, Year)]
# plot
nFT <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=0.5, linetype="dashed") +
  geom_line(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=0.5) +
  geom_point(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1) +
  geom_point(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
  geom_errorbar(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, color=factor(Cluster)), width=1.5) +
  # annotate("text", x=0, y=28, label= "(a)", size=3) +
  scale_colour_brewer(palette = "Dark2") +
  labs(color="Landscape cluster") + 
  guides(col = "none") +
  # guides(col = guide_legend(nrow = 2)) +
  labs(tag = "(a)") +
  ylab("Mean number of functional types \n (population size>0)") + xlab("Amount of virtually implemented agricultural \n buffer zones (ABZs) [%]") +
  theme(panel.border=element_blank(), axis.line = element_line(size=0.5)) +
  theme(legend.position=c(0.82, 0.16),legend.background = element_rect(size=0.2, linetype="solid", 
                                                                      colour ="black"), axis.title = element_text(size=7), legend.title = element_text(size=7), 
        axis.text = element_text(size=6), legend.text = element_text(size=6),
        plot.tag = element_text(size=8))

#####
# Figure 2b
# Shannon index over the amount of TZ
#####
# mean per landcapes
Landscapes_Shannon_all <- NFT.all.land[,.(mean=mean(Shannon), sd=sd(Shannon)), by=.(TZ, Year, Cluster, LID)]
# mean per Cluster
Cluster_Shannon_all <- NFT.all.land[,.(mean=mean(Shannon), sd=sd(Shannon)), by=.(TZ, Year, Cluster)]
# mean per Agroscape
Agroscape_Shannon_all <- NFT.all.land[,.(mean=mean(Shannon), sd=sd(Shannon)), by=.(TZ, Year)]

Shannon <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=0.5, linetype="dashed") +
  geom_line(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=0.5) +
  geom_point(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1) +
  geom_point(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
  geom_errorbar(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, color=factor(Cluster)), width=1.5) +
  # annotate("text", x=0, y=1, label= "(b)", size=3) +
  scale_colour_brewer(palette = "Dark2") +
  ylab("Mean Shannon diversity index") + xlab("Amount of virtually implemented \n agricultural buffer zones (ABZs) [%]") +
  labs(tag = "(b)") +
  theme(panel.border=element_blank(), axis.line = element_line(size=0.5)) +
  theme(legend.position="none", axis.title = element_text(size=7),axis.text = element_text(size=6),
        plot.tag = element_text(size=8))

#####
# Figure 2c
# extinction risk: Risk of falling below a threshold of 10.000 individuals/9km? at least once within the last 10 years
#####
extinction_risk<-copy(pop.all.land)
# pro TZ, Cluster, LID, Year, FT_ID: length of years
# count the events of threshold of 10000 reached
extinction_risk<- extinction_risk[Popsize<10000 & (Year>39 & Year<50), 
                                  .(ext.times=length(Year)), by=.(TZ, Cluster, LID, MC, FT_ID)]
# combine data set so all cases are included
extinction_risk_complete<-copy(pop.all.land)
extinction_risk_complete<- extinction_risk_complete[(Year>39 & Year<50), 
                                                    .(ext.times=0), by=.(TZ, Cluster, LID, MC, FT_ID)]
setkey(extinction_risk, TZ, Cluster, LID, MC, FT_ID)
setkey(extinction_risk_complete, TZ, Cluster, LID, MC, FT_ID)
extinction_risk<-merge(extinction_risk_complete, extinction_risk, all.x=T)
extinction_risk[!is.na(ext.times.y), ext.times.x:=ext.times.y]
extinction_risk[,ext.times.y:=NULL]

# if threshold is reached more than once
extinction_risk[,thresh_reached:=0]
extinction_risk[ext.times.x>1,thresh_reached:=1]
# calculate the probability per FT
extinction_risk<- extinction_risk[, 
                                  .(ext.prob=sum(thresh_reached)/10), by=.(TZ, Cluster, LID, FT_ID)]
# extinction_risk<- extinction_risk[, 
#                                   .(ext.prob=mean(ext.prob)), by=.(TZ, Cluster, LID)]
# mean per Cluster
Cluster_ext_all <- extinction_risk[,.(mean=mean(ext.prob), sd=sd(ext.prob)), by=.(TZ, Cluster)]
Cluster_ext_all <- Cluster_ext_all[TZ<=25, TZ_plot:=1]
Cluster_ext_all <- Cluster_ext_all[TZ==50, TZ_plot:=2]
Cluster_ext_all <- Cluster_ext_all[TZ==75, TZ_plot:=3]
Cluster_ext_all <- Cluster_ext_all[TZ==100, TZ_plot:=4]
# mean per Agroscape
Agroscape_ext_all <- extinction_risk[,.(mean=mean(ext.prob), sd=sd(ext.prob)), by=.(TZ)]
Agroscape_ext_all <- Agroscape_ext_all[TZ<=25, TZ_plot:=1]
Agroscape_ext_all <- Agroscape_ext_all[TZ==50, TZ_plot:=2]
Agroscape_ext_all <- Agroscape_ext_all[TZ==75, TZ_plot:=3]
Agroscape_ext_all <- Agroscape_ext_all[TZ==100, TZ_plot:=4]
# plot
# 1 small scale
plot1 <- ggplot()+
  theme_few() +
  geom_bar(data=Agroscape_ext_all[TZ_plot==1], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=Cluster_ext_all[TZ_plot==1 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=Agroscape_ext_all[TZ_plot==1], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=Cluster_ext_all[TZ_plot==1 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                      group=factor(Cluster)), 
                color="black",position=position_dodge(width=4.5), width=1) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(0, 5, 10, 15, 20, 25)) +
  ylim(-0.2,1.2) + 
  ylab("Mean quasi-extinction risk") + xlab("") +
  guides(fill=FALSE) +
  labs(tag = "(c)") +
  theme(panel.border=element_blank(), axis.line = element_line(size=0.5)) +
  theme(axis.title = element_text(size=8), axis.title.x = element_blank(),
        legend.title = element_text(size=8), axis.text = element_text(size=6), legend.text = element_text(size=6),
        plot.tag = element_text(size=8))


# 2 50
plot2 <- ggplot()+
  theme_few() +
  geom_bar(data=Agroscape_ext_all[TZ_plot==2], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=Cluster_ext_all[TZ_plot==2 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=Agroscape_ext_all[TZ_plot==2], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=Cluster_ext_all[TZ_plot==2 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                      group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(50)) +
  xlab("") +
  ylim(-0.2,1.2) +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5)) +
  theme(axis.title = element_text(size=8), axis.title.x = element_blank(),
        legend.title = element_text(size=8), axis.text = element_text(size=6), legend.text = element_text(size=6))


# 3 75
plot3 <- ggplot()+
  theme_few() +
  geom_bar(data=Agroscape_ext_all[TZ_plot==3], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=Cluster_ext_all[TZ_plot==3 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=Agroscape_ext_all[TZ_plot==3], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=Cluster_ext_all[TZ_plot==3 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                      group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(75)) +
  ylim(-0.2,1.2) +xlab("") +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5)) +
  theme(axis.title = element_text(size=8), axis.title.x = element_blank(),
        legend.title = element_text(size=8), axis.text = element_text(size=6), legend.text = element_text(size=6))


# 4 100
plot4 <- ggplot()+
  theme_few() +
  geom_bar(data=Agroscape_ext_all[TZ_plot==4], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=Cluster_ext_all[TZ_plot==4 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=Agroscape_ext_all[TZ_plot==4], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=Cluster_ext_all[TZ_plot==4 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                      group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  # annotate("text", x=100, y=1.2, label= "(c)", size=3) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(100)) +
  ylim(-0.2,1.2) +
  xlab("") +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5)) +
  theme(axis.title = element_text(size=8), axis.title.x = element_blank(),
        legend.title = element_text(size=8), axis.text = element_text(size=6), legend.text = element_text(size=6))


plot5 <- ggplot() + 
  annotate("text", x = 4, y = 25, size=2.5, label = "Amount of virtually implemented agricultural buffer zones (ABZs) [%]") + 
  theme_void() + theme(aspect.ratio=0.1)

#####
#
# Figure 2d 
# Community weighted mean of traits on landscape scale
#
#####
cwm.land <- copy(pop.all.land)
# trait data
traits <-fread("FT_ID_traits.txt")
# merge
setkey(cwm.land, FT_ID)
setkey(traits, FT_ID)
cwm.land<-merge(cwm.land, traits)
cwm.land<-cwm.land[,.(wtm.R=weighted.mean(R, Popsize), 
                      wtm.c=weighted.mean(c, Popsize), 
                      wtm.disp=weighted.mean(dispmean, Popsize), 
                      wtm.fly=weighted.mean(flying_period, Popsize), 
                      wtm.dist=weighted.mean(dist_eff, Popsize)), 
                   by=.(Scenario, MC, Year, TZ, LID, Cluster)]
# mean per Cluster
Cluster_cwm <- cwm.land[Year==49,.(mean.R=mean(wtm.R), sd.R=sd(wtm.R),
                                   mean.c=mean(wtm.c), sd.c=sd(wtm.c),
                                   mean.disp=mean(wtm.disp), sd.disp=sd(wtm.disp),
                                   mean.fly=mean(wtm.fly), sd.fly=sd(wtm.fly),
                                   mean.dist=mean(wtm.dist), sd.dist=sd(wtm.dist)), by=.(TZ, Cluster)]
Cluster_cwm<-Cluster_cwm[!is.na(Cluster)]
# mean per Agroscape
Agroscape_cwm <- cwm.land[Year==49,.(mean.R=mean(wtm.R), sd.R=sd(wtm.R),
                                     mean.c=mean(wtm.c), sd.c=sd(wtm.c),
                                     mean.disp=mean(wtm.disp), sd.disp=sd(wtm.disp),
                                     mean.fly=mean(wtm.fly), sd.fly=sd(wtm.fly),
                                     mean.dist=mean(wtm.dist), sd.dist=sd(wtm.dist)), by=.(TZ)]

Cluster_disp <- Cluster_cwm[,c(1,2,7,8)]
setnames(Cluster_disp, "mean.disp", "mean")
setnames(Cluster_disp, "sd.disp", "sd")
Cluster_disp[,Trait:="Dispersal [m]"]
Agroscape_disp <- Agroscape_cwm[,c(1,6,7)]
setnames(Agroscape_disp, "mean.disp", "mean")
setnames(Agroscape_disp, "sd.disp", "sd")
Agroscape_disp[,Trait:="Dispersal [m]"]
Cluster_dist <- Cluster_cwm[,c(1,2,11,12)]
setnames(Cluster_dist, "mean.dist", "mean")
setnames(Cluster_dist, "sd.dist", "sd")
Cluster_dist[,Trait:="Disturbance susceptibility"]
Agroscape_dist <- Agroscape_cwm[,c(1,10,11)]
setnames(Agroscape_dist, "mean.dist", "mean")
setnames(Agroscape_dist, "sd.dist", "sd")
Agroscape_dist[,Trait:="Disturbance susceptibility"]
Cluster_fly <- Cluster_cwm[,c(1,2,9,10)]
setnames(Cluster_fly, "mean.fly", "mean")
setnames(Cluster_fly, "sd.fly", "sd")
Cluster_fly[,Trait:="Flying period"]
Agroscape_fly <- Agroscape_cwm[,c(1,8,9)]
setnames(Agroscape_fly, "mean.fly", "mean")
setnames(Agroscape_fly, "sd.fly", "sd")
Agroscape_fly[,Trait:="Flying period"]

l <- list(Cluster_disp, Cluster_dist, Cluster_fly)
Cluster <- rbindlist(l)
l <- list(Agroscape_disp, Agroscape_dist, Agroscape_fly)
Agroscape <- rbindlist(l)

# plot
CMW <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape, aes(x=TZ, y=mean, color="darkgrey"), linetype="dashed") +
  geom_line(data=Cluster, aes(x=TZ, y=mean, color=factor(Cluster))) +
  geom_point(data=Agroscape, aes(x=TZ, y=mean, color="darkgrey")) +
  geom_point(data=Cluster, aes(x=TZ, y=mean, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape, aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="darkgrey", linetype="dashed", width=3) +
  geom_errorbar(data=Cluster, aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                  color=factor(Cluster), width=3)) +
  scale_color_manual(values=c(brewer.pal(4, "Dark2"), "darkgrey"), label=c("1", "2", "3", "4", "all")) +
  facet_wrap(~Trait, scales="free_y")+
  guides(color=guide_legend(title="Landscape cluster")) +
  ylab("Community weighted mean") + xlab("Amount of virtually implemented agricultural buffer zones (ABZs) [%]") +
  labs(tag = "(d)") +
  theme(panel.border=element_blank(), axis.line = element_line(size=0.5)) +
  theme(axis.title = element_text(size=7), legend.title = element_text(size=7), legend.position = "bottom", 
        axis.text = element_text(size=6), legend.text = element_text(size=6), strip.text = element_text(size=7), 
        legend.background = element_rect(size=0.2, linetype="solid", colour ="black"),
        plot.tag = element_text(size=8))

#####
# Figure 2 a & b & c & d
#####
jpeg("Fig2abcd.jpeg", width=180, height=180, units="mm", res=600)
multiplot(nFT, Shannon, plot1, plot2, plot3 , plot4, plot5, CMW, layout=matrix(c(
  1,1,1,1,2,2,2,2,
  1,1,1,1,2,2,2,2,
  1,1,1,1,2,2,2,2,
  1,1,1,1,2,2,2,2,
  1,1,1,1,2,2,2,2,
  3,3,3,3,3,4,5,6,
  3,3,3,3,3,4,5,6,
  3,3,3,3,3,4,5,6,
  3,3,3,3,3,4,5,6,
  7,7,7,7,7,7,7,7,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8), nrow=16, byrow=TRUE))
dev.off()
# 
pdf("Fig2abcd.pdf", width=7, height=7)
multiplot(nFT, Shannon, plot1, plot2, plot3 , plot4, plot5, CMW, layout=matrix(c(
  1,1,1,1,2,2,2,2,
  1,1,1,1,2,2,2,2,
  1,1,1,1,2,2,2,2,
  1,1,1,1,2,2,2,2,
  1,1,1,1,2,2,2,2,
  3,3,3,3,3,4,5,6,
  3,3,3,3,3,4,5,6,
  3,3,3,3,3,4,5,6,
  3,3,3,3,3,4,5,6,
  7,7,7,7,7,7,7,7,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8), nrow=16, byrow=TRUE))
dev.off()



#####
#
# Figure 3: Feeding intensities per landscape for one MC 
#
# This figure was generated using the script Final_Fig3_allLandscapes.R
#
#####



#####
#
# Figure 4: Local sensivity analyses: effect on number of FTs
# 
# This figure was generated within the BiTZ SA R-project (file "(2) Figures")
#
#####

#####
#
# Statistical analyses of quasi extinction risk
# using an ANOVA
#
#####

extinction_risk$TZ<-factor(extinction_risk$TZ)
extinction_risk$Cluster<-factor(extinction_risk$Cluster)

# summary(extinction_risk)

two.way <- aov(ext.prob ~ TZ + Cluster, data = extinction_risk)
kruskal1 <- kruskal.test(ext.prob ~ TZ, data = extinction_risk[Cluster==1])
kruskal2 <- kruskal.test(ext.prob ~ TZ, data = extinction_risk[Cluster==2])
kruskal3 <- kruskal.test(ext.prob ~ TZ, data = extinction_risk[Cluster==3])
kruskal4 <- kruskal.test(ext.prob ~ TZ, data = extinction_risk[Cluster==4])

Cl1 <- extinction_risk[Cluster==1]
pairwise.wilcox.test(Cl1$ext.prob, Cl1$TZ,
                     p.adjust.method = "BH")

one.way <- aov(ext.prob ~ TZ, data = extinction_risk[Cluster==1])

# multiple linear regression
model <- lm(ext.prob~TZ+Cluster,data=extinction_risk)
summary(model)

hist(rstandard(model))
hist(residuals(model))
qqnorm(rstandard(model))
qqline(rstandard(model))
shapiro.test(rstandard(model))


#1
plot(model, 1)

#2
plot(fitted.values(model), rstandard(model))

par(mfrow=c(2,2))
plot(two.way)
par(mfrow=c(1,1))
