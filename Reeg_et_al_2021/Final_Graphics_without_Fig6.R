# required packages
require(ggplot2)
require(ggthemes)
require(gganimate)
require(gifski)
require(data.table)
require(vegan)
require(rgdal)
require(rgeos)
library(raster)
library(sp)
library(ggpattern)
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


# set working directory
# setwd("W:/Bibs/Simulationen mit BiTZ/Landscapes_Sissi")
dir <- getwd()

# read in files
pop.all.lu <- fread("pop.all.lu.txt", sep="\t")
NFT.all.lu <- fread("NFT.all.lu.txt", sep="\t")
pop.all.lu.pa <- fread("pop.all.lu.pa.txt", sep="\t")
NFT.all.lu.pa <- fread("NFT.all.lu.pa.txt", sep="\t")
pop.all.land <- fread("pop.all.land.txt", sep="\t")
NFT.all.land <- fread("NFT.all.land.txt", sep="\t")

#####
# Figure 2
# Shannon index
#####
# mean per landcapes
Landscapes_Shannon_all <- NFT.all.land[,.(mean=mean(Shannon), sd=sd(Shannon)), by=.(TZ, Year, Cluster, LID)]
# mean per Cluster
Cluster_Shannon_all <- NFT.all.land[,.(mean=mean(Shannon), sd=sd(Shannon)), by=.(TZ, Year, Cluster)]
# mean per Agroscape
Agroscape_Shannon_all <- NFT.all.land[,.(mean=mean(Shannon), sd=sd(Shannon)), by=.(TZ, Year)]

ggplot()+
  theme_few() +
  geom_line(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=0.5, linetype="dashed") +
  geom_line(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=0.5) +
  geom_point(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1) +
  geom_point(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
  geom_errorbar(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, color=factor(Cluster)), width=1.5) +
  # geom_line(data=Landscapes_Shannon_all[Year==49], aes(x=TZ, y=mean, color=factor(LID))) +
  scale_colour_brewer(palette = "Dark2") +
  ylab("Mean Shannon diversity index") + xlab("Amount of realized agricultural buffer zones [%]") +
  guides(fill=F) +  labs(color="Landscape cluster") +
  theme(axis.title = element_text(size=7), legend.title = element_text(size=7), axis.text = element_text(size=6), legend.text = element_text(size=6))
ggsave("Fig2.jpeg", width=80, height=45, units="mm", dpi=600)

ggsave("Fig2.pdf", width=80, height=45, units="mm", dpi=600)
#####
# Figure 3
# Number of functional types with population size > 0
#####
# mean per Cluster
Cluster_NFT0_all <- NFT.all.land[,.(mean=mean(FT), sd=sd(FT)), by=.(TZ, Year, Cluster)]
# mean per Agroscape
Agroscape_NFT0_all <- NFT.all.land[,.(mean=mean(FT), sd=sd(FT)), by=.(TZ, Year)]
# plot
ggplot()+
  theme_few() +
  geom_line(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=0.5, linetype="dashed") +
  geom_line(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=0.5) +
  geom_point(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1) +
  geom_point(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
  geom_errorbar(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, color=factor(Cluster)), width=1.5) +
  scale_colour_brewer(palette = "Dark2") +
  ylab("Mean number of functional types \n (population size>0)") + xlab("Amount of realized agricultural buffer zones [%]") +
  guides(fill=F) +  labs(color="Landscape cluster") +
  theme(axis.title = element_text(size=7), legend.title = element_text(size=7), 
        axis.text = element_text(size=6), legend.text = element_text(size=6))
ggsave("Fig3.jpeg", width=80, height=45, units="mm", dpi=600)

ggsave("Fig3.pdf", width=80, height=45, units="mm", dpi=600)


