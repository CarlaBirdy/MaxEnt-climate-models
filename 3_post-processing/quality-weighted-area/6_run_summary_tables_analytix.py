# !/bin/env python3
#
# 6_run_summary_tables_analytix.py - to run tabular reporting for species
# Companion script to def_create_summary_tables.py - to compile climate suitability reporting for species
#
# This scripts uitlises multiprocessing to run a function that reports on how climate change scenarios impact species available climate space and climate refugia
#
# By Carla Arcihbald (c.archibaldc@deakin.edu.au)
# Created: 2021-01-20
# Last modified: 2021-01-20
#
#
################################################

################ Set up ################
import time
import os
os.chdir("N:\\Planet-A\\LUF-Modelling\\Species-Distribution-Modelling\\Script\\MaxEnt-climate-models\\3_post-processing\\quality-weighted-area\\")
import def_create_summary_tables
from multiprocessing import Pool
import fnmatch

# Parallellising main analysis 

if __name__ == '__main__':
          
    root_wd ="N:\\Planet-A\\Data-Master\\Biodiversity_priority_areas\\Biodiversity\\"    

    species_list = list()    # write out this file and then simply read it back in here... pickle it.
    for root, dirnames, filenames in os.walk(root_wd, topdown=True):
        for filename in fnmatch.filter(filenames, '*_Historical_1970-2000_AUS_5km_ClimSuit.tif*'):
            taxa = root.split('\\')[6]
            spp = root.split('\\')[7]
            species= taxa + "\\" + spp
            species_list.append(species)
                    
    # Start multiprocessing pool and run in parallel.... workout how much memory/RAM each loops/core needs, Denathor has 250 cores
    t0 = time.time()   
    with Pool(25) as pool:
        ret = pool.map(def_create_summary_tables.tabulate_summary, species_list, chunksize = 1) 
    print('Finished in ' + str(time.time() - t0) + ' seconds')

    