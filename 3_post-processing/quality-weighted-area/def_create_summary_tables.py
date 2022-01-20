import numpy as np
import rasterio
import glob
import pandas as pd





#### TO DO 

#Absolute Change in Climate Space	
#   2030 Absolute change in climate space
#	2050 Absolute change in climate space
#	2070 Absolute change in climate space
#	2090 Absolute change in climate space
#Percentage (%) Change in Climate Space	
#   2030 % change in climate space
#	2050 % change in climate space
#	2070 % change in climate space
#	2090 % change in climate space
      
#
# 2. For each species, climate refugia
#Climate Refugia (Spatial areas that overlap)	
#   2030 Absolute spatial overlap
#	2050 Absolute spatial overlap
#	2070 Absolute spatial overlap
#	2090 Absolute spatial overlap
#Climate Refugia % (Spatial areas that overlap)	
#   2030 % spatial overlap
#	2050 %  spatial overlap
#	2070 %  spatial overlap
#	2090 %  spatial overlap

# 3. For each species, climate shifts
#Climate Sensativity (Spatial areas that dont overlap)	
#   2030 Absolute change in spatial overlap
#	2050 Absolute change in spatial overlap
#	2070 Absolute change in spatial overlap
#	2090 Absolute change in spatial overlap
#Climate Sensativity (Spatial areas that dont overlap)	
#   2030 % change in spatial overlap
#	2050 % change in spatial overlap
#	2070 % change in spatial overlap
#	2090 % change in spatial overlap


