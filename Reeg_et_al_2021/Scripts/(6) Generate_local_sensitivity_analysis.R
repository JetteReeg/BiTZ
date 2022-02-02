#' ####################################################################### #
#' PROJECT: Reeg, J.; Strigl, L.; Jeltsch, F. (submitted) Agricultural buffer 
#'                   zone thresholds to safeguard functional bee diversity:  
#'                   Insights from a community modelling approach
#' CONTENTS: 
#'  - This code is implemented to generate the simulation file for a local 
#'  sensitivity analysis
#'  DEPENDENCIES:
#'  - The code needs a normal simulation file as reference
#'  
#' AUTHOR: Jette Reeg
#' ####################################################################### #

## Required packages ===========================================================
# no package required
## Sensitivity analysis: Change ================================================
# deviations tested
low <- 0.1
high <- 0.25
# change proportions between values
distance_decrease <- 0.5
distance_increase <- 1.5
## Simulation file =============================================================
# Simulations.txt
## read original simulation file
simulations <- read.table("Input/Simulations.txt", header=T)
TZ_percentages <- c(0,0.05,0.1,0.15,0.2,0.25,0.5,0.75,1.0)
## prepare the file
simulations <- simulations[rep(seq_len(nrow(simulations)), each = 9), ]
## complete TZ_percentages
row = 1
for (p in TZ_percentages){
  simulations$TZ_percentage[row]=p
  row <- row+1
}
## temporary data.frames for FT unspecific and FT specific parameters
simulations.FT_unspecific <- simulations[rep(seq_len(nrow(simulations)), each = 16), ] # 1 original + 15 variations
simulations.FT_specific <- simulations[rep(seq_len(nrow(simulations)), each = 57), ] # 57 variations

################################################################################
# FT unspecific parameters
################################################################################
## size order [place 1]
for (i in  seq(1,nrow(simulations.FT_unspecific),16)){
  simulations.FT_unspecific$size_order[1+i] <- "ascending"
}

## dispersal tries [place 2-5]
for (i in  seq(1,nrow(simulations.FT_unspecific),16)){
  simulations.FT_unspecific$dispersal_tries[2+i] <- simulations.FT_unspecific$dispersal_tries[1]-(simulations.FT_unspecific$dispersal_tries[1]*high)
  simulations.FT_unspecific$dispersal_tries[3+i] <- simulations.FT_unspecific$dispersal_tries[1]-(simulations.FT_unspecific$dispersal_tries[1]*low)
  simulations.FT_unspecific$dispersal_tries[4+i] <- simulations.FT_unspecific$dispersal_tries[1]+(simulations.FT_unspecific$dispersal_tries[1]*low)
  simulations.FT_unspecific$dispersal_tries[5+i] <- simulations.FT_unspecific$dispersal_tries[1]+(simulations.FT_unspecific$dispersal_tries[1]*high)
}

## weather_std [place 6-9]
for (i in  seq(1,nrow(simulations.FT_unspecific),16)){
  simulations.FT_unspecific$weather_std[6+i] <- simulations.FT_unspecific$weather_std[1]-(simulations.FT_unspecific$weather_std[1]*high)
  simulations.FT_unspecific$weather_std[7+i] <- simulations.FT_unspecific$weather_std[1]-(simulations.FT_unspecific$weather_std[1]*low)
  simulations.FT_unspecific$weather_std[8+i] <- simulations.FT_unspecific$weather_std[1]+(simulations.FT_unspecific$weather_std[1]*low)
  simulations.FT_unspecific$weather_std[9+i] <- simulations.FT_unspecific$weather_std[1]+(simulations.FT_unspecific$weather_std[1]*high)
}

