# MaxEnt modelling
This folder contains the code and example shell files for the MaxEnt models based on Graham, et al. (2019). This analysis was led by Carla Archibald and assisted by Erin Graham and Brett Bryan based on MaxEnt models fitted as a part of the CliMAS project by Erin Graham and JCU https://www.jcu.edu.au/offline/climas. The original CliMAS analysis can be found here https://github.com/erinmgraham/NRM. This analysis was done as a part of the @land-use-trade-offs project.

## MaxEnt
The maximum entropy method (henceforth, MaxEnt) is a method specifically for modelling species geographic distributions with presence-only data. MaxEnt is a niche-based general-purpose machine learning method with a simple and precise mathematical formulation, and it has several aspects that make it well-suited for species distribution modelling (see, Phillips et al., 2006; Elith et al., 2011). MaxEnt sofware can be downloaded here, https://biodiversityinformatics.amnh.org/open_source/maxent/

Graham, et al. (2019) fitted climate niche models in MaxEnt Version 3.4.1 first with 10 replicates validated using a cross validation method. See code here, https://github.com/erinmgraham/NRM/blob/master/01.nrm.model.R 

MaxEnt models were fitted as a part of the CliMAS project by Erin Graham and JCU https://www.jcu.edu.au/offline/climas. We used these MaxEnt models to project how four climate change scenarios drawn from the CMIP6 suite of climate models influence the climatic niches of Australian species. We used MaxEnt to predict the climate niche of 1,303 terrestrial vertebrates and 9,252 vascular plants from a historical baseline (1990) out to 2090 under four climate scenarios using 8 General Circulation Models.

## Workflow
MaxEnt models were projected onto the future climate scenarios SPP1-RCP2.6, SSP2- RCP 4.5, SSP3- RCP 3.7 and SSP5- RCP 8.5, 8 GCMs, 1 past time-period (1985) and 4 future time-periods (2030, 2050, 2070, 2090). For each species, climate scenario and time-period we calculated an ensemble average (mean) climate suitability and the standard deviation (to capture model variance) across 8 GCMs. 

R statistical software was used to write one shell file per specie. Species shell files were then run on a high performace cluster. The majority of this analysis was submitted to a Linux (virtural machine) cluster computer using a SLURM Queue Manager. Each Server Node has: E5-2680v3 @2.50Ghz (or slightly better), 12 Cores, 70Gb.

## Key References
Elith, J. et al. (2011) ‘A statistical explanation of MaxEnt for ecologists’, Diversity and Distributions, 17(1), pp. 43–57. doi: 10.1111/j.1472-4642.2010.00725.x.
Graham, E. M. et al. (2019) ‘Climate change and biodiversity in Australia: a systematic modelling approach to nationwide species distributions’, Australasian Journal of Environmental Management. Taylor & Francis, 26(2), pp. 112–123. doi: 10.1080/14486563.2019.1599742.
Phillips, S. B. et al. (2006) ‘Maximum entropy modeling of species geographic distributions’, Ecological Modelling, 6(2–3), pp. 231–252. doi: 10.1016/j.ecolmodel.2005.03.026.