def tabulate_summary(taxa_species):
    # working directory
    wd ="N:\\Planet-A\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\" 
    # output directory
    summary_wd = "N:\\Planet-A\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\Species-summaries_20-year_snapshots-5km\\"  
    
    # climate scenario list
    ssp_list = ['0_ssp126','1_ssp245','2_ssp370','3_ssp585']
    # year list
    yr_list = ['2030_2021-2040','2050_2041-2060','2070_2061-2080','2090_2081-2100']
    
    # taxa
    taxa = taxa_species.split('\\')[0]
    # species
    species = taxa_species.split('\\')[1]  
    
    # build data frame
    df_qwcna = pd.DataFrame({'Taxon':[], 
            'Species':[], 
            'Climate Scenario':[], 
            'Historical quality weighted climate space [km2]':[],
            '2030 Future quality weighted climate space (min) [km2]':[],
        	'2050 Future quality weighted climate space (min) [km2]':[],
        	'2070 Future quality weighted climate space (min) [km2]':[],
        	'2090 Future quality weighted climate space (min) [km2]':[],
        	'2030 Future quality weighted climate space (mean) [km2]':[],
        	'2050 Future quality weighted climate space (mean) [km2]':[],
        	'2070 Future quality weighted climate space (mean) [km2]':[],
        	'2090 Future quality weighted climate space (mean) [km2]':[],
            '2030 Future quality weighted climate space (max) [km2]':[],
        	'2050 Future quality weighted climate space (max) [km2]':[],
        	'2070 Future quality weighted climate space (max) [km2]':[],
        	'2090 Future quality weighted climate space (max) [km2]':[],
            '2030 Absolute change in quality weighted climate space (mean) [km2]':[],
        	'2050 Absolute change in quality weighted climate space (mean) [km2]':[],
        	'2070 Absolute change in quality weighted climate space (mean) [km2]':[],
            '2090 Absolute change in quality weighted climate space (mean) [km2]':[],
            '2030 Proportional change in quality weighted climate space (mean) [%]':[],
            '2050 Proportional change in quality weighted climate space (mean) [%]':[],
        	'2070 Proportional change in quality weighted climate space (mean) [%]':[],
        	'2090 Proportional change in quality weighted climate space (mean) [%]':[],
            '1990-2100 Absolute climate refugia (mean) [km2]':[],
            '1990-2100 Proportion of historical climate niche overlaping with climate refugia (mean) [%]':[],
            '1990-2100 Proportion of historical climate niche not overlaping with climate refugia (mean) [%]':[],
            '1990-2100 Climate space that imporve in quality (mean) [km2]':[],
            '1990-2100 Proportional improvement in climate space (mean) [%]':[],
            '1990-2100 Climate space that worsen in quality (mean) [km2]':[],
            '1990-2100 Proportional worsening in climate space (mean) [%]':[]},
                      dtype="float32")
        
            #'2030 Absolute spatial overlap':[],
            #'2050 Absolute spatial overlap':[],
            #'2070 Absolute spatial overlap':[],
            #'2090 Absolute spatial overlap':[],
            #'2030 % spatial overlap':[],
            #'2050 %  spatial overlap':[],
            #'2070 %  spatial overlap':[],
            #'2090 %  spatial overlap':[],
            #'2030 Absolute change in spatial overlap':[],
            #'2050 Absolute change in spatial overlap':[],
            #'2070 Absolute change in spatial overlap':[],
            #'2090 Absolute change in spatial overlap':[],
            #'2030 % change in spatial overlap':[],
            #'2050 % change in spatial overlap':[],
            #'2070 % change in spatial overlap':[],
            #'2090 % change in spatial overlap':[]},
                             
    df_qwcna = df_qwcna.astype(dtype= {"Taxon":"string","Species":"string","Climate Scenario":"string"})

    # Begin loop for climate scenario
    for index_ssp in ssp_list:
        
        index = index_ssp.split('_')[0]
        ssp = index_ssp.split('_')[1]
        
        print('Beginning '+ssp+' loop')
        
        df_qwcna.at[index, 'Taxon'] = taxa
        df_qwcna.at[index, 'Species'] = species    
        df_qwcna.at[index, 'Climate Scenario'] = ssp    

        histFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + '_Historical_1970-2000_AUS_5km_ClimSuit.tif'
        with rasterio.open(histFile) as src_h:
              histRas = src_h.read(1).astype('float32')                                          # read band 1
              histArr = np.where(histRas == 255, 0, histRas)                     
              histSum = sum(map(sum, histArr)) / 100   
        
        df_qwcna.at[index, 'Historical quality weighted climate space [km2]'] = histSum
                            
        # Begin loop for time period
        for index_year in yr_list:
            
            yr_label = index_year.split('_')[0]
            yr = index_year.split('_')[1]
        
            print('Beginning '+yr+' loop')
  
        # 1. Absolute Number and Change in Climate Space	  
        #      - Suitability (QWCNA)          
        #      - Absolute change in climate space
        #      - % change in climate space

            futrMinFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_" + yr + "_AUS_5km_ClimSuit_min.tif"
            with rasterio.open(futrMinFile) as srcfmin:
              futrMinRas = srcfmin.read(1).astype('float32')                                          # read band 1
              futrMinArr = np.where(futrMinRas == 255, 0, futrMinRas)  
              # Sum                   
              futrMinSum = sum(map(sum, futrMinArr)) / 100  
              
            futrMaxFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_" + yr + "_AUS_5km_ClimSuit_max.tif"
            with rasterio.open(futrMaxFile) as srcfmax:
              futrMaxRas = srcfmax.read(1).astype('float32')                                          # read band 1
              futrMaxArr = np.where(futrMaxRas == 255, 0, futrMaxRas)  
              # Sum                   
              futrMaxSum = sum(map(sum, futrMaxArr)) / 100  
              
            futrFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_" + yr + "_AUS_5km_ClimSuit.tif"
            with rasterio.open(futrFile) as src_f:
              futrRas = src_f.read(1).astype('float32')                                          # read band 1
              futrArr = np.where(futrRas == 255, 0, futrRas)  
              # Sum                   
              futrSum = sum(map(sum, futrArr)) / 100     
              # Absolute change 
              absChange = futrSum - histSum / 100    
               # Percent change 
              percChange = ((futrSum - histSum)/  histSum) * 100
              
            df_qwcna.at[index, (yr_label+' Future quality weighted climate space (min) [km2]')] = futrMinSum
            df_qwcna.at[index, (yr_label+' Future quality weighted climate space (mean) [km2]')] = futrSum
            df_qwcna.at[index, (yr_label+' Future quality weighted climate space (max) [km2]')] = futrMaxSum
            df_qwcna.at[index, (yr_label+' Absolute change in quality weighted climate space (mean) [km2]')] = absChange
            df_qwcna.at[index, (yr_label+' Proportional change in quality weighted climate space (mean) [%]')] = percChange
            
                      
        # 2. For each species, climate refugia
        #      - Climate Refugia (Spatial areas that overlap)	         
        #      - Climate Refugia % (Spatial areas that overlap)	
                
        refugiaFile = summary_wd + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_1990-2100_AUS_5km_ClimateRefugia.tif"
        with rasterio.open(refugiaFile) as src_r:
          refugiaRas = src_r.read(1).astype('float32')     
          refugiaRasSum = sum(map(sum, refugiaRas)) / 10000
          refugiaRasPerc = (refugiaRasSum / histSum) *100
        
          df_qwcna.at[index, ('1990-2100 Absolute climate refugia (mean) [km2]')] = refugiaRasSum
          df_qwcna.at[index, ('1990-2100 Proportion of historical climate niche overlaping with climate refugia (mean) [%]')] = refugiaRasPerc
          df_qwcna.at[index, ('1990-2100 Proportion of historical climate niche not overlaping with climate refugia (mean) [%]')] = 100-refugiaRasPerc

            
        # 3. For each species, climate refugia
        #      - Climate Gains        
        #      - Climate Losses % 
        
        shiftFile = summary_wd + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_1990-2100_AUS_5km_ClimateShifts.tif"
        with rasterio.open(shiftFile) as src_s:
            shiftRas = src_s.read(1).astype('float32')
            shiftGainArr = np.where(shiftRas > 0, shiftRas,0)  
            # Sum                   
            shiftGainSum = sum(map(sum, shiftGainArr)) / 100    
            shiftGainPerc =  (shiftGainSum / histSum) * 100

            shiftLossArr = np.where(shiftRas < 0, shiftRas,0)  
            # Sum                   
            shiftLossSum = sum(map(sum, shiftLossArr)) / 100    
            shiftLossPerc =  (shiftLossSum / histSum) * 100
        
        df_qwcna.at[index, ('1990-2100 Climate space that imporve in quality (mean) [km2]')] = shiftGainSum
        df_qwcna.at[index, ('1990-2100 Proportional improvement in climate space (mean) [%]')] = shiftGainPerc
        df_qwcna.at[index, ('1990-2100 Climate space that worsen in quality (mean) [km2]')] = shiftLossSum
        df_qwcna.at[index, ('1990-2100 Proportional worsening in climate space (mean) [%]')] = shiftLossPerc
        
    df_qwcna.to_csv(summary_wd +taxa + "\\" + species + "\\Climate-niche-summary-"+taxa+"_"+species+"_AUS.csv", index=False)

   