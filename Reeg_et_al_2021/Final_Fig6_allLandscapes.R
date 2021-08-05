require(ggplot2)
require(ggthemes)
require(rgdal)
require(rgeos)
library(raster)
library(rasterVis)#this is a good one for plotting raster with ggplot

# make the resource_uptake_heatmap_*.txt files to raster files
for (i in c("./1c", "./1f", "./2c", "./2h", 
            "./2j", "./3a", "./4e", "./5i", "./7a", 
            "./6e", "./8e", "./7g")){
  setwd(i)
  setwd("Output")
  resource_uptake_100 <-transpose(fread("resource_uptake_heatmap_100.txt"))
  fwrite(resource_uptake_100, "res_heat_100.txt", sep=" ", row.names = F, col.names = F)
  resource_uptake_75 <-transpose(fread("resource_uptake_heatmap_75.txt"))
  fwrite(resource_uptake_75, "res_heat_75.txt", sep=" ", row.names = F, col.names = F)
  resource_uptake_50 <-transpose(fread("resource_uptake_heatmap_50.txt"))
  fwrite(resource_uptake_50, "res_heat_50.txt", sep=" ", row.names = F, col.names = F)
  resource_uptake_25 <-transpose(fread("resource_uptake_heatmap_25.txt"))
  fwrite(resource_uptake_25, "res_heat_25.txt", sep=" ", row.names = F, col.names = F)
  resource_uptake_0 <-transpose(fread("resource_uptake_heatmap_0.txt"))
  fwrite(resource_uptake_0, "res_heat_0.txt", sep=" ", row.names = F, col.names = F)
  setwd('..')
  dir <- unlist(strsplit(i,"./"))[2]
  file<-paste("Agroscapelab_20m_150x150_", dir, ".asc", sep="")
  fileName=file
  con=file(fileName,open="r")
  line=readLines(con)[1:6] 
  close(con)
  
  lines <- line
  for (input in 1:nrow(resource_uptake_100)){
    to.write<-paste(t(as.data.frame(resource_uptake_100)[input,])[,1],collapse=" ")
    lines<-c(lines,to.write)
  }
  fileOut<-file("Res_Heat_100.txt")
  writeLines(lines, fileOut)
  
  lines <- line
  for (input in 1:nrow(resource_uptake_75)){
    to.write<-paste(t(as.data.frame(resource_uptake_75)[input,])[,1],collapse=" ")
    lines<-c(lines,to.write)
  }
  fileOut<-file("Res_Heat_75.txt")
  writeLines(lines, fileOut)
  
  lines <- line
  for (input in 1:nrow(resource_uptake_50)){
    to.write<-paste(t(as.data.frame(resource_uptake_50)[input,])[,1],collapse=" ")
    lines<-c(lines,to.write)
  }
  fileOut<-file("Res_Heat_50.txt")
  writeLines(lines, fileOut)
  
  lines <- line
  for (input in 1:nrow(resource_uptake_25)){
    to.write<-paste(t(as.data.frame(resource_uptake_25)[input,])[,1],collapse=" ")
    lines<-c(lines,to.write)
  }
  fileOut<-file("Res_Heat_25.txt")
  writeLines(lines, fileOut)
  
  lines <- line
  for (input in 1:nrow(resource_uptake_0)){
    to.write<-paste(t(as.data.frame(resource_uptake_0)[input,])[,1],collapse=" ")
    lines<-c(lines,to.write)
  }
  fileOut<-file("Res_Heat_0.txt")
  writeLines(lines, fileOut)
  
  setwd('..')
}

