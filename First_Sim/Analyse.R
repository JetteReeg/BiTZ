# required packages
require(ggplot2)
require(ggthemes)
require(data.table)

# read in simulation file
scenarios<-fread("Input/Simulations.txt", header=T)
data_container<-data.table()

# read in data
for (z in min(scenarios$SimNb):max(scenarios$SimNb)){
  data<-fread(paste("GridOut_", z, ".txt", sep=""), header=T)
  data[,TZ_width:=scenarios[SimNb==z,TZ_width]]
  data[,disturbances:=scenarios[SimNb==z,disturbances]]
  l<-list(data_container,data)
  data_container=rbindlist(l)
}

setkey(data_container, Year, FT_ID, LU_ID)
data_container[LU_ID==0,LU:="bare"]
data_container[LU_ID==1,LU:="arable"]
data_container[LU_ID==2,LU:="forest"]
data_container[LU_ID==3,LU:="grassland"]
data_container[LU_ID==4,LU:="urban"]
data_container[LU_ID==5,LU:="water"]
data<-data_container[,.(mean=mean(Popsize), sd=sd(Popsize)),by=.(Year, FT_ID, LU_ID, LU, TZ_width, disturbances)]
data2<-data_container[,.(mean=mean(Popsize), sd=sd(Popsize)),by=.(Year, LU_ID, LU, TZ_width, disturbances)]

g<-ggplot(data=data[LU=="arable",]) +
  geom_line(aes(x=Year, y=mean, colour=factor(TZ_width), linetype=factor(disturbances))) +
  facet_wrap(~FT_ID, scales="free")

g<-ggplot(data=data[LU=="grassland",]) +
  geom_line(aes(x=Year, y=mean, colour=factor(TZ_width), linetype=factor(disturbances))) +
  facet_wrap(~FT_ID, scales="free")