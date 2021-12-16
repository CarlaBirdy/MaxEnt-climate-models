#!/bin/bash
module load gdal 
module load R 
cd /home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/mammals/models/Acrobates_pygmaeus
/opt/miniconda3/envs/R40/bin/Rscript /home/archibaldc/Documents/Species-Distribution-Modelling/Script/sdm_projections/scripts/sdm_projections/s7.2_ensemble_suitability_accross_gcms.R
cd /home/archibaldc/Documents/Species-Distribution-Modelling/