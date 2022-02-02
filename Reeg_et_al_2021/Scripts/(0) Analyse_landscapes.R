#' ####################################################################### #
#' PROJECT: Reeg, J.; Strigl, L.; Jeltsch, F. (submitted) Agricultural buffer 
#'                   zone thresholds to safeguard functional bee diversity:  
#'                   Insights from a community modelling approach
#' CONTENTS: 
#'  - This code is implemented to analyse landscape rasters of the AgroScapeLabs
#'  DEPENDENCIES:
#'  - The code needs a landscape parameter file as calculated by FragStats
#'  
#' AUTHOR: Jette Reeg
#' ####################################################################### #
## Packages ====================================================================
require(ggplot2)
require(ggthemes)
require(data.table)
require(FactoMineR)
require(RColorBrewer)
require(pca3d)
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
## Working directory ===========================================================
# make sure to set the correct working directory!
## Data ========================================================================
parameters<-fread("Data/Landscapes/Landscape_parameters.txt")
parameters[, Cluster:=0]
parameters[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
parameters[LID=="1f" | LID=="2j"| LID=="5i", Cluster:=3]
parameters[LID=="1c" | LID=="2c" | LID=="4e", Cluster:=2]
parameters[LID=="3a" | LID=="8e" | LID=="2h" , Cluster:=4]

## PCA =========================================================================
res.pca <- PCA(parameters[,-c(1,17)], graph = FALSE, ncp=3)
res.pca3d <- prcomp(parameters[,-c(1,17)], scale=T, center=T)

## Figures =====================================================================
#####
# Figure B1
gr <- factor(parameters$Cluster)
col <- gr
col <- as.character(col)
col[col==0]<-"white"
col[col==1]<-brewer.pal(n = 4, name = "Dark2")[1]
col[col==2]<-brewer.pal(n = 4, name = "Dark2")[2]
col[col==3]<-brewer.pal(n = 4, name = "Dark2")[3]
col[col==4]<-brewer.pal(n = 4, name = "Dark2")[4]
col
pca3d(res.pca3d, group=gr, col=col)
snapshotPCA3d(file="FigB1.png")

#####
# Figure B2

# Extract coordinates
Cluster1 <- res.pca$ind$coord[c(59,65,71),]
Cluster2 <- res.pca$ind$coord[c(3,38,14),]
Cluster3 <- res.pca$ind$coord[c(6,21,53),]
Cluster4 <- res.pca$ind$coord[c(19,23,78),]

Cluster1 <- colMeans(Cluster1)
Cluster2 <- colMeans(Cluster2)
Cluster3 <- colMeans(Cluster3)
Cluster4 <- colMeans(Cluster4)

Cluster_coordinates <- rbind(Cluster1, Cluster2, Cluster3, Cluster4)
Cluster_coordinates <- cbind(Cluster_coordinates, "Cluster"=c(1,2,3,4), "position"=c(0.3,0.3,0.3,0.3))

# create polygon
ids <- factor(c("1"))

values <- data.frame(
  id = ids,
  value = c(3)
)

positions <- data.frame(
  id = rep(ids, each = 3),
  x = c(min(as.data.frame(Cluster_coordinates)$Dim.1)-0.1, max(as.data.frame(Cluster_coordinates)$Dim.1)+0.1,max(as.data.frame(Cluster_coordinates)$Dim.1)+0.1),
  y = c(0,0, 0.2)
)

datapoly1 <- merge(values, positions, by = c("id"))

# PC1 timeline
PC1 <- ggplot()+
  geom_polygon(data=datapoly1, aes(x = x, y = y, group = id), fill = "grey") +
  geom_segment(data=as.data.frame(Cluster_coordinates),aes(x=Dim.1,y=position,yend=0,xend=Dim.1),
               color='black', size=0.2) +
  geom_point(data=as.data.frame(Cluster_coordinates), aes(x=Dim.1, y=position, 
                                                          colour=factor(Cluster)), size=4) +
  scale_colour_brewer(palette = "Dark2") +
  xlab("") + labs(color="Landscape cluster") +
  xlab("PC 1: Landscape heterogeneity") +
  theme_classic() +
  theme(
    axis.line.y=element_blank(),
        axis.text.y=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.position = "top"
        # ,
        # axis.line.x=element_blank(),
        # axis.text.x=element_blank(),
        # # axis.title.y=element_blank(),
        # axis.ticks.x=element_blank()
  ) 

# create polygon
ids <- factor(c("1"))

values <- data.frame(
  id = ids,
  value = c(3)
)

positions <- data.frame(
  id = rep(ids, each = 3),
  x = c(min(as.data.frame(Cluster_coordinates)$Dim.2)-0.1, min(as.data.frame(Cluster_coordinates)$Dim.2)-0.1,
        max(as.data.frame(Cluster_coordinates)$Dim.2)+0.1),
  y = c(0.2,0,0)
)

datapoly2 <- merge(values, positions, by = c("id"))

# PC2 timeline
PC2 <- ggplot()+
  geom_polygon(data=datapoly2, aes(x = x, y = y, group = id), fill = "grey") +
  geom_segment(data=as.data.frame(Cluster_coordinates),aes(x=Dim.2,y=position,yend=0,xend=Dim.2),
               color='black', size=0.2) +
  geom_point(data=as.data.frame(Cluster_coordinates), aes(x=Dim.2, y=position, 
                                                          colour=factor(Cluster)), size=4) +
  scale_colour_brewer(palette = "Dark2") +
  xlab("PC 2: Amount of arable land") +
  theme_classic() +
  theme(axis.line.y=element_blank(),
        axis.text.y=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.position = "none"
  ) 

# create polygon
ids <- factor(c("1"))

values <- data.frame(
  id = ids,
  value = c(3)
)

positions <- data.frame(
  id = rep(ids, each = 3),
  x = c(min(as.data.frame(Cluster_coordinates)$Dim.3)-0.1, min(as.data.frame(Cluster_coordinates)$Dim.3)-0.1,
        max(as.data.frame(Cluster_coordinates)$Dim.3)+0.1),
  y = c(0.2,0,0)
)

datapoly3 <- merge(values, positions, by = c("id"))

# PC3 timeline
PC3 <- ggplot()+
  geom_polygon(data=datapoly3, aes(x = x, y = y, group = id), fill = "grey") +
  geom_segment(data=as.data.frame(Cluster_coordinates),aes(x=Dim.3,y=position,yend=0,xend=Dim.3),
               color='black', size=0.2) +
  geom_point(data=as.data.frame(Cluster_coordinates), aes(x=Dim.3, y=position, 
                                                          colour=factor(Cluster)), size=4) +
  scale_colour_brewer(palette = "Dark2") +
  xlab("PC 3: Amount of natural land") +
  theme_classic() +
  theme(axis.line.y=element_blank(),
        axis.text.y=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.position = "none"
  ) 

# multiplot
jpeg("PCA_Landscapes/PCA_scales.jpeg", width=180, height=160, res=600, units="mm")
multiplot(PC1, PC2, PC3, layout=matrix(c(1,1,1,1,2,2,2,3,3,3), nrow=10, byrow=TRUE))
dev.off()