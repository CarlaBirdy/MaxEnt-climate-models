#!/bin/bash
source activate /opt/miniconda3/envs/spatial/ 
cd /home/archibaldc/Documents/Species-Distribution-Modelling/Projections/NRM_lambdas/NRM/mammals/models/Acrobates_pygmaeus
/opt/miniconda3/envs/R40/bin/Rscript /home/archibaldc/Documents/Species-Distribution-Modelling/Script/sdm_projections/scripts/sdm_projections/s9_climate_refugia_species_summary_linux.R
cd /home/archibaldc/Documents/Species-Distribution-Modelling/