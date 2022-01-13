####################################################################################
#
# Summarise quality weighted area and graph
#    By: Carla Archibald
#    Date: 14/1/2021
#    Method: - Calculate quality weighted area: For each species calculate the quality weighted area for each climate ensembal and time period
#            - Summarise quality weighted area: For each species quality weighted area value summarise for each climate ensembal and time period
#
####################################################################################
 
library(tidyverse)
library(stringr)
library(raster)
library(sf)

sp_wd <- getwd()
taxa <- str_remove(sp_wd,"/home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/") 
taxa <- str_remove(taxa,"/models")
taxa <- str_extract(taxa,"^.{5}")

HistoricListFile <-list.files(sp_wd, pattern = "*_historic_1990_baseline_5x5_proc.tif*", full.names = TRUE)
HistoricListRas <- raster(HistoricListFile)
HistoricListRas[HistoricListRas == 255] <- 0

FutureRasListFiles <- list.files(sp_wd, pattern = "*_5x5ensembles*", full.names = TRUE)

rasList <- stack(c(HistoricListRas,FutureRasListFiles))

sumTibbleQwa <- as_tibble(cellStats(rasList, stat='sum', na.rm=TRUE), rownames = "fileName")%>%
                     rename(qwMean = "value")%>%
              dplyr::mutate(qwMean_div100 = qwMean /100)%>%
              dplyr::filter(grepl('*_5x5ensembles.1|*_historic_1990_baseline_5x5_proc*', fileName)) 

historical<-as.list(sumTibbleQwa[1,2])$qwMean

sumTibble <- sumTibbleQwa %>% 
              dplyr::mutate(temp = str_remove_all(fileName,"_5x5ensembles.1"))%>%
              dplyr::mutate(changeAbs = qwMean-historical,
                            changePer = (((qwMean-historical)/historical)*100))%>%
              dplyr::mutate(scenarioRunTemp = str_sub(temp,-10,-1),
                            scenarioRun = str_replace(scenarioRunTemp, "sp","ssp"),
                            scenarioRun = str_replace(scenarioRun, "e_5x5_proc","historic_1990"),
                            year = str_sub(scenarioRun,-4,-1),
                            sspTemp = str_sub(scenarioRun,1,6),
                            ssp = str_replace(sspTemp , "e_5x5_","historic"),
                            speciesTemp = str_replace(temp, scenarioRun,""),
                            species = str_replace_all(speciesTemp, "_"," "),
                            species = str_replace_all(species, "  baseline 5x5 proc",""),
                            species = str_replace_all(species, " sp126 2030",""),
                            species = str_replace_all(species, " sp126 2050",""),
                            species = str_replace_all(species, " sp126 2070",""),
                            species = str_replace_all(species, " sp126 2090",""),
                            species = str_replace_all(species, " sp245 2030",""),
                            species = str_replace_all(species, " sp245 2050",""),
                            species = str_replace_all(species, " sp245 2070",""),
                            species = str_replace_all(species, " sp245 2090",""),	
                            species = str_replace_all(species, " sp370 2030",""),
                            species = str_replace_all(species, " sp370 2050",""),
                            species = str_replace_all(species, " sp370 2070",""),
                            species = str_replace_all(species, " sp370 2090",""),
                            species = str_replace_all(species, " sp585 2030",""),
                            species = str_replace_all(species, " sp585 2050",""),
                            species = str_replace_all(species, " sp585 2070",""),
                            species = str_replace_all(species, " sp585 2090",""),
                            taxa = taxa,
                            extent = "Total niche area size") %>%
              dplyr::select(extent, taxa, species,scenarioRun,ssp,year,qwMean,qwMean_div100,changeAbs,changePer)
   
paMask <- raster("/home/archibaldc/Documents/Species-Distribution-Modelling/Script/sdm_projections/inputs/bioclim_mask_RandomID_PA_only.tif")

  projectionPACrop <- crop(rasList, paMask )
  extent(projectionPACrop) <- extent(paMask)
  projectionPAMask <- mask(projectionPACrop, paMask )

sumTibblePAQwa <- as_tibble(cellStats(projectionPAMask, stat='sum', na.rm=TRUE), rownames = "fileName")%>%
                     rename(qwMean = "value")%>%
                    dplyr::mutate(qwMean_div100 = qwMean /100)%>%
                    dplyr::filter(grepl('*_5x5ensembles.1|*_historic_1990_baseline_5x5_proc*', fileName)) 

historicalPA <-as.list(sumTibblePAQwa[1,2])$qwMean

sumTibblePA <-sumTibblePAQwa %>% 
              dplyr::mutate(temp = str_remove_all(fileName,"_5x5ensembles.1"))%>%
              dplyr::mutate(changeAbs = qwMean-historicalPA,
                            changePer = (((qwMean-historicalPA)/historicalPA)*100))%>%
              dplyr::mutate(scenarioRunTemp = str_sub(temp,-10,-1),
                            scenarioRun = str_replace(scenarioRunTemp, "sp","ssp"),
                            scenarioRun = str_replace(scenarioRun, "e_5x5_proc","historic_1990"),
                            year = str_sub(scenarioRun,-4,-1),
                            sspTemp = str_sub(scenarioRun,1,6),
                            ssp = str_replace(sspTemp, "curren","historic"),
                            speciesTemp = str_replace(temp, scenarioRun,""),
                            species = str_replace_all(speciesTemp, "_"," "),
                            species = str_replace_all(species, "  baseline 5x5 proc",""),
                            species = str_replace_all(species, " sp126 2030",""),
                            species = str_replace_all(species, " sp126 2050",""),
                            species = str_replace_all(species, " sp126 2070",""),
                            species = str_replace_all(species, " sp126 2090",""),
                            species = str_replace_all(species, " sp245 2030",""),
                            species = str_replace_all(species, " sp245 2050",""),
                            species = str_replace_all(species, " sp245 2070",""),
                            species = str_replace_all(species, " sp245 2090",""),	
                            species = str_replace_all(species, " sp370 2030",""),
                            species = str_replace_all(species, " sp370 2050",""),
                            species = str_replace_all(species, " sp370 2070",""),
                            species = str_replace_all(species, " sp370 2090",""),
                            species = str_replace_all(species, " sp585 2030",""),
                            species = str_replace_all(species, " sp585 2050",""),
                            species = str_replace_all(species, " sp585 2070",""),
                            species = str_replace_all(species, " sp585 2090",""),
                            taxa = taxa,
                            extent = "Protected area niche size (nlum PAs 2010)") %>%
              dplyr::select(extent,taxa, species,scenarioRun,ssp,year,qwMean,qwMean_div100,changeAbs,changePer)
 
  species <- unique(sumTibble$species)
  species <- str_replace_all(species," ", "_")

  sumTibbleAll <- rbind(sumTibble,sumTibblePA)
  sumDataFrameAll <-as.data.frame(sumTibbleAll) 
  write.csv(sumDataFrameAll, file=paste0(sp_wd,"/",species,"_quality_weighted_area_5x5res_summary.csv"))






