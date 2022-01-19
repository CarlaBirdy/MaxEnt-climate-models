####################################################################################
#
# Shell file creation for the climate refugia and shift 
#    By: Dr Carla Archibald. This script is based on 
#        Dr Erin Graham's code that can be found in this repository: jcu_sdm_model_origin.R
#    Start Date:    4/11/2020
#    Last Modified: 4/12/2020
#    Method: Parent script that: 
#            1) Writes shell script to average the climate suitability prediction across all 9 GCMs
#            2) Writes a text file containing the list of shell files
#
####################################################################################

# define the working directory
wd = '/home/archibaldc/Documents/Species-Distribution-Modelling/'

# define the taxa
taxa =  c("mammals", "birds", "reptiles", "amphibians", "plants")

# for each taxon
for (taxon in taxa) {
  
  # define the taxon dir
  taxon_dir = paste0(wd, "Projections","/NRM_lambdas/NRM/",taxon)
  
  # get the species list
  species = list.files(paste0(taxon_dir, "/models"))
  
  # for each species
  for (sp in species) {
    
    # set the species specific working directory argument
    sp_wd = paste0(taxon_dir, "/models/", sp)
    
    # create the shell file
    shell_dir = paste0(wd,"Script/sdm_projections/scripts/sdm_projections/shell_files/climate_refugia")
    
    shellfile_name = paste0(shell_dir,"/02.refugia.",sp,"_",taxon,".sh")
    
    # open shell file for writing
    shellfile = file(shellfile_name, "w")
    
    # shabang script header
    cat('#!/bin/bash',"\n",sep="",file=shellfile)
    # activate the spatial environment
    cat('source activate /opt/miniconda3/envs/spatial/', "\n", file=shellfile)
    # change the working directory to the species folder, this is how I have set up the standard input variables to the subsequent mask  
    cat('cd ', sp_wd, "\n",sep="",file=shellfile)
    # calculate climate shifts                sp_wds
    cat('/opt/miniconda3/envs/R40/bin/Rscript ','/home/archibaldc/Documents/Species-Distribution-Modelling/Script/sdm_projections/scripts/sdm_projections/s9_climate_refugia_species_summary_linux', "\n",sep="",file=shellfile) # use R to execute the mask, the R script needs to be exacutable rwx----
    # change the directory back to the root directory just as a precaution    
    cat('cd ', wd, sep="",file=shellfile)    
    
    # close shellfile
    close(shellfile)
    
    message('Processing ', sp) # print what species the analysis is up to
    
  } # end for species
  
} # end for taxon

# write .txt file list of all shell files in the shell directory... the SLURM script will use this to lodge jobs

# read in list of .sh files
shellfiles_list <- list.files(shell_dir,pattern=".sh*") # writes text file containing list of .sh files

# writes text file containing list of .sh files, need to make sure the quotations have been removed
write.table(shellfiles_list, file = paste0(shell_dir,"/refugia_shellfiles.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote = FALSE)

# End script :) 