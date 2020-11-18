# required packages
require(ggplot2)
require(ggthemes)
require(gganimate)
require(gifski)
require(data.table)
require(vegan)
#####
# Multiple plot function
#
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

# read in files
pop.all.lu <- fread("pop.all.lu.txt", sep="\t")
NFT.all.lu <- fread("NFT.all.lu.txt", sep="\t")
pop.all.lu.pa <- fread("pop.all.lu.pa.txt", sep="\t")
NFT.all.lu.pa <- fread("NFT.all.lu.pa.txt", sep="\t")
pop.all.land <- fread("pop.all.land.txt", sep="\t")
NFT.all.land <- fread("NFT.all.land.txt", sep="\t")

#####
# Figure 1
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
  geom_line(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1, linetype="dashed") +
  geom_line(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
  geom_point(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1) +
  geom_point(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
  geom_errorbar(data=Agroscape_Shannon_all[Year==49], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=Cluster_Shannon_all[Year==49 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, color=factor(Cluster)), width=1) +
  # geom_line(data=Landscapes_Shannon_all[Year==49], aes(x=TZ, y=mean, color=factor(LID))) +
  scale_colour_brewer(palette = "Dark2") +
  ylab("Mean Shannon diversity index") + xlab("Amount of realized transition zones [%]") +
  guides(fill=F) +  labs(color="Landscape cluster")
ggsave("Mean_shannon_Landscape.png", width=10, height=5)

#####
# Figure 2
# Number of functional types with population size > 0
#####
# mean per Cluster
Cluster_NFT0_all <- NFT.all.land[,.(mean=mean(FT), sd=sd(FT)), by=.(TZ, Year, Cluster)]
# mean per Agroscape
Agroscape_NFT0_all <- NFT.all.land[,.(mean=mean(FT), sd=sd(FT)), by=.(TZ, Year)]
# plot
ggplot()+
  theme_few() +
  geom_line(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1, linetype="dashed") +
  geom_line(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
  geom_point(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1) +
  geom_point(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
  geom_errorbar(data=Agroscape_NFT0_all[Year==49], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
  geom_errorbar(data=Cluster_NFT0_all[Year==49 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, color=factor(Cluster)), width=1) +
  scale_colour_brewer(palette = "Dark2") +
  ylab("Mean number of functional types (population size>0)") + xlab("Amount of realized transition zones [%]") +
  guides(fill=F) +  labs(color="Landscape cluster")
ggsave("Mean_NFT_0_Landscape.png", width=10, height=5)

#####
# Figure 2a
# Number of functional types with population size > 0
#####
# # mean per Cluster
# Cluster_NFT10.000_all <- NFT.all.land[,.(mean=mean(FT_10.000), sd=sd(FT_10.000)), by=.(TZ, Year, Cluster)]
# # mean per Agroscape
# Agroscape_NFT10.000_all <- NFT.all.land[,.(mean=mean(FT_10.000), sd=sd(FT_10.000)), by=.(TZ, Year)]
# # plot
# ggplot()+
#   theme_few() +
#   geom_line(data=Agroscape_NFT10.000_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1, linetype="dashed") +
#   geom_line(data=Cluster_NFT10.000_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
#   geom_point(data=Agroscape_NFT10.000_all[Year==49], aes(x=TZ, y=mean), color="darkgrey", size=1) +
#   geom_point(data=Cluster_NFT10.000_all[Year==49 & Cluster!="NA"], aes(x=TZ, y=mean, color=factor(Cluster)), size=1) +
#   geom_errorbar(data=Agroscape_NFT10.000_all[Year==49], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=1) +
#   geom_errorbar(data=Cluster_NFT10.000_all[Year==49 & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, color=factor(Cluster)), width=1) +
#   scale_colour_brewer(palette = "Dark2") +
#   scale_fill_brewer(palette = "Dark2") +
#   ylab("Mean number of functional types (population size>10.000)") + xlab("Amount of realized transition zones [%]") +
#   guides(fill=F) +  labs(color="Landscape cluster")
# ggsave("Mean_NFT_10.000_Landscape.png", width=10, height=5)

#####
# Figure 3a
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
# mean per Agroscape
Agroscape_ext_all <- extinction_risk[,.(mean=mean(ext.prob), sd=sd(ext.prob)), by=.(TZ)]
# plot
ggplot()+
  theme_few() +
  geom_bar(data=Agroscape_ext_all[], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=Cluster_ext_all[Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)), stat="identity", position="dodge") +
  geom_errorbar(data=Agroscape_ext_all[], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=2) +
  geom_errorbar(data=Cluster_ext_all[Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                         group=factor(Cluster)), 
                color="black",position=position_dodge(width=4.5), width=2) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks=c(0, 25, 50, 75, 100)) +
  ylab("Mean quasi-extinction risk") + xlab("Amount of realized transition zones [%]") +
  labs(fill="Landscape cluster")
ggsave("Mean_ext_10.000_Landscape.png", width=10, height=5)

# #####
# # Figure 3b
# # number of FTs with no extinction risk (as pop.sizes do not fall below 10.000 within the last 10 years)
# #####
# # calculate the number of FTs with a probability >0
# extinction_risk_NFT<-extinction_risk[ext.prob>0,.(FT=length(FT_ID)), by=.(TZ, Cluster, LID)]
# # combine data set so all cases are included
# extinction_risk_NFT_complete<-copy(extinction_risk)
# extinction_risk_NFT_complete<- extinction_risk_NFT_complete[, 
#                                                             .(FT=0), by=.(TZ, Cluster, LID)]
# setkey(extinction_risk_NFT, TZ, Cluster, LID)
# setkey(extinction_risk_NFT_complete, TZ, Cluster, LID)
# extinction_risk_NFT<-merge(extinction_risk_NFT_complete, extinction_risk_NFT, all.x=T)
# extinction_risk_NFT[!is.na(FT.y), FT.x:=FT.y]
# extinction_risk[,FT.y:=NULL]
# # mean per Cluster
# Cluster_ext_NFT_all <- extinction_risk_NFT[,.(mean=mean(FT.x), sd=sd(FT.x)), by=.(TZ, Cluster)]
# # mean per Agroscape
# Agroscape_ext_NFT_all <- extinction_risk_NFT[,.(mean=mean(FT.x), sd=sd(FT.x)), by=.(TZ)]
# # plot
# ggplot()+
#   theme_few() +
#   geom_bar(data=Agroscape_ext_NFT_all[], aes(x=TZ, y=28-mean), fill="grey", stat="identity") +
#   geom_bar(data=Cluster_ext_NFT_all[Cluster!="NA"], aes(x=TZ, y=28-mean, fill=factor(Cluster)), stat="identity", position="dodge") +
#   geom_errorbar(data=Agroscape_ext_NFT_all[], aes(x=TZ, ymin=28-mean-sd, ymax=28-mean+sd), color="grey") +
#   geom_errorbar(data=Cluster_ext_NFT_all[Cluster!="NA"], aes(x=TZ, ymin=28-mean-sd, ymax=28-mean+sd, 
#                                                              group=factor(Cluster)), color="black",position="dodge") +
#   scale_fill_brewer(palette = "Dark2") +
#   ylab("Mean number of FTs with no quasi-extinction risk") + xlab("Amount of realized transition zones [%]") +
#   labs(fill="Landscape cluster")
# ggsave("Mean_NFT_pop_10.000_Landscape.png", width=10, height=5)

#####
# Figure 4
# Spillover effect: 
#####
# extinction risk: Risk of falling below a threshold of 1 individuals/lu class area at least once within the last 10 years
extinction_risk.lu<-copy(pop.all.lu.pa)
extinction_risk.lu[,PLAND:=0]
# normalize the values by the area of the land use class in the landscapes
# read in the land use class parameters
# luclass.parameters <- fread("LUclass_Parameters.txt", sep="\t")[,1:3]
# do not read in the land use class parameters, but the patches that were included and read in the patch def file --> sum up the area
for(dir in c("./1c", "./1f", "./2c", "./2h", 
             "./2j", "./3a", "./3c", "./7a", 
             "./6e", "./8e", "./7g")){
  setwd(dir)
  analysed_patches <- fread("Analyse_patches.txt")$x
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
# mean per Agroscape
Agroscape_ext_all.lu <- extinction_risk.lu[,.(mean=mean(ext.prob), sd=sd(ext.prob)), by=.(LU, TZ)]
# plot
ggplot()+
  theme_few() +
  geom_bar(data=Agroscape_ext_all.lu[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean), fill="grey", stat="identity") +
  geom_bar(data=Cluster_ext_all.lu[LU=="arable" | LU=="grassland" | LU=="forest" & Cluster!="NA"], aes(x=TZ, y=mean, fill=factor(Cluster)),
           stat="identity", position="dodge") +
  geom_errorbar(data=Agroscape_ext_all.lu[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd), color="grey", width=2) +
  geom_errorbar(data=Cluster_ext_all.lu[LU=="arable" | LU=="grassland" | LU=="forest" & Cluster!="NA"], aes(x=TZ, ymin=mean-sd, ymax=mean+sd, 
                                                         group=factor(Cluster)), 
                color="black",position=position_dodge(width=4.5), width=2) +
  facet_grid(~LU) +
  scale_fill_brewer(palette = "Dark2") +
  facet_grid(LU~.) +
  scale_x_continuous(breaks=c(0, 25, 50, 75, 100)) +
  ylab("Mean quasi-extinction risk") + xlab("Amount of realized transition zones [%]") +
  labs(fill="Landscape cluster")
ggsave("Spillover_Land_use_class.png", width=10, height=7)

fwrite(Cluster_ext_all.lu, "Cluster_quasi_extinction_landuse.txt", sep="\t")
fwrite(Agroscape_ext_all.lu, "Agroscape_quasi_extinction_landuse.txt", sep="\t")

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
# plot
disp <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm, aes(x=TZ, y=mean.disp), color="grey") +
  geom_line(data=Cluster_cwm[], aes(x=TZ, y=mean.disp, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm, aes(x=TZ, y=mean.disp), color="grey") +
  geom_point(data=Cluster_cwm[], aes(x=TZ, y=mean.disp, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[], aes(x=TZ, ymin=mean.disp-sd.disp, ymax=mean.disp+sd.disp), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[], aes(x=TZ, ymin=mean.disp-sd.disp, ymax=mean.disp+sd.disp, 
                            color=factor(Cluster), width=1)) +
  scale_color_brewer(palette = "Dark2") +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Dispersal range") +
  labs(fill="Landscape cluster")
R <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm, aes(x=TZ, y=mean.R), color="grey") +
  geom_line(data=Cluster_cwm[], aes(x=TZ, y=mean.R, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm, aes(x=TZ, y=mean.R), color="grey") +
  geom_point(data=Cluster_cwm[], aes(x=TZ, y=mean.R, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[], aes(x=TZ, ymin=mean.R-sd.R, ymax=mean.R+sd.R), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[], aes(x=TZ, ymin=mean.R-sd.R, ymax=mean.R+sd.R, 
                                        color=factor(Cluster)), width=1.5) +
  scale_color_brewer(palette = "Dark2") +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Growth rate") +
  labs(fill="Landscape cluster")
c <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm, aes(x=TZ, y=mean.c), color="grey") +
  geom_line(data=Cluster_cwm[], aes(x=TZ, y=mean.c, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm, aes(x=TZ, y=mean.c), color="grey") +
  geom_point(data=Cluster_cwm[], aes(x=TZ, y=mean.c, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[], aes(x=TZ, ymin=mean.c-sd.c, ymax=mean.c+sd.c), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[], aes(x=TZ, ymin=mean.c-sd.c, ymax=mean.c+sd.c, 
                                        color=factor(Cluster)), width=1.5) +
  scale_color_brewer(palette = "Dark2") +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Competitiveness") +
  labs(fill="Landscape cluster")
Fly <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm, aes(x=TZ, y=mean.fly), color="grey") +
  geom_line(data=Cluster_cwm[], aes(x=TZ, y=mean.fly, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm, aes(x=TZ, y=mean.fly), color="grey") +
  geom_point(data=Cluster_cwm[], aes(x=TZ, y=mean.fly, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[], aes(x=TZ, ymin=mean.fly-sd.fly, ymax=mean.fly+sd.fly), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[], aes(x=TZ, ymin=mean.fly-sd.fly, ymax=mean.fly+sd.fly, 
                                        color=factor(Cluster)), width=1.5) +
  scale_color_brewer(palette = "Dark2") +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Flying period") +
  labs(fill="Landscape cluster")
dist <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm, aes(x=TZ, y=mean.dist), color="grey") +
  geom_line(data=Cluster_cwm[], aes(x=TZ, y=mean.dist, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm, aes(x=TZ, y=mean.dist), color="grey") +
  geom_point(data=Cluster_cwm[], aes(x=TZ, y=mean.dist, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[], aes(x=TZ, ymin=mean.dist-sd.dist, ymax=mean.dist+sd.dist), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[], aes(x=TZ, ymin=mean.dist-sd.dist, ymax=mean.dist+sd.dist, 
                                        color=factor(Cluster)), width=1.5) +
  scale_color_brewer(palette = "Dark2") +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Disturbance susceptibility") +
  labs(fill="Landscape cluster")

png("CWM_landscape.png", width=900, height=300)
multiplot(disp, Fly, dist, cols=3)
dev.off()

#####
#
# Figure 6
# CWM on land use scale
# 
#####
cwm.lu <- copy(pop.all.lu.pa)
# trait data
traits <-fread("FT_ID_traits.txt")
# merge
setkey(cwm.lu, FT_ID)
setkey(traits, FT_ID)
cwm.lu<-merge(cwm.lu, traits)
cwm.lu<-cwm.lu[,.(wtm.R=weighted.mean(R, Popsize), 
                      wtm.c=weighted.mean(c, Popsize), 
                      wtm.disp=weighted.mean(dispmean, Popsize), 
                      wtm.fly=weighted.mean(flying_period, Popsize), 
                      wtm.dist=weighted.mean(dist_eff, Popsize)), 
                   by=.(Scenario, MC, Year, TZ, LID, Cluster, LU)]
# mean per Cluster
Cluster_cwm <- cwm.lu[Year==49,.(mean.R=mean(wtm.R), sd.R=sd(wtm.R),
                                   mean.c=mean(wtm.c), sd.c=sd(wtm.c),
                                   mean.disp=mean(wtm.disp), sd.disp=sd(wtm.disp),
                                   mean.fly=mean(wtm.fly), sd.fly=sd(wtm.fly),
                                   mean.dist=mean(wtm.dist), sd.dist=sd(wtm.dist)), by=.(TZ, Cluster, LU)]
Cluster_cwm<-Cluster_cwm[!is.na(Cluster)]
# mean per Agroscape
Agroscape_cwm <- cwm.lu[Year==49,.(mean.R=mean(wtm.R), sd.R=sd(wtm.R),
                                     mean.c=mean(wtm.c), sd.c=sd(wtm.c),
                                     mean.disp=mean(wtm.disp), sd.disp=sd(wtm.disp),
                                     mean.fly=mean(wtm.fly), sd.fly=sd(wtm.fly),
                                     mean.dist=mean(wtm.dist), sd.dist=sd(wtm.dist)), by=.(TZ, LU)]
# plot
disp <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.disp), color="grey") +
  geom_line(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.disp, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.disp), color="grey") +
  geom_point(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.disp, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.disp-sd.disp, ymax=mean.disp+sd.disp), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.disp-sd.disp, ymax=mean.disp+sd.disp, 
                                        color=factor(Cluster), width=1)) +
  facet_grid(~LU) +
  scale_color_brewer(palette = "Dark2") +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Dispersal range") +
  labs(fill="Landscape cluster")
R <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.R), color="grey") +
  geom_line(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.R, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.R), color="grey") +
  geom_point(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.R, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.R-sd.R, ymax=mean.R+sd.R), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.R-sd.R, ymax=mean.R+sd.R, 
                                        color=factor(Cluster)), width=1.5) +
  scale_color_brewer(palette = "Dark2") +
  facet_grid(~LU) +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Growth rate") +
  labs(fill="Landscape cluster")
