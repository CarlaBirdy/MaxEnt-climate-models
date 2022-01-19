####################################################################################
#
# Shell file creation for th summarise quality weighted area and graph
#    By: Carla Archibald
#    Date: 14/1/2021

####################################################################################

# define the working directory
wd = '/home/archibaldc/Documents/Species-Distribution-Modelling/'

# define the taxa
taxa =  c("mammals", "birds", "reptiles", "amphibians", "plants")

# for each taxon
for (taxon in taxa) {
  # define the taxon dir
  taxon_dir = paste0(wd, "Projections/NRM_lambdas","/NRM/",taxon)
  
  # get the species list
  species = list.files(paste0(taxon_dir, "/models"))
  
  # for each species
  for (sp in species) {
    #sp=species[1]
    # set the species specific working directory argument
    sp_wd = paste0(taxon_dir, "/models/", sp)
    
    # create the shell file
    shell_dir = paste0(wd,"Script/sdm_projections/scripts/sdm_projections/shell_files/quality_weighted_area")
    
    shellfile_name = paste0(shell_dir,"/03.qwa.summary.",sp,"_",taxon,".sh")
    
    # open shell file for writing
    shellfile = file(shellfile_name, "w")
    
      cat('#!/bin/bash',"\n",sep="",file=shellfile)
      cat('source activate /opt/miniconda3/envs/spatial/', "\n", file=shellfile)
      cat('source activate /opt/miniconda3/envs/R40', "\n", file=shellfile)
      cat('cd ', sp_wd, "\n",sep="",file=shellfile)
      # load mask R script as a module
      cat('/opt/miniconda3/envs/R40/bin/Rscript ','/home/archibaldc/Documents/Species-Distribution-Modelling/Script/sdm_projections/scripts/sdm_projections/s8_quality_weighted_area_summary_linux.R', "\n",sep="",file=shellfile) # use R to execute the mask, the R script needs to be exacutable rwx----
      #cat('cd ', wd, sep="",file=shellfile)    # the R script needs to be exacutable rwx----
    close(shellfile)
    
    message('Processing ', sp) # print what species the analysis is up to
    
  } # end for species
} # end for taxon

# write .txt file which the SLURM script will use
shellfiles_list <- list.files(shell_dir) # writes text file containing list of .sh files
write.table(shellfiles_list, file = paste0(shell_dir,"/qwa_shellfiles.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote=FALSE)

rept_shellfiles_list <- list.files(shell_dir, pattern="*_reptiles.sh*") # writes text file containing list of .sh files
write.table(rept_shellfiles_list, file = paste0(shell_dir,"/qwa_shellfiles_reptile.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote=FALSE)

bird_shellfiles_list <- list.files(shell_dir, pattern="*_birds.sh*") # writes text file containing list of .sh files
write.table(bird_shellfiles_list, file = paste0(shell_dir,"/qwa_shellfiles_bird.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote=FALSE)

mammal_shellfiles_list <- list.files(shell_dir, pattern="*_mammals.sh*") # writes text file containing list of .sh files
write.table(mammal_shellfiles_list, file = paste0(shell_dir,"/qwa_shellfiles_mammals.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote=FALSE)

amph_shellfiles_list <- list.files(shell_dir, pattern="*_amphibians.sh*") # writes text file containing list of .sh files
write.table(amph_shellfiles_list, file = paste0(shell_dir,"/qwa_shellfiles_amphibians.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote=FALSE)

plant_shellfiles_list <- list.files(shell_dir, pattern="*_plants.sh*") # writes text file containing list of .sh files
write.table(plant_shellfiles_list, file = paste0(shell_dir,"/qwa_shellfiles_plants.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote=FALSE)

