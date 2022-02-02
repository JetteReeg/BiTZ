# required packages
require(foreach)
require(doParallel)
        
MC_max<-10 # number o repetition
no_cores <- MC_max # adapt if needed
cl <- makeCluster(no_cores)
registerDoParallel(cl)
foreach(MC = 1:MC_max) %dopar%
      system(paste('./BiTZ', MC, sep=" "), intern=T) # start model
stopCluster(cl)
  


      
      
    