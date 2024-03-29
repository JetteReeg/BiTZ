#' ####################################################################### #
#' PROJECT: Reeg, J.; Strigl, L.; Jeltsch, F. (submitted) Agricultural buffer 
#'                   zone thresholds to safeguard functional bee diversity:  
#'                   Insights from a community modelling approach
#' CONTENTS: 
#'  - This code is implemented to calculate feeding intensity txt files for
#'  an examplary repetition
#'  DEPENDENCIES:
#'  - The code needs simulation output
#'  
#' AUTHOR: Jette Reeg
#' ####################################################################### #
## required packages ===========================================================
require(data.table)
require(ggplot2)
require(ggthemes)

## Working directory ===========================================================
# make sure to set the working directory to the simulation folder
## Remarks =====================================================================
# This script has a long runtime, it might be faster when running on a cluster
## Generating feeding intensity maps ===========================================
# go through each landscape folder
directories <- list.dirs(recursive=F)
for (dir in directories){
  # set working directory
  setwd(dir)
  setwd("Input")
  # FT definitions
  FT_def <- fread("FT_Definitions.txt")
  LU_resources <- fread("LU_FT_suitability_forage_flying_period.txt")
  # change working directory
  setwd('..')
  setwd('Output')
  # read in one example file (one repetition)
  # Landscape
  landscape <- transpose(fread("Land_1_1.txt", skip=1))[-1,]
  landscape1 <- data.table(expand.grid(y=1:150, x=1:150))
  landscape1[,LU:=0]
  for ( j in 1:150){
    for ( i in 1:150){
      ID <- ((i-1)*150)+j
      lu <- landscape[ID]
      landscape1[y==j & x==i, LU:=lu]
    }
  }
  landscape1[LU==6, LU:=1]
  
  #####
  # TZ 0: simulation nb. 5
  #####
  Landscape0 <- copy(landscape1)
  TZ0 <- transpose(fread("TZ_5_1.txt", skip = 1))[-1]
  for (j in 1:150){
    for (i in 1:150){
    ID <- ((i-1)*150)+j
    lu <- TZ0[ID]
    if (lu==1) Landscape0[y==j & x==i, LU:=6]
    }
  }
  # Populations
  Pop0 <-matrix( list(rep(0,28)), 150,150)
  FTpop <- fread("LandOut_5_1.txt")
  # which FT is foraging in which cell?
  
  FTpop<-FTpop[Year==49]
  # 
  for (j in 1:150){
    for (i in 1:150){
      popincell<-FTpop[x==i & y==j]
      for (ft_id in popincell$FT_ID){
        Pop0[[j,i]][ft_id] <- Pop0[[j,i]][ft_id] + popincell[FT_ID==ft_id,popsize]
      }
    }
  }
  
  foragingPop0 <-matrix( list(rep(0,28)), 150,150)
  # go through each Pop100[[j,i]] vector and calculate the foraging range of each FT
  for (j in 1:150){
    for (i in 1:150){
      FTs_toforage <- Pop0[[j,i]]
      for (ft in 1:length(FTs_toforage)){
        if (Pop0[[j,i]][ft]>0){
          foraging_distance <- FT_def[ID==ft,dispmean/20]
          # within the whole foraging range
          xmin <- i-foraging_distance
          if (xmin<1) xmin <- 1
          xmax <- i+foraging_distance
          if (xmax>150) xmax <- 150
          ymin <- j-foraging_distance
          if (ymin<1) ymin <- 1
          ymax <- j+foraging_distance
          if (ymax>150) ymax <- 150
          for (x in xmin:xmax){
            for (y in ymin:ymax){
              # calculate exact distance
              dist_curr <- sqrt(((i-x)^2)+((j-y)^2))
              if (dist_curr<=foraging_distance){
                foragingPop0[[y,x]][ft] <- foragingPop0[[y,x]][ft] + Pop0[[j,i]][ft]
              } # end if
            }
          } # end foraging range
        } # end if there is a population
        
        
      }# end foraging FTs
    }
  }
  # end population grid
  
  Resource_uptake <- matrix(0, nrow=150, ncol=150)
  # calculate for each cell the resource uptake
  # go through each cell
  for (j in 1:150){
    for (i in 1:150){
      
      foraging_populations <- foragingPop0[[j,i]]
      resource_uptake <- 0
      for (ft_curr in  1:length(foraging_populations)){
        
        if (foraging_populations[ft_curr]>0){
          
          sum_pop <- 0
          C <- 0
          sum_res_comp <- 0
          cj <- FT_def[ID==ft_curr, c]
          
          lu_id <- Landscape0[x==i & y==j, LU]
  
          
          uptake <- as.data.frame(LU_resources[ID==lu_id])
          uptake <- uptake[1,ft_curr+1]
          if (lu_id==6) uptake <- uptake + 1
          
          # get flying period of the FT
          flying_period_curr <- FT_def[ID==ft_curr, flying_period]
          
          if (flying_period_curr == 1){
            
            competing_fts <- FT_def[flying_period==1 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            } # end for competing
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            } # end for competing
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
          }
          
          if (flying_period_curr == 2){
            
            competing_fts <- FT_def[flying_period==2 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
          
          if (flying_period_curr == 3){
            
            competing_fts <- FT_def[, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
        }
      }
      
      Resource_uptake[j,i] <- resource_uptake
    }
  }
  # store output
  fwrite(Resource_uptake, "resource_uptake_heatmap_0.txt")

  #####
  # TZ 100: simulation nb. 1
  #####
  Landscape100 <- copy(landscape1)
  TZ100 <- transpose(fread("TZ_1_1.txt", skip = 1))[-1]
  for (j in 1:150){
    for (i in 1:150){
      ID <- ((i-1)*150)+j
      lu <- TZ100[ID]
      # Landscape0[y==j & x==i, LU:=lu]
      if (lu==1) Landscape100[y==j & x==i, LU:=6]
    }
  }
  # Populations
  Pop100 <-matrix( list(rep(0,28)), 150,150)
  FTpop100 <- fread("LandOut_1_1.txt")
  # which FT is foraging in which cell?
  
  FTpop100<-FTpop100[Year==49]
  # 
  for (j in 1:150){
    for (i in 1:150){
      popincell<-FTpop100[x==i & y==j]
      for (ft_id in popincell$FT_ID){
        Pop100[[j,i]][ft_id] <- Pop100[[j,i]][ft_id] + popincell[FT_ID==ft_id,popsize]
      }
    }
  }
  
  foragingPop100 <-matrix( list(rep(0,28)), 150,150)
  # go through each Pop100[[j,i]] vector and calculate the foraging range of each FT
  for (j in 1:150){
    for (i in 1:150){
      FTs_toforage <- Pop100[[j,i]]
      for (ft in 1:length(FTs_toforage)){
        if (Pop100[[j,i]][ft]>0){
          foraging_distance <- FT_def[ID==ft,dispmean/20]
          # within the whole foraging range
          xmin <- i-foraging_distance
          if (xmin<1) xmin <- 1
          xmax <- i+foraging_distance
          if (xmax>150) xmax <- 150
          ymin <- j-foraging_distance
          if (ymin<1) ymin <- 1
          ymax <- j+foraging_distance
          if (ymax>150) ymax <- 150
          for (x in xmin:xmax){
            for (y in ymin:ymax){
              # calculate exact distance
              dist_curr <- sqrt(((i-x)^2)+((j-y)^2))
              if (dist_curr<=foraging_distance){
                foragingPop100[[y,x]][ft] <- foragingPop100[[y,x]][ft] + Pop100[[j,i]][ft]
              } # end if
            }
          } # end foraging range
        } # end if there is a population
        
        
      }# end foraging FTs
    }
  }
  # end population grid
  
  Resource_uptake <- matrix(0, nrow=150, ncol=150)
  # calculate for each cell the resource uptake
  # go through each cell
  for (j in 1:150){
    for (i in 1:150){
      
      foraging_populations <- foragingPop100[[j,i]]
      resource_uptake <- 0
      for (ft_curr in  1:length(foraging_populations)){
        
        if (foraging_populations[ft_curr]>0){
          
          sum_pop <- 0
          C <- 0
          sum_res_comp <- 0
          cj <- FT_def[ID==ft_curr, c]
          
          lu_id <- Landscape100[x==i & y==j, LU]
          
          
          uptake <- as.data.frame(LU_resources[ID==lu_id])
          uptake <- uptake[1,ft_curr+1]
          if (lu_id==6) uptake <- uptake + 1
          
          # get flying period of the FT
          flying_period_curr <- FT_def[ID==ft_curr, flying_period]
          
          if (flying_period_curr == 1){
            
            competing_fts <- FT_def[flying_period==1 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            } # end for competing
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            } # end for competing
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
          }
          
          if (flying_period_curr == 2){
            
            competing_fts <- FT_def[flying_period==2 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
          
          if (flying_period_curr == 3){
            
            competing_fts <- FT_def[, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
        }
      }
      
      Resource_uptake[j,i] <- resource_uptake
    }
  }
  # store output
  fwrite(Resource_uptake, "resource_uptake_heatmap_100.txt")
  
  #####
  # TZ 25: simulation nb. 4
  #####
  Landscape25 <- copy(landscape1)
  TZ25 <- transpose(fread("TZ_4_1.txt", skip = 1))[-1]
  for (j in 1:150){
    for (i in 1:150){
      ID <- ((i-1)*150)+j
      lu <- TZ25[ID]
      # Landscape0[y==j & x==i, LU:=lu]
      if (lu==1) Landscape25[y==j & x==i, LU:=6]
    }
  }
  # Populations
  Pop25 <-matrix( list(rep(0,28)), 150,150)
  FTpop25 <- fread("LandOut_4_1.txt")
  # which FT is foraging in which cell?
  
  FTpop25<-FTpop25[Year==49]
  # 
  for (j in 1:150){
    for (i in 1:150){
      popincell<-FTpop25[x==i & y==j]
      for (ft_id in popincell$FT_ID){
        Pop25[[j,i]][ft_id] <- Pop25[[j,i]][ft_id] + popincell[FT_ID==ft_id,popsize]
      }
    }
  }
  
  foragingPop25 <-matrix( list(rep(0,28)), 150,150)
  # go through each Pop100[[j,i]] vector and calculate the foraging range of each FT
  for (j in 1:150){
    for (i in 1:150){
      FTs_toforage <- Pop25[[j,i]]
      for (ft in 1:length(FTs_toforage)){
        if (Pop25[[j,i]][ft]>0){
          foraging_distance <- FT_def[ID==ft,dispmean/20]
          # within the whole foraging range
          xmin <- i-foraging_distance
          if (xmin<1) xmin <- 1
          xmax <- i+foraging_distance
          if (xmax>150) xmax <- 150
          ymin <- j-foraging_distance
          if (ymin<1) ymin <- 1
          ymax <- j+foraging_distance
          if (ymax>150) ymax <- 150
          for (x in xmin:xmax){
            for (y in ymin:ymax){
              # calculate exact distance
              dist_curr <- sqrt(((i-x)^2)+((j-y)^2))
              if (dist_curr<=foraging_distance){
                foragingPop25[[y,x]][ft] <- foragingPop25[[y,x]][ft] + Pop25[[j,i]][ft]
              } # end if
            }
          } # end foraging range
        } # end if there is a population
        
        
      }# end foraging FTs
    }
  }
  # end population grid
  
  Resource_uptake <- matrix(0, nrow=150, ncol=150)
  # calculate for each cell the resource uptake
  # go through each cell
  for (j in 1:150){
    for (i in 1:150){
      
      foraging_populations <- foragingPop25[[j,i]]
      resource_uptake <- 0
      for (ft_curr in  1:length(foraging_populations)){
        
        if (foraging_populations[ft_curr]>0){
          
          sum_pop <- 0
          C <- 0
          sum_res_comp <- 0
          cj <- FT_def[ID==ft_curr, c]
          
          lu_id <- Landscape25[x==i & y==j, LU]
          
          
          uptake <- as.data.frame(LU_resources[ID==lu_id])
          uptake <- uptake[1,ft_curr+1]
          if (lu_id==6) uptake <- uptake + 1
          
          # get flying period of the FT
          flying_period_curr <- FT_def[ID==ft_curr, flying_period]
          
          if (flying_period_curr == 1){
            
            competing_fts <- FT_def[flying_period==1 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            } # end for competing
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            } # end for competing
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
          }
          
          if (flying_period_curr == 2){
            
            competing_fts <- FT_def[flying_period==2 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
          
          if (flying_period_curr == 3){
            
            competing_fts <- FT_def[, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
        }
      }
      
      Resource_uptake[j,i] <- resource_uptake
    }
  }
  # store output
  fwrite(Resource_uptake, "resource_uptake_heatmap_25.txt")
  
  #####
  # TZ 50: simulation nb. 3
  #####
  Landscape50 <- copy(landscape1)
  TZ50 <- transpose(fread("TZ_3_1.txt", skip = 1))[-1]
  for (j in 1:150){
    for (i in 1:150){
      ID <- ((i-1)*150)+j
      lu <- TZ50[ID]
      # Landscape0[y==j & x==i, LU:=lu]
      if (lu==1) Landscape50[y==j & x==i, LU:=6]
    }
  }
  # Populations
  Pop50 <-matrix( list(rep(0,28)), 150,150)
  FTpop50 <- fread("LandOut_3_1.txt")
  # which FT is foraging in which cell?
  
  FTpop50<-FTpop50[Year==49]
  # 
  for (j in 1:150){
    for (i in 1:150){
      popincell<-FTpop50[x==i & y==j]
      for (ft_id in popincell$FT_ID){
        Pop50[[j,i]][ft_id] <- Pop50[[j,i]][ft_id] + popincell[FT_ID==ft_id,popsize]
      }
    }
  }
  
  foragingPop50 <-matrix( list(rep(0,28)), 150,150)
  # go through each Pop100[[j,i]] vector and calculate the foraging range of each FT
  for (j in 1:150){
    for (i in 1:150){
      FTs_toforage <- Pop50[[j,i]]
      for (ft in 1:length(FTs_toforage)){
        if (Pop50[[j,i]][ft]>0){
          foraging_distance <- FT_def[ID==ft,dispmean/20]
          # within the whole foraging range
          xmin <- i-foraging_distance
          if (xmin<1) xmin <- 1
          xmax <- i+foraging_distance
          if (xmax>150) xmax <- 150
          ymin <- j-foraging_distance
          if (ymin<1) ymin <- 1
          ymax <- j+foraging_distance
          if (ymax>150) ymax <- 150
          for (x in xmin:xmax){
            for (y in ymin:ymax){
              # calculate exact distance
              dist_curr <- sqrt(((i-x)^2)+((j-y)^2))
              if (dist_curr<=foraging_distance){
                foragingPop50[[y,x]][ft] <- foragingPop50[[y,x]][ft] + Pop50[[j,i]][ft]
              } # end if
            }
          } # end foraging range
        } # end if there is a population
        
        
      }# end foraging FTs
    }
  }
  # end population grid
  
  Resource_uptake <- matrix(0, nrow=150, ncol=150)
  # calculate for each cell the resource uptake
  # go through each cell
  for (j in 1:150){
    for (i in 1:150){
      
      foraging_populations <- foragingPop50[[j,i]]
      resource_uptake <- 0
      for (ft_curr in  1:length(foraging_populations)){
        
        if (foraging_populations[ft_curr]>0){
          
          sum_pop <- 0
          C <- 0
          sum_res_comp <- 0
          cj <- FT_def[ID==ft_curr, c]
          
          lu_id <- Landscape50[x==i & y==j, LU]
          
          
          uptake <- as.data.frame(LU_resources[ID==lu_id])
          uptake <- uptake[1,ft_curr+1]
          if (lu_id==6) uptake <- uptake + 1
          
          # get flying period of the FT
          flying_period_curr <- FT_def[ID==ft_curr, flying_period]
          
          if (flying_period_curr == 1){
            
            competing_fts <- FT_def[flying_period==1 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            } # end for competing
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            } # end for competing
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
          }
          
          if (flying_period_curr == 2){
            
            competing_fts <- FT_def[flying_period==2 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
          
          if (flying_period_curr == 3){
            
            competing_fts <- FT_def[, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
        }
      }
      
      Resource_uptake[j,i] <- resource_uptake
    }
  }
  # store output
  fwrite(Resource_uptake, "resource_uptake_heatmap_50.txt")
  
  #####
  # TZ 75: simulation nb. 2
  #####
  Landscape75 <- copy(landscape1)
  TZ75 <- transpose(fread("TZ_2_1.txt", skip = 1))[-1]
  for (j in 1:150){
    for (i in 1:150){
      ID <- ((i-1)*150)+j
      lu <- TZ75[ID]
      # Landscape0[y==j & x==i, LU:=lu]
      if (lu==1) Landscape75[y==j & x==i, LU:=6]
    }
  }
  # Populations
  Pop75 <-matrix( list(rep(0,28)), 150,150)
  FTpop75 <- fread("LandOut_2_1.txt")
  # which FT is foraging in which cell?
  
  FTpop75<-FTpop75[Year==49]
  # 
  for (j in 1:150){
    for (i in 1:150){
      popincell<-FTpop75[x==i & y==j]
      for (ft_id in popincell$FT_ID){
        Pop75[[j,i]][ft_id] <- Pop75[[j,i]][ft_id] + popincell[FT_ID==ft_id,popsize]
      }
    }
  }
  
  foragingPop75 <-matrix( list(rep(0,28)), 150,150)
  # go through each Pop100[[j,i]] vector and calculate the foraging range of each FT
  for (j in 1:150){
    for (i in 1:150){
      FTs_toforage <- Pop75[[j,i]]
      for (ft in 1:length(FTs_toforage)){
        if (Pop75[[j,i]][ft]>0){
          foraging_distance <- FT_def[ID==ft,dispmean/20]
          # within the whole foraging range
          xmin <- i-foraging_distance
          if (xmin<1) xmin <- 1
          xmax <- i+foraging_distance
          if (xmax>150) xmax <- 150
          ymin <- j-foraging_distance
          if (ymin<1) ymin <- 1
          ymax <- j+foraging_distance
          if (ymax>150) ymax <- 150
          for (x in xmin:xmax){
            for (y in ymin:ymax){
              # calculate exact distance
              dist_curr <- sqrt(((i-x)^2)+((j-y)^2))
              if (dist_curr<=foraging_distance){
                foragingPop75[[y,x]][ft] <- foragingPop75[[y,x]][ft] + Pop75[[j,i]][ft]
              } # end if
            }
          } # end foraging range
        } # end if there is a population
        
        
      }# end foraging FTs
    }
  }
  # end population grid
  
  Resource_uptake <- matrix(0, nrow=150, ncol=150)
  # calculate for each cell the resource uptake
  # go through each cell
  for (j in 1:150){
    for (i in 1:150){
      
      foraging_populations <- foragingPop75[[j,i]]
      resource_uptake <- 0
      for (ft_curr in  1:length(foraging_populations)){
        
        if (foraging_populations[ft_curr]>0){
          
          sum_pop <- 0
          C <- 0
          sum_res_comp <- 0
          cj <- FT_def[ID==ft_curr, c]
          
          lu_id <- Landscape75[x==i & y==j, LU]
          
          
          uptake <- as.data.frame(LU_resources[ID==lu_id])
          uptake <- uptake[1,ft_curr+1]
          if (lu_id==6) uptake <- uptake + 1
          
          # get flying period of the FT
          flying_period_curr <- FT_def[ID==ft_curr, flying_period]
          
          if (flying_period_curr == 1){
            
            competing_fts <- FT_def[flying_period==1 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            } # end for competing
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            } # end for competing
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
          }
          
          if (flying_period_curr == 2){
            
            competing_fts <- FT_def[flying_period==2 | flying_period==3, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
          
          if (flying_period_curr == 3){
            
            competing_fts <- FT_def[, ID]
            
            # sum of competition parameter
            for (z in competing_fts) {
              # sum of populations
              sum_pop <- sum_pop + foraging_populations[z]
              # sum of competition effects
              if (foraging_populations[z]>0) C <- C + FT_def[ID==z, c]
            }
            
            # calculate competition
            for (z in competing_fts){
              if (foraging_populations[z]>0){
                ci <- FT_def[ID==z, c]
                Ni <- foraging_populations[z]
                to_add <- (1+((cj-ci)/C))*Ni
                sum_res_comp <- sum_res_comp + to_add
              }
            }
            
            sum_res_comp <- sum_res_comp/sum_pop
            resource_uptake <- resource_uptake + (sum_res_comp*uptake)
            
          }
        }
      }
      
      Resource_uptake[j,i] <- resource_uptake
    }
  }
  # store output
  fwrite(Resource_uptake, "resource_uptake_heatmap_75.txt")
  
  #####
  # save all landscapes
  #####
  
  fwrite(Landscape100, "Landscape_TZ100.txt")
  fwrite(Landscape75, "Landscape_TZ75.txt")
  fwrite(Landscape50, "Landscape_TZ50.txt")
  fwrite(Landscape25, "Landscape_TZ25.txt")
  fwrite(Landscape0, "Landscape_TZ0.txt")
}