## disturbance probability [place 10-15]
### arable 
for (i in  seq(1,nrow(simulations.FT_unspecific),16)){
  simulations.FT_unspecific$p_dist_arable[10+i] <- simulations.FT_unspecific$p_dist_arable[1]-(simulations.FT_unspecific$p_dist_arable[1]*high)
  simulations.FT_unspecific$p_dist_arable[11+i] <- simulations.FT_unspecific$p_dist_arable[1]-(simulations.FT_unspecific$p_dist_arable[1]*low)
  simulations.FT_unspecific$p_dist_arable[12+i] <- min(1,simulations.FT_unspecific$p_dist_arable[1]+(simulations.FT_unspecific$p_dist_arable[1]*low))
  simulations.FT_unspecific$p_dist_arable[13+i] <- min(1,simulations.FT_unspecific$p_dist_arable[1]+(simulations.FT_unspecific$p_dist_arable[1]*high))
  # arable is the standard value
  simulations.FT_unspecific$p_dist_arable[14+i] <- simulations.FT_unspecific$p_dist_arable[1]
  simulations.FT_unspecific$p_dist_arable[15+i] <- simulations.FT_unspecific$p_dist_arable[1]
}
### grassland
for (i in  seq(1,nrow(simulations.FT_unspecific),16)){
  simulations.FT_unspecific$p_dist_grass[10+i] <- simulations.FT_unspecific$p_dist_grass[1]-(simulations.FT_unspecific$p_dist_grass[1]*high)
  simulations.FT_unspecific$p_dist_grass[11+i] <- simulations.FT_unspecific$p_dist_grass[1]-(simulations.FT_unspecific$p_dist_grass[1]*low)
  simulations.FT_unspecific$p_dist_grass[12+i] <- min(1,simulations.FT_unspecific$p_dist_grass[1]+(simulations.FT_unspecific$p_dist_grass[1]*low))
  simulations.FT_unspecific$p_dist_grass[13+i] <- min(1,simulations.FT_unspecific$p_dist_grass[1]+(simulations.FT_unspecific$p_dist_grass[1]*high))
  # distance arable to grassland
  lower_distance <- (simulations.FT_unspecific$p_dist_arable[1]-simulations.FT_unspecific$p_dist_grass[1])*distance_decrease
  higher_distance <- (simulations.FT_unspecific$p_dist_arable[1]-simulations.FT_unspecific$p_dist_grass[1])*distance_increase
  # less distance
  simulations.FT_unspecific$p_dist_grass[14+i] <- simulations.FT_unspecific$p_dist_arable[1]-lower_distance
  # higher distance
  simulations.FT_unspecific$p_dist_grass[15+i] <- simulations.FT_unspecific$p_dist_arable[1]-higher_distance
}
### urban
for (i in  seq(1,nrow(simulations.FT_unspecific),16)){
  simulations.FT_unspecific$p_dist_urban[10+i] <- simulations.FT_unspecific$p_dist_urban[1]-(simulations.FT_unspecific$p_dist_urban[1]*high)
  simulations.FT_unspecific$p_dist_urban[11+i] <- simulations.FT_unspecific$p_dist_urban[1]-(simulations.FT_unspecific$p_dist_urban[1]*low)
  simulations.FT_unspecific$p_dist_urban[12+i] <- min(1,simulations.FT_unspecific$p_dist_urban[1]+(simulations.FT_unspecific$p_dist_urban[1]*low))
  simulations.FT_unspecific$p_dist_urban[13+i] <- min(1,simulations.FT_unspecific$p_dist_urban[1]+(simulations.FT_unspecific$p_dist_urban[1]*high))
  # distance arable to urban
  lower_distance <- (simulations.FT_unspecific$p_dist_arable[1]-simulations.FT_unspecific$p_dist_urban[1])*distance_decrease
  higher_distance <- (simulations.FT_unspecific$p_dist_arable[1]-simulations.FT_unspecific$p_dist_urban[1])*distance_increase
  # less distance
  simulations.FT_unspecific$p_dist_urban[14+i] <- simulations.FT_unspecific$p_dist_arable[1]-lower_distance
  # higher distance
  simulations.FT_unspecific$p_dist_urban[15+i] <- simulations.FT_unspecific$p_dist_arable[1]-higher_distance
}
### forest
for (i in  seq(1,nrow(simulations.FT_unspecific),16)){
  simulations.FT_unspecific$p_dist_forest[10+i] <- simulations.FT_unspecific$p_dist_forest[1]-(simulations.FT_unspecific$p_dist_forest[1]*high)
  simulations.FT_unspecific$p_dist_forest[11+i] <- simulations.FT_unspecific$p_dist_forest[1]-(simulations.FT_unspecific$p_dist_forest[1]*low)
  simulations.FT_unspecific$p_dist_forest[12+i] <- min(1,simulations.FT_unspecific$p_dist_forest[1]+(simulations.FT_unspecific$p_dist_forest[1]*low))
  simulations.FT_unspecific$p_dist_forest[13+i] <- min(1,simulations.FT_unspecific$p_dist_forest[1]+(simulations.FT_unspecific$p_dist_forest[1]*high))
  # distance arable to forest
  lower_distance <- (simulations.FT_unspecific$p_dist_arable[1]-simulations.FT_unspecific$p_dist_forest[1])*distance_decrease
  higher_distance <- (simulations.FT_unspecific$p_dist_arable[1]-simulations.FT_unspecific$p_dist_forest[1])*distance_increase
  # less distance
  simulations.FT_unspecific$p_dist_forest[14+i] <- simulations.FT_unspecific$p_dist_arable[1]-lower_distance
  # higher distance
  simulations.FT_unspecific$p_dist_forest[15+i] <- max(0,simulations.FT_unspecific$p_dist_arable[1]-higher_distance)
}
### bare
for (i in  seq(1,nrow(simulations.FT_unspecific),16)){
  simulations.FT_unspecific$p_dist_bare[10+i] <- simulations.FT_unspecific$p_dist_bare[1]-(simulations.FT_unspecific$p_dist_bare[1]*high)
  simulations.FT_unspecific$p_dist_bare[11+i] <- simulations.FT_unspecific$p_dist_bare[1]-(simulations.FT_unspecific$p_dist_bare[1]*low)
  simulations.FT_unspecific$p_dist_bare[12+i] <- min(1,simulations.FT_unspecific$p_dist_bare[1]+(simulations.FT_unspecific$p_dist_bare[1]*low))
  simulations.FT_unspecific$p_dist_bare[13+i] <- min(1,simulations.FT_unspecific$p_dist_bare[1]+(simulations.FT_unspecific$p_dist_bare[1]*high))
  # distance arable to bare
  lower_distance <- (simulations.FT_unspecific$p_dist_arable[1]-simulations.FT_unspecific$p_dist_bare[1])*distance_decrease
  higher_distance <- (simulations.FT_unspecific$p_dist_arable[1]-simulations.FT_unspecific$p_dist_bare[1])*distance_increase
  # less distance
  simulations.FT_unspecific$p_dist_bare[14+i] <- simulations.FT_unspecific$p_dist_arable[1]-lower_distance
  # higher distance
  simulations.FT_unspecific$p_dist_bare[15+i] <- max(0,simulations.FT_unspecific$p_dist_arable[1]-higher_distance)
}

