require(ggplot2)
require(ggthemes)
require(data.table)
data<-fread("GridOut_1.txt", header=T)
data<-data[FT_ID!=0,]
setkey(data, Year, FT_ID, LU_ID)
data[LU_ID==0,LU:="bare"]
data[LU_ID==1,LU:="arable"]
data[LU_ID==2,LU:="forest"]
data[LU_ID==3,LU:="grassland"]
data[LU_ID==4,LU:="urban"]
data[LU_ID==5,LU:="water"]
data1<-data[,.(mean=mean(Popsize), sd=sd(Popsize)),by=.(Year, FT_ID, LU_ID, LU)]
g1<-ggplot(data=data1, aes(y=mean, x=Year)) +
  geom_line(aes( color=factor(FT_ID))) +
  facet_wrap(~LU, scales="free")

data<-fread("GridOut.txt", header=T)
data<-data[FT_ID!=0,]
data<-data[FT_ID!=107998672,]
data<-data[FT_ID!=1225530629,]
setkey(data, Year, FT_ID, LU_ID)
data[LU_ID==0,LU:="bare"]
data[LU_ID==1,LU:="arable"]
data[LU_ID==2,LU:="forest"]
data[LU_ID==3,LU:="grassland"]
data[LU_ID==4,LU:="urban"]
data[LU_ID==5,LU:="water"]
data1<-data[,.(mean=mean(Popsize), sd=sd(Popsize)),by=.(Year, FT_ID, LU_ID, LU)]
g2<-ggplot(data=data1, aes(y=mean, x=Year)) +
  geom_line(aes( color=factor(FT_ID))) +
  facet_wrap(~LU, scales="free")