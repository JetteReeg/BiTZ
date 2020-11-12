require(foreach)
require(doParallel)
MC_max<-20
no_cores <- 4
cl <- makeCluster(no_cores)
registerDoParallel(cl)
foreach(MC = 16:MC_max) %dopar%
  system(paste('./BiTZ', MC, sep=" "), intern=T)
stopCluster(cl)


      
      
    