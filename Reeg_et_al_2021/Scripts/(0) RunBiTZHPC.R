#' ####################################################################### #
#' PROJECT: Reeg, J.; Strigl, L.; Jeltsch, F. (submitted) Agricultural buffer 
#'                   zone thresholds to safeguard functional bee diversity:  
#'                   Insights from a community modelling approach
#' CONTENTS: 
#'  - This code is implemented to run BiTZ on an HPC
#'  DEPENDENCIES:
#'  - The folder structure and files need to be prepared in advance:
#'    You should have a simulation folder with subfolder for each landscape.
#'    See repository for the folder structure considered in this mansucript#'    
#'    Within each landscape subfolder, there should be an Input and Output folder,
#'    all model files (see repository) and a simulation.txt file
#' AUTHOR: Jette Reeg
#' ####################################################################### #
## required packages ===========================================================
require(foreach)
require(doParallel)
## Remarks =====================================================================
# This script needs to be located in the Simulation folder on a HPC
# It goes through each subdirectory to start the model for each landscape 
# raster map (i.e. subfolder)
# Make sure to copy all Model files into each subdirectory and build the model
# on the HPC. 

## Start BiTZ model ============================================================
# number of available cores on HPC
MC_max<-10 # in this version MC_max also corresponds to the repetitions

# for loop through all subdirectories/landscapes
directories <- list.dirs(recursive=F)
for (dir in directories){
  # set working directory to subfolder
  setwd(dir)
  # read simulation file
  sims<-read.table('Simulations.txt', header=T)
  # go through each simulation
  for (row in 1:nrow(sims)){
    Simulation <- sims[row,]
    write.table(Simulation, "Input/Simulations.txt", sep="\t", quote = F, row.names = F)
    no_cores <- MC_max # adapt if necessary
    cl <- makeCluster(no_cores)
    registerDoParallel(cl)
    foreach(MC = 1:MC_max) %dopar%
      system(paste('./BiTZ', MC, sep=" "), intern=T)
    stopCluster(cl)
  }
  setwd('..')
}

      
      
    