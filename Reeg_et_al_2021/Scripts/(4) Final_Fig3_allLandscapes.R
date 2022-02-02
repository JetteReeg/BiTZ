#' ####################################################################### #
#' PROJECT: Reeg, J.; Strigl, L.; Jeltsch, F. (submitted) Agricultural buffer 
#'                   zone thresholds to safeguard functional bee diversity:  
#'                   Insights from a community modelling approach
#' CONTENTS: 
#'  - This code is implemented to generate landscape and feeding intensity maps
#'  as shown in figure 3 of the main manuscript
#'  DEPENDENCIES:
#'  - The code needs feeding intensity files
#'  
#' AUTHOR: Jette Reeg
#' ####################################################################### #
## required packages ===========================================================
require(ggplot2)
require(ggthemes)
require(rgdal)
require(rgeos)
library(raster)
library(rasterVis)
# install.packages("devtools")
# devtools::install_github("marcosci/layer")
library(layer)
library(scico)
library(sf)
source('Plot_map_function.R') # adapted from marcosci/layer
## Prepare data ================================================================
# go through each subdirectory
directories <- list.dirs(recursive=F)
# make the resource_uptake_heatmap_*.txt files to raster files
 for (i in directories){
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
## Figures =====================================================================
# generate the plots
for (i in directories){
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
  
  # NEW PLOT FIG 6: 
  # tilt maps and stack them over eachother
  tilt_landscape_1 <- tilt_map(ls.raster, y_tilt = 0.7)
  tilt_landscape_1$value <- factor(tilt_landscape_1$value)
  tilt_landscape_2 <- tilt_map(feed.raster.0, y_tilt = 0.7, x_shift = 0, y_shift = 2500)
  tilt_landscape_3 <- tilt_map(feed.raster.25, y_tilt = 0.7,  x_shift = 0, y_shift = 5000)
  tilt_landscape_4 <- tilt_map(feed.raster.50, y_tilt = 0.7,  x_shift = 0, y_shift = 7500)
  tilt_landscape_5 <- tilt_map(feed.raster.75, y_tilt = 0.7,  x_shift = 0, y_shift = 10000)
  tilt_landscape_6 <- tilt_map(feed.raster.100, y_tilt = 0.7,  x_shift = 0, y_shift = 12500)
  
  
  map_list <- list(tilt_landscape_1, tilt_landscape_2, tilt_landscape_3,
                   tilt_landscape_4, tilt_landscape_5, tilt_landscape_6)
  
  
  # Landscape map
  map_tilt <- ggplot() +
    geom_sf(
      data = tilt_landscape_1,
      aes_string(fill = "value",
                 color = "value"), size = 0.01
    ) +
    annotate("Text", x = st_bbox(tilt_landscape_1)[[1]], y = st_bbox(tilt_landscape_1)[[4]] , label = "Landscape") +
    scale_fill_manual(name = "Land use class", 
                      values=c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"),
                      labels = c("bare", "arable", "forest", "grassland", "urban", "water")) +
    scale_color_manual(name = "Land use class", 
                       values=c("darkgrey", "darkgoldenrod3", "darkgreen", "darkolivegreen3", "black", "cornflowerblue"),
                       labels = c("bare", "arable", "forest", "grassland", "urban", "water"))
  # TZ maps acc. to function based on layer package https://github.com/marcosci/layer
  maps <- plot_tiltedmaps_2(map_list, 
                            layer = c("value", "value", "value","value", "value", "value"),
                            palette = c("bamako", "magma", "magma", "magma", "magma", "magma")
                            , direction = c(-1, 1, 1, 1, 1, 1)
                            , label=c("Landscape","0%", "25%", "50%", "75%", "100%")
                            , xmin = c(st_bbox(tilt_landscape_1)[[1]], st_bbox(tilt_landscape_2)[[1]], st_bbox(tilt_landscape_3)[[1]],
                                       st_bbox(tilt_landscape_4)[[1]], st_bbox(tilt_landscape_5)[[1]], st_bbox(tilt_landscape_6)[[1]])
                            , ymax = c(st_bbox(tilt_landscape_1)[[4]], st_bbox(tilt_landscape_2)[[4]], st_bbox(tilt_landscape_3)[[4]],
                                       st_bbox(tilt_landscape_4)[[4]], st_bbox(tilt_landscape_5)[[4]], st_bbox(tilt_landscape_6)[[4]]))
  
  maps <- maps + annotate("Text", x = st_bbox(tilt_landscape_1)[[1]]-2000, y = st_bbox(tilt_landscape_1)[[4]] + 7000, angle = 90, label="Amount of virtually implemented agricultural buffer zones (ABZ)")
  
  ggsave(paste("Fig3_Landscape_", unlist(strsplit(i,"./"))[2], ".jpeg", sep=""), plot=maps, width=180, height=200, units="mm", dpi=600)
  ggsave(paste("Fig3_Landscape_", unlist(strsplit(i,"./"))[2], ".pdf", sep=""), plot=maps, width=180, height=200, units="mm", dpi=600)
  
  setwd('..')
}