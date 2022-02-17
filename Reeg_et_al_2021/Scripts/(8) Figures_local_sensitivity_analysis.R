#' ####################################################################### #
#' PROJECT: Reeg, J.; Strigl, L.; Jeltsch, F. (submitted) Agricultural buffer 
#'                   zone thresholds to safeguard functional bee diversity:  
#'                   Insights from a community modelling approach
#' CONTENTS: 
#'  - This code is implemented to analyse the simulations of a local sensitivity analysis 
#'    varying the main (uncertain) parameters of BiTZ
#'  DEPENDENCIES:
#'  - The code needs the output of the preprocessing of the simulation model output files (file (1) Preprocessing.R)
#'  
#' AUTHOR: Jette Reeg
#' ####################################################################### #

# PREAMBLE ================================================================
rm(list=ls())

## Packages ---------------------------------------------------------------
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE))
    install.packages(x, repos='http://cran.us.r-project.org')
  require(x, character.only = TRUE)
}
package_vec <- c(
  "ggplot2", "ggthemes", "data.table", "vegan", "RColorBrewer" # names of the packages required placed here as character objects
)

sapply(package_vec, install.load.package)

## Functions --------------------------------------------------------------

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

## DATA -------------------------------------------------------------

NFT.all.land <- fread("NFT.all.land.txt")

Landscape_Shannon_all <- NFT.all.land[Parameter=="original",.(mean.shannon=mean(Shannon), mean.FT=mean(FT)), by=.(TZ, Year)]
# merge
setkey(Landscape_Shannon_all, TZ, Year)
setkey(NFT.all.land, TZ, Year, Parameter, Change)
Landscape_Shannon_all <- merge(Landscape_Shannon_all, NFT.all.land, all=T)
Landscape_Shannon_all[,relative.change.shannon:=((Shannon-mean.shannon)/mean.shannon)*100]
Landscape_Shannon_all[,relative.change.FT:=((FT-mean.FT)/mean.FT)*100]
Landscape_Shannon_all <- Landscape_Shannon_all[Change==0.75,Change:=-25]
Landscape_Shannon_all <- Landscape_Shannon_all[Change==0.9,Change:=-10]
Landscape_Shannon_all <- Landscape_Shannon_all[Change==1.1,Change:=10]
Landscape_Shannon_all <- Landscape_Shannon_all[Change==1.25,Change:=25]
Landscape_Shannon_all[Parameter=="original",Change:=0]

# mean values
Landscape_mean <- Landscape_Shannon_all[,.(mean.shannon=mean(relative.change.shannon), sd.shannon=sd(relative.change.shannon), 
                                           min.shannon=min(relative.change.shannon), max.shannon=max(relative.change.shannon),
                                           mean.FT=mean(relative.change.FT), sd.FT=sd(relative.change.FT), 
                                           min.FT=min(relative.change.FT), max.FT=max(relative.change.FT)),
                                        by=.(TZ, Year, Parameter, Change)]
Landscape_mean$Parameter <- factor(Landscape_mean$Parameter,
                                   levels = c('original', 'weather_std', 'disturbance_prob', 'dispersal_tries', 'order', 'competition_strength', 
                                              'growth_rate', 'nest_suitability', 'res_suitability', 
                                              'dispersal_mean', 'dispersal_sd', 'emigration_mu', 'emigration_omega',
                                              'disturbance_eff',
                                              'trans_effect_nest', 'trans_effect_res', 'trans_effect_nest_res'))

# Rename
Landscape_mean[Parameter=="weather_std"]$Parameter <- "standard deviation \n weather"
Landscape_mean[Parameter=="disturbance_prob"]$Parameter <- "disturbance \n probability"
Landscape_mean[Parameter=="dispersal_tries"]$Parameter <- "dispersal \n tries"
Landscape_mean[Parameter=="competition_strength"]$Parameter <- "competition \n strength"
Landscape_mean[Parameter=="growth_rate"]$Parameter <- "growth rate"
Landscape_mean[Parameter=="nest_suitability"]$Parameter <- "nesting site \n suitability"
Landscape_mean[Parameter=="res_suitability"]$Parameter <- "resource \n suitability"
Landscape_mean[Parameter=="dispersal_mean"]$Parameter <- "mean dispersal"
Landscape_mean[Parameter=="dispersal_sd"]$Parameter <- "standard deviation \n dispersal"
Landscape_mean[Parameter=="emigration_mu"]$Parameter <- "emigration \n parameter mu"
Landscape_mean[Parameter=="emigration_omega"]$Parameter <- "emigration \n parameter omega"
Landscape_mean[Parameter=="disturbance_eff"]$Parameter <- "disturbance \n effect"
Landscape_mean[Parameter=="trans_effect_nest"]$Parameter <- "effect of ABZs \n on nesting site"
Landscape_mean[Parameter=="trans_effect_res"]$Parameter <- "effect of ABZs  \n on resources"
Landscape_mean[Parameter=="trans_effect_nest_res"]$Parameter <- "effect of ABZs \n on nesting site \n and resources"

