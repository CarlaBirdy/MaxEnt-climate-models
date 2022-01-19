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
library(raster)
library(rgdal)
library(sf)

# get the standard input here so I can use it below
sp_wd <- getwd() # this set in the .sh file to be the species working directory

refugia_ssp585_2090_Files <- list.files(sp_wd, recursive = TRUE, pattern="*_ssp585_2090_1x1ensemble_refugia.tif*", full.names = TRUE)
refugia_ssp585_2090_Brick <- brick(refugia_ssp585_2090_Files)
refugia_ssp585_2090_Brick

mean_refugia_ssp585_2090 <- raster::calc(refugia_ssp585_2090_Brick, mean)

writeRaster(mean_refugia_ssp585_2090, "/home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/amphibians/mean_refugia_ssp585_2090_amphibians_refugia", bylayer=FALSE, overwrite=TRUE, format="GTiff", options=c("COMPRESS=LZW"))

shifts_ssp585_2090_Files <- list.files(sp_wd, recursive = TRUE, pattern="*_ssp585_2090_1x1ensemble_shifts.tif*", full.names = TRUE)
shifts_ssp585_2090_Brick <- brick(shifts_ssp585_2090_Files)
shifts_ssp585_2090_Brick

mean_shift_ssp585_2090 <- raster::calc(shifts_ssp585_2090_Brick, mean)

writeRaster(mean_shift_ssp585_2090, "/home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/amphibians/mean_shift_ssp585_2090_amphibians_shifts", bylayer=FALSE, overwrite=TRUE, format="GTiff", options=c("COMPRESS=LZW"))
