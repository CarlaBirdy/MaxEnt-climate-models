#!/bin/bash
source activate /opt/miniconda3/envs/spatial/ 
source activate /opt/miniconda3/envs/R40 
cd /home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/mammals/models/Acrobates_pygmaeus
/opt/miniconda3/envs/R40/bin/Rscript /home/archibaldc/Documents/Species-Distribution-Modelling/Script/sdm_projections/scripts/sdm_projections/s8_quality_weighted_area_summary_linux.R