#####
# Figure 4
# extinction risk: Risk of falling below a threshold of 10.000 individuals/9km² at least once within the last 10 years
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
  theme(panel.border=element_blank(), axis.line = element_line(size=0.5)) +
  theme(axis.title = element_text(size=8), axis.title.x = element_blank(),
        legend.title = element_text(size=8), axis.text = element_text(size=6), legend.text = element_text(size=6))


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
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(100)) +
  ylim(-0.2,1.2) +
  xlab("") +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  labs(fill="Landscape cluster") +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5)) +
  theme(axis.title = element_text(size=8), axis.title.x = element_blank(),
        legend.title = element_text(size=8), axis.text = element_text(size=6), legend.text = element_text(size=6))


plot5 <- ggplot() + 
  annotate("text", x = 4, y = 25, size=3, label = "Amount of realized agricultural buffer zones [%]") + 
  theme_void() + theme(aspect.ratio=0.1)


# jpeg("Mean_ext_10.000_Landscape.jpeg", width=140, height=100, units="mm", res=300)
# multiplot(plot1, plot2, plot3 , plot4, plot5, layout=matrix(c(1,1,1,1,1,2,3,4,4,4,
#                                                               1,1,1,1,1,2,3,4,4,4,
#                                                               1,1,1,1,1,2,3,4,4,4,
#                                                               1,1,1,1,1,2,3,4,4,4,
#                                                               1,1,1,1,1,2,3,4,4,4,
#                                                               5,5,5,5,5,5,5,5,5,5), nrow=6, byrow=TRUE))
# dev.off()


jpeg("Fig4.jpeg", width=180, height=100, units="mm", res=600)
multiplot(plot1, plot2, plot3 , plot4, plot5, layout=matrix(c(1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              5,5,5,5,5,5,5,5,5,5), nrow=7, byrow=TRUE))
dev.off()

pdf("Fig4.pdf", width=7, height=4)
multiplot(plot1, plot2, plot3 , plot4, plot5, layout=matrix(c(1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              1,1,1,1,1,2,3,4,4,4,
                                                              5,5,5,5,5,5,5,5,5,5), nrow=7, byrow=TRUE))
dev.off()

#####
# Figure D1
# Spillover effect land use class: 
#####
# extinction risk: Risk of falling below a threshold of 1 individuals/lu class area at least once within the last 10 years
extinction_risk.lu<-copy(pop.all.lu.pa)
extinction_risk.lu[,PLAND:=0]
# normalize the values by the area of the land use class in the landscapes
# read in the land use class parameters
# luclass.parameters <- fread("LUclass_Parameters.txt", sep="\t")[,1:3]
# do not read in the land use class parameters, but the patches that were included and read in the patch def file --> sum up the area
for(dir in c("./1c", "./1f", "./2c", "./2h", 
             "./2j", "./3a", "./7a", 
             "./6e", "./8e", "./7g")){
  setwd(dir)
  analysed_patches <- fread("Analyse_patches.txt")
  analysed_patches <- analysed_patches$x
  Patch_def <- fread(list.files(pattern = "Patch"))
  Patch_def <- Patch_def[TYPE=="arable" | PID %in% analysed_patches]
  Patch_def <- Patch_def[,.(PLAND=sum(AREA)), by=.(TYPE)]
  setnames(Patch_def, "TYPE", "LU")
  Patch_def[,LID:=unlist(strsplit(dir,"./"))[2]]
  arable <- Patch_def[LU=="arable"]
  forest <- Patch_def[LU=="forest"]
  grassland <- Patch_def[LU=="grassland"]
  extinction_risk.lu[LU=="arable" & LID==arable$LID, PLAND:=arable$PLAND]
  extinction_risk.lu[LU=="forest" & LID==forest$LID, PLAND:=forest$PLAND]
  extinction_risk.lu[LU=="grassland" & LID==arable$LID, PLAND:=grassland$PLAND]
  setwd('..')
}

extinction_risk.lu[,Popsize:=Popsize/(PLAND*10000)] # population size per square meter adjust PLAND for the analysed patches
# pro TZ, Cluster, LID, Year, FT_ID: length of years
# count the events of threshold of 10.000 reached
extinction_risk.lu<- extinction_risk.lu[Popsize<0.001 & (Year>39 & Year<50), 
                                        .(ext.times=length(Year)), by=.(LU, TZ, Cluster, LID, MC, FT_ID)]
