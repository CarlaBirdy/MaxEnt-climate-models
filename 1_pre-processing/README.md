# Input data for MaxEnt modelling
This analysis utilised data from WorldClim and from the Atlas of Living Australia. 

Location: Australia, 5km resolution
Time period: At the species-level, data is provided over five time-periods: 1985, 2030, 2050, 2070 and 2090. 
Major taxa: Mammalia, Reptilia, Amphibia, Aves and Vascular Plants, 1,303 terrestrial vertebrates and 9,252 vascular plants.
Methods: We modelled how four climate change scenarios drawn from the CMIP6 suite of climate models influence the climatic niches of Australian species. We used MaxEnt to predict the climate niche of 1,303 terrestrial vertebrates and 9,252 vascular plants from a historical baseline (1990) out to 2090 under four climate scenarios using 8 General Circulation Models. We then conducted a Zonation prioritisation. 

## WorldClim
The source data for the climate scenarios can be found on the WorldClim website here https://www.worldclim.org/. WorldClim data was downloaded using an R script written by Brett Bryan. Brett and Carla then clipped and masked the global-scale WorldClim data to Australia (masked to the National Land Use Map).

## Atlas of Living Australia
The source data for the species data can be found on the Atlas of Living Australia website here: https://www.ala.org.au/. We used occurance and lambda files provided by Erin Graham. 

Graham, E. M. et al. (2019) ‘Climate change and biodiversity in Australia: a systematic modelling approach to nationwide species distributions’, Australasian Journal of Environmental Management. Taylor & Francis, 26(2), pp. 112–123. doi: 10.1080/14486563.2019.1599742.

This analysis was done as a part of the @land-use-trade-offs project.