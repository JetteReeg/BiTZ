# next step: automatically go through each folder
directories <- list.dirs(recursive=F)
# go through each directory (landscape folder)
for (dir in directories){
  setwd(dir)
  # read in the landscape patch id file
  landscape <- as.data.frame(fread(paste("Input/Agroscapelab_20m_150x150_", unlist(strsplit(dir,"./"))[2], "_id4.asc", sep=""), sep=" "))
  landscape<-landscape[1:150,1:150]
  # read in the patch definition file
  Patch_def <- fread(paste("Input/Patch_ID_definitions_150x150_", unlist(strsplit(dir,"./"))[2], ".txt", sep=""), sep="\t")

  analysed_patches <- c()
  # go through each cell:
  for (i in 1:150){
    for (j in 1:150){
      #
      Patch_ID <- landscape[i,j]
      land_use_ij <- Patch_def[PID==Patch_ID,TYPE]
      
      # only if it is a cell in a grassland or forest patch
      if ((land_use_ij=="grassland" | land_use_ij=="forest") & !(Patch_ID %in% analysed_patches)){
        print(paste("Cell: ", i, " ", j, "with land use class ", land_use_ij))
        count <- F
        # check all neighbours
        for (inew in (i-1:i+1)){
          for (jnew in (j-1:j+1)){
              Patch_ID_new <- landscape[inew,jnew]
              if (!is.null(Patch_ID_new)){
              land_use_ijnew <- Patch_def[PID==Patch_ID_new,TYPE]
              if (land_use_ijnew=="arable") count <- T
            }
          }
        }
        # if neighbour is arable set count to true
        if (count==T) analysed_patches <- c(analysed_patches, Patch_ID)
      }
    }
  }
  
  write.table(analysed_patches, "Analyse_patches.txt", sep="\t")
  setwd('..')
}