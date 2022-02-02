#' ####################################################################### #
#' PROJECT: Reeg, J.; Strigl, L.; Jeltsch, F. (submitted) Agricultural buffer 
#'                   zone thresholds to safeguard functional bee diversity:  
#'                   Insights from a community modelling approach
#' CONTENTS: 
#'  - This code is implemented to analyse the simulations of a local sensitivity analysis 
#'    varying the main (uncertain) parameters of BiTZ
#'  DEPENDENCIES:
#'  - The code need simulation output files of BiTZ
#'  
#' AUTHOR: Jette Reeg
#' ####################################################################### #

# PREAMBLE ================================================================
rm(list=ls())

## Directories ------------------------------------------------------------
### Define dicrectories in relation to project directory
Dir.Base <- getwd()
# Dir.Data <- file.path(Dir.Base, "data")
Dir.Data <- file.path("Output")
Dir.Exports <- file.path(Dir.Base, "Exports")
### Create directories which aren't present yet
Dirs <- c(Dir.Data, Dir.Exports)
CreateDir <- sapply(Dirs, function(x) if(!dir.exists(x)) dir.create(x))

## Packages ====================================================================
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE))
    install.packages(x, repos='http://cran.us.r-project.org')
  require(x, character.only = TRUE)
}
package_vec <- c(
  "ggplot2", "ggthemes", "data.table", "vegan" # names of the packages required placed here as character objects
)

sapply(package_vec, install.load.package)
# DATA =========================================================================

## Preparing --------------------------------------------------------------

# assign SimNb to each changed parameter
Simulations <- data.frame(rbind(
## original version / control
c("original", 1, seq(1,130,16)),
## size order
c("order", "ascending", seq(2,131,16)),
## dispersal tries
c("dispersal_tries", 0.75, seq(3,132,16)),
c("dispersal_tries", 0.9, seq(4,133,16)),
c("dispersal_tries", 1.1, seq(5,134,16)),
c("dispersal_tries", 1.25, seq(6,135,16)),
## weather std
c("weather_std", 0.75, seq(7,136,16)),
c("weather_std", 0.9, seq(8,137,16)),
c("weather_std", 1.1, seq(9,138,16)),
c("weather_std", 1.25, seq(10,139,16)),
## disturbance probabilities
c("disturbance_prob", 0.75, seq(11,140,16)),
c("disturbance_prob", 0.9, seq(12,141,16)),
c("disturbance_prob", 1.1, seq(13,142,16)),
c("disturbance_prob", 1.25, seq(14,143,16)),
c("disturbance_prob", "low_dist", seq(15,144,16)),
c("disturbance_prob", "high_dist", seq(16,145,16)),
## transition zone effects on resources
c("trans_effect_res", 0.9, seq(145,602,57)),
c("trans_effect_res", 1.1, seq(146,603,57)),
c("trans_effect_res", 0.75, seq(147,604,57)),
c("trans_effect_res", 1.25, seq(148,605,57)),
## transition zone effects on nest availabilities
c("trans_effect_nest", 0.9, seq(149,606,57)),
c("trans_effect_nest", 1.1, seq(150,607,57)),
c("trans_effect_nest", 0.75, seq(151,608,57)),
c("trans_effect_nest", 1.25, seq(152,609,57)),
## transition zone effects on resources and nest availability
c("trans_effect_nest_res", 0.9, seq(153,610,57)),
c("trans_effect_nest_res", 1.1, seq(154,611,57)),
c("trans_effect_nest_res", 0.75, seq(155,612,57)),
c("trans_effect_nest_res", 1.25, seq(156,613,57)),
## growth rate
c("growth_rate", 0.9, seq(157,614,57)),
c("growth_rate", 1.1, seq(158,615,57)),
c("growth_rate", 0.75, seq(159,616,57)),
c("growth_rate", 1.25, seq(160,617,57)),
c("growth_rate", "low_dist", seq(161,618,57)),
c("growth_rate", "high_dist", seq(162,619,57)),
## competition strength
c("competition_strength", "order", seq(163,620,57)),
## dispersal mean
c("dispersal_mean", 0.9, seq(164,621,57)),
c("dispersal_mean", 1.1, seq(165,622,57)),
c("dispersal_mean", 0.75, seq(166,623,57)),
c("dispersal_mean", 1.25, seq(167,624,57)),
c("dispersal_mean", "low_dist", seq(168,625,57)),
c("dispersal_mean", "high_dist", seq(169,626,57)),
## dispersal sd
c("dispersal_sd", 0.9, seq(170,627,57)),
c("dispersal_sd", 1.1, seq(171,628,57)),
c("dispersal_sd", 0.75, seq(172,629,57)),
c("dispersal_sd", 1.25, seq(173,630,57)),
c("dispersal_sd", "low_dist", seq(174,631,57)),
c("dispersal_sd", "high_dist", seq(175,632,57)),
## emigration mu
c("emigration_mu", 0.9, seq(176,633,57)),
c("emigration_mu", 1.1, seq(177,634,57)),
c("emigration_mu", 0.75, seq(178,635,57)),
c("emigration_mu", 1.25, seq(179,636,57)),
## emigration omega
c("emigration_omega", 0.9, seq(180,637,57)),
c("emigration_omega", 1.1, seq(181,638,57)),
c("emigration_omega", 0.75, seq(182,639,57)),
c("emigration_omega", 1.25, seq(183,640,57)),
## disturbance effect
c("disturbance_eff", 0.9, seq(184,641,57)),
c("disturbance_eff", 1.1, seq(185,642,57)),
c("disturbance_eff", 0.75, seq(186,643,57)),
c("disturbance_eff", 1.25, seq(187,644,57)),
c("disturbance_eff", "low_dist", seq(188,645,57)),
c("disturbance_eff", "high_dist", seq(189,646,57)),
## land use suitability resources
c("res_suitability", 0.9, seq(190,647,57)),
c("res_suitability", 1.1, seq(191,648,57)),
c("res_suitability", 0.75, seq(192,649,57)),
c("res_suitability", 1.25, seq(193,650,57)),
c("res_suitability", "low_dist",  seq(194,651,57)),
c("res_suitability", "high_dist",  seq(195,652,57)),
## land use suitability nesting
c("nest_suitability", 0.9, seq(196,653,57)),
c("nest_suitability", 1.1, seq(197,654,57)),
c("nest_suitability", 0.75, seq(198,655,57)),
c("nest_suitability", 1.25, seq(199,656,57)),
c("nest_suitability", "low_dist", seq(200,657,57)),
c("nest_suitability", "high_dist", seq(201,658,57))
))
colnames(Simulations) <- c("Parameter","change","0", "5", "10", "15", "20", "25", "50", "75", "100")
# Landscape patches to analyse
analysed_patches<-fread("Analyse_patches.txt")[,2]
Patch_def <- fread("Input/Patch_ID_definitions_150x150_1c.txt", sep="\t")
Patch_def <- Patch_def[TYPE=="arable"]
analysed_patches <- c(analysed_patches$x, Patch_def$PID)