Landscape_Shannon_all[Parameter=="weather_std"]$Parameter <- "standard deviation \n weather"
Landscape_Shannon_all[Parameter=="disturbance_prob"]$Parameter <- "disturbance \n probability"
Landscape_Shannon_all[Parameter=="dispersal_tries"]$Parameter <- "dispersal \n tries"
Landscape_Shannon_all[Parameter=="competition_strength"]$Parameter <- "competition \n strength"
Landscape_Shannon_all[Parameter=="growth_rate"]$Parameter <- "growth rate"
Landscape_Shannon_all[Parameter=="nest_suitability"]$Parameter <- "nesting site \n suitability"
Landscape_Shannon_all[Parameter=="res_suitability"]$Parameter <- "resource \n suitability"
Landscape_Shannon_all[Parameter=="dispersal_Shannon_all"]$Parameter <- "mean dispersal"
Landscape_Shannon_all[Parameter=="dispersal_sd"]$Parameter <- "standard deviation \n dispersal"
Landscape_Shannon_all[Parameter=="emigration_mu"]$Parameter <- "emigration \n parameter mu"
Landscape_Shannon_all[Parameter=="emigration_omega"]$Parameter <- "emigration \n parameter omega"
Landscape_Shannon_all[Parameter=="disturbance_eff"]$Parameter <- "disturbance \n effect"
Landscape_Shannon_all[Parameter=="trans_effect_nest"]$Parameter <- "effect of ABZs \n on nesting site"
Landscape_Shannon_all[Parameter=="trans_effect_res"]$Parameter <- "effect of ABZs  \n on resources"
Landscape_Shannon_all[Parameter=="trans_effect_nest_res"]$Parameter <- "effect of ABZs \n on nesting site \n and resources"


#####
# Figure F.3
# how strong is the relative change in Shannon and NFT in year 49 over the amount of change?
# for numerical parameters
#####
plot.data <- Landscape_mean[(TZ==0 | 
                               # TZ== 25 | TZ==50 | TZ==75 | 
                               TZ==100) & Year==49
                            & (Change!="ascending" & Change!="order" & Change!="high_dist"  & Change!="low_dist")
                            ]

color.para.0 <- levels(factor(plot.data[Parameter!="original" & 
                                          TZ==0 & 
                                          (Change==-10 | Change==10) &
                                          ((mean.shannon<plot.data[Parameter=="original" & TZ==0]$min.shannon)
                                        | 
                                          (mean.shannon>plot.data[Parameter=="original" & TZ==0]$max.shannon))
                                        ]$Parameter))
color.para.100 <- levels(factor(plot.data[Parameter!="original" & 
                                           TZ==100 & 
                                           (Change==-10 | Change==10) &
                                           ((mean.shannon<plot.data[Parameter=="original" & TZ==0]$min.shannon)
                                            | 
                                              (mean.shannon>plot.data[Parameter=="original" & TZ==0]$max.shannon))
                                        ]$Parameter))
color.para <- levels(factor(c(color.para.0,color.para.100)))


sh <- ggplot()+
  theme_few() +
  geom_rect(data = plot.data[Parameter=="original"], 
            aes(xmin=-25, xmax=25,ymin=min.shannon, ymax=max.shannon), alpha=0.2)+
  geom_line(data=plot.data[Parameter!="original"], aes(x=as.numeric(Change), y=mean.shannon, group=Parameter), color="grey") +
  geom_line(data=plot.data[Parameter %in% color.para], aes(x=as.numeric(Change), y=mean.shannon, color=Parameter)) +
  facet_grid(TZ~.) +
  ylab("Relative change in Shannon diversity [%]") + xlab("Change in parameter [%]") + 
  theme(axis.title = element_text(size=7), legend.title = element_text(size=7), axis.text = element_text(size=6), legend.text = element_text(size=6))

