# -*- coding: utf-8 -*-
"""
Created on Fri Jul 23 10:09:47 2021

@author: archibaldc
"""
import time
import os
os.chdir("N:\\Data-Master\\Biodiversity_priority_areas\\Script")
import def_calculate_climate_summary
from multiprocessing import Pool
import fnmatch

# Parallellising main analysis 

if __name__ == '__main__':
          
    root_wd ="N:\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\"    

    species_list = list()    # write out this file and then simply read it back in here... pickle it.
    for root, dirnames, filenames in os.walk(root_wd, topdown=True):
        for filename in fnmatch.filter(filenames, '*_Historical_1970-2000_AUS_5km_ClimSuit.tif*'):
            taxa = root.split('\\')[6]
            spp = root.split('\\')[7]
            species= taxa + "\\" + spp
            species_list.append(species)
                        
    # Start multiprocessing pool and run in parallel.... workout how much memory/RAM each loops/core needs, Denathor has 250 cores
    t0 = time.time()   
    with Pool(100) as pool:
        ret = pool.map(def_calculate_climate_summary.calculate_climate_summary, species_list, chunksize = 1) 
    print('Finished in ' + str(time.time() - t0) + ' seconds')

    