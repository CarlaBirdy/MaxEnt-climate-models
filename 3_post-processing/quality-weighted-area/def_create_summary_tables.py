# !/bin/env python3
#
# def_create_summary_tables.py - to compile climate suitability reporting for species
#
# This functions reports on how climate change scenarios impact species available climate space and climate refugia
#
# By Carla Arcihbald (c.archibaldc@deakin.edu.au)
# Created: 2021-01-20
# Last modified: 2021-01-20
#
#
################################################

################ Set up ################
# Load python modules
import numpy as np
import rasterio
import pandas as pd

################ Define function ################
# Give function list of taxa_species names
def tabulate_summary(taxa_species):
    
    # Working directory
    wd ="N:\\Planet-A\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\" 
    # Output directory
    summary_wd = "N:\\Planet-A\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\Species-summaries_20-year_snapshots-5km\\"  
    
    # Row + climate scenario list: Specifying the row number helps by providing the location as to where the data from each scenario is written  in the dataframe
    ssp_list = ['0_ssp126','1_ssp245','2_ssp370','3_ssp585']
    # Year + time period list: This also help write data into the dataframe
    yr_list = ['2030_2021-2040','2050_2041-2060','2070_2061-2080','2090_2081-2100']
    
    # Pull out taxa
    taxa = taxa_species.split('\\')[0]
    # Pull out species
    species = taxa_species.split('\\')[1]  
    
    # Build data frame
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
    
    # Assign character columns as strings                       
    df_qwcna = df_qwcna.astype(dtype= {"Taxon":"string","Species":"string","Climate Scenario":"string"})

    # Begin loop for climate scenario
    for index_ssp in ssp_list:
        
        # Pull out row number
        index = index_ssp.split('_')[0]
        # Pull out ssp number
        ssp = index_ssp.split('_')[1]
        
        print('Beginning '+ssp+' loop')
        
        # Fill in df with Taxa, Species and Climate Scenario
        df_qwcna.at[index, 'Taxon'] = taxa
        df_qwcna.at[index, 'Species'] = species    
        df_qwcna.at[index, 'Climate Scenario'] = ssp    

        # Open historical raster
        histFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + '_Historical_1970-2000_AUS_5km_ClimSuit.tif'
        with rasterio.open(histFile) as src_h:
              histRas = src_h.read(1).astype('float32') # read band 1
              # Where there is nodata (nodata == 255), replace with 0, this helps with the summing below
              histArr = np.where(histRas == 255, 0, histRas)    
              # Sum values and divide by 100 to get the quality weighted km2 (As 100 is the max value a 1x1km cell coudld be if it had the highest suitability)                   
              histSum = sum(map(sum, histArr)) / 100   
        
        # Add into df
        df_qwcna.at[index, 'Historical quality weighted climate space [km2]'] = histSum
                            
        # Begin loop for time period
        for index_year in yr_list:
            
            # Pull out year label
            yr_label = index_year.split('_')[0]
            # Pull out year period
            yr = index_year.split('_')[1]
        
            print('Beginning '+yr+' loop')
  
        # 1. Report on the absolute area and change in climate space	  
        #      - Suitability (QWCNA)          
        #      - Absolute change in climate space
        #      - % change in climate space

            # Open future minimum suitability raster
            futrMinFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_" + yr + "_AUS_5km_ClimSuit_min.tif"
            with rasterio.open(futrMinFile) as srcfmin:
              futrMinRas = srcfmin.read(1).astype('float32') # read band 1
              # Where there is nodata (nodata == 255), replace with 0, this helps with the summing below
              futrMinArr = np.where(futrMinRas == 255, 0, futrMinRas)  
              # Sum values and divide by 100 to get the quality weighted km2                                  
              futrMinSum = sum(map(sum, futrMinArr)) / 100  
             
            # Open future maximum suitability raster
            futrMaxFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_" + yr + "_AUS_5km_ClimSuit_max.tif"
            with rasterio.open(futrMaxFile) as srcfmax:
              futrMaxRas = srcfmax.read(1).astype('float32') # read band 1
              # Where there is nodata (nodata == 255), replace with 0, this helps with the summing below
              futrMaxArr = np.where(futrMaxRas == 255, 0, futrMaxRas)  
              # Sum values and divide by 100 to get the quality weighted km2                                  
              futrMaxSum = sum(map(sum, futrMaxArr)) / 100  
          
            # Open future average (mean) suitability raster
            futrFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_" + yr + "_AUS_5km_ClimSuit.tif"
            with rasterio.open(futrFile) as src_f:
              futrRas = src_f.read(1).astype('float32') # read band 1
              # Where there is nodata (nodata == 255), replace with 0, this helps with the summing below              
              futrArr = np.where(futrRas == 255, 0, futrRas)  
              # Sum values and divide by 100 to get the quality weighted km2                              
              futrSum = sum(map(sum, futrArr)) / 100     
              # Calculate absolute change by minusing the historical by the future suitability and divide by 100 to get the quality weighted km2      
              absChange = futrSum - histSum / 100    
              # Convert the above number to a percentage
              percChange = ((futrSum - histSum)/  histSum) * 100
            
            # Add into df              
            df_qwcna.at[index, (yr_label+' Future quality weighted climate space (min) [km2]')] = futrMinSum
            df_qwcna.at[index, (yr_label+' Future quality weighted climate space (mean) [km2]')] = futrSum
            df_qwcna.at[index, (yr_label+' Future quality weighted climate space (max) [km2]')] = futrMaxSum
            df_qwcna.at[index, (yr_label+' Absolute change in quality weighted climate space (mean) [km2]')] = absChange
            df_qwcna.at[index, (yr_label+' Proportional change in quality weighted climate space (mean) [%]')] = percChange
            
                      
        # 2. Report on the absolute area and change in climate refugia	
        #      - Climate Refugia (Spatial areas that overlap)	         
        #      - Climate Refugia % (Spatial areas that overlap)	
               
        # Open climate refugia raster
        refugiaFile = summary_wd + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_1990-2100_AUS_5km_ClimateRefugia.tif"
        with rasterio.open(refugiaFile) as src_r:
          refugiaRas = src_r.read(1).astype('float32') # read band 1 
          # Sum values and divide by 10000 to get the quality weighted km2 (As 10000 is the max value a 1x1km cell coudld be if it had the highest refugia value)                             
          refugiaRasSum = sum(map(sum, refugiaRas)) / 10000
          # Convert the above number to a percentage
          refugiaRasPerc = (refugiaRasSum / histSum) *100
        
          # Add into df              
          df_qwcna.at[index, ('1990-2100 Absolute climate refugia (mean) [km2]')] = refugiaRasSum
          df_qwcna.at[index, ('1990-2100 Proportion of historical climate niche overlaping with climate refugia (mean) [%]')] = refugiaRasPerc
          df_qwcna.at[index, ('1990-2100 Proportion of historical climate niche not overlaping with climate refugia (mean) [%]')] = 100-refugiaRasPerc

        
        # 3. Report on areas where climate spaces has and has not impoved
        #      - Climate Gains        
        #      - Climate Losses % 
        
        # Open climate shifts raster
        shiftFile = summary_wd + taxa + "\\" + species + "\\" + species + "_GCM-Ensembles_" + ssp + "_1990-2100_AUS_5km_ClimateShifts.tif"
        with rasterio.open(shiftFile) as src_s:
            shiftRas = src_s.read(1).astype('float32') # read band 1
            # Remove cells where there was no cliate suitability gain
            shiftGainArr = np.where(shiftRas > 0, shiftRas,0)  
            # Sum values and divide by 100 to get the quality weighted km2                                                
            shiftGainSum = sum(map(sum, shiftGainArr)) / 100 
            # Convert the above number to a percentage
            shiftGainPerc =  (shiftGainSum / histSum) * 100
            # Remove cells where there was no cliate suitability loss
            shiftLossArr = np.where(shiftRas < 0, shiftRas,0)  
            # Sum values and divide by 100 to get the quality weighted km2                                               
            shiftLossSum = sum(map(sum, shiftLossArr)) / 100    
            # Convert the above number to a percentage
            shiftLossPerc =  (shiftLossSum / histSum) * 100
       
        # Add into df  
        df_qwcna.at[index, ('1990-2100 Climate space that imporve in quality (mean) [km2]')] = shiftGainSum
        df_qwcna.at[index, ('1990-2100 Proportional improvement in climate space (mean) [%]')] = shiftGainPerc
        df_qwcna.at[index, ('1990-2100 Climate space that worsen in quality (mean) [km2]')] = shiftLossSum
        df_qwcna.at[index, ('1990-2100 Proportional worsening in climate space (mean) [%]')] = shiftLossPerc
 
    # Write out df 
    df_qwcna.to_csv(summary_wd +taxa + "\\" + species + "\\Climate-niche-summary-"+taxa+"_"+species+"_AUS.csv", index=False)
    
### END :) 