# generate the plots
for (i in c("./1c", "./1f", "./2c", "./2h", 
            "./2j", "./3a", "./4e", "./5i", "./7a", 
            "./6e", "./8e", "./7g")){
  setwd(i)
  
  ls.raster = raster(paste("Agroscapelab_20m_150x150_",unlist(strsplit(i,"./"))[2], ".asc", sep=""))
  # image(ls.raster) # works
  # crs(ls.raster) # not set
  
  ls.poly = readOGR("Shape_alone_all_classes.shp")
  # plot(ls.poly) # works
  # crs(ls.poly) # set
  
  feed.raster.100 = raster("Res_Heat_100.txt")
  feed.raster.75 = raster("Res_Heat_75.txt")
  feed.raster.50 = raster("Res_Heat_50.txt")
  feed.raster.25 = raster("Res_Heat_25.txt")
  feed.raster.0 = raster("Res_Heat_0.txt")
  # image(feed.raster) # works
  
  
  #Set coordinate reference system of the raster. Must be the same, always ;)
  crs(ls.raster)=crs(ls.poly)
  crs(feed.raster.100)=crs(ls.poly)
  crs(feed.raster.75)=crs(ls.poly)
  crs(feed.raster.50)=crs(ls.poly)
  crs(feed.raster.25)=crs(ls.poly)
  crs(feed.raster.0)=crs(ls.poly)
  
  #"shape_alone_xx.shp" is corrupt let's make if with R
  
  ls.poly=rasterToPolygons(ls.raster,dissolve = T)
  ls.poly@plotOrder<-as.integer(c(6,5,4,3,2,1))
  
  plot.landscape=gplot(ls.raster)+ #note: gplot() from rasterVis
    geom_raster(aes(fill=factor(value)),alpha=1)+
    scale_fill_manual(name = "Land use class", 
                      values=c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"),
                      labels = c("bare", "arable", "forest", "grassland", "urban", "water"))+
    # geom_polygon(data = ls.poly, aes( x = long, y = lat, group = group,color=NA),fill=NA,size=.1) +
    scale_color_manual(values=c("darkred"))+
    theme_bw() +
    labs(x="easting [m]",y="northing [m]",title = "Landscape",color="")+
    coord_equal(expand=F)+
    theme(title = element_text(size=8), plot.title = element_text(hjust=0.5),
          axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
          legend.title = element_text(size=8),
          legend.text = element_text(size=6), legend.position="none")
  
  # plot.landscape
  
  #for making the polygone lines according to the ls, we must work a bit on the data
  #I faced the issues of self intersections. this sucks, lets make the polygones new
  
  plot.feed.100=gplot(feed.raster.100)+ #note: gplot() from rasterVis
    geom_raster(aes(fill=value),alpha=1,interpolate = T)+ #interpolate smoothes the raster, you may do not want this
    scale_fill_viridis_c(limits = c(0, max(getValues(feed.raster.100))), direction = 1, option = "magma")+
    geom_polygon(data = ls.poly, aes( x = long, y = lat, group = group,color=factor(id)),fill=NA,size=.25) +
    scale_color_manual(name = "Land use\nclass",
                       values=c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"),
                       labels = c("bare", "arable", "forest", "grassland", "urban", "water")
    )+
    theme_bw() +
    labs(x="",y="",title = "100%",color="Land use class",fill="Feeding\nintensity")+
    coord_equal(expand=F)+
    guides(color=guide_legend(override.aes = list(fill = c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"))),
           fill=F)+
    theme(title = element_text(size=8), plot.title = element_text(hjust=0.5), 
          axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
          legend.title = element_text(size=8), legend.key.width=unit(0.9,"cm"),
          legend.text = element_text(size=6), legend.position="right")
  
  plot.feed.75=gplot(feed.raster.75)+ #note: gplot() from rasterVis
    geom_raster(aes(fill=value),alpha=1,interpolate = T)+ #interpolate smoothes the raster, you may do not want this
    scale_fill_viridis_c(limits = c(0, max(getValues(feed.raster.100))), direction = 1, option = "magma")+
    geom_polygon(data = ls.poly, aes( x = long, y = lat, group = group,color=factor(id)),fill=NA,size=.25) +
    scale_color_manual(name = "Land use class",
                       values=c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"),
                       labels = c("bare", "arable", "forest", "grassland", "urban", "water")
    )+
    theme_bw() + guides(color=F)+
    labs(x="",y="",title = "75%",color="Land use\nclass",fill="Feeding\nintensity")+
    coord_equal(expand=F)+
    theme(title = element_text(size=8), plot.title = element_text(hjust=0.5), 
          axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
          legend.title = element_text(size=8), legend.key.width=unit(1.5,"cm"),
          legend.text = element_text(size=6), legend.position="right")
  
  plot.feed.50=gplot(feed.raster.50)+ #note: gplot() from rasterVis
    geom_raster(aes(fill=value),alpha=1,interpolate = T)+ #interpolate smoothes the raster, you may do not want this
    scale_fill_viridis_c(limits = c(0, max(getValues(feed.raster.100))), direction =  1, option = "magma")+
    geom_polygon(data = ls.poly, aes( x = long, y = lat, group = group,color=factor(id)),fill=NA,size=.25) +
    scale_color_manual(name = "Land use class",
                       values=c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"),
                       labels = c("bare", "arable", "forest", "grassland", "urban", "water")
    )+
    theme_bw() +
    guides(color=F)+
    labs(x="",y="",title = "50%",color="",fill="Feeding\nintensity")+
    coord_equal(expand=F)+
    theme(title = element_text(size=8), plot.title = element_text(hjust=0.5), 
          axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
          legend.title = element_text(size=8),
          legend.text = element_text(size=6), legend.position="none")
  
  plot.feed.25=gplot(feed.raster.25)+ #note: gplot() from rasterVis
    geom_raster(aes(fill=value),alpha=1,interpolate = T)+ #interpolate smoothes the raster, you may do not want this
    scale_fill_viridis_c(limits = c(0, max(getValues(feed.raster.100))), direction =  1, option = "magma")+
    geom_polygon(data = ls.poly, aes( x = long, y = lat, group = group,color=factor(id)),fill=NA,size=.25) +
    scale_color_manual(name = "Land use class",
                       values=c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"),
                       labels = c("bare", "arable", "forest", "grassland", "urban", "water")
    )+
    theme_bw() +
    guides(color=F)+
    labs(x="",y="",title = "25%",color="",fill="Feeding\nintensity")+
    coord_equal(expand=F)+
    theme(title = element_text(size=8), plot.title = element_text(hjust=0.5), 
          axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
          legend.title = element_text(size=8),
          legend.text = element_text(size=6), legend.position="none")
  
  plot.feed.0=gplot(feed.raster.0)+ #note: gplot() from rasterVis
    geom_raster(aes(fill=value),alpha=1,interpolate = T)+ #interpolate smoothes the raster, you may do not want this
    scale_fill_viridis_c(limits = c(0, max(getValues(feed.raster.100))), direction =  1, option = "magma")+
    geom_polygon(data = ls.poly, aes( x = long, y = lat, group = group,color=factor(id)),fill=NA,size=.25) +
    scale_color_manual(name = "Land use class",
                       values=c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"),
                       labels = c("bare", "arable", "forest", "grassland", "urban", "water")
    )+
    theme_bw() +
    guides(color=F)+
    labs(x="",y="",title = "0%",color="",fill="Feeding\nintensity")+
    coord_equal(expand=F)+
    theme(title = element_text(size=8), plot.title = element_text(hjust=0.5), 
          axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
          legend.title = element_text(size=8),
          legend.text = element_text(size=6), legend.position="none")
  
  # plot.feed
  # blank plot
  df <- data.frame()
  clean <- ggplot(df) + geom_point() + theme_void() +xlim(0, 10) + ylim(0, 100)
  
  jpeg("Resource_uptake.jpeg", width=18, height=12, res=600, units="cm")
  multiplot(plot.feed.0, plot.landscape, plot.feed.100, plot.feed.25, plot.feed.50, plot.feed.75,
            layout=matrix(c(1,1,1,1,2,2,2,2,3,3,3,3,3,3,
                            4,4,4,4,5,5,5,5,6,6,6,6,6,6), nrow=2, byrow=TRUE))
  dev.off()
  
  pdf("Resource_uptake.pdf", width=7, height=5)
  multiplot(plot.feed.0, plot.landscape, plot.feed.100, plot.feed.25, plot.feed.50, plot.feed.75,
            layout=matrix(c(1,1,1,1,2,2,2,2,3,3,3,3,3,3,
                            4,4,4,4,5,5,5,5,6,6,6,6,6,6), nrow=2, byrow=TRUE))
  dev.off()
  setwd('..')
}