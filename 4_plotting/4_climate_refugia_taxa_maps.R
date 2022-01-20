####################################################################################
#
# Graph the quality weighted area
#    By: Carla Archibald
#    Date: 14/1/2021
#    Method: - Calculate quality weighted area: For each species calculate the quality weighted area for each climate ensembal and time period
#            - Summarise quality weighted area: For each species quality weighted area value summarise for each climate ensembal and time period
#
####################################################################################

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(stringr) # Simple, Consistent Wrappers for Common String Operations
library(ggplot2) # Create Elegant Data Visualisations Using the Grammar of Graphics
library(viridis) # Default Color Maps from 'matplotlib' 
library(rasterVis)
library(RColorBrewer)
library(sf)
library(sp)
library(exactextractr)

### 1. Set working dirs, load files
  root <-'N:/Planet-A/Data-Master/Biodiversity_priority_areas/Biodiversity/Species-summaries_20-year_snapshots-5km/'
  out <-'N:/Planet-A/Data-Master/Biodiversity_priority_areas/Biodiversity/Species-summaries_20-year_snapshots-5km/'
  
  mask <- 'N:/Planet-A/LUF-Modelling/Species-Distribution-Modelling/Script/sdm_projections/inputs/NLUM_2010-11_mask.tif'
  maskRas <- raster(mask)
  raster::plot(maskRas)
  
  stateFile <- 'N:/Planet-A/LUF-Modelling/Species-Distribution-Modelling/Data/study_area_map/state_2011_aus/STE11aAust.shp'
  stateSf <- read_sf(stateFile)
  st_crs(stateSf)
  plot(stateSf$geometry)

  states <-c("New South Wales","Victoria","Queensland","South Australia","Western Australia","Tasmania","Northern Territory","Australian Capital Territory")
  mainStateSf <- stateSf %>%
                 dplyr:::filter(STATE_NAME %in% states)
  
  mainStateSp <- as_Spatial(mainStateSf)
  mainStateSf$area <- st_area(mainStateSf)
    
  nrmFile <- 'N:/Planet-A/LUF-Modelling/Species-Distribution-Modelling/Data/study_area_map/nrm_2016_aus/nrm_gda94.shp'
  nrmSf <- read_sf(nrmFile)%>%
           dplyr::mutate(rowname = as.character(DEH100G_ID))
  st_crs(stateSf)
  plot(nrmSf$geometry)
  
  ibraFile <- 'N:/Planet-A/LUF-Modelling/Species-Distribution-Modelling/Data/study_area_map/IBRA7_subregions_states/IBRA7_subregions_states.shp'
  ibraSf <- read_sf(ibraFile)%>%
    dplyr::mutate(rowname = as.character(OBJECTID))
  st_crs(ibraSf)
  plot(ibraSf$geometry)
  
  suitabilityFiles <-list.files(root, pattern = '*_additive_suitability.tif', full.names = TRUE, recursive=TRUE)
  suiabilityStack <- raster::stack(suitabilityFiles)
  suiabilityStackMask <- mask(suiabilityStack,maskRas)
  
      ssp_2090_suitablity_amphibians <- suiabilityStackMask[[1:17]]
      ssp_2090_suitablity_birds <- suiabilityStackMask[[18:34]]
      ssp_2090_suitablity_reptiles <- suiabilityStackMask[[52:68]]
      ssp_2090_suitablity_mammals <- suiabilityStackMask[[35:51]]
  
  ssp_2090_refuge_Files <-list.files(root, pattern = '*_historical-to-2090_climate_refugia.tif', full.names = TRUE, recursive=TRUE)
  ssp_2090_refuge_Stack <- raster::stack(ssp_2090_refuge_Files)
  ssp_2090_refuge_StackMask <- mask(ssp_2090_refuge_Stack,maskRas)
  
      ssp_2090_refuge_amphibians <- ssp_2090_refuge_StackMask[[1:4]]
      ssp_2090_refuge_birds <- ssp_2090_refuge_StackMask[[5:8]]
      ssp_2090_refuge_reptiles <- ssp_2090_refuge_StackMask[[13:16]]
      ssp_2090_refuge_mammals <- ssp_2090_refuge_StackMask[[9:12]]
  
  ssp_2090_shifts_Files <-list.files(root, pattern = '*_historical-to-2090_climate_shifts.tif', full.names = TRUE, recursive=TRUE)
  ssp_2090_shifts_Stack <- raster::stack(ssp_2090_shifts_Files)
  ssp_2090_shifts_StackMask <- mask(ssp_2090_shifts_Stack,maskRas)

      ssp_2090_shifts_amphibians <- ssp_2090_shifts_StackMask[[1:4]]
      ssp_2090_shifts_birds <- ssp_2090_shifts_StackMask[[5:8]]
      ssp_2090_shifts_reptiles <- ssp_2090_shifts_StackMask[[13:16]]
      ssp_2090_shifts_mammals <- ssp_2090_shifts_StackMask[[9:12]]
     
      st_crs(ssp_2090_suitablity_amphibians[[1]])
  
  suitabilityFiles <-list.files(paste0(root,"/plants"), pattern = '*_additive_suitability.tif', full.names = TRUE, recursive=TRUE)
  suiabilityStack <- raster::stack(suitabilityFiles)
  suiabilityStackMask <- mask(suiabilityStack,maskRas)
      
