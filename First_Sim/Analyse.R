# required packages
require(ggplot2)
require(ggthemes)
require(data.table)

# read in simulation file
scenarios<-fread("Simulations.txt", header=T)
data_container<-data.table()

# read in data
for (z in min(scenarios$SimNb):max(scenarios$SimNb)){
  data<-fread(paste("GridOut_", z, ".txt", sep=""), header=T)
  data[,TZ_width:=scenarios[SimNb==z,TZ_width]]
  data[,disturbances:=scenarios[SimNb==z,disturbances]]
  repetitions <- c()
  for (i in 1:scenarios[SimNb==z,Nrep]){
    repetitions = c(repetitions, rep(i,nrow(data)/scenarios[SimNb==z,Nrep]))
    }
  data[,repetition:=repetitions]
  l<-list(data_container,data)
  data_container=rbindlist(l)
}

setkey(data_container, Year, FT_ID, LU_ID, repetition)
data_container[LU_ID==0,LU:="bare"]
data_container[LU_ID==1,LU:="arable"]
data_container[LU_ID==2,LU:="forest"]
data_container[LU_ID==3,LU:="grassland"]
data_container[LU_ID==4,LU:="urban"]
data_container[LU_ID==5,LU:="water"]
data<-data_container[,.(mean=mean(Popsize), sd=sd(Popsize)),by=.(Year, FT_ID, LU_ID, LU, TZ_width, disturbances)]
data2<-data_container[,.(mean=mean(Popsize), sd=sd(Popsize)),by=.(Year, LU_ID, LU, TZ_width, disturbances)]

# calculate nb_FT/land use type
tmp<-data_container[Popsize!=0,]
tmp <- tmp[,.(nb_FT=length(Popsize), totalN=sum(Popsize)),by=.(Year, LU_ID, LU, TZ_width, disturbances, repetition)]
setkey(data_container, Year, FT_ID, LU_ID, LU, repetition, TZ_width, disturbances) 
setkey(tmp, Year, LU_ID, LU, repetition, TZ_width, disturbances) 
test<-merge(tmp,data_container)
test<-test[Popsize!=0,]
test[,pi:=Popsize/totalN]
test<-test[,.(div=-sum(pi*log(pi))),by=.(Year, LU_ID, LU, TZ_width, disturbances, repetition, nb_FT, totalN)]
data.com<-test[,.(mean.div=mean(div), sd.div=sd(div), mean.nb_FT=mean(nb_FT), sd.nb_FT=sd(nb_FT), mean.totalN=mean(totalN), sd.totalN=sd(totalN)),by=.(Year, LU_ID, LU, TZ_width, disturbances)]



# read landscape configuration
landscape<-fread("Patch_ID_definitions.txt", header=T)
landscape_proportions<-landscape[,.(cumArea=sum(AREA)), by=.(TYPE)]
totalArea=sum(landscape_proportions[,cumArea])
landscape_proportions[,relativeArea:=cumArea/totalArea]
landscape_proportions[,LU:=TYPE]

# merging
setkey(data, Year, FT_ID, LU_ID, LU, TZ_width, disturbances)
setkey(data.com, Year, LU_ID, LU, TZ_width, disturbances)
setkey(landscape_proportions, TYPE, LU)
data3<-merge(data, landscape_proportions)
data3[,relPop:=mean/cumArea]

data4<-merge(data.com, landscape_proportions)
data4[,relPop:=mean/cumArea]

relPop<-ggplot(data=data3[LU!="water"]) +
  geom_line(aes(x=Year, y=relPop, colour=factor(TZ_width), linetype=factor(disturbances))) +
  ylab("nb individuals/ha") +
  facet_grid(LU~FT_ID, scales="free")

div<-ggplot(data=data.com) +
  geom_line(aes(x=Year, y=mean.div, colour=factor(TZ_width), linetype=factor(disturbances))) +
  geom_ribbon(aes(x=Year, ymin=mean.div-sd.div, ymax=mean.div+sd.div, group=factor(TZ_width+disturbances)), alpha=0.1) +
  ylab("mean diversity") +
  facet_wrap(~LU, scales="free")

nb_FT<-ggplot(data=data.com) +
  geom_line(aes(x=Year, y=mean.nb_FT, colour=factor(TZ_width), linetype=factor(disturbances))) +
  geom_ribbon(aes(x=Year, ymin=mean.nb_FT-sd.nb_FT, ymax=mean.nb_FT+sd.nb_FT, group=factor(TZ_width+disturbances)), alpha=0.1) +
  ylab("mean number of FT") +
  facet_wrap(~LU, scales="free")

totalN<-ggplot(data=data.com) +
  geom_line(aes(x=Year, y=mean.totalN, colour=factor(TZ_width), linetype=factor(disturbances))) +
  geom_ribbon(aes(x=Year, ymin=mean.totalN-sd.totalN, ymax=mean.totalN+sd.totalN, group=factor(TZ_width+disturbances)), alpha=0.1) +
  ylab("mean total N") +
  facet_wrap(~LU, scales="free")






g<-ggplot(data=data[LU=="arable",]) +
  geom_line(aes(x=Year, y=mean, colour=factor(TZ_width), linetype=factor(disturbances))) +
  facet_wrap(~FT_ID, scales="free")

g<-ggplot(data=data[LU=="grassland",]) +
  geom_line(aes(x=Year, y=mean, colour=factor(TZ_width), linetype=factor(disturbances))) +
  facet_wrap(~FT_ID, scales="free")