# combine data set so all cases are included
extinction_risk_complete.lu<-copy(pop.all.lu)
extinction_risk_complete.lu<- extinction_risk_complete.lu[(Year>39 & Year<50), 
                                                          .(ext.times=0), by=.(LU, TZ, Cluster, LID, MC, FT_ID)]
setkey(extinction_risk.lu, LU, TZ, Cluster, LID, MC, FT_ID)
setkey(extinction_risk_complete.lu, LU, TZ, Cluster, LID, MC, FT_ID)
extinction_risk.lu<-merge(extinction_risk_complete.lu, extinction_risk.lu, all.x=T)
extinction_risk.lu[!is.na(ext.times.y), ext.times.x:=ext.times.y]
extinction_risk.lu[,ext.times.y:=NULL]

# if threshold is reached more than once
extinction_risk.lu[,thresh_reached:=0]
extinction_risk.lu[ext.times.x>1,thresh_reached:=1]
# calculate the probability per FT
extinction_risk.lu<- extinction_risk.lu[, 
                                        .(ext.prob=sum(thresh_reached)/10), by=.(LU, TZ, Cluster, LID, FT_ID)]
# mean per Cluster
Cluster_ext_all.lu <- extinction_risk.lu[,.(mean=mean(ext.prob), sd=sd(ext.prob)), by=.(LU, TZ, Cluster)]
Cluster_ext_all.lu<-Cluster_ext_all.lu[!is.na(Cluster)]

# arable
arable.Cluster_ext_all.lu <- Cluster_ext_all.lu[LU=="arable"]
arable.Cluster_ext_all.lu <- arable.Cluster_ext_all.lu[TZ<=25, TZ_plot:=1]
arable.Cluster_ext_all.lu <- arable.Cluster_ext_all.lu[TZ==50, TZ_plot:=2]
arable.Cluster_ext_all.lu <- arable.Cluster_ext_all.lu[TZ==75, TZ_plot:=3]
arable.Cluster_ext_all.lu <- arable.Cluster_ext_all.lu[TZ==100, TZ_plot:=4]

# grassland
grass.Cluster_ext_all.lu <- Cluster_ext_all.lu[LU=="grassland"]
grass.Cluster_ext_all.lu <- grass.Cluster_ext_all.lu[TZ<=25, TZ_plot:=1]
grass.Cluster_ext_all.lu <- grass.Cluster_ext_all.lu[TZ==50, TZ_plot:=2]
grass.Cluster_ext_all.lu <- grass.Cluster_ext_all.lu[TZ==75, TZ_plot:=3]
grass.Cluster_ext_all.lu <- grass.Cluster_ext_all.lu[TZ==100, TZ_plot:=4]

# forest
forest.Cluster_ext_all.lu <- Cluster_ext_all.lu[LU=="forest"]
forest.Cluster_ext_all.lu <- forest.Cluster_ext_all.lu[TZ<=25, TZ_plot:=1]
forest.Cluster_ext_all.lu <- forest.Cluster_ext_all.lu[TZ==50, TZ_plot:=2]
forest.Cluster_ext_all.lu <- forest.Cluster_ext_all.lu[TZ==75, TZ_plot:=3]
forest.Cluster_ext_all.lu <- forest.Cluster_ext_all.lu[TZ==100, TZ_plot:=4]

# mean per Agroscape
Agroscape_ext_all.lu <- extinction_risk.lu[,.(mean=mean(ext.prob), sd=sd(ext.prob)), by=.(LU, TZ)]

# arable
arable.Agroscape_ext_all.lu <- Agroscape_ext_all.lu[LU=="arable"]
arable.Agroscape_ext_all.lu <- arable.Agroscape_ext_all.lu[TZ<=25, TZ_plot:=1]
arable.Agroscape_ext_all.lu <- arable.Agroscape_ext_all.lu[TZ==50, TZ_plot:=2]
arable.Agroscape_ext_all.lu <- arable.Agroscape_ext_all.lu[TZ==75, TZ_plot:=3]
arable.Agroscape_ext_all.lu <- arable.Agroscape_ext_all.lu[TZ==100, TZ_plot:=4]