## Aggregating data ============================================================
for (parameter in levels(factor(Simulations$Parameter))){
  # subset the simulations
  sub.Simulations <- Simulations[Simulations$Parameter==parameter,]
  
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
  
  
  for(change in sub.Simulations$change){
    TZ <- t(Simulations[Simulations$Parameter==parameter & Simulations$change==change,-c(1,2)])
    # for each parameter, go through the SimNb i in vector and load the  corresponding MC files
    Scenario <- 1
    for (i in TZ){ # loop over TZ percentages
      # read in all output file names for patch level output
      file_list_Gridout <- list.files(path = Dir.Data, pattern = paste("GridOut_", i,"__*", sep=""))
      for (file in 1:length(file_list_Gridout)){ # loop over MC runs
        # read in file
        data<-fread(paste(Dir.Data,file_list_Gridout[file],sep="/"))
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
        # assign Parameter
        data[,Parameter:=parameter]
        # assing change
        data[,Change:=change]
        if(min(data$Popsize)<0) {
          warning(paste("Negative Population size in simulation number", i, sep=" "))
        } else {
          # population level output
          ## per LU class of selected patches
          data_LU.pa<-data[Pa_ID %in% analysed_patches,]
          data_LU.pa<-data_LU.pa[,.(Popsize=sum(Popsize)),, by=.(Parameter, Change, Scenario, MC, Year, FT_ID, LU, LU_ID)]
          data_LU.pa[is.na(data_LU.pa)] <-0 # take care of NAs (shouldn't be actually there)
          ### combine data sets
          l <- list(data.list.lu.pa, data_LU.pa)
          data.list.lu.pa<-rbindlist(l)
          
          ## per land use class: calculate the sum of the population sizes per land use class
          data_LU<-data[,.(Popsize=sum(Popsize)),, by=.(Parameter,Change,Scenario, MC, Year, FT_ID, LU, LU_ID)]
          data_LU[is.na(data_LU)] <-0 # take care of NAs (shouldn't be actually there)
          ### combine data sets
          l <- list(data_LU, data.list.lu)
          data.list.lu<-rbindlist(l)
          
          ## per landscape: calculate the sum of the population sizes per landscape
          data_land<-data[,.(Popsize=sum(Popsize)),, by=.(Parameter,Change,Scenario, MC, Year, FT_ID)]
          data_land[is.na(data_land)] <-0 # take care of NAs (shouldn't be actually there)
          ### combine data sets
          l <- list(data_land, data.list.land)
          data.list.land<-rbindlist(l)
          
          # community level output
          ## per LU_class selected patches: calculate the number of FTs, individuals and diversity
          NFT_LU.pa<-data[Pa_ID %in% analysed_patches]
          NFT_LU.pa<-NFT_LU.pa[,.(Popsize=sum(Popsize)),, by=.(Parameter,Change,Scenario, MC, Year, FT_ID, LU, LU_ID)]
          ### then calculate the number of FTs, individuals and diversity
          NFT_LU.pa<-NFT_LU.pa[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Parameter,Change,Scenario, MC, Year, LU, LU_ID)]
          NFT_LU.pa[is.na(NFT_LU.pa)] <-0 # take care of NAs (could be there @ diversity measures)
          ### combine data sets
          l <- list(NFT_LU.pa, NFT.list.lu.pa)
          NFT.list.lu.pa<-rbindlist(l)
          
          ## per land use class: first calculate the sum per land use class
          NFT_LU<-data[,.(Popsize=sum(Popsize)),, by=.(Parameter,Change,Scenario, MC, Year, FT_ID, LU, LU_ID)]
          ### then calculate the number of FTs, individuals and diversity
          NFT_LU<-NFT_LU[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Parameter,Change,Scenario, MC, Year, LU, LU_ID)]
          NFT_LU[is.na(NFT_LU)] <-0 # take care of NAs (could be there @ diversity measures)
          ### combine data sets
          l <- list(NFT_LU, NFT.list.lu)
          NFT.list.lu<-rbindlist(l)
          
          ## per landscape: first calculate the sum
          NFT_land<-data[,.(Popsize=sum(Popsize)),, by=.(Parameter, Change, Scenario, MC, Year, FT_ID)]
          ### then calculate the number of FTs, individuals and diversity
          NFT_land<-NFT_land[,.(FT=specnumber(Popsize), Inds=sum(Popsize), Shannon=diversity(Popsize, index="shannon"), Eveness=diversity(Popsize)/log(specnumber(Popsize)) ), by=.(Parameter,Change,Scenario, MC, Year)]
          NFT_land[is.na(NFT_land)] <-0 # take care of NAs (could be there @ diversity measures)
          
          ## per landscape and FTs with pop sizes > 10.000: first calculate the sum
          NFT_land.10.000<-data[,.(Popsize=sum(Popsize)),, by=.(Parameter,Change,Scenario, MC, Year, FT_ID)]
          ### then calculate the number of FTs, individuals and diversityv
          NFT_land.10.000<-NFT_land.10.000[Popsize>10000,.(FT_10.000=specnumber(Popsize)), by=.(Parameter,Change,Scenario, MC, Year)]
          
          ### merge the two NFT_land data.tables
          setkey(NFT_land, Parameter, Change, Scenario, MC, Year)
          setkey(NFT_land.10.000, Parameter, Change, Scenario, MC, Year)
          NFT_land<-merge(NFT_land, NFT_land.10.000)
          ### combine data sets
          l <- list(NFT_land, NFT.list.land)
          NFT.list.land<-rbindlist(l)
          } # end else
      } # end MC files percentage   
      Scenario <- Scenario + 1 # next TZ level
    } # end TZ percentage
  } # end change
  data.list.lu.pa[Scenario==1, TZ:=0]
  data.list.lu.pa[Scenario==2, TZ:=5]
  data.list.lu.pa[Scenario==3, TZ:=10]
  data.list.lu.pa[Scenario==4, TZ:=15]
  data.list.lu.pa[Scenario==5, TZ:=20]
  data.list.lu.pa[Scenario==6, TZ:=25]
  data.list.lu.pa[Scenario==7, TZ:=50]
  data.list.lu.pa[Scenario==8, TZ:=75]
  data.list.lu.pa[Scenario==9, TZ:=100]
  
  data.list.lu[Scenario==1, TZ:=0]
  data.list.lu[Scenario==2, TZ:=5]
  data.list.lu[Scenario==3, TZ:=10]
  data.list.lu[Scenario==4, TZ:=15]
  data.list.lu[Scenario==5, TZ:=20]
  data.list.lu[Scenario==6, TZ:=25]
  data.list.lu[Scenario==7, TZ:=50]
  data.list.lu[Scenario==8, TZ:=75]
  data.list.lu[Scenario==9, TZ:=100]
  
  data.list.land[Scenario==1, TZ:=0]
  data.list.land[Scenario==2, TZ:=5]
  data.list.land[Scenario==3, TZ:=10]
  data.list.land[Scenario==4, TZ:=15]
  data.list.land[Scenario==5, TZ:=20]
  data.list.land[Scenario==6, TZ:=25]
  data.list.land[Scenario==7, TZ:=50]
  data.list.land[Scenario==8, TZ:=75]
  data.list.land[Scenario==9, TZ:=100]
  
  NFT.list.lu.pa[Scenario==1, TZ:=0]
  NFT.list.lu.pa[Scenario==2, TZ:=5]
  NFT.list.lu.pa[Scenario==3, TZ:=10]
  NFT.list.lu.pa[Scenario==4, TZ:=15]
  NFT.list.lu.pa[Scenario==5, TZ:=20]
  NFT.list.lu.pa[Scenario==6, TZ:=25]
  NFT.list.lu.pa[Scenario==7, TZ:=50]
  NFT.list.lu.pa[Scenario==8, TZ:=75]
  NFT.list.lu.pa[Scenario==9, TZ:=100]
  
  NFT.list.lu[Scenario==1, TZ:=0]
  NFT.list.lu[Scenario==2, TZ:=5]
  NFT.list.lu[Scenario==3, TZ:=10]
  NFT.list.lu[Scenario==4, TZ:=15]
  NFT.list.lu[Scenario==5, TZ:=20]
  NFT.list.lu[Scenario==6, TZ:=25]
  NFT.list.lu[Scenario==7, TZ:=50]
  NFT.list.lu[Scenario==8, TZ:=75]
  NFT.list.lu[Scenario==9, TZ:=100]
  
  NFT.list.land[Scenario==1, TZ:=0]
  NFT.list.land[Scenario==2, TZ:=5]
  NFT.list.land[Scenario==3, TZ:=10]
  NFT.list.land[Scenario==4, TZ:=15]
  NFT.list.land[Scenario==5, TZ:=20]
  NFT.list.land[Scenario==6, TZ:=25]
  NFT.list.land[Scenario==7, TZ:=50]
  NFT.list.land[Scenario==8, TZ:=75]
  NFT.list.land[Scenario==9, TZ:=100]
  # write the output files
  fwrite(data.list.lu.pa, paste("data.list.lu.pa_",parameter,".txt", sep=""), sep="\t")
  fwrite(NFT.list.lu.pa, paste("NFT.list.lu.pa_",parameter,".txt", sep=""), sep="\t")
  fwrite(data.list.lu, paste("data.list.lu_",parameter,".txt", sep=""), sep="\t")
  fwrite(NFT.list.lu, paste("NFT.list.lu_",parameter,".txt", sep=""), sep="\t")
  fwrite(data.list.land, paste("data.list.land_",parameter,".txt", sep=""), sep="\t")
  fwrite(NFT.list.land, paste("NFT.list.land_",parameter,".txt", sep=""), sep="\t")
  rm(data.list.pa, NFT.list.pa, data.list.lu, NFT.list.lu, data.list.land, NFT.list.land)
} # end parameter

## combine all data.tables
NFT.all.land <- data.table()

for (parameter in levels(factor(Simulations$Parameter))){
  NFT.land <- fread(paste("NFT.list.land_",parameter,".txt", sep=""))
  l<-list(NFT.all.land , NFT.land)
  NFT.all.land <-rbindlist(l)
}

fwrite(NFT.all.land , "NFT.all.land.txt", sep="\t")

pop.all.land <- data.table()

for (parameter in levels(factor(Simulations$Parameter))){
  pop.land <- fread(paste("data.list.land_",parameter,".txt", sep=""))
  l<-list(pop.all.land , pop.land)
  pop.all.land <-rbindlist(l)
}

fwrite(pop.all.land , "pop.all.land.txt", sep="\t")