c <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.c), color="grey") +
  geom_line(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.c, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.c), color="grey") +
  geom_point(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.c, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.c-sd.c, ymax=mean.c+sd.c), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.c-sd.c, ymax=mean.c+sd.c, 
                                        color=factor(Cluster)), width=1.5) +
  scale_color_brewer(palette = "Dark2") +
  facet_grid(~LU) +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Competitiveness") +
  labs(fill="Landscape cluster")
Fly <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.fly), color="grey") +
  geom_line(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.fly, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.fly), color="grey") +
  geom_point(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.fly, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.fly-sd.fly, ymax=mean.fly+sd.fly), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.fly-sd.fly, ymax=mean.fly+sd.fly, 
                                        color=factor(Cluster)), width=1.5) +
  scale_color_brewer(palette = "Dark2") +
  facet_grid(~LU) +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Flying period") +
  labs(fill="Landscape cluster")
dist <- ggplot()+
  theme_few() +
  geom_line(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.dist), color="grey") +
  geom_line(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.dist, color=factor(Cluster))) +
  geom_point(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.dist), color="grey") +
  geom_point(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, y=mean.dist, color=factor(Cluster))) +
  geom_errorbar(data=Agroscape_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.dist-sd.dist, ymax=mean.dist+sd.dist), color="grey", width=1.5) +
  geom_errorbar(data=Cluster_cwm[LU=="arable" | LU=="grassland" | LU=="forest"], aes(x=TZ, ymin=mean.dist-sd.dist, ymax=mean.dist+sd.dist, 
                                        color=factor(Cluster)), width=1.5) +
  facet_grid(~LU) +
  scale_color_brewer(palette = "Dark2") +
  ylab("Community weighted mean") + xlab("Amount of realized transition zones [%]") +
  ggtitle("Disturbance susceptibility") +
  labs(fill="Landscape cluster")

png("CWM_lu_class_pa.png", width=800, height=700)
multiplot(disp, Fly, dist, cols=1)
dev.off()