################################################################################
# FT specific
################################################################################
# FT_definitions.txt
## read original simulation file
FT_definitions <- read.table("Input/FT_definitions.txt", header=T)
SA.nb <- 20
Sim.nb <- 1
## trans_effect_res
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$trans_effect_res <- FT_definitions.tmp$trans_effect_res-(FT_definitions.tmp$trans_effect_res*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$trans_effect_res <- FT_definitions.tmp$trans_effect_res+(FT_definitions.tmp$trans_effect_res*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}
## trans_eff_nest
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$trans_effect_nest <- FT_definitions.tmp$trans_effect_nest-(FT_definitions.tmp$trans_effect_nest*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$trans_effect_nest <- FT_definitions.tmp$trans_effect_nest+(FT_definitions.tmp$trans_effect_nest*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}
## trans_eff_nest & trans_eff_res
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$trans_effect_nest <- FT_definitions.tmp$trans_effect_nest-(FT_definitions.tmp$trans_effect_nest*i)
  FT_definitions.tmp$trans_effect_res <- FT_definitions.tmp$trans_effect_res-(FT_definitions.tmp$trans_effect_res*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$trans_effect_nest <- FT_definitions.tmp$trans_effect_nest+(FT_definitions.tmp$trans_effect_nest*i)
  FT_definitions.tmp$trans_effect_res <- FT_definitions.tmp$trans_effect_res+(FT_definitions.tmp$trans_effect_res*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

## growth rate
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$R <- FT_definitions.tmp$R-(FT_definitions.tmp$R*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$R <- FT_definitions.tmp$R+(FT_definitions.tmp$R*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}
# vary the distance
for (i in c(distance_decrease, distance_increase)){
  relative.value <- min (FT_definitions$R)
  FT_definitions.tmp <- FT_definitions
  for (row in 1:nrow(FT_definitions)){
    distance <- abs(relative.value-FT_definitions$R[row])*i
    FT_definitions.tmp$R[row] <- relative.value+distance
  }
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

## competition strength
FT_definitions.tmp<- FT_definitions
FT_definitions.tmp[FT_definitions$c==0,5] <- 5
FT_definitions.tmp[FT_definitions$c==1,5] <- 4
FT_definitions.tmp[FT_definitions$c==2,5] <- 3
FT_definitions.tmp[FT_definitions$c==3,5] <- 2
FT_definitions.tmp[FT_definitions$c==4,5] <- 1
FT_definitions.tmp[FT_definitions$c==5,5] <- 0
write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
  simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
}
SA.nb <- SA.nb + 1
Sim.nb <- Sim.nb + 1

## dispersal mean
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$dispmean <- FT_definitions.tmp$dispmean-(FT_definitions.tmp$dispmean*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$dispmean <- FT_definitions.tmp$dispmean+(FT_definitions.tmp$dispmean*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}
# vary the distance
for (i in c(distance_decrease, distance_increase)){
  relative.value <- min (FT_definitions$dispmean)
  FT_definitions.tmp <- FT_definitions
  for (row in 1:nrow(FT_definitions)){
    distance <- abs(relative.value-FT_definitions$dispmean[row])*i
    FT_definitions.tmp$dispmean[row] <- relative.value+distance
  }
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

## dispersal sd
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$dispsd <- FT_definitions.tmp$dispsd-(FT_definitions.tmp$dispsd*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$dispsd <- FT_definitions.tmp$dispsd+(FT_definitions.tmp$dispsd*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}
# vary the distance
for (i in c(distance_decrease, distance_increase)){
  relative.value <- min (FT_definitions$dispsd)
  FT_definitions.tmp <- FT_definitions
  for (row in 1:nrow(FT_definitions)){
    distance <- abs(relative.value-FT_definitions$dispsd[row])*i
    FT_definitions.tmp$dispsd[row] <- relative.value+distance
  }
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

## emigration mu
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$mu <- FT_definitions.tmp$mu-(FT_definitions.tmp$mu*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$mu <- FT_definitions.tmp$mu+(FT_definitions.tmp$mu*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

## emigration omega
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$omega <- FT_definitions.tmp$omega-(FT_definitions.tmp$omega*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$omega <- FT_definitions.tmp$omega+(FT_definitions.tmp$omega*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

## disturbance effect
for(i in c(low, high)){
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$dist_eff <- FT_definitions.tmp$dist_eff-(FT_definitions.tmp$dist_eff*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  FT_definitions.tmp<- FT_definitions
  FT_definitions.tmp$dist_eff <- FT_definitions.tmp$dist_eff+(FT_definitions.tmp$dist_eff*i)
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}
# vary the distance
for (i in c(distance_decrease, distance_increase)){
  relative.value <- min (FT_definitions$dist_eff)
  FT_definitions.tmp <- FT_definitions
  for (row in 1:nrow(FT_definitions)){
    distance <- abs(relative.value-FT_definitions$dist_eff[row])*(i)
    FT_definitions.tmp$dist_eff[row] <- relative.value+distance
  }
  write.table(FT_definitions.tmp, paste("Input/FT_definitions_",SA.nb,".txt", sep=""),sep="\t", row.names = F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameFtFile[j] <- paste("Input/FT_definitions_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

########################
# Change land use suitability files
########################

# Resources
LU_res <- read.table("Input/LU_FT_suitability_forage_flying_period.txt", header=T)
colnames(LU_res) <-c("ID", 1:28)
# SA.nb <- 20 # is 65
# Sim.nb <- 1 # should be 46 from here
for(i in c(low, high)){
  LU_res.tmp<- LU_res
  LU_res.tmp <- LU_res.tmp-(LU_res.tmp*i)
  LU_res.tmp$ID <- LU_res$ID
  write.table(LU_res.tmp, paste("Input/LU_res_",SA.nb,".txt", sep=""),sep="\t", row.names = F, quote=F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameForageSuitabilityFile[j] <- paste("Input/LU_res_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  LU_res.tmp<- LU_res
  LU_res.tmp <- LU_res.tmp+(LU_res.tmp*i)
  LU_res.tmp$ID <- LU_res$ID
  write.table(LU_res.tmp, paste("Input/LU_res_",SA.nb,".txt", sep=""),sep="\t", row.names = F, quote=F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameForageSuitabilityFile[j] <- paste("Input/LU_res_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}
# vary the distance
for (i in c(distance_decrease, distance_increase)){
  relative.value.1 <- min(LU_res[2,])
  relative.value.2 <- min(LU_res[3,])
  relative.value.3 <- min(LU_res[4,])
  relative.value.4 <- min(LU_res[5,])
  relative.value.6 <- min(LU_res[7,])
  LU_res.tmp <- LU_res
  for (col in 2:ncol(LU_res.tmp)){
    # arable
    distance <- abs(relative.value.1-LU_res[2,col])*i
    LU_res.tmp[2,col] <- relative.value.1+distance
    # forest
    distance <- abs(relative.value.2-LU_res[3,col])*i
    LU_res.tmp[3,col] <- relative.value.2+distance
    # grassland
    distance <- abs(relative.value.3-LU_res[4,col])*i
    LU_res.tmp[4,col] <- relative.value.3+distance
    # urban
    distance <- abs(relative.value.4-LU_res[5,col])*i
    LU_res.tmp[5,col] <- relative.value.4+distance
    # TZ (same as arable)
    distance <- abs(relative.value.6-LU_res[7,col])*i
    LU_res.tmp[7,col] <- relative.value.6+distance
  }
  write.table(LU_res.tmp, paste("Input/LU_res_",SA.nb,".txt", sep=""),sep="\t", row.names = F, quote=F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameForageSuitabilityFile[j] <- paste("Input/LU_res_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

# Nesting sites
LU_nest <- read.table("Input/LU_FT_suitability_nesting.txt", header=T)
colnames(LU_nest) <-c("ID", 1:28)
# SA.nb <- 20 # is 65
# Sim.nb <- 1 # should be 46 from here
for(i in c(low, high)){
  LU_nest.tmp<- LU_nest
  LU_nest.tmp <- LU_nest.tmp-(LU_nest.tmp*i)
  LU_nest.tmp$ID <- LU_nest$ID
  write.table(LU_nest.tmp, paste("Input/LU_nest_",SA.nb,".txt", sep=""),sep="\t", row.names = F, quote=F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameNestSuitabilityFile[j] <- paste("Input/LU_nest_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
  LU_nest.tmp<- LU_nest
  LU_nest.tmp <- LU_nest.tmp+(LU_nest.tmp*i)
  LU_nest.tmp$ID <- LU_nest$ID
  write.table(LU_nest.tmp, paste("Input/LU_nest_",SA.nb,".txt", sep=""),sep="\t", row.names = F, quote=F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameNestSuitabilityFile[j] <- paste("Input/LU_nest_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}
# vary the distance
for (i in c(distance_decrease, distance_increase)){
  relative.value.0 <- min(LU_nest[1,])
  relative.value.1 <- min(LU_nest[2,])
  relative.value.2 <- min(LU_nest[3,])
  relative.value.3 <- min(LU_nest[4,])
  relative.value.4 <- min(LU_nest[5,])
  relative.value.6 <- min(LU_nest[7,])
  LU_nest.tmp <- LU_nest
  for (col in 2:ncol(LU_nest.tmp)){
    # bare
    distance <- abs(relative.value.0-LU_nest[1,col])*i
    LU_nest.tmp[1,col] <- relative.value.0+distance
    # arable
    distance <- abs(relative.value.1-LU_nest[2,col])*i
    LU_nest.tmp[2,col] <- relative.value.1+distance
    # fonestt
    distance <- abs(relative.value.2-LU_nest[3,col])*i
    LU_nest.tmp[3,col] <- relative.value.2+distance
    # grassland
    distance <- abs(relative.value.3-LU_nest[4,col])*i
    LU_nest.tmp[4,col] <- relative.value.3+distance
    # urban
    distance <- abs(relative.value.4-LU_nest[5,col])*i
    LU_nest.tmp[5,col] <- relative.value.4+distance
    # TZ (same as arable)
    distance <- abs(relative.value.6-LU_nest[7,col])*i
    LU_nest.tmp[7,col] <- relative.value.6+distance
  }
  write.table(LU_nest.tmp, paste("Input/LU_nest_",SA.nb,".txt", sep=""),sep="\t", row.names = F, quote=F)
  for (j in  seq(Sim.nb,nrow(simulations.FT_specific),57)){
    simulations.FT_specific$NameNestSuitabilityFile[j] <- paste("Input/LU_nest_",SA.nb,".txt", sep="")
  }
  SA.nb <- SA.nb + 1
  Sim.nb <- Sim.nb + 1
}

################################################################################
# combine FT specific and unspecific SA
simulations.new <- rbind(simulations.FT_unspecific, simulations.FT_specific)
simulations.new$SimNb <- c(1:nrow(simulations.new))
write.table(simulations.new, "Simulations_SA.txt", sep="\t", row.names = F, quote=F)