# grassland
grass.Agroscape_ext_all.lu <- Agroscape_ext_all.lu[LU=="grassland"]
grass.Agroscape_ext_all.lu <- grass.Agroscape_ext_all.lu[TZ<=25, TZ_plot:=1]
grass.Agroscape_ext_all.lu <- grass.Agroscape_ext_all.lu[TZ==50, TZ_plot:=2]
grass.Agroscape_ext_all.lu <- grass.Agroscape_ext_all.lu[TZ==75, TZ_plot:=3]
grass.Agroscape_ext_all.lu <- grass.Agroscape_ext_all.lu[TZ==100, TZ_plot:=4]

# forest
forest.Agroscape_ext_all.lu <- Agroscape_ext_all.lu[LU=="forest"]
forest.Agroscape_ext_all.lu <- forest.Agroscape_ext_all.lu[TZ<=25, TZ_plot:=1]
forest.Agroscape_ext_all.lu <- forest.Agroscape_ext_all.lu[TZ==50, TZ_plot:=2]
forest.Agroscape_ext_all.lu <- forest.Agroscape_ext_all.lu[TZ==75, TZ_plot:=3]
forest.Agroscape_ext_all.lu <- forest.Agroscape_ext_all.lu[TZ==100, TZ_plot:=4]


# plot arable
# 1 small scale
arable.plot1 <- ggplot()+
  theme_few() +
  geom_bar(data=arable.Agroscape_ext_all.lu[TZ_plot==1], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=arable.Cluster_ext_all.lu[TZ_plot==1 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=arable.Agroscape_ext_all.lu[TZ_plot==1], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=arable.Cluster_ext_all.lu[TZ_plot==1 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                      group=factor(Cluster)), 
                color="black",position=position_dodge(width=4.5), width=1) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(0, 5, 10, 15, 20, 25)) +
  # facet_grid(LU~.)+
  ylim(-0.2,1.2) + 
  ylab("") + xlab("") +
  labs(fill="Landscape cluster") +
  theme(panel.border=element_blank(), axis.line = element_line(size=0.5),legend.position="top",
        axis.text.x=element_blank())

# 2 50
arable.plot2 <- ggplot()+
  theme_few() +
  geom_bar(data=arable.Agroscape_ext_all.lu[TZ_plot==2], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=arable.Cluster_ext_all.lu[TZ_plot==2 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=arable.Agroscape_ext_all.lu[TZ_plot==2], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=arable.Cluster_ext_all.lu[TZ_plot==2 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                      group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(50)) +
  xlab("") +
  ylim(-0.2,1.2) +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5),
        axis.text.x=element_blank())

# 3 75
arable.plot3 <- ggplot()+
  theme_few() +
  geom_bar(data=arable.Agroscape_ext_all.lu[TZ_plot==3], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=arable.Cluster_ext_all.lu[TZ_plot==3 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=arable.Agroscape_ext_all.lu[TZ_plot==3], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=arable.Cluster_ext_all.lu[TZ_plot==3 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                      group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(75)) +
  ylim(-0.2,1.2) +xlab("") +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5),
        axis.text.x=element_blank())

# 4 100
arable.plot4 <- ggplot()+
  theme_few() +
  geom_bar(data=arable.Agroscape_ext_all.lu[TZ_plot==4], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=arable.Cluster_ext_all.lu[TZ_plot==4 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=arable.Agroscape_ext_all.lu[TZ_plot==4], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=arable.Cluster_ext_all.lu[TZ_plot==4 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                      group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(100)) +
  ylim(-0.2,1.2) +
  facet_grid(LU~.) +
  xlab("") +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5),
        axis.text.x=element_blank())