color.para.0 <- levels(factor(plot.data[Parameter!="original" & 
                                          TZ==0 & 
                                          (Change==-10 | Change==10) &
                                          ((mean.FT<plot.data[Parameter=="original" & TZ==0]$min.FT)
                                           | 
                                             (mean.FT>plot.data[Parameter=="original" & TZ==0]$max.FT))
                                          ]$Parameter))
color.para.100 <- levels(factor(plot.data[Parameter!="original" & 
                                            TZ==100 & 
                                            (Change==-10 | Change==10) &
                                            ((mean.FT<plot.data[Parameter=="original" & TZ==0]$min.FT)
                                             | 
                                               (mean.FT>plot.data[Parameter=="original" & TZ==0]$max.FT))
                                            ]$Parameter))
color.para <- levels(factor(c(color.para.0,color.para.100)))

ft <- ggplot()+
  theme_few() +
  geom_rect(data = plot.data[Parameter=="original"], 
            aes(xmin=-25, xmax=25,ymin=min.FT, ymax=max.FT), alpha=0.2)+
  geom_line(data=plot.data[Parameter!="original"], aes(x=as.numeric(Change), y=mean.FT, group=Parameter), color="grey") +
  geom_line(data=plot.data[Parameter %in% color.para], aes(x=as.numeric(Change), y=mean.FT, color=Parameter)) +
  facet_grid(TZ~.) +
  ylab("Relative change in number of FTs [%]") + xlab("Change in parameter [%]") + 
theme(axis.title = element_text(size=7), legend.title = element_text(size=7), axis.text = element_text(size=6), legend.text = element_text(size=6))

jpeg("FigF3_SA_shannon+NFT_numerical.jpeg", width=160, height=200, units="mm", res=600)
multiplot(ft, sh,
          cols = 1)
dev.off()
#####
# Figure F.4
# how strong is the relative change in Shannon and NFT in year 49 over the amount of change?
# for categorial parameters and distances
#####
plot.data <- Landscape_mean[(TZ==0 | 
                               # TZ== 25 | TZ==50 | TZ==75 | 
                               TZ==100) & Year==49
                            & (Change=="ascending" | Change=="order" | Change=="high_dist"  | Change=="low_dist" | Change=="0")
]

plot.data[Change=="ascending", Change:="ascending order"]
plot.data[Change=="order", Change:="competition order"]
plot.data[Change=="low_dist", Change:="lower distance btw. FTs"]
plot.data[Change=="high_dist", Change:="higher distance btw. FTs"]


Landscape_Shannon_all[Change=="ascending", Change:="ascending order"]
Landscape_Shannon_all[Change=="order", Change:="competition order"]
Landscape_Shannon_all[Change=="low_dist", Change:="lower distance btw. FTs"]
Landscape_Shannon_all[Change=="high_dist", Change:="higher distance btw. FTs"]

color.para.0 <- levels(factor(plot.data[Parameter!="original" & 
                                          TZ==0 & 
                                          ((mean.shannon<plot.data[Parameter=="original" & TZ==0]$min.shannon)
                                           | 
                                             (mean.shannon>plot.data[Parameter=="original" & TZ==0]$max.shannon))
                            ]$Parameter))
color.para.100 <- levels(factor(plot.data[Parameter!="original" & 
                                            TZ==100 & 
                                            ((mean.shannon<plot.data[Parameter=="original" & TZ==0]$min.shannon)
                                             | 
                                               (mean.shannon>plot.data[Parameter=="original" & TZ==0]$max.shannon))
                            ]$Parameter))

color.para <- levels(factor(c(color.para.0,color.para.100)))

