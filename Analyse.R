require(ggplot2)
require(ggthemes)
data<-read.table("GridOut.txt", header=T)
ggplot(data=data, aes(y=Popsize, x=Year)) +
  geom_line(aes(linetype=factor(FT_ID), color=factor(LU_ID))) +
  facet_wrap(~FT_ID, scales="free")