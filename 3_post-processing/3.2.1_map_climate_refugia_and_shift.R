####################################################################################
#
# Summarize climate refugia and shifts
#    By: Carla Archibald
#    Date: 14/1/2021
#    Method: - Map refugia: For each taxa calculate the average climate suitability by scores by time and SSP.
#            - Map shifts: for each taxa calculate the difference between climate suitability now and in 2100 by scores by SSP. 
#
####################################################################################

library(tidyverse)
library(stringr)
library(raster)
library(rgdal)
library(sf)

# get the standard input here so I can use it below

#sp_wd <- getwd() # this set in the .sh file to be the species working directory
sp_wd <- getwd() # this set in the .sh file to be the species working directory
root<- "/home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/"

# extract bits to allow for the loop below
hsm_filepath <- as_tibble(list.files(sp_wd, pattern = "*2090_1x1ensembles.tif*", full.names = TRUE))%>%
  mutate(source = value) %>%
  mutate(species_temp = str_sub(source, 105,-24))%>%   # Mammals= 103, Birds = 100, Amphibians = 105, Reptiles = .
  mutate(species = sub("/.*", "", species_temp))%>%
  mutate(yr = str_sub(source,-21,-18))%>%
  mutate(ssp = str_sub(source,-28,-23))%>%  
  mutate(yr_ssp = paste0(yr,"_",ssp))%>%
  dplyr::select(yr_ssp,yr, ssp, species, source)

yr <- unique(hsm_filepath$yr)
ssp <- unique(hsm_filepath$ssp)
yr_ssp <- unique(hsm_filepath$yr_ssp)
species <- unique(hsm_filepath$species)
source <-hsm_filepath$source  

historical <- list.files(sp_wd, recursive = TRUE, pattern="*_historic_1990_baseline_1x1mask*" ,full.names = TRUE)
historicalRaster <- raster(historical)

#future <- list.files(sp_wd, recursive = TRUE, pattern="*_1x1ensembles*", full.names = TRUE)
#futureStack <- stack(future, bands=1)

future <- list.files(sp_wd, recursive = TRUE, pattern="*2090_1x1ensembles.tif*", full.names = TRUE)
futureStack <- stack(future, bands=1)

for (i in 1:length(yr_ssp)) {
  #refugia <- raster::overlay(futureStack[[i]],historicalRaster,fun=function(r1, r2){return(r1*r2)})
  refugia_add <- raster::overlay(futureStack[[i]],historicalRaster,fun=function(r1, r2){return(r1+r2)})  
  #shifts <- raster::overlay(futureStack[[i]],historicalRaster,fun=function(r1, r2){return(r1-r2)})
  writeRaster(refugia_add, paste0(sp_wd, "/",names(futureStack[[i]]),"_refugia_addition"), bylayer=FALSE, overwrite=TRUE, format="GTiff", options=c("COMPRESS=LZW"))
  #writeRaster(refugia, paste0(sp_wd, "/",names(futureStack[[i]]),"_refugia"), bylayer=FALSE, overwrite=TRUE, format="GTiff", options=c("COMPRESS=LZW"))
  #writeRaster(shifts, paste0(sp_wd, "/",names(futureStack[[i]]),"_shifts"), bylayer=FALSE, overwrite=TRUE, format="GTiff", options=c("COMPRESS=LZW"))
}