SH <- ggplot()+
  theme_few() +
  # ribbon of original min/max
  geom_rect(data = plot.data[Parameter=="original"], aes(xmin="competition_strength", xmax="res_suitability",ymin=min.shannon, ymax=max.shannon), alpha=0.2)+
  # boxplots inside range
  geom_boxplot(data=Landscape_Shannon_all[(TZ==0 | 
                                             # TZ== 25 | TZ==50 | TZ==75 | 
                                             TZ==100) & Year==49
                                          & (Change=="ascending order" | Change=="competition order" | Change=="higher distance btw. FTs"  | Change=="lower distance btw. FTs")
                                          & !(Parameter %in% color.para)
            ],
            aes(x=as.factor(Parameter), y=relative.change.shannon, color=Change), lwd=0.5) +
  # boxplots outside range
  geom_boxplot(data=Landscape_Shannon_all[(TZ==0 | 
                                             # TZ== 25 | TZ==50 | TZ==75 | 
                                             TZ==100) & Year==49
                                          & (Change=="ascending order" | Change=="competition order" | Change=="higher distance btw. FTs"  | Change=="lower distance btw. FTs")
                                          & Parameter %in% color.para
            ], 
            aes(x=as.factor(Parameter), y=relative.change.shannon, fill=Change), lwd=0.2) +
  facet_grid(TZ~.) +
  ylab("Relative change in Shannon diversity") + xlab("Parameter") + 
  scale_color_manual(name="Change \n within range",values = c("#F781BF", "#984EA3", "#A65628", "#E41A1C")) + ggtitle("Shannon diversity index") +
  scale_fill_manual(name= "Change \n outside range", values = c("#A65628", "#E41A1C")) +
  guides(fill=guide_legend(order=1), col = guide_legend(order=2)) +
  theme(axis.title = element_text(size=7), 
        legend.title = element_text(size=7), axis.text = element_text(size=6), legend.text = element_text(size=6), legend.position = "top",
        plot.title = element_text(hjust = 0.5))

color.para.0 <- levels(factor(plot.data[Parameter!="original" & 
                                          TZ==0 & 
                                          ((mean.FT<plot.data[Parameter=="original" & TZ==0]$min.FT)
                                           | 
                                             (mean.FT>plot.data[Parameter=="original" & TZ==0]$max.FT))
                                          ]$Parameter))
color.para.100 <- levels(factor(plot.data[Parameter!="original" & 
                                            TZ==100 & 
                                            ((mean.FT<plot.data[Parameter=="original" & TZ==0]$min.FT)
                                             | 
                                               (mean.FT>plot.data[Parameter=="original" & TZ==0]$max.FT))
                                          ]$Parameter))

color.para <- levels(factor(c(color.para.0,color.para.100)))

FT <- ggplot()+
  theme_few() +
  # ribbon of original min/max
  geom_rect(data = plot.data[Parameter=="original"], aes(xmin="competition_strength", xmax="res_suitability",ymin=min.FT, ymax=max.FT), alpha=0.2)+
  # boxplots inside range
  geom_boxplot(data=Landscape_Shannon_all[(TZ==0 | 
                                             TZ==100) & Year==49
                                          & (Change=="ascending order" | Change=="competition order" | Change=="higher distance btw. FTs"  | Change=="lower distance btw. FTs")
                                          & !(Parameter %in% color.para)
  ],
  aes(x=as.factor(Parameter), y=relative.change.FT, color=Change), lwd=0.5) +
  # boxplots outside range
  geom_boxplot(data=Landscape_Shannon_all[(TZ==0 | 
                                             TZ==100) & Year==49
                                          & (Change=="ascending order" | Change=="competition order" | Change=="higher distance btw. FTs"  | Change=="lower distance btw. FTs")
                                          & Parameter %in% color.para
  ], 
  aes(x=as.factor(Parameter), y=relative.change.FT, fill=Change), lwd=0.2) +
  facet_grid(TZ~.) +
  ylab("Relative change in number of FTs") + xlab("Parameter") + ggtitle("Number of functional types") +
  scale_color_manual(name="Change \n within range", values = c("#F781BF", "#A65628", "#E41A1C")) +
  scale_fill_manual(name= "Change \n outside range", values = c("#984EA3", "#A65628", "#E41A1C")) +
  guides(fill=guide_legend(order=1), col = guide_legend(order=2)) +
  theme(axis.title = element_text(size=7), legend.title = element_text(size=7), axis.text = element_text(size=6), legend.text = element_text(size=6), legend.position = "top",
        plot.title = element_text(hjust = 0.5))

jpeg("FigF4_SA_shannon+NFT_other_changes.jpeg", width=220, height=150, units="mm", res=600)
multiplot(FT, SH,
          cols = 1)
dev.off()

