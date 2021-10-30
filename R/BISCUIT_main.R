## 21st Dec 2016
## BISCUIT main and helper functions 
## main()
## Code author SP
##

###
###

col_palette = color_palette(); 

###output directory creation

if( dir.exists(paste0(getwd(),"/", output_folder_name))){
    file.rename(paste0(getwd(),"/", output_folder_name),paste0(getwd(),"/","BISCUIT_previous_run","/"))
}

if(! dir.exists(paste0(getwd(),"/",output_folder_name))){
     dir.create(paste0(getwd(),"/",output_folder_name,"/"))
     dir.create(paste0(getwd(),"/",output_folder_name,"/plots/"))
     dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_labels/"))
     dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_labels_per_step_per_batch/"))
     dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_alphas_betas/"))
     dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_Sigmas/"))
     dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_means/"))
     dir.create(paste0(getwd(),"/",output_folder_name,"/plots/extras/"))
}

############## Run BISCUIT ##############

start_time_overall <- Sys.time()

#1) Prepare the input data. Explain what is input and what has to be the output.
source("BISCUIT_process_data.R");


#2) Main MCMC engine. Do not change anything. This runs in parallel where each parallel run takes in a matrix X of all cells and a gene batch i.e. dim(X) is numcells x gene_batch.
source("BISCUIT_IMM_Gibbs_MCMC_parallel.R")

#3) Postprocess MCMC chains from multiple parallel runs
source("BISCUIT_post_MCMC_genesplit_merge.R")

#4) Compute imputed data based on inferred variables and generate plots
source("BISCUIT_post_process.R")
########################################

#print(Sys.time() - start_time_overall)
curr_time <- Sys.time()
print(curr_time - start_time_overall)
write(paste('Overall run time: ',curr_time - start_time_overall),file=f1, append=TRUE)