# plot grassland
# 1 small scale
grass.plot1 <- ggplot()+
  theme_few() +
  geom_bar(data=grass.Agroscape_ext_all.lu[TZ_plot==1], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=grass.Cluster_ext_all.lu[TZ_plot==1 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=grass.Agroscape_ext_all.lu[TZ_plot==1], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=grass.Cluster_ext_all.lu[TZ_plot==1 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                                group=factor(Cluster)), 
                color="black",position=position_dodge(width=4.5), width=1) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(0, 5, 10, 15, 20, 25)) +
  # facet_grid(LU~.)+
  ylim(-0.2,1.2) + 
  ylab("Mean quasi-extinction risk") + xlab("") +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line = element_line(size=0.5),
        axis.text.x=element_blank())

# 2 50
grass.plot2 <- ggplot()+
  theme_few() +
  geom_bar(data=grass.Agroscape_ext_all.lu[TZ_plot==2], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=grass.Cluster_ext_all.lu[TZ_plot==2 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=grass.Agroscape_ext_all.lu[TZ_plot==2], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=grass.Cluster_ext_all.lu[TZ_plot==2 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                                group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(50)) +
  xlab("") +
  ylim(-0.2,1.2) +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5),
        axis.text.x=element_blank())

# 3 75
grass.plot3 <- ggplot()+
  theme_few() +
  geom_bar(data=grass.Agroscape_ext_all.lu[TZ_plot==3], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=grass.Cluster_ext_all.lu[TZ_plot==3 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=grass.Agroscape_ext_all.lu[TZ_plot==3], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=grass.Cluster_ext_all.lu[TZ_plot==3 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                                group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(75)) +
  ylim(-0.2,1.2) +xlab("") +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5),
        axis.text.x=element_blank())

# 4 100
grass.plot4 <- ggplot()+
  theme_few() +
  geom_bar(data=grass.Agroscape_ext_all.lu[TZ_plot==4], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=grass.Cluster_ext_all.lu[TZ_plot==4 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=grass.Agroscape_ext_all.lu[TZ_plot==4], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=grass.Cluster_ext_all.lu[TZ_plot==4 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                                group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(100)) +
  ylim(-0.2,1.2) +
  facet_grid(LU~.) +
  xlab("") +
  theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5),
        axis.text.x=element_blank())

# plot forest
# 1 small scale
forest.plot1 <- ggplot()+
  theme_few() +
  geom_bar(data=forest.Agroscape_ext_all.lu[TZ_plot==1], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=forest.Cluster_ext_all.lu[TZ_plot==1 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=forest.Agroscape_ext_all.lu[TZ_plot==1], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=forest.Cluster_ext_all.lu[TZ_plot==1 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                               group=factor(Cluster)), 
                color="black",position=position_dodge(width=4.5), width=1) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(0, 5, 10, 15, 20, 25)) +
  # facet_grid(LU~.)+
  ylim(-0.2,1.2) + 
  ylab("") + xlab("") +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line = element_line(size=0.5), axis.title.x = element_blank())