### 2. Plotting Suitabilities #####
  suitabilityPallete3 <- colorRampPalette(c('#B4B1A9','#C6C3BA','#DAD7CD','#BFC4AC','#A3B18A','#588157','#3A5A40','#375441','#344E41'))(9)
  mapTheme <- rasterTheme(suitabilityPallete3)
  
  #### Amphibians
  
  stack <- ssp_2090_suitablity_amphibians
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  #### Birds
  
  stack <- ssp_2090_suitablity_birds
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  #### Reptiles
  
  stack <- ssp_2090_suitablity_reptiles
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  #### Mammals
  
  stack <- ssp_2090_suitablity_mammals
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)

 for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  
#### Plants
  
  stack <- ssp_2090_suitablity_plants
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
### 3. Plotting Refugia #####
  refugiaPallete4 <- colorRampPalette(c('#F6F6F3','#DAD7CD','#BFC4AC','#A3B18A','#588157','#3A5A40','#375441','#344E41'))(8)
  mapTheme <- rasterTheme(refugiaPallete4)
  
  #### Amphibians
  
  stack <- ssp_2090_refuge_amphibians
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  #### Birds
  
  stack <- ssp_2090_refuge_birds
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  #### Reptiles

  stack <- ssp_2090_refuge_reptiles
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)

  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
