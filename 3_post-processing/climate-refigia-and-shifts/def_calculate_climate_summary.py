import numpy as np
import rasterio
import glob

# create output directory folder structure
#root_wd = "\\\school-les-m.shares.deakin.edu.au\\school-les-m\\Planet-A\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\Climate_suitability_data\\"
#print('create output directory folder structure')
#for root, dirnames, filenames in os.walk(root_wd, topdown=True):
#  for filename in fnmatch.filter(filenames, '*_Historical_1970-2000_AUS_5km_ClimSuit.tif*'):
#      taxa = root.split('\\')[9]
#      spp = root.split('\\')[10]
#      Path(out + "\\" + taxa + "\\" + spp + "\\").mkdir(parents=True, exist_ok=True)

def calculate_climate_summary(taxa_species):
    
    wd ="N:\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\" 
    # cwd  = os.getcwd()
    nlumFile = r"N:\\Data-Master\Biodiversity_priority_areas\Protected_area_masks\Raw_masks_res_5x5\nlumMask_2010_5km_GDA94.tif"
    
    outDir = "N:\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\Species-summaries_20-year_snapshots-5km\\"  
    
    # Open NLUM_ID as mask raster and get metadata
    with rasterio.open(nlumFile) as rst:
        # Load a 2D masked array with nodata masked out
        NLUM_ID_raster = rst.read(1, masked=True) 
        # Get NLUM meta
        meta = rst.meta.copy()
        meta.update(compress='lzw', driver='GTiff') 
        [meta.pop(key) for key in ['dtype', 'nodata']]  
    
    taxa = taxa_species.split('\\')[0]
    species = taxa_species.split('\\')[1]  
    
    print('species loop for ' + species) 
    histFile = wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species + '_Historical_1970-2000_AUS_5km_ClimSuit.tif'
    with rasterio.open(histFile) as src_h:
          histRas = src_h.read(1).astype('float32')                                          # read band 1
          histArr = np.where(histRas == 255, 0, histRas)                      # change 255 to 0
          #histSum = sum(map(sum, histArr))                                    # sum all cells in array into one total value
    
    # For each species, ssp and future year:
    # 2. Calculate the ratio of the sum of the future to the sum of the historical. Do we want to add standard dev or max min
    timeperiod = ['2021-2040', '2041-2060','2061-2080', '2081-2100']
  
    for tp in timeperiod:
        
        file_list = glob.glob(wd + "Annual-species-suitability_20-year_snapshots_5km\\" + taxa + "\\" + species + "\\" + species +'_GCM-Ensembles_*_'+ tp +'_AUS_5km_ClimSuit.tif')
        for file in file_list:              
            with rasterio.open(file) as src: 
                futrRas = src.read(1).astype('float32')                                                   # read band 1
                futrArr = np.where(futrRas == 255, 0, futrRas)                    # change 255 to 0
               
                refugiaArr = (futrArr * histArr)     
                shiftArr = (futrArr - histArr)          
    
                taxa = file.split('\\')[5] + "\\"
                spp = file.split('\\')[6]
                gcm = file.split('_')[7] + "_"
                ssp = file.split('_')[9] + "_"
                yrTemp = file.split('_')[10] + "_"
                yr = yrTemp.split('-')[1] 
    
                fileName_ref = outDir + taxa + spp + "\\" + spp + "_" + gcm + ssp + '1990-'+ yr + 'AUS_5km_ClimateRefugia.tif'
                fileName_shift = outDir + taxa + spp + "\\" + spp + "_" + gcm + ssp + '1990-'+ yr + 'AUS_5km_ClimateShifts.tif'
                           
            with rasterio.open(fileName_ref, 'w+', dtype = np.float32, **meta) as dst:
                dst.write(refugiaArr, indexes=1)
                
            with rasterio.open(fileName_shift, 'w+', dtype = np.float32, **meta) as dst:
                dst.write(shiftArr, indexes=1)