####################################################################################
#
# Calculating habitat suitability ensemble across 9 GCMs
#    By: Carla Archibald
#    Date: 5/10/2020
#    Method: Need to average the habitat suitability prediction across all 8 GCMs for each Time period-SSP-Species combination. 
#            This script will summarize the suitability maps by taking the deciles suitability across GCMs.
#
####################################################################################
library(tidyverse)
library(stringr)
library(raster)
library(rgdal)
library(sf)

(rasterMaxMemory = 1e10) # increases RAM used to save temp filed from 100MB to 10G, surplus will be written to disk

# get the standard input here so I can use it below

#sp_wd <- getwd() # this set in the .sh file to be the species working directory
sp_wd <- getwd() # this set in the .sh file to be the species working directory
root <- "/home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/"
 
# extract bits to allow for the loop below
hsm_filepath <- as_tibble(list.files(sp_wd, pattern = "*0_5x5_proc*", full.names = TRUE))%>%
                 mutate(source = value) %>%
                 mutate(species_temp = str_sub(source, 101,-25))%>%
                 mutate(species = sub("/.*", "", species_temp))%>%
                 mutate(gcm_temp = str_sub(source,-31,-26))%>%
                 mutate(gcm = str_replace_all(gcm_temp,c("SM2.MR"="BCC.CSM2.MR",
                                                         "anESM5"="CanESM5",
                                                         ".CM6.1"="CNRM.CM6.1",
                                                         "ESM2.1"="CNRM.ESM2.1",
                                                         "M6A.LR"="IPSL.CM6A.LR",
                                                         "C.ES2L"="MIROC.ES2L",
                                                         "MIROC6"="MIROC6",
                                                         "ESM2.0"="MRI.ESM2.0")))%>%
                 mutate(yr_ssp = str_sub(source,-24,-14)) %>%
                 dplyr::select(yr_ssp, gcm, species, source)

      yr_ssp <- unique(hsm_filepath$yr_ssp)
      gcm <- unique(hsm_filepath$gcm)
     # gcm_temp <- unique(hsm_filepath$gcm_temp)
      species <- unique(hsm_filepath$species)
      source <-hsm_filepath$source 

  rasterstack_meansd_slow <- function(x) {
  mean <- round(raster::mean(x), digits = 0)
  sd <- round(raster::calc(x, sd), digits = 0)
  stack(mean ,sd)
}

for (i in yr_ssp) {
  
  print(paste0("Calculating ensemble average for [",species,"] for [",i, "] climate scenario"))
  
  ## Read in files & manipulate data
  ensembal_filepath <- list.files(sp_wd, pattern = paste0("*",i,"_5x5_proc.tif"), full.names = TRUE)
  
  ## Calculate statistics across GCMs
  spp_rasstack_byte <- stack(ensembal_filepath)
  
  # reclissify values of 101 to 255 to NA values
  rc <- c(101, 255, NA)
  ensemble_stack <- reclassify(spp_rasstack_byte,rc)
  ensemble_stack_mean <- rasterstack_meansd_slow(ensemble_stack)
  NAvalue(ensemble_stack)<- 255
  
  # Calculate ensemble lower 95% bound 
  
  ensemble_stack_low <- round(min(ensemble_stack))
  NAvalue(ensemble_stack_low)<- 255
  
  # Calculate ensemble upper 95% bound 
  
  ensemble_stack_high <-  round(max(ensemble_stack))
  NAvalue(ensemble_stack_high)<- 255
  
  # Write out raters
  writeRaster(ensemble_stack_mean, paste0(sp_wd, "/",species,"_",i,"_5x5ensembles"), bylayer=FALSE, dataType="INT1U", overwrite=TRUE, format="GTiff", options=c("COMPRESS=LZW"))  
  writeRaster(ensemble_stack_high, paste0(sp_wd, "/",species,"_",i,"_5x5ensemblesMax"), bylayer=TRUE, dataType="INT1U", overwrite=TRUE, format="GTiff", options=c("COMPRESS=LZW"))  
  writeRaster(ensemble_stack_low, paste0(sp_wd, "/",species,"_",i,"_5x5ensemblesMin"), bylayer=TRUE, dataType="INT1U", overwrite=TRUE, format="GTiff", options=c("COMPRESS=LZW"))  
  
  
}