#### Mammals
  
  stack <- ssp_2090_refuge_mammals
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  my.at<-c(0,(maxVal*0.1),(maxVal*0.2),(maxVal*0.3),(maxVal*0.4),(maxVal*0.5),(maxVal*0.6),(maxVal*0.7),(maxVal*0.8),(maxVal*0.9),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
### 4. Plotting Shifting  #####
 # shiftPallete3 <- colorRampPalette(c("#BC6C25","#CD8742", "#DDA15E","#93987C","#FFFFFF","#EECE9F","#283618","#445128", "#606C38"))(9)
  shiftPallete4 <- colorRampPalette(c("#BC6C25","#CD8742", "#DDA15E","#FFFFFF","#FFFFFF","#FFFFFF","#283618","#445128", "#606C38"))(9)
  shiftPallete5 <- colorRampPalette(c("#2B2D42","#5C6378", "#8D99AE","#BDC6D1","#EDF2F4","#F1B6BF", "#F57A89","#E11432","#8C031A"))(9)
  shiftPallete6 <- colorRampPalette(c("#8C031A", "#E11432", "#F57A89","#F1B6BF","#EDF2F4","#BDC6D1","#8D99AE","#5C6378","#2B2D42"))(9)
  
  mapTheme <- rasterTheme(shiftPallete6)
  
  #### Amphibians
  
  stack <- ssp_2090_shifts_amphibians
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  minStack <- minValue(stack)
  minVal<- min(minStack)
  my.at<-c(minVal,(minVal*0.25),(minVal*0.50),(minVal*0.75),0,(maxVal*0.25),(maxVal*0.50),(maxVal*0.75),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  #### Birds
  
  stack <- ssp_2090_shifts_birds
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  minStack <- minValue(stack)
  minVal<- min(minStack)
  my.at<-c(minVal,(minVal*0.25),(minVal*0.50),(minVal*0.75),0,(maxVal*0.25),(maxVal*0.50),(maxVal*0.75),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  #### Reptiles
  
  stack <- ssp_2090_shifts_reptiles
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  minStack <- minValue(stack)
  minVal<- min(minStack)
  my.at<-c(minVal,(minVal*0.25),(minVal*0.50),(minVal*0.75),0,(maxVal*0.25),(maxVal*0.50),(maxVal*0.75),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }
  
  #### Mammals
  
  stack <- ssp_2090_shifts_mammals
  maxStack <- maxValue(stack)
  maxVal<- max(maxStack)
  minStack <- minValue(stack)
  minVal<- min(minStack)
  my.at<-c(minVal,(minVal*0.25),(minVal*0.50),(minVal*0.75),0,(maxVal*0.25),(maxVal*0.50),(maxVal*0.75),maxVal)
  
  for (i in 1:dim(stack)[3]) {
    plt <- levelplot(stack[[i]], 
                     main=names(stack[[i]]), 
                     margin=F, 
                     at=my.at,
                     par.settings=mapTheme)
    pltS <- plt + latticeExtra::layer(sp.lines(mainStateSp, col="gray30", lwd=0.5))
    file_name = paste("Climate_refugia_",names(stack[[i]]),".png", sep="")
    png(file_name,width = 740, height = 568, units = "px")
    print(pltS)
    dev.off()
  }


### 5. Spatial Summary Tables #####
  
  suiabilityStack_ExtractByState <- as.tibble(exact_extract(suiabilityStackMask,mainStateSf,'sum'))%>%
                                    rownames_to_column()%>%
                                    left_join(.,mainStateSf,by = c("rowname" = "STATE_CODE"))%>%
                                    dplyr::select(-rowname,-geometry)%>%
                                    pivot_longer(!c(STATE_NAME,area), names_to = "taxa_ssp_yr", values_to = "sumSuitabilityValue")%>%
                                    dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                                  taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                     "birds" = "Birds",
                                                                                     "repti" = "Reptiles",
                                                                                     "mamma" = "Mammals")),
                                                  sspYr = sub("^[^_]*_", "", taxa_ssp_yr))%>%
                                    dplyr::rename("stateName"=STATE_NAME)%>%
                                    dplyr::mutate(`areaWeighted_Suit/area` = as.numeric(sumSuitabilityValue/area))%>%
                                    dplyr::select(stateName,area,taxa_ssp_yr,sspYr,taxa,sumSuitabilityValue,`areaWeighted_Suit/area`)
  
  suiabilityStack_ExtractByStateSummary <- suiabilityStack_ExtractByState %>%
                                    ungroup() %>%
                                    pivot_longer(!c(stateName,taxa,sspYr,taxa_ssp_yr,area), names_to = "valueType", values_to = "suitabilityValue")%>%
                                    dplyr::mutate(sceanrio_valueType = str_remove(paste0(sspYr,valueType),"additive_suitability"))%>%
                                    dplyr::select(stateName,taxa,area,sceanrio_valueType,suitabilityValue)%>%
                                    pivot_wider(names_from = sceanrio_valueType, values_from = suitabilityValue)%>%
                                    dplyr::mutate(DiffBetweenHistTo126 = ((`ssp126_2090_sumSuitabilityValue`/historic_1990_baseline_sumSuitabilityValue)*100)-100) %>%
                                    dplyr::mutate(DiffBetweenHistTo245 = ((`ssp245_2090_sumSuitabilityValue`/historic_1990_baseline_sumSuitabilityValue)*100)-100) %>%
                                    dplyr::mutate(DiffBetweenHistTo370 = ((`ssp370_2090_sumSuitabilityValue`/historic_1990_baseline_sumSuitabilityValue)*100)-100) %>%
                                    dplyr::mutate(DiffBetweenHistTo585 = ((`ssp585_2090_sumSuitabilityValue`/historic_1990_baseline_sumSuitabilityValue)*100)-100) %>%
                                    dplyr::mutate(DiffBetween126to585 = ((`ssp585_2090_sumSuitabilityValue`/`ssp126_2090_sumSuitabilityValue`)*100)-100) %>%
                                    dplyr::group_by(taxa)%>%
                                    dplyr::mutate(historicPerc_sumSV = (historic_1990_baseline_sumSuitabilityValue/sum(historic_1990_baseline_sumSuitabilityValue)*100)) %>%
                                    dplyr::mutate(ssp126_2090Perc_sumSV = (`ssp126_2090_sumSuitabilityValue`/sum(`ssp126_2090_sumSuitabilityValue`)*100)) %>%
                                    dplyr::mutate(ssp245_2090Perc_sumSV = (`ssp245_2090_sumSuitabilityValue`/sum(`ssp245_2090_sumSuitabilityValue`)*100)) %>%
                                    dplyr::mutate(ssp370_2090Perc_sumSV = (`ssp370_2090_sumSuitabilityValue`/sum(`ssp370_2090_sumSuitabilityValue`)*100)) %>%
                                    dplyr::mutate(ssp585_2090Perc_sumSV = (`ssp585_2090_sumSuitabilityValue`/sum(`ssp585_2090_sumSuitabilityValue`)*100)) %>%
                                    dplyr::mutate(historicPerc_sumAW = (`historic_1990_baseline_areaWeighted_Suit/area`/sum(`historic_1990_baseline_areaWeighted_Suit/area`)*100)) %>%
                                    dplyr::mutate(ssp126_2090Perc_sumAW = (`ssp126_2090_areaWeighted_Suit/area`/sum(`ssp126_2090_areaWeighted_Suit/area`)*100)) %>%
                                    dplyr::mutate(ssp245_2090Perc_sumAW = (`ssp245_2090_areaWeighted_Suit/area`/sum(`ssp245_2090_areaWeighted_Suit/area`)*100)) %>%
                                    dplyr::mutate(ssp370_2090Perc_sumAW = (`ssp370_2090_areaWeighted_Suit/area`/sum(`ssp370_2090_areaWeighted_Suit/area`)*100)) %>%
                                    dplyr::mutate(ssp585_2090Perc_sumAW = (`ssp585_2090_areaWeighted_Suit/area`/sum(`ssp585_2090_areaWeighted_Suit/area`)*100)) %>%
                                    ungroup() %>%
                                    dplyr::select(taxa,stateName,area,
                                                  historic_1990_baseline_sumSuitabilityValue,
                                                    `ssp126_2030_sumSuitabilityValue`,`ssp126_2050_sumSuitabilityValue`,`ssp126_2070_sumSuitabilityValue`,`ssp126_2090_sumSuitabilityValue`,
                                                    `ssp245_2030_sumSuitabilityValue`,`ssp245_2050_sumSuitabilityValue`,`ssp245_2070_sumSuitabilityValue`,`ssp245_2090_sumSuitabilityValue`,
                                                    `ssp370_2030_sumSuitabilityValue`,`ssp370_2050_sumSuitabilityValue`,`ssp370_2070_sumSuitabilityValue`,`ssp370_2090_sumSuitabilityValue`,
                                                    `ssp585_2030_sumSuitabilityValue`,`ssp585_2050_sumSuitabilityValue`,`ssp585_2070_sumSuitabilityValue`,`ssp585_2090_sumSuitabilityValue`,
                                                  historicPerc_sumSV,ssp126_2090Perc_sumSV,ssp245_2090Perc_sumSV,ssp585_2090Perc_sumSV,
                                                  `historic_1990_baseline_areaWeighted_Suit/area`,
                                                    `ssp126_2030_areaWeighted_Suit/area`,`ssp126_2050_areaWeighted_Suit/area`,`ssp126_2070_areaWeighted_Suit/area`,`ssp126_2090_areaWeighted_Suit/area`,
                                                    `ssp245_2030_areaWeighted_Suit/area`,`ssp245_2050_areaWeighted_Suit/area`,`ssp245_2070_areaWeighted_Suit/area`,`ssp245_2090_areaWeighted_Suit/area`,
                                                    `ssp370_2030_areaWeighted_Suit/area`,`ssp370_2050_areaWeighted_Suit/area`,`ssp370_2070_areaWeighted_Suit/area`,`ssp370_2090_areaWeighted_Suit/area`,
                                                    `ssp585_2030_areaWeighted_Suit/area`,`ssp585_2050_areaWeighted_Suit/area`,`ssp585_2070_areaWeighted_Suit/area`,`ssp585_2090_areaWeighted_Suit/area`,
                                                  historicPerc_sumAW,ssp126_2090Perc_sumAW,ssp245_2090Perc_sumAW,ssp585_2090Perc_sumAW,
                                                  DiffBetweenHistTo126,DiffBetweenHistTo245,DiffBetweenHistTo370,DiffBetweenHistTo585,DiffBetween126to585)
  
  write.csv(suiabilityStack_ExtractByState, file = paste0(out,"/ClimateSuiability_ExtractByState_Raw.csv"))
  write.csv(suiabilityStack_ExtractByStateSummary, file = paste0(out,"/ClimateSuiability_ExtractByState_Summary.csv"))
  
  
  ssp_2090_shifts_ExtractByState <- as.tibble(exact_extract(ssp_2090_shifts_StackMask,mainStateSf,'sum'))%>%
                                    rownames_to_column()%>%
                                    left_join(.,mainStateSf,by = c("rowname" = "STATE_CODE"))%>%
                                    dplyr::select(-rowname,-geometry)%>%
                                    pivot_longer(!c(STATE_NAME,area), names_to = "taxa_ssp_yr", values_to = "sumShiftValue")%>%
                                    dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                                  taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                     "birds" = "Birds",
                                                                                     "repti" = "Reptiles",
                                                                                     "mamma" = "Mammals")),
                                                  sspYr = sub("^[^_]*_", "", taxa_ssp_yr))%>%
                                    dplyr::rename("stateName"=STATE_NAME)%>%
                                    dplyr::mutate(`areaWeighted_Shift/area` = sumShiftValue/area)%>%
                                    dplyr::select(stateName,area,taxa_ssp_yr,sspYr,taxa,sumShiftValue,`areaWeighted_Shift/area`)
  
  ssp_2090_refuge_ExtractByState <- as.tibble(exact_extract(ssp_2090_refuge_StackMask,mainStateSf,'sum'))%>%
                                    rownames_to_column()%>%
                                    left_join(.,mainStateSf,by = c("rowname" = "STATE_CODE"))%>%
                                    dplyr::select(-rowname,-geometry)%>%
                                    pivot_longer(!c(STATE_NAME,area), names_to = "taxa_ssp_yr", values_to = "sumRefugiaValue")%>%
                                    dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                                  taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                     "birds" = "Birds",
                                                                                     "repti" = "Reptiles",
                                                                                     "mamma" = "Mammals")),
                                                  sspYr = sub("^[^_]*_", "", taxa_ssp_yr))%>%
                                    dplyr::rename("stateName"=STATE_NAME)%>%
                                    dplyr::mutate(`areaWeighted_Refugia/area` = sumRefugiaValue/area)%>%
                                    dplyr::select(stateName,area,taxa_ssp_yr,sspYr,taxa,sumRefugiaValue,`areaWeighted_Refugia/area`)
   
  write.csv(ssp_2090_shifts_ExtractByState, file = paste0(out,"/ClimateShifts_ExtractByState.csv"))
  write.csv(ssp_2090_refuge_ExtractByState, file = paste0(out,"/ClimateRefugia_ExtractByState.csv"))
  
  suiabilityStack_ExtractByNrm <- as.tibble(exact_extract(suiabilityStackMask,nrmSf,'sum'))%>%
                                  rownames_to_column()%>%
                                   left_join(.,nrmSf,by = c("rowname" = "rowname")) %>%
                                   dplyr::select(-rowname,-AREA,-PERIMETER ,-DEH100G_,-DEH100G_ID,-OBJECTID ,-STATE ,-COMMENT_ ,-CODE, -SHAPE_AREA ,-geometry,-SHAPE_LEN)%>%
                                   pivot_longer(!c(NHT2NAME,ZONE_,AREA_HA), names_to = "taxa_ssp_yr", values_to = "sumSuitabilityValue")%>%
                                   dplyr::group_by(NHT2NAME,ZONE_,AREA_HA,taxa_ssp_yr)%>%
                                   dplyr::summarise(sumSuitabilityValue = sum(sumSuitabilityValue))%>%
                                   dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                                 taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                                     "birds" = "Birds",
                                                                                                     "repti" = "Reptiles",
                                                                                                     "mamma" = "Mammals")),
                                                                  sspYr = sub("^[^_]*_", "", taxa_ssp_yr))%>%
                                    dplyr::rename("nrmName"=NHT2NAME,
                                                  "zone"=ZONE_,
                                                  "areaHa"=AREA_HA) %>%
                                    dplyr::group_by(nrmName,zone,taxa_ssp_yr,sspYr,taxa)%>%
                                    dplyr::summarise(areaHa=sum(areaHa),
                                                     sumSuitabilityValue = sum(sumSuitabilityValue)) %>%
                                    dplyr::mutate(`areaWeighted_Suit/area` = sumSuitabilityValue/areaHa)%>%
                                    dplyr::select(nrmName,zone,taxa_ssp_yr,sspYr,taxa,areaHa,sumSuitabilityValue,`areaWeighted_Suit/area`)
  

  suiabilityStack_ExtractByNrmBase <- suiabilityStack_ExtractByNrm %>%
                                         dplyr::group_by(nrmName,zone,taxa_ssp_yr,sspYr,taxa)%>%
                                         dplyr::summarise(areaHa=sum(areaHa),
                                                          sumSuitabilityValue = sum(sumSuitabilityValue),
                                                          sumAreaWeightedSuitabilityValue = sum(`areaWeighted_Suit/area`))%>% 
                                         dplyr::filter(zone=='terrestrial')%>%
                                         dplyr::select(nrmName,taxa,sspYr,areaHa,sumSuitabilityValue,sumAreaWeightedSuitabilityValue)
    
  suiabilityStack_ExtractByNrmSummary <- suiabilityStack_ExtractByNrmBase %>%
                                         ungroup() %>%
                                         pivot_longer(!c(nrmName,zone,taxa,sspYr,taxa_ssp_yr,areaHa), names_to = "valueType", values_to = "suitabilityValue")%>%
                                         dplyr::mutate(sceanrio_valueType = str_remove(paste0(sspYr,valueType),"additive_suitability"))%>%
                                         dplyr::select(nrmName,taxa,areaHa,sceanrio_valueType,suitabilityValue)%>%
                                         pivot_wider(names_from = sceanrio_valueType, values_from = suitabilityValue)%>%
                                         dplyr::mutate(DiffBetweenHistTo126 = ((ssp126_2090_sumSuitabilityValue/historic_1990_baseline_sumSuitabilityValue)*100)-100) %>%
                                         dplyr::mutate(DiffBetweenHistTo245 = ((ssp245_2090_sumSuitabilityValue/historic_1990_baseline_sumSuitabilityValue)*100)-100) %>%
                                         dplyr::mutate(DiffBetweenHistTo370 = ((ssp370_2090_sumSuitabilityValue/historic_1990_baseline_sumSuitabilityValue)*100)-100) %>%
                                         dplyr::mutate(DiffBetweenHistTo585 = ((ssp585_2090_sumSuitabilityValue/historic_1990_baseline_sumSuitabilityValue)*100)-100) %>%
                                         dplyr::mutate(DiffBetween126to585 = ((ssp585_2090_sumSuitabilityValue/ssp126_2090_sumSuitabilityValue)*100)-100) %>%
                                         dplyr::group_by(taxa)%>%
                                           dplyr::mutate(historicPerc_sumSV = (historic_1990_baseline_sumSuitabilityValue/sum(historic_1990_baseline_sumSuitabilityValue)*100)) %>%
                                           dplyr::mutate(ssp126_2090Perc_sumSV = (ssp126_2090_sumSuitabilityValue/sum(ssp126_2090_sumSuitabilityValue)*100)) %>%
                                           dplyr::mutate(ssp245_2090Perc_sumSV = (ssp245_2090_sumSuitabilityValue/sum(ssp245_2090_sumSuitabilityValue)*100)) %>%
                                           dplyr::mutate(ssp370_2090Perc_sumSV = (ssp370_2090_sumSuitabilityValue/sum(ssp370_2090_sumSuitabilityValue)*100)) %>%
                                           dplyr::mutate(ssp585_2090Perc_sumSV = (ssp585_2090_sumSuitabilityValue/sum(ssp585_2090_sumSuitabilityValue)*100)) %>%
                                           dplyr::mutate(historicPerc_sumAW = (historic_1990_baseline_sumAreaWeightedSuitabilityValue/sum(historic_1990_baseline_sumAreaWeightedSuitabilityValue)*100)) %>%
                                           dplyr::mutate(ssp126_2090Perc_sumAW = (ssp126_2090_sumAreaWeightedSuitabilityValue/sum(ssp126_2090_sumAreaWeightedSuitabilityValue)*100)) %>%
                                           dplyr::mutate(ssp245_2090Perc_sumAW = (ssp245_2090_sumAreaWeightedSuitabilityValue/sum(ssp245_2090_sumAreaWeightedSuitabilityValue)*100)) %>%
                                           dplyr::mutate(ssp370_2090Perc_sumAW = (ssp370_2090_sumAreaWeightedSuitabilityValue/sum(ssp370_2090_sumAreaWeightedSuitabilityValue)*100)) %>%
                                           dplyr::mutate(ssp585_2090Perc_sumAW = (ssp585_2090_sumAreaWeightedSuitabilityValue/sum(ssp585_2090_sumAreaWeightedSuitabilityValue)*100)) %>%
                                         ungroup() %>%
                                         dplyr::select(taxa,nrmName,areaHa,
                                                       historic_1990_baseline_sumSuitabilityValue,ssp126_2030_sumSuitabilityValue,ssp126_2050_sumSuitabilityValue,ssp126_2070_sumSuitabilityValue,ssp126_2090_sumSuitabilityValue,ssp245_2030_sumSuitabilityValue,ssp245_2050_sumSuitabilityValue,ssp245_2070_sumSuitabilityValue,ssp245_2090_sumSuitabilityValue,ssp370_2030_sumSuitabilityValue,ssp370_2050_sumSuitabilityValue,ssp370_2070_sumSuitabilityValue,ssp370_2090_sumSuitabilityValue,ssp585_2030_sumSuitabilityValue,ssp585_2050_sumSuitabilityValue,ssp585_2070_sumSuitabilityValue,ssp585_2090_sumSuitabilityValue,
                                                       historicPerc_sumSV,ssp126_2090Perc_sumSV,ssp245_2090Perc_sumSV,ssp585_2090Perc_sumSV,
                                                       historic_1990_baseline_sumAreaWeightedSuitabilityValue,ssp126_2030_sumAreaWeightedSuitabilityValue,ssp126_2050_sumAreaWeightedSuitabilityValue,ssp126_2070_sumAreaWeightedSuitabilityValue,ssp126_2090_sumAreaWeightedSuitabilityValue,ssp245_2030_sumAreaWeightedSuitabilityValue,ssp245_2070_sumAreaWeightedSuitabilityValue,ssp245_2050_sumAreaWeightedSuitabilityValue,ssp245_2090_sumAreaWeightedSuitabilityValue,ssp370_2030_sumAreaWeightedSuitabilityValue,ssp370_2050_sumAreaWeightedSuitabilityValue,ssp370_2070_sumAreaWeightedSuitabilityValue,ssp370_2090_sumAreaWeightedSuitabilityValue,ssp585_2030_sumAreaWeightedSuitabilityValue,ssp585_2050_sumAreaWeightedSuitabilityValue,ssp585_2070_sumAreaWeightedSuitabilityValue,ssp585_2090_sumAreaWeightedSuitabilityValue,
                                                       historicPerc_sumAW,ssp126_2090Perc_sumAW,ssp245_2090Perc_sumAW,ssp585_2090Perc_sumAW,
                                                       DiffBetweenHistTo126,DiffBetweenHistTo245,DiffBetweenHistTo370,DiffBetweenHistTo585,DiffBetween126to585)
  
  write.csv(suiabilityStack_ExtractByNrm, file = paste0(out,"/ClimateSuiability_ExtractByNrm_Raw.csv"))
  write.csv(suiabilityStack_ExtractByNrmSummary, file = paste0(out,"/ClimateSuiability_ExtractByNrm_Summary.csv"))
  
  ssp_2090_shifts_ExtractByNrm <- as.tibble(exact_extract(ssp_2090_shifts_StackMask,nrmSf,'sum'))%>%
                                  rownames_to_column()%>%
                                  left_join(.,nrmSf,by = c("rowname" = "rowname")) %>%
                                  dplyr::select(-rowname,-AREA,-PERIMETER ,-DEH100G_,-DEH100G_ID,-OBJECTID ,-STATE ,-COMMENT_ ,-CODE, -SHAPE_AREA ,-geometry,-SHAPE_LEN)%>%
                                  pivot_longer(!c(NHT2NAME,ZONE_,AREA_HA), names_to = "taxa_ssp_yr", values_to = "sumShiftValue")%>%
                                  dplyr::group_by(NHT2NAME,ZONE_,AREA_HA,taxa_ssp_yr)%>%
                                  dplyr::summarise(sumShiftValue = sum(sumShiftValue))%>%
                                  dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                                taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                   "birds" = "Birds",
                                                                                   "repti" = "Reptiles",
                                                                                   "mamma" = "Mammals")),
                                                sspYr = sub("^[^_]*_", "", taxa_ssp_yr))%>%
                                  dplyr::rename("nrmName"=NHT2NAME,
                                                "zone"=ZONE_,                                                  
                                                "areaHa"=AREA_HA)%>%
                                  dplyr::group_by(nrmName,zone,taxa_ssp_yr,sspYr,taxa)%>%
                                  dplyr::summarise(areaHa=sum(areaHa),
                                                   sumShiftValue = sum(sumShiftValue)) %>%
                                  dplyr::mutate(`areaWeighted_Shift/area` = sumShiftValue/areaHa)%>%
                                  dplyr::select(nrmName,zone,taxa_ssp_yr,sspYr,taxa,areaHa,sumShiftValue,`areaWeighted_Shift/area`)
 
   write.csv(ssp_2090_shifts_ExtractByNrm, file = paste0(out,"/ClimateShifts_ExtractByNrm.csv"))
  
  ssp_2090_refuge_ExtractByNrm <- as.tibble(exact_extract(ssp_2090_refuge_StackMask,nrmSf,'sum'))%>%
                                  rownames_to_column()%>%
                                  left_join(.,nrmSf,by = c("rowname" = "rowname")) %>%
                                  dplyr::select(-rowname,-AREA,-PERIMETER ,-DEH100G_,-DEH100G_ID,-OBJECTID ,-STATE ,-COMMENT_ ,-CODE, -SHAPE_AREA ,-geometry,-SHAPE_LEN)%>%
                                  pivot_longer(!c(NHT2NAME,ZONE_,AREA_HA), names_to = "taxa_ssp_yr", values_to = "sumRefugiaValue")%>%
                                  dplyr::group_by(NHT2NAME,ZONE_,AREA_HA,taxa_ssp_yr)%>%
                                  dplyr::summarise(sumRefugiaValue = sum(sumRefugiaValue))%>%
                                  dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                                taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                   "birds" = "Birds",
                                                                                   "repti" = "Reptiles",
                                                                                   "mamma" = "Mammals")),
                                                sspYr = sub("^[^_]*_", "", taxa_ssp_yr))%>%
                                  dplyr::rename("nrmName"=NHT2NAME,
                                                "zone"=ZONE_,                                                  
                                                "areaHa"=AREA_HA)%>%
                                dplyr::group_by(nrmName,zone,taxa_ssp_yr,sspYr,taxa)%>%
                                dplyr::summarise(areaHa=sum(areaHa),
                                                 sumRefugiaValue = sum(sumRefugiaValue)) %>%
                                dplyr::mutate(`areaWeighted_Refugia/area` = sumRefugiaValue/areaHa)%>%
                                dplyr::select(nrmName,zone,taxa_ssp_yr,sspYr,taxa,areaHa,sumRefugiaValue,`areaWeighted_Refugia/area`)

  write.csv(ssp_2090_refuge_ExtractByNrm, file = paste0(out,"/ClimateRefugia_ExtractByNrm.csv"))
  
  suiabilityStack_ExtractByIbra <- as.tibble(exact_extract(suiabilityStackMask,ibraSf,'sum'))%>%
                                   rownames_to_column()%>%
                                left_join(.,ibraSf,by = c("rowname" = "rowname")) %>%
                                dplyr::select(-rowname, -OBJECTID ,-STA_CODE,-STATE_CODE,-SUB_CODE_7,-REG_CODE_7, -HECTARES, -REC_ID,-SUB_CODE_6,-SUB_NAME_6,-SUB_NO_61_,-REG_CODE_6, -REG_NAME_6, -REG_NO_61,-SHAPE_AREA,-SHAPE_LEN,-geometry)%>%
                                pivot_longer(!c(SUB_NAME_7,REG_NAME_7,SQ_KM), names_to = "taxa_ssp_yr", values_to = "sumSuitabilityValue")%>%
                                dplyr::group_by(SUB_NAME_7,REG_NAME_7,SQ_KM,taxa_ssp_yr)%>%
                                dplyr::summarise(sumSuitabilityValue = sum(sumSuitabilityValue))%>%
                                dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                              taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                 "birds" = "Birds",
                                                                                 "repti" = "Reptiles",
                                                                                 "mamma" = "Mammals")),
                                              sspYr = sub("^[^_]*_", "", taxa_ssp_yr),
                                              areaWeightedSumSuitabilityValue = sumSuitabilityValue/SQ_KM)%>%
                                dplyr::rename("ibraSubRegion7"=SUB_NAME_7,
                                              "ibraRegion7"=REG_NAME_7,
                                              "sqKmAreaSubRegion" = SQ_KM)%>%
                                dplyr::select(ibraRegion7,ibraSubRegion7,sqKmAreaSubRegion,taxa_ssp_yr,sspYr,taxa,sumRefugiaValue,areaWeightedSumSuitabilityValue)
                              
                                
  
  ssp_2090_shifts_ExtractByIbra <- as.tibble(exact_extract(ssp_2090_shifts_StackMask,ibraSf,'sum'))%>%
                                   rownames_to_column()%>%
                                    left_join(.,ibraSf,by = c("rowname" = "rowname")) %>%
                                    dplyr::select(-rowname, -OBJECTID ,-STA_CODE,-STATE_CODE,-SUB_CODE_7,-REG_CODE_7, -HECTARES, -REC_ID,-SUB_CODE_6,-SUB_NAME_6,-SUB_NO_61_,-REG_CODE_6, -REG_NAME_6, -REG_NO_61,-SHAPE_AREA,-SHAPE_LEN,-geometry)%>%
                                    pivot_longer(!c(SUB_NAME_7,REG_NAME_7,SQ_KM), names_to = "taxa_ssp_yr", values_to = "sumShiftValue")%>%
                                    dplyr::group_by(SUB_NAME_7,REG_NAME_7,SQ_KM,taxa_ssp_yr)%>%
                                    dplyr::summarise(sumShiftValue = sum(sumShiftValue))%>%
                                    dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                                  taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                     "birds" = "Birds",
                                                                                     "repti" = "Reptiles",
                                                                                     "mamma" = "Mammals")),
                                                  sspYr = sub("^[^_]*_", "", taxa_ssp_yr),
                                                  areaWeightedSumShiftValue = sumShiftValue/SQ_KM)%>%
                                    dplyr::rename("ibraSubRegion7"=SUB_NAME_7,
                                                  "ibraRegion7"=REG_NAME_7,
                                                  "sqKmAreaSubRegion" = SQ_KM)%>%
                                    dplyr::select(ibraRegion7,ibraSubRegion7,sqKmAreaSubRegion,taxa_ssp_yr,sspYr,taxa,sumRefugiaValue,areaWeightedSumShiftValue)
                                  
  
  ssp_2090_refuge_ExtractByIbra <- as.tibble(exact_extract(ssp_2090_refuge_StackMask,ibraSf,'sum'))%>%
                                   rownames_to_column()%>%
                                  left_join(.,ibraSf,by = c("rowname" = "rowname")) %>%
                                  dplyr::select(-rowname, -OBJECTID ,-STA_CODE,-STATE_CODE,-SUB_CODE_7,-REG_CODE_7, -HECTARES, -REC_ID,-SUB_CODE_6,-SUB_NAME_6,-SUB_NO_61_,-REG_CODE_6, -REG_NAME_6, -REG_NO_61,-SHAPE_AREA,-SHAPE_LEN,-geometry)%>%
                                  pivot_longer(!c(SUB_NAME_7,REG_NAME_7,SQ_KM), names_to = "taxa_ssp_yr", values_to = "sumRefugiaValue")%>%
                                  dplyr::group_by(SUB_NAME_7,REG_NAME_7,SQ_KM,taxa_ssp_yr)%>%
                                  dplyr::summarise(sumRefugiaValue = sum(sumRefugiaValue))%>%
                                  dplyr::mutate(taxaTemp = substring(taxa_ssp_yr, 5, 9),
                                                taxa = str_replace_all(taxaTemp, c("amphi" = "Amphibians",
                                                                                   "birds" = "Birds",
                                                                                   "repti" = "Reptiles",
                                                                                   "mamma" = "Mammals")),
                                                sspYr = sub("^[^_]*_", "", taxa_ssp_yr),
                                                areaWeightedSumRefugiaValue = sumRefugiaValue/SQ_KM)%>%
                                  dplyr::rename("ibraSubRegion7"=SUB_NAME_7,
                                                "ibraRegion7"=REG_NAME_7,
                                                "sqKmAreaSubRegion" = SQ_KM)%>%
                                  dplyr::select(ibraRegion7,ibraSubRegion7,sqKmAreaSubRegion,taxa_ssp_yr,sspYr,taxa,sumRefugiaValue,areaWeightedSumRefugiaValue)
  
 
  write.csv(suiabilityStack_ExtractByIbra, file = paste0(out,"/ClimateSuiability_ExtractByIbra.csv"))
  write.csv(ssp_2090_shifts_ExtractByIbra, file = paste0(out,"/ClimateShifts_ExtractByIbra.csv"))
  write.csv(ssp_2090_refuge_ExtractByIbra, file = paste0(out,"/ClimateRefugia_ExtractByIbra.csv"))
  
  
  
  