#####
# Figure F.2
# Mean relative change in Shannon diversity index over the amount of established TZ
#####
plot.data <- Landscape_mean[Year==49
                            # & (Change!="ascending" & Change!="order" & Change!="high_dist"  & Change!="low_dist")
]
plot.data[TZ==0, min.control:=plot.data[Parameter=="original" & TZ==0]$min.shannon]
plot.data[TZ==5, min.control:=plot.data[Parameter=="original" & TZ==5]$min.shannon]
plot.data[TZ==10, min.control:=plot.data[Parameter=="original" & TZ==10]$min.shannon]
plot.data[TZ==15, min.control:=plot.data[Parameter=="original" & TZ==15]$min.shannon]
plot.data[TZ==20, min.control:=plot.data[Parameter=="original" & TZ==20]$min.shannon]
plot.data[TZ==25, min.control:=plot.data[Parameter=="original" & TZ==25]$min.shannon]
plot.data[TZ==50, min.control:=plot.data[Parameter=="original" & TZ==50]$min.shannon]
plot.data[TZ==75, min.control:=plot.data[Parameter=="original" & TZ==75]$min.shannon]
plot.data[TZ==100, min.control:=plot.data[Parameter=="original" & TZ==100]$min.shannon]

plot.data[TZ==0, max.control:=plot.data[Parameter=="original" & TZ==0]$max.shannon]
plot.data[TZ==5, max.control:=plot.data[Parameter=="original" & TZ==5]$max.shannon]
plot.data[TZ==10, max.control:=plot.data[Parameter=="original" & TZ==10]$max.shannon]
plot.data[TZ==15, max.control:=plot.data[Parameter=="original" & TZ==15]$max.shannon]
plot.data[TZ==20, max.control:=plot.data[Parameter=="original" & TZ==20]$max.shannon]
plot.data[TZ==25, max.control:=plot.data[Parameter=="original" & TZ==25]$max.shannon]
plot.data[TZ==50, max.control:=plot.data[Parameter=="original" & TZ==50]$max.shannon]
plot.data[TZ==75, max.control:=plot.data[Parameter=="original" & TZ==75]$max.shannon]
plot.data[TZ==100, max.control:=plot.data[Parameter=="original" & TZ==100]$max.shannon]

plot.data$Change <- factor(plot.data$Change,
                       levels = c('-25', '-10', '10', '25', 'high_dist', 'low_dist', 'ascending', 'order', '0'))

# Complete fig for appendix
plot.data[Change=="ascending", Change:="ascending order"]
plot.data[Change=="order", Change:="competition order"]
plot.data[Change=="low_dist", Change:="lower distance btw. FTs"]
plot.data[Change=="high_dist", Change:="higher distance btw. FTs"]


ggplot()+
  theme_few() +
  geom_line(data=plot.data[Year==49 & Parameter!="original"], aes(x=TZ, y=mean.shannon, color=Change), size=0.5) +
  geom_ribbon(data = plot.data[Year==49 & Parameter!="original"], 
              aes(x=TZ, ymin=min.control, ymax=max.control), alpha=0.2)+
  facet_wrap(.~Parameter) +
  scale_color_brewer(palette="Spectral") +
  ylab("Relative change in Shannon diversity index") + xlab("Amount of virtually implemented agricultural buffer zones (ABZs) [%]") +
  theme(axis.title = element_text(size=7), legend.title = element_text(size=7), axis.text = element_text(size=6), legend.text = element_text(size=6))
ggsave("FigF2_SA_over_TZ_Shannon.jpeg", width=200, height=180, units="mm", dpi=1000)

#####
# Figure 4 main manuscript
# Mean realtive change in nb FTs over the amount of established TZ - x% Changes for manuscript and all changes for appendix
#####
plot.data <- Landscape_mean[Year==49
                            # & (Change!="ascending" & Change!="order" & Change!="high_dist"  & Change!="low_dist")
]
plot.data[TZ==0, min.control:=plot.data[Parameter=="original" & TZ==0]$min.FT]
plot.data[TZ==5, min.control:=plot.data[Parameter=="original" & TZ==5]$min.FT]
plot.data[TZ==10, min.control:=plot.data[Parameter=="original" & TZ==10]$min.FT]
plot.data[TZ==15, min.control:=plot.data[Parameter=="original" & TZ==15]$min.FT]
plot.data[TZ==20, min.control:=plot.data[Parameter=="original" & TZ==20]$min.FT]
plot.data[TZ==25, min.control:=plot.data[Parameter=="original" & TZ==25]$min.FT]
plot.data[TZ==50, min.control:=plot.data[Parameter=="original" & TZ==50]$min.FT]
plot.data[TZ==75, min.control:=plot.data[Parameter=="original" & TZ==75]$min.FT]
plot.data[TZ==100, min.control:=plot.data[Parameter=="original" & TZ==100]$min.FT]

