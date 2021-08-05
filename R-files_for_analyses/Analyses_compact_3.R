# required packages
require(ggplot2)
require(ggthemes)
require(gganimate)
require(gifski)
require(data.table)
require(vegan)
# set working directory
#home_work_dir <- "C:/Users/least/OneDrive/Dokumente/GitHub/BiTZ/Output/Neu"
#setwd(home_work_dir)

# next step: automatically go through each folder
directories <- list.dirs(recursive=F)
# for (dir in directories){
# go through each directory (landscape folder)
for (dir in c("./1c", "./1f", "./2c", "./2h", 
              "./2j", "./3a", "./3c", "./7a", 
              "./6e", "./8e", "./7g")){
  setwd(dir)
  # create data tables to store the results
  # population based analyses on
  # land use class level only selected patches
  data.list.lu.pa<-data.table()
  # land use class level
  data.list.lu<-data.table()
  # landscape level
  data.list.land<-data.table()
    
  # community based analyses on
  # land use class level only selected patches
  NFT.list.lu.pa<-data.table()
  # land use class level
  NFT.list.lu<-data.table()
  # landscape level
  NFT.list.land<-data.table()
  
  # read in the scenarios
  scenarios <- fread("Simulations.txt")
  # if there is more than one scenario in at least one simulation number (duplicated Simnb.)
  if (any(duplicated(scenarios$SimNb))){
    Scenario <- 1
    analysed_patches<-fread("Analyse_patches.txt")[,2]
    Patch_def <- fread(paste("Input/Patch_ID_definitions_150x150_", unlist(strsplit(dir,"./"))[2], ".txt", sep=""), sep="\t")
    Patch_def <- Patch_def[TYPE=="arable"]
    analysed_patches <- c(analysed_patches$x, Patch_def$PID)
    # change the working directory
    setwd('Output')
    for (i in unique(scenarios$SimNb)){
      # read in all output file names for patch level output
      file_list_Gridout <- list.files(pattern=paste("GridOut_", i,"_*", sep=""))
      # go through this file list and summarize on different output levels + combine all MC simulations
      for (file in 1:length(file_list_Gridout)){
        # read in file
        data<-fread(file_list_Gridout[file])
        # how big should the data set be?
        max_FTs <- max(data$FT_ID) # maximal number of FTs
        max_patch <- max(data$Pa_ID) # maximal number of patches
        max_year <- max(data$Year)+1 # maximal number of years
        max_nrow <- max_FTs*max_patch*max_year # full combination
        # if the data set is greater than expected
        if (nrow(data)> max_nrow){
          # number of scenarios in this data table
          nb_simulations <- nrow(data)/max_nrow
          # help variable
          Scenario_help <- Scenario
          # for each scenario in this data table
          for (j in 0:(nb_simulations-1)){
            data_help <- data[(j*max_nrow+1):((j+1)*max_nrow),]
            # define the land use classes
            data_help[LU_ID==0,LU:="bare"]
            data_help[LU_ID==1,LU:="arable"]
            data_help[LU_ID==2,LU:="forest"]
            data_help[LU_ID==3,LU:="grassland"]
            data_help[LU_ID==4,LU:="urban"]
            data_help[LU_ID==5,LU:="water"]
            data_help[LU_ID==6,LU:="transition zone"]
            # take care of NAs
            data_help[is.na(data_help)] <-0
            # assign the Scenario number
            data_help[,Scenario:=Scenario_help]
            # assign the Monte Carlo simulation number
            data_help[,MC:=file]
            
            # population level output
            ## per LU class of selected patches
            data_LU.pa<-data_help[Pa_ID %in% analysed_patches,]
            data_LU.pa<-data_LU.pa[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
            data_LU.pa[is.na(data_LU.pa)] <-0 # take care of NAs (shouldn't be actually there)
            ### combine data sets
            l <- list(data.list.lu.pa, data_LU.pa)
            data.list.lu.pa<-rbindlist(l)

            ## per land use class: calculate the sum of the population sizes per land use class
            data_LU<-data_help[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
            data_LU[is.na(data_LU)] <-0 # take care of NAs (shouldn't be actually there)
            ### combine data sets
            l <- list(data_LU, data.list.lu)
            data.list.lu<-rbindlist(l)

            ## per landscape: calculate the sum of the population sizes per landscape
            data_land<-data_help[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
            data_land[is.na(data_land)] <-0 # take care of NAs (shouldn't be actually there)
            ### combine data sets
            l <- list(data_land, data.list.land)
            data.list.land<-rbindlist(l)

            # community level output
            ## per LU_class selected patches: calculate the number of FTs, individuals and diversity
            NFT_LU.pa<-data_help[Pa_ID %in% analysed_patches]
            NFT_LU.pa[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
            ### then calculate the number of FTs, individuals and diversity
            NFT_LU.pa<-NFT_LU.pa[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year, LU, LU_ID)]
            NFT_LU.pa[is.na(NFT_LU.pa)] <-0 # take care of NAs (could be there @ diversity measures)
            ### combine data sets
            l <- list(NFT_LU.pa, NFT.list.lu.pa)
            NFT.list.lu.pa<-rbindlist(l)

            ## per land use class: first calculate the sum per land use class
            NFT_LU<-data_help[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
            ### then calculate the number of FTs, individuals and diversity
            NFT_LU<-NFT_LU[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year, LU, LU_ID)]
            NFT_LU[is.na(NFT_LU)] <-0 # take care of NAs (could be there @ diversity measures)
            ### combine data sets
            l <- list(NFT_LU, NFT.list.lu)
            NFT.list.lu<-rbindlist(l)

            ## per landscape: first calculate the sum
            NFT_land<-data_help[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
            ### then calculate the number of FTs, individuals and diversityv
            NFT_land<-NFT_land[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year)]
            NFT_land[is.na(NFT_land)] <-0 # take care of NAs (could be there @ diversity measures)

            ## per landscape and FTs with pop sizes > 10.000: first calculate the sum
            NFT_land.10.000<-data_help[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
            ### then calculate the number of FTs, individuals and diversityv
            NFT_land.10.000<-NFT_land.10.000[Popsize>10000,.(FT_10.000=specnumber(Popsize)), by=.(Scenario, MC, Year)]

            ### merge the two NFT_land data.tables
            setkey(NFT_land, Scenario, MC, Year)
            setkey(NFT_land.10.000, Scenario, MC, Year)
            NFT_land<-merge(NFT_land, NFT_land.10.000)
            ### combine data sets
            l <- list(NFT_land, NFT.list.land)
            NFT.list.land<-rbindlist(l)


            # remove the temporary help file
            rm(data_help)
            Scenario_help <- Scenario_help + 1
          }
        } else {# otherwise normal
          # define the land use classes
          data[LU_ID==0,LU:="bare"]
          data[LU_ID==1,LU:="arable"]
          data[LU_ID==2,LU:="forest"]
          data[LU_ID==3,LU:="grassland"]
          data[LU_ID==4,LU:="urban"]
          data[LU_ID==5,LU:="water"]
          data[LU_ID==6,LU:="transition zone"]
          # take care of NAs
          data[is.na(data)] <-0
          # assign the Scenario number
          data[,Scenario:=Scenario]
          # assign the Monte Carlo simulation number
          data[,MC:=file]

          # # population level output
          ## per LU class of selected patches
          data_LU.pa<-data[Pa_ID %in% analysed_patches,]
          data_LU.pa<-data_LU.pa[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
          data_LU.pa[is.na(data_LU.pa)] <-0 # take care of NAs (shouldn't be actually there)
          ### combine data sets
          l <- list(data.list.lu.pa, data_LU.pa)
          data.list.lu.pa<-rbindlist(l)

          ## per land use class: calculate the sum of the population sizes per land use class
          data_LU<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
          data_LU[is.na(data_LU)] <-0 # take care of NAs (shouldn't be actually there)
          ### combine data sets
          l <- list(data_LU, data.list.lu)
          data.list.lu<-rbindlist(l)

          ## per landscape: calculate the sum of the population sizes per landscape
          data_land<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
          data_land[is.na(data_land)] <-0 # take care of NAs (shouldn't be actually there)
          ### combine data sets
          l <- list(data_land, data.list.land)
          data.list.land<-rbindlist(l)

          # community level output
          ## per LU_class selected patches: calculate the number of FTs, individuals and diversity
          NFT_LU.pa<-data[Pa_ID %in% analysed_patches]
          NFT_LU.pa[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
          ### then calculate the number of FTs, individuals and diversity
          NFT_LU.pa<-NFT_LU.pa[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year, LU, LU_ID)]
          NFT_LU.pa[is.na(NFT_LU.pa)] <-0 # take care of NAs (could be there @ diversity measures)
          ### combine data sets
          l <- list(NFT_LU.pa, NFT.list.lu.pa)
          NFT.list.lu.pa<-rbindlist(l)
          
          ## per land use class: first calculate the sum per land use class
          NFT_LU<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
          ### then calculate the number of FTs, individuals and diversity
          NFT_LU<-NFT_LU[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year, LU, LU_ID)]
          NFT_LU[is.na(NFT_LU)] <-0 # take care of NAs (could be there @ diversity measures)
          ### combine data sets
          l <- list(NFT_LU, NFT.list.lu)
          NFT.list.lu<-rbindlist(l)

          ## per landscape: first calculate the sum
          NFT_land<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
          ### then calculate the number of FTs, individuals and diversityv
          NFT_land<-NFT_land[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year)]
          NFT_land[is.na(NFT_land)] <-0 # take care of NAs (could be there @ diversity measures)

          ## per landscape and FTs with pop sizes > 10.000: first calculate the sum
          NFT_land.10.000<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
          ### then calculate the number of FTs, individuals and diversityv
          NFT_land.10.000<-NFT_land.10.000[Popsize>10000,.(FT_10.000=specnumber(Popsize)), by=.(Scenario, MC, Year)]

          ### merge the two NFT_land data.tables
          setkey(NFT_land, Scenario, MC, Year)
          setkey(NFT_land.10.000, Scenario, MC, Year)
          NFT_land<-merge(NFT_land, NFT_land.10.000)
          ### combine data sets
          l <- list(NFT_land, NFT.list.land)
          NFT.list.land<-rbindlist(l)
        }
      }
      Scenario <- Scenario + nrow(data)/max_nrow
    }

    data.list.lu.pa[Scenario==1, TZ:=100]
    data.list.lu.pa[Scenario==2, TZ:=75]
    data.list.lu.pa[Scenario==3, TZ:=50]
    data.list.lu.pa[Scenario==4, TZ:=25]
    data.list.lu.pa[Scenario==5, TZ:=0]
    data.list.lu.pa[Scenario==6, TZ:=20]
    data.list.lu.pa[Scenario==7, TZ:=15]
    data.list.lu.pa[Scenario==8, TZ:=10]
    data.list.lu.pa[Scenario==9, TZ:=5]
    data.list.lu.pa[,LID:=unlist(strsplit(dir,"./"))[2]]
    data.list.lu.pa[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    data.list.lu.pa[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    data.list.lu.pa[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    data.list.lu.pa[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    data.list.lu[Scenario==1, TZ:=100]
    data.list.lu[Scenario==2, TZ:=75]
    data.list.lu[Scenario==3, TZ:=50]
    data.list.lu[Scenario==4, TZ:=25]
    data.list.lu[Scenario==5, TZ:=0]
    data.list.lu[Scenario==6, TZ:=20]
    data.list.lu[Scenario==7, TZ:=15]
    data.list.lu[Scenario==8, TZ:=10]
    data.list.lu[Scenario==9, TZ:=5]
    data.list.lu[,LID:=unlist(strsplit(dir,"./"))[2]]
    data.list.lu[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    data.list.lu[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    data.list.lu[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    data.list.lu[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    data.list.land[Scenario==1, TZ:=100]
    data.list.land[Scenario==2, TZ:=75]
    data.list.land[Scenario==3, TZ:=50]
    data.list.land[Scenario==4, TZ:=25]
    data.list.land[Scenario==5, TZ:=0]
    data.list.land[Scenario==6, TZ:=20]
    data.list.land[Scenario==7, TZ:=15]
    data.list.land[Scenario==8, TZ:=10]
    data.list.land[Scenario==9, TZ:=5]
    data.list.land[,LID:=unlist(strsplit(dir,"./"))[2]]
    data.list.land[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    data.list.land[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    data.list.land[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    data.list.land[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    NFT.list.lu.pa[Scenario==1, TZ:=100]
    NFT.list.lu.pa[Scenario==2, TZ:=75]
    NFT.list.lu.pa[Scenario==3, TZ:=50]
    NFT.list.lu.pa[Scenario==4, TZ:=25]
    NFT.list.lu.pa[Scenario==5, TZ:=0]
    NFT.list.lu.pa[Scenario==6, TZ:=20]
    NFT.list.lu.pa[Scenario==7, TZ:=15]
    NFT.list.lu.pa[Scenario==8, TZ:=10]
    NFT.list.lu.pa[Scenario==9, TZ:=5]
    NFT.list.lu.pa[,LID:=unlist(strsplit(dir,"./"))[2]]
    NFT.list.lu.pa[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    NFT.list.lu.pa[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    NFT.list.lu.pa[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    NFT.list.lu.pa[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    NFT.list.lu[Scenario==1, TZ:=100]
    NFT.list.lu[Scenario==2, TZ:=75]
    NFT.list.lu[Scenario==3, TZ:=50]
    NFT.list.lu[Scenario==4, TZ:=25]
    NFT.list.lu[Scenario==5, TZ:=0]
    NFT.list.lu[Scenario==6, TZ:=20]
    NFT.list.lu[Scenario==7, TZ:=15]
    NFT.list.lu[Scenario==8, TZ:=10]
    NFT.list.lu[Scenario==9, TZ:=5]
    NFT.list.lu[,LID:=unlist(strsplit(dir,"./"))[2]]
    NFT.list.lu[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    NFT.list.lu[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    NFT.list.lu[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    NFT.list.lu[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    NFT.list.land[Scenario==1, TZ:=100]
    NFT.list.land[Scenario==2, TZ:=75]
    NFT.list.land[Scenario==3, TZ:=50]
    NFT.list.land[Scenario==4, TZ:=25]
    NFT.list.land[Scenario==5, TZ:=0]
    NFT.list.land[Scenario==6, TZ:=20]
    NFT.list.land[Scenario==7, TZ:=15]
    NFT.list.land[Scenario==8, TZ:=10]
    NFT.list.land[Scenario==9, TZ:=5]
    NFT.list.land[,LID:=unlist(strsplit(dir,"./"))[2]]
    NFT.list.land[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    NFT.list.land[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    NFT.list.land[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    NFT.list.land[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]

    # write the output files
    fwrite(data.list.lu.pa, paste("data.list.lu.pa.txt", sep=""), sep="\t")
    fwrite(NFT.list.lu.pa, paste("NFT.list.lu.pa.txt", sep=""), sep="\t")
    fwrite(data.list.lu, paste("data.list.lu.txt", sep=""), sep="\t")
    fwrite(NFT.list.lu, paste("NFT.list.lu.txt", sep=""), sep="\t")
    fwrite(data.list.land, paste("data.list.land.txt", sep=""), sep="\t")
    fwrite(NFT.list.land, paste("NFT.list.land.txt", sep=""), sep="\t")
    rm(data.list.pa, NFT.list.pa, data.list.lu, NFT.list.lu, data.list.land, NFT.list.land)
    # go back to basis working directory
    setwd('..')
  
  }

  # if each scenario has its own simulation number
  if (!any(duplicated(scenarios$SimNb))){
    Scenario <- 1
    analysed_patches<-fread("Analyse_patches.txt")[,2]
    Patch_def <- fread(paste("Input/Patch_ID_definitions_150x150_", unlist(strsplit(dir,"./"))[2], ".txt", sep=""), sep="\t")
    Patch_def <- Patch_def[TYPE=="arable"]
    analysed_patches <- c(analysed_patches$x, Patch_def$PID)
    # change the working directory
    setwd('Output')
    for (i in scenarios$SimNb){
      # read in all output file names for patch level output
      file_list_Gridout <- list.files(pattern=paste("GridOut_", i,"_*", sep=""))
      # go through this file list and summarize on different output levels + combine all MC simulations
      for (file in 1:length(file_list_Gridout)){
        # read in file
        data<-fread(file_list_Gridout[file])
        # define the land use classes
        data[LU_ID==0,LU:="bare"]
        data[LU_ID==1,LU:="arable"]
        data[LU_ID==2,LU:="forest"]
        data[LU_ID==3,LU:="grassland"]
        data[LU_ID==4,LU:="urban"]
        data[LU_ID==5,LU:="water"]
        data[LU_ID==6,LU:="transition zone"]
        # take care of NAs
        data[is.na(data)] <-0
        # assign the Scenario number
        data[,Scenario:=Scenario]
        # assign the Monte Carlo simulation number
        data[,MC:=file]
        
        # population level output
        ## per LU class of selected patches
        data_LU.pa<-data[Pa_ID %in% analysed_patches,]
        data_LU.pa<-data_LU.pa[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
        data_LU.pa[is.na(data_LU.pa)] <-0 # take care of NAs (shouldn't be actually there)
        ### combine data sets
        l <- list(data.list.lu.pa, data_LU.pa)
        data.list.lu.pa<-rbindlist(l)
        
        ## per land use class: calculate the sum of the population sizes per land use class
        data_LU<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
        data_LU[is.na(data_LU)] <-0 # take care of NAs (shouldn't be actually there)
        ### combine data sets
        l <- list(data_LU, data.list.lu)
        data.list.lu<-rbindlist(l)
        
        ## per landscape: calculate the sum of the population sizes per landscape
        data_land<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
        data_land[is.na(data_land)] <-0 # take care of NAs (shouldn't be actually there)
        ### combine data sets
        l <- list(data_land, data.list.land)
        data.list.land<-rbindlist(l)
        
        # community level output
        ## per LU_class selected patches: calculate the number of FTs, individuals and diversity
        NFT_LU.pa<-data[Pa_ID %in% analysed_patches]
        NFT_LU.pa[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
        ### then calculate the number of FTs, individuals and diversity
        NFT_LU.pa<-NFT_LU.pa[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year, LU, LU_ID)]
        NFT_LU.pa[is.na(NFT_LU.pa)] <-0 # take care of NAs (could be there @ diversity measures)
        ### combine data sets
        l <- list(NFT_LU.pa, NFT.list.lu.pa)
        NFT.list.lu.pa<-rbindlist(l)
        
        ## per land use class: first calculate the sum per land use class
        NFT_LU<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID, LU, LU_ID)]
        ### then calculate the number of FTs, individuals and diversity
        NFT_LU<-NFT_LU[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year, LU, LU_ID)]
        NFT_LU[is.na(NFT_LU)] <-0 # take care of NAs (could be there @ diversity measures)
        ### combine data sets
        l <- list(NFT_LU, NFT.list.lu)
        NFT.list.lu<-rbindlist(l)
        
        ## per landscape: first calculate the sum
        NFT_land<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
        ### then calculate the number of FTs, individuals and diversityv
        NFT_land<-NFT_land[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Scenario, MC, Year)]
        NFT_land[is.na(NFT_land)] <-0 # take care of NAs (could be there @ diversity measures)
        
        ## per landscape and FTs with pop sizes > 10.000: first calculate the sum
        NFT_land.10.000<-data[,.(Popsize=sum(Popsize)),, by=.(Scenario, MC, Year, FT_ID)]
        ### then calculate the number of FTs, individuals and diversityv
        NFT_land.10.000<-NFT_land.10.000[Popsize>10000,.(FT_10.000=specnumber(Popsize)), by=.(Scenario, MC, Year)]
        
        ### merge the two NFT_land data.tables
        setkey(NFT_land, Scenario, MC, Year)
        setkey(NFT_land.10.000, Scenario, MC, Year)
        NFT_land<-merge(NFT_land, NFT_land.10.000)
        ### combine data sets
        l <- list(NFT_land, NFT.list.land)
        NFT.list.land<-rbindlist(l)
      }
      Scenario <- Scenario +1
    }
    
    data.list.lu.pa[Scenario==1, TZ:=100]
    data.list.lu.pa[Scenario==2, TZ:=75]
    data.list.lu.pa[Scenario==3, TZ:=50]
    data.list.lu.pa[Scenario==4, TZ:=25]
    data.list.lu.pa[Scenario==5, TZ:=0]
    data.list.lu.pa[Scenario==6, TZ:=20]
    data.list.lu.pa[Scenario==7, TZ:=15]
    data.list.lu.pa[Scenario==8, TZ:=10]
    data.list.lu.pa[Scenario==9, TZ:=5]
    data.list.lu.pa[,LID:=unlist(strsplit(dir,"./"))[2]]
    data.list.lu.pa[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    data.list.lu.pa[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    data.list.lu.pa[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    data.list.lu.pa[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    data.list.lu[Scenario==1, TZ:=100]
    data.list.lu[Scenario==2, TZ:=75]
    data.list.lu[Scenario==3, TZ:=50]
    data.list.lu[Scenario==4, TZ:=25]
    data.list.lu[Scenario==5, TZ:=0]
    data.list.lu[Scenario==6, TZ:=20]
    data.list.lu[Scenario==7, TZ:=15]
    data.list.lu[Scenario==8, TZ:=10]
    data.list.lu[Scenario==9, TZ:=5]
    data.list.lu[,LID:=unlist(strsplit(dir,"./"))[2]]
    data.list.lu[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    data.list.lu[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    data.list.lu[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    data.list.lu[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    data.list.land[Scenario==1, TZ:=100]
    data.list.land[Scenario==2, TZ:=75]
    data.list.land[Scenario==3, TZ:=50]
    data.list.land[Scenario==4, TZ:=25]
    data.list.land[Scenario==5, TZ:=0]
    data.list.land[Scenario==6, TZ:=20]
    data.list.land[Scenario==7, TZ:=15]
    data.list.land[Scenario==8, TZ:=10]
    data.list.land[Scenario==9, TZ:=5]
    data.list.land[,LID:=unlist(strsplit(dir,"./"))[2]]
    data.list.land[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    data.list.land[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    data.list.land[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    data.list.land[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    NFT.list.lu.pa[Scenario==1, TZ:=100]
    NFT.list.lu.pa[Scenario==2, TZ:=75]
    NFT.list.lu.pa[Scenario==3, TZ:=50]
    NFT.list.lu.pa[Scenario==4, TZ:=25]
    NFT.list.lu.pa[Scenario==5, TZ:=0]
    NFT.list.lu.pa[Scenario==6, TZ:=20]
    NFT.list.lu.pa[Scenario==7, TZ:=15]
    NFT.list.lu.pa[Scenario==8, TZ:=10]
    NFT.list.lu.pa[Scenario==9, TZ:=5]
    NFT.list.lu.pa[,LID:=unlist(strsplit(dir,"./"))[2]]
    NFT.list.lu.pa[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    NFT.list.lu.pa[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    NFT.list.lu.pa[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    NFT.list.lu.pa[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    NFT.list.lu[Scenario==1, TZ:=100]
    NFT.list.lu[Scenario==2, TZ:=75]
    NFT.list.lu[Scenario==3, TZ:=50]
    NFT.list.lu[Scenario==4, TZ:=25]
    NFT.list.lu[Scenario==5, TZ:=0]
    NFT.list.lu[Scenario==6, TZ:=20]
    NFT.list.lu[Scenario==7, TZ:=15]
    NFT.list.lu[Scenario==8, TZ:=10]
    NFT.list.lu[Scenario==9, TZ:=5]
    NFT.list.lu[,LID:=unlist(strsplit(dir,"./"))[2]]
    NFT.list.lu[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    NFT.list.lu[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    NFT.list.lu[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    NFT.list.lu[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    NFT.list.land[Scenario==1, TZ:=100]
    NFT.list.land[Scenario==2, TZ:=75]
    NFT.list.land[Scenario==3, TZ:=50]
    NFT.list.land[Scenario==4, TZ:=25]
    NFT.list.land[Scenario==5, TZ:=0]
    NFT.list.land[Scenario==6, TZ:=20]
    NFT.list.land[Scenario==7, TZ:=15]
    NFT.list.land[Scenario==8, TZ:=10]
    NFT.list.land[Scenario==9, TZ:=5]
    NFT.list.land[,LID:=unlist(strsplit(dir,"./"))[2]]
    NFT.list.land[LID=="7g" | LID=="7a" | LID=="6e", Cluster:=1]
    NFT.list.land[LID=="1f" | LID=="2j" | LID=="5i", Cluster:=3]
    NFT.list.land[LID=="1c" | LID=="2c" | LID=="3c" | LID=="4e", Cluster:=2]
    NFT.list.land[LID=="3a" | LID=="2h" | LID=="8e", Cluster:=4]
    
    # write the output files
    fwrite(data.list.lu.pa, paste("data.list.lu.pa.txt", sep=""), sep="\t")
    fwrite(NFT.list.lu.pa, paste("NFT.list.lu.pa.txt", sep=""), sep="\t")
    fwrite(data.list.lu, paste("data.list.lu.txt", sep=""), sep="\t")
    fwrite(NFT.list.lu, paste("NFT.list.lu.txt", sep=""), sep="\t")
    fwrite(data.list.land, paste("data.list.land.txt", sep=""), sep="\t")
    fwrite(NFT.list.land, paste("NFT.list.land.txt", sep=""), sep="\t")
    rm(data.list.pa, NFT.list.pa, data.list.lu, NFT.list.lu, data.list.land, NFT.list.land)
    # go back to basis working directory
    setwd('..')

  }
  ##### change working directory
  setwd('..')

}

# land use class level only selected patches
pop.all.lu.pa<-data.table()
NFT.all.lu.pa<-data.table()
# land use class level
pop.all.lu<-data.table()
NFT.all.lu<-data.table()
# landscape level
pop.all.land<-data.table()
NFT.all.land<-data.table()

for (dir in c("./1c", "./1f", "./2c", "./2h", 
              "./2j", "./3a", "./3c", "./7a", 
              "./6e", "./8e", "./7g")){
  setwd(dir)
  setwd("Output")
  data.list.lu.pa<-fread("data.list.lu.pa.txt", sep="\t")
  NFT.list.lu.pa<-fread("NFT.list.lu.pa.txt", sep="\t")
  data.list.lu<-fread("data.list.lu.txt", sep="\t")
  NFT.list.lu<-fread("NFT.list.lu.txt", sep="\t")
  data.list.land<-fread("data.list.land.txt", sep="\t")
  NFT.list.land<-fread("NFT.list.land.txt", sep="\t")
  
  l<-list(pop.all.lu.pa, data.list.lu.pa)
  pop.all.lu.pa<-rbindlist(l)
  l<-list(NFT.all.lu.pa, NFT.list.lu.pa)
  NFT.all.lu.pa<-rbindlist(l)
  l<-list(pop.all.lu, data.list.lu)
  pop.all.lu<-rbindlist(l)
  l<-list(NFT.all.lu, NFT.list.lu)
  NFT.all.lu<-rbindlist(l)
  l<-list(pop.all.land, data.list.land)
  pop.all.land<-rbindlist(l)
  l<-list(NFT.all.land, NFT.list.land)
  NFT.all.land<-rbindlist(l)
   setwd('..')
   setwd('..')
  
 
}

fwrite(pop.all.lu.pa, paste("pop.all.lu.pa.txt", sep=""), sep="\t")
fwrite(NFT.all.lu.pa, paste("NFT.all.lu.pa.txt", sep=""), sep="\t")
fwrite(pop.all.lu, paste("pop.all.lu.txt", sep=""), sep="\t")
fwrite(NFT.all.lu, paste("NFT.all.lu.txt", sep=""), sep="\t")
fwrite(pop.all.land, paste("pop.all.land.txt", sep=""), sep="\t")
fwrite(NFT.all.land, paste("NFT.all.land.txt", sep=""), sep="\t")

