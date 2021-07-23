# required packages
require(foreach)
require(doParallel)
# number of available cores on HPC
MC_max<-10
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
    no_cores <- MC_max
    cl <- makeCluster(no_cores)
    registerDoParallel(cl)
    foreach(MC = 1:MC_max) %dopar%
      system(paste('./BiTZ', MC, sep=" "), intern=T)
    stopCluster(cl)
  }
  setwd('..')
}

      
      
    