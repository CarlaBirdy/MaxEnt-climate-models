####################################################################################
#
# Shell file creation for MaxEnt projections using future climate scenarios
# this script utilises pre-masked bioclim layers.
#    By: Dr Carla Archibald. This script is based on 
#        Dr Erin Graham's code that can be found in this repository: jcu_sdm_model_origin.R
#    Start Date:    26/11/2020
#    Last Modified: 4/12/2020
#    Method: Parent script that: 
#            1) Writes shell scripts containing MAXENT java command for each future climate scenario.
#            2) Transforms .asc file to .gtiff and deleted asc file. 
#            3) Executes R script which is the spatial mask for LUTO, as post processing
#            4) Writes a text file containing the list of shell files
#
####################################################################################

# define the working directory
wd = '/home/archibaldc/Documents/Species-Distribution-Modelling/'

# define the taxa
taxa =  c("plants")#"mammals", "birds", "reptiles", "amphibians", "plants")

# define the location of the environmental layers
scenarios_dir = paste0(wd,'Script/sdm_projections/inputs/non-masked_future_scenarios') 

# define location of maxent_jar file
maxent_jar = paste0(wd,'Maxent/maxent.jar') 

# define location of future projections
future_scenarios = list.files(scenarios_dir, full.names=TRUE)

# for each taxon
for (taxon in taxa) {
  
# define the taxon dir
  taxon_dir = paste0(wd, "Projections/NRM_lambdas/NRM/",taxon)
  
  # get the species list
  species = list.files(paste0(taxon_dir, "/models"))
  
  # for each species
  for (sp in species) {

    # set the species specific working directory argument
    sp_wd = paste0(taxon_dir, "/models/", sp)
    
    # create the shell file
    shell_dir = paste0(wd,"Script/sdm_projections/scripts/sdm_projections/shell_files/future_scenarios_5x5/")

    shellfile_name = paste0(shell_dir,"/01.sdm.model.",sp,"_",taxon,".sh")
    
    # open shell file for writing
    shellfile = file(shellfile_name, "w")

         # shabang script header
         cat('#!/bin/bash',"\n",sep="",file=shellfile)
         # activate the spatial environment
         cat('module load gdal', "\n", file=shellfile)

    for (pr in future_scenarios) {
      # set output file name for MaxEnt projection
         outfilename = paste0(sp_wd,  "/", basename(sp),"_",basename(pr),"_5x5") 
         # MaxEnt projection java command
         # cat('java -cp ',maxent_jar, ' density.Project ',sp_wd,'/',sp,'.lambdas ',' ',pr, '/',' ', outfilename,'_raw.asc nowriteclampgrid nowritemess fadebyclamping', "\n", sep="",file=shellfile)
         # convert .asc file to .tif file and compress
         # cat('gdal_translate -of ','"GTiff" -co COMPRESS=LZW ', outfilename,'_raw.asc ', outfilename,'_raw.tif', "\n", sep="",file=shellfile)          
         # remove .asc file, as it is too large... and not needed
         # cat('rm ', outfilename,'_raw.asc', "\n",sep="",file=shellfile) # deletes .asc file
         # transforms climate suitability values from values between 0 and 1 to values between 0 to 100
         cat('gdal_calc.py --co="COMPRESS=LZW" -A ', outfilename,'_raw.tif --outfile ', outfilename,'_calc.tif --calc="A*100"',"\n", sep="",file=shellfile)
         # translates climate suitability values into a byte, much more efficient way to store the data
         cat('gdal_translate -of ','"GTiff" -co COMPRESS=LZW -ot Byte -a_nodata 255 ', outfilename,'_calc.tif ', outfilename,'_proc.tif', "\n", sep="",file=shellfile) 
         # remove the raw float raster
         #cat('rm ', outfilename,'_raw.tif', "\n",sep="",file=shellfile)
         # remove the raw temp calc integer raster
         cat('rm ', outfilename,'_calc.tif', "\n",sep="",file=shellfile)

    } # end for gcm

      # change the directory back to the root directory just as a precaution
      cat('cd ', wd, sep="",file=shellfile)
      
      # close shell file        
      close(shellfile)
    
    message('Processing ', sp) # print what species the analysis is up to, this can be helpful to find species info in the SLURM log file. 

  } # end for species

} # end for taxon

# write .txt file list of all shell files in the shell directory... the SLURM script will use this to lodge jobs

  # read in list of .sh files
  shellfiles_list <- list.files(shell_dir, pattern="*01.sdm.model.*") # writes all text file containing list of .sh files
  shellfiles_verts_list <- list.files(shell_dir, pattern="*_reptiles*|*_mammals*|*_birds*|*_amphibians*") # writes all text file containing list of .sh files
  shellfiles_plants_list <- list.files(shell_dir, pattern="*_plants*") # writes all text file containing list of .sh files

  # writes text file containing list of .sh files, need to make sure the quotations have been removed
  write.table(shellfiles_list, file = paste0(shell_dir,"/sdm_all_shellfiles.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote = FALSE)
  write.table(shellfiles_verts_list, file = paste0(shell_dir,"/sdm_verts_shellfiles.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote = FALSE)
  write.table(shellfiles_plants_list, file = paste0(shell_dir,"/sdm_plants_shellfiles.txt"), sep = "\t", row.names=FALSE, col.names=FALSE, quote = FALSE)

# End script :) 