# 2 50
forest.plot2 <- ggplot()+
  theme_few() +
  geom_bar(data=forest.Agroscape_ext_all.lu[TZ_plot==2], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=forest.Cluster_ext_all.lu[TZ_plot==2 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=forest.Agroscape_ext_all.lu[TZ_plot==2], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=forest.Cluster_ext_all.lu[TZ_plot==2 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                               group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(50)) +
  xlab("") +
  ylim(-0.2,1.2) +
  theme(axis.title=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5))

# 3 75
forest.plot3 <- ggplot()+
  theme_few() +
  geom_bar(data=forest.Agroscape_ext_all.lu[TZ_plot==3], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=forest.Cluster_ext_all.lu[TZ_plot==3 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=forest.Agroscape_ext_all.lu[TZ_plot==3], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=forest.Cluster_ext_all.lu[TZ_plot==3 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                               group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(75)) +
  ylim(-0.2,1.2) +xlab("") +
  theme(axis.title=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5))

# 4 100
forest.plot4 <- ggplot()+
  theme_few() +
  geom_bar(data=forest.Agroscape_ext_all.lu[TZ_plot==4], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=forest.Cluster_ext_all.lu[TZ_plot==4 & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=forest.Agroscape_ext_all.lu[TZ_plot==4], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=forest.Cluster_ext_all.lu[TZ_plot==4 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                                               group=factor(Cluster)), 
                color="black",position=position_dodge(width=0.9), width=0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(100)) +
  ylim(-0.2,1.2) +
  facet_grid(LU~.) +
  xlab("") +
  theme(axis.title=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  guides(fill=FALSE) +
  theme(panel.border=element_blank(), axis.line.x = element_line(size=0.5))

plot5 <- ggplot() + geom_text(aes(x=0,y=0.01,label="Amount of realized agriculutral buffer zones [%]"), size=4.5) +
  ylim(-0.01,0.01) +theme_few() +theme(axis.title=element_blank(), axis.text=element_blank(), axis.line=element_blank(), axis.ticks=element_blank(), panel.border=element_blank())

plot5 <- ggplot() + 
  annotate("text", x = 0, y = 0.01, size=4, label = "Amount of realized agricultural buffer zones [%]") + 
  theme_void() + theme(aspect.ratio=0.1)

jpeg("Spillover_Land_use_class.jpeg", width=190, height=190, res=300, units="mm")
multiplot(arable.plot1, arable.plot2, arable.plot3 , arable.plot4,
          grass.plot1, grass.plot2, grass.plot3 , grass.plot4,
          forest.plot1, forest.plot2, forest.plot3 , forest.plot4,
          plot5, layout=matrix(c(1,1,1,1,1,2,3,4,
                                 1,1,1,1,1,2,3,4,
                                 5,5,5,5,5,6,7,8,
                                 5,5,5,5,5,6,7,8,
                                 9,9,9,9,9,10,11,12,
                                 9,9,9,9,9,10,11,12,
                                 13,13,13,13,13,13,13,13), nrow=7, byrow=TRUE))
dev.off()

jpeg("FigD1.jpeg", width=190, height=190, res=300, units="mm")
multiplot(arable.plot1, arable.plot2, arable.plot3 , arable.plot4,
          grass.plot1, grass.plot2, grass.plot3 , grass.plot4,
          forest.plot1, forest.plot2, forest.plot3 , forest.plot4,
          plot5, layout=matrix(c(1,1,1,1,1,2,3,4,
                                 1,1,1,1,1,2,3,4,
                                 5,5,5,5,5,6,7,8,
                                 5,5,5,5,5,6,7,8,
                                 9,9,9,9,9,10,11,12,
                                 9,9,9,9,9,10,11,12,
                                 13,13,13,13,13,13,13,13), nrow=7, byrow=TRUE))
dev.off()

# fwrite(Cluster_ext_all.lu, "Cluster_quasi_extinction_landuse.txt", sep="\t")
# fwrite(Agroscape_ext_all.lu, "Agroscape_quasi_extinction_landuse.txt", sep="\t")

#####
#
# Figure 5
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
ggplot()+
  theme_few() +
  geom_line(data=Agroscape, aes(x=TZ, y=mean), color="grey") +
  geom_line(data=Cluster, aes(x=TZ, y=mean, color=factor(Cluster))) +
  geom_point(data=Agroscape, aes(x=TZ, y=mean), color="grey") +
  geom_point(data=Cluster, aes(x=TZ, y=mean, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape, aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=3) +
  geom_errorbar(data=Cluster, aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                            color=factor(Cluster), width=3)) +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Trait, scales="free_y")+
  guides(color=guide_legend(title="Landscape cluster")) +
  ylab("Community weighted mean") + xlab("Amount of realized agricultural buffer zones [%]") +
  theme(axis.title = element_text(size=8), legend.title = element_text(size=8), 
        axis.text = element_text(size=6), legend.text = element_text(size=6), strip.text = element_text(size=8))

ggsave("Fig5.jpeg", width=180, height=90, units="mm", dpi=600)
ggsave("Fig5.pdf", width=180, height=90, units="mm", dpi=600)
