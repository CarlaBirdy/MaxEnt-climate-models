####################################################################################
#
# Apply LUTO Mask to historical climate scenario data
#    By: Dr Carla Archibald Prof Brett Bryan
#    Date: 9\09\2020
#    Method: Apply LUTO Mask output file saves at 7mb, this analysis takes about 2-mins to run per rster
#
####################################################################################

library(tidyverse)
library(stringr)
library(raster)
library(rgdal)
library(sf)

# get the standard input here so I can use it below

climate_wd <- getwd() # this set in the .sh file to be the species working directory
cs_filepath <-list.files(climate_wd, pattern = "*.asc", full.names = TRUE) # list all future climate projections
print(climate_wd)
#####################################################################################################
# Fill nodata holes
#####################################################################################################

# Load raster from file 
raster_template <- raster("/home/archibaldc/Documents/Species-Distribution-Modelling/Script/sdm_projections/inputs/NLUM_2010-11_mask.tif")
crs(raster_template) <- crs('+init=EPSG:4283')

# Create neighbourhood function to find most frequent value
fill.na <- function(x) {
  if(all(is.na(x))) {return(0)}
  else {return(mean(x, na.rm=TRUE))} # takes the mean
}

# Create raster with nodata values only for the cells that need filling, replace nodata areas in raster_template with zero
ovr <- function(x, y) {ifelse(is.na(x), ifelse(!is.na(y), NA, 0), x)}

for (i in cs_filepath) {
  
  cs_raster <- raster(cs_filepath[[i]]) # how can I incorperate this into  the SDM automation loop to read in the specific SDM it is using??
  crs(cs_raster) <- crs('+init=EPSG:4283')
  
  # resample to match extent of mask
  extent(cs_raster) <- extent(raster_template)
  cs_raster_res <- resample(cs_raster, raster_template, method='ngb') # the nearest neighbor method is a better suited method for bioclim data as temperature or precipitation could depend of altitude, vegetation, orography, micro-climate, etc. Those data depend of too many factors, so a downscale of that kind of data could be achieved with co-kriging or other complex resampling methods, but not with a simple bilinear interpolation
  
  procRast <- overlay(cs_raster_res, raster_template, fun=ovr)
  
  cStats <- function(x, y) {cellStats((is.na(x)) & !is.na(y), stat='sum', na.rm=TRUE)}
  sumNA <- cStats(procRast, raster_template)
  sumNAold <- 1000000
  diffNA <- sumNAold - sumNA
  
  print(paste('Number of initial cells to fill = ', sumNA))
  
  # Timer
  ptm <- proc.time()

while (sumNA > 0 & diffNA != 0) {
  
  procRastFoc <- focal(procRast, w = matrix(1,3,3), fun=fill.na, pad=TRUE, NAonly=TRUE)
  procRast <- overlay(crop(procRastFoc, extent(raster_template)), raster_template, fun=ovr)
  
  sumNA <- cStats(procRast, raster_template)
  diffNA <- sumNAold - sumNA
  sumNAold <- sumNA
  print(paste('Number of remaining cells to fill = ', sumNA))
  print(paste('Processing time =', (proc.time() - ptm)[[3]], 'seconds'))
}

  # Final mask to raster template      # valid cells = 6956407, nodata = 6738437, ncells = 13694844
  procRast <- mask(procRast, raster_template)
  
  # Substitute random property ID values to the last few isolated cells which could not be nibbled
  pr <- (is.na(procRast)) & !is.na(raster_template)
  pr[pr!=1] <- 0
  
  print(paste('Number of cells to assign random numbers to = ', freq(pr)[[1,1]]))
  
  rnd <- setValues(pr, floor(runif(ncell(pr), min=0, max=0))) # set all remaining values to 0
  rndfunc <- function(x, y, z) {ifelse(x==1, y, z)}
  procRast_fill <- overlay(pr, rnd, procRast, fun=rndfunc)
  extent(procRast_fill)

  # Save raster to file
  outdir <- "/home/archibaldc/Documents/Species-Distribution-Modelling/Script/sdm_projections/inputs/masked_historic_1990_baseline/historic_1990_baseline"
  writeRaster(procRast_fill, paste0(outdir, "/",names(cs_raster),".asc"), overwrite=TRUE, format="ascii", options=c("COMPRESS=LZW")) # how can I incorperate this into  the SDM automation loop to read in the specific SDM it is using??
    
} # end loop for climate scenario