plot.data[TZ==0, max.control:=plot.data[Parameter=="original" & TZ==0]$max.FT]
plot.data[TZ==5, max.control:=plot.data[Parameter=="original" & TZ==5]$max.FT]
plot.data[TZ==10, max.control:=plot.data[Parameter=="original" & TZ==10]$max.FT]
plot.data[TZ==15, max.control:=plot.data[Parameter=="original" & TZ==15]$max.FT]
plot.data[TZ==20, max.control:=plot.data[Parameter=="original" & TZ==20]$max.FT]
plot.data[TZ==25, max.control:=plot.data[Parameter=="original" & TZ==25]$max.FT]
plot.data[TZ==50, max.control:=plot.data[Parameter=="original" & TZ==50]$max.FT]
plot.data[TZ==75, max.control:=plot.data[Parameter=="original" & TZ==75]$max.FT]
plot.data[TZ==100, max.control:=plot.data[Parameter=="original" & TZ==100]$max.FT]

plot.data$Change <- as.factor(plot.data$Change)

plot.data$Change <- factor(plot.data$Change,
                           levels = c('-25', '-10', '10', '25', 'high_dist', 'low_dist', 'ascending', 'order', '0'))

# fig for manuscript
ggplot()+
  theme_few() +
  geom_line(data=plot.data[Year==49 & Parameter!="original" & Change!="ascending" & Change!="order" & Change!="low_dist" & Change!="high_dist"], aes(x=TZ, y=mean.FT, color=Change), size=0.5) +
  geom_ribbon(data = plot.data[Year==49 & Parameter!="original"& Change!="ascending" & Change!="order" & Change!="low_dist" & Change!="high_dist"], 
              aes(x=TZ, ymin=min.control, ymax=max.control), alpha=0.2)+
  facet_wrap(.~Parameter) +
  scale_color_brewer(palette="Spectral") +
  ylab("Relative change in number of FTs") + xlab("Amount of virtually implemented agricultural buffer zones (ABZs) [%]") +
  theme(axis.title = element_text(size=7), legend.title = element_text(size=7), axis.text = element_text(size=6), legend.text = element_text(size=6))
ggsave("Fig_4.jpeg", width=180, height=180, units="mm", dpi=1000)
ggsave("Fig_4.pdf", width=180, height=180, units="mm", dpi=1000)

# Complete fig for appendix
plot.data[Change=="ascending", Change:="ascending order"]
plot.data[Change=="order", Change:="competition order"]
plot.data[Change=="low_dist", Change:="lower distance btw. FTs"]
plot.data[Change=="high_dist", Change:="higher distance btw. FTs"]


ggplot()+
  theme_few() +
  geom_line(data=plot.data[Year==49 & Parameter!="original"], aes(x=TZ, y=mean.FT, color=Change), size=0.5) +
  geom_ribbon(data = plot.data[Year==49 & Parameter!="original"], 
              aes(x=TZ, ymin=min.control, ymax=max.control), alpha=0.2)+
  facet_wrap(.~Parameter) +
  scale_color_brewer(palette="Spectral") +
  ylab("Relative change in number of FTs") + xlab("Amount of virtually implemented agricultural buffer zones (ABZs) [%]") +
  theme(axis.title = element_text(size=7), legend.title = element_text(size=7), axis.text = element_text(size=6), legend.text = element_text(size=6))
ggsave("FigF1_Appendix.jpeg", width=180, height=180, units="mm", dpi=1000)
ggsave("FigF1_Appendix.pdf", width=180, height=180, units="mm", dpi=1000)

#####
# Tables
#####
table.shannon<-Landscape_mean[Year==49 & Parameter!="original",c(1,3,4,5)]
table.shannon$mean.shannon <- round(table.shannon$mean.shannon,2)
table.shannon<-dcast(table.shannon, Parameter + TZ ~ Change, value.var = "mean.shannon")
table.shannon[is.na(table.shannon)] <- "-"
fwrite(table.shannon, "SA_Shannon.txt", sep="\t")

table.FT<-Landscape_mean[Year==49 & Parameter!="original",c(1,3,4,9)]
table.FT$mean.FT <- round(table.FT$mean.FT,2)
table.FT<-dcast(table.FT, Parameter + TZ ~ Change, value.var = "mean.FT")
table.FT[is.na(table.FT)] <- "-"
fwrite(table.FT, "SA_FT.txt", sep="\t")