#script to run maxent model for NRM

# define the working directory
wd = 'C:/Users/jc140298/Documents/NRM/Deakin'

# create a directory to hold the shellfiles and pbs output (if applicable)
# EMG Yeu, pbs output is for running on our hpc, yours might be different
pbs_dir = paste0(wd, '/tmp.pbs'); dir.create(pbs_dir); setwd(pbs_dir)

# define the taxa
taxa =  c("mammals", "birds", "reptiles", "amphibians")

# define the location of the environmental layers
# EMG Yeu, the gridDirs with the bioclim asc's we created in step 2
scenarios_dir = 'C:/Users/jc140298/Documents/NRM/Deakin/bioclim_asc'

# define location of maxent_jar file
maxent_jar = 'C:/Users/jc140298/Documents/NRM/maxent' 

# define location of future projections
future_scenarios = list.files(scenarios_dir, full.names=TRUE)
		
# for each taxon
for (taxon in taxa) {
#taxon=taxa[1]
	# define the taxon dir
	# EMG Yeu, the folder of lambdas I sent you
	taxon_dir = paste0(wd, "/NRM/", taxon)
	
	# get the species list
	species = list.files(paste0(taxon_dir, "/models"))

	# for each species
	for (sp in species) {
#sp=species[1]
		# set the species specific working directory argument
		sp_wd = paste0(taxon_dir, "/models/", sp)
		
		# create the shell file
		shellfile_name = paste0(pbs_dir, "/01.nrm.model.", sp, ".sh")
		
		# open shell file for writing
		shellfile = file(shellfile_name, "w")
			cat('#!/bin/bash\n', file=shellfile)
			cat('#PBS -j oe\n', file=shellfile) # combine stdout and stderr into one file
			cat('#PBS -l pmem=32gb\n', file=shellfile)
			cat('#PBS -l nodes=1:ppn=1\n', file=shellfile)
			cat('#PBS -l walltime=48:00:00\n', file=shellfile)
			cat('cd $PBS_O_WORKDIR\n', file=shellfile)
			cat('source /etc/profile.d/modules.sh\n', file=shellfile) # need for java
			cat('module load java\n', file=shellfile) # need for maxent
			
			# project maxent model
			for (pr in future_scenarios) {
				outfilename = paste0(sp_wd, "/", basename(pr))
				cat('java -cp ',maxent_jar, ' density.Project ',sp_wd, '/',sp, '.lambdas ',pr, ' ', outfilename, '.asc nowriteclampgrid nowritemess fadebyclamping \n', sep="", file=shellfile)
				# zip it
				cat('gzip ', outfilename, '.asc\n', sep="", file=shellfile)
			} # end for
		close(shellfile)
		
		# submit the job
		# EMG Yeu, may want to comment this next line out until you know the shellfile looks okay
		system(paste("qsub ", shellfile_name, sep=""))
		Sys.sleep(5) # wait 5 sec between job submissions 
	} # end for species
} # end for taxon