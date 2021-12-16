#!/bin/bash
module load gdal 
gdal_calc.py --co="COMPRESS=LZW" -A /home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/mammals/models/Acrobates_pygmaeus/Acrobates_pygmaeus_historic_1990_baseline_5x5raw.tif --outfile /home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/mammals/models/Acrobates_pygmaeus/Acrobates_pygmaeus_historic_1990_baseline_5x5_calc.tif --calc="A*100"
gdal_translate -of "GTiff" -co COMPRESS=LZW -ot Byte -a_nodata 255 /home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/mammals/models/Acrobates_pygmaeus/Acrobates_pygmaeus_historic_1990_baseline_5x5_calc.tif /home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/mammals/models/Acrobates_pygmaeus/Acrobates_pygmaeus_historic_1990_baseline_5x5_proc.tif
rm /home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/mammals/models/Acrobates_pygmaeus/Acrobates_pygmaeus_historic_1990_baseline_5x5_calc.tif
cd /home/archibaldc/Documents/Species-Distribution-Modelling/