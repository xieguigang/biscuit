## 21st Dec 2016
## BISCUIT main and helper functions
## main()
## Code author SP
##

#' call BISCUIT
#'
#' @description run single cell data pre-processing via \code{BISCUIT} algorithm.
#'
#' @param input_data_tab_delimited set to TRUE if the input data is tab-delimited
#' @param is_format_genes_cells set to TRUE if input data has rows as genes and columns as cells
#' @param choose_cells comment if you want all the cells to be considered
#' @param choose_genes comment if you want all the genes to be considered
#' @param gene_batch number of genes per batch, therefore num_batches = choose_genes (or numgenes)/gene_batch. Max value is 150
#' @param num_iter number of iterations, choose based on data size.
#' @param num_cores number of cores for parallel processing. Ensure that detectCores() > 1 for parallel processing to work, else set num_cores to 1.
#' @param z_true_labels_avl set this to TRUE if the true labels of cells are available, else set it to FALSE. If TRUE, ensure to populate 'z_true' with the true labels in 'BISCUIT_process_data.R'
#' @param num_cells_batch set this to 1000 if input number of cells is in the 1000s, else set it to 100.
#' @param alpha DPMM dispersion parameter. A higher value spins more clusters whereas a lower value spins lesser clusters.
#' @param output_folder_name give a name for your output folder.
#'
singlecell_processor = function(
    input_file_name          = stop("missing the raw data table file!"),
    input_data_tab_delimited = TRUE,
    is_format_genes_cells    = TRUE,
    choose_cells             = 3000,
    choose_genes             = 150,
    gene_batch               = 50,
    num_iter                 = 20,
    num_cores                = detectCores() - 4,
    z_true_labels_avl        = TRUE,
    num_cells_batch          = 1000,
    alpha                    = 1,
    output_folder_name       = "./output") {

    require(dplyr);
    require(magrittr);

    pip = list(
        input_file_name          = input_file_name,
        input_data_tab_delimited = input_data_tab_delimited,
        is_format_genes_cells    = is_format_genes_cells,
        choose_cells             = choose_cells,
        choose_genes             = choose_genes,
        gene_batch               = gene_batch,
        num_iter                 = num_iter,
        num_cores                = num_cores,
        z_true_labels_avl        = z_true_labels_avl,
        num_cells_batch          = num_cells_batch,
        alpha                    = alpha,
        output_folder_name       = output_folder_name,
        col_palette              = color_palette()
    );

    ### output directory creation
    if (dir.exists(paste0(getwd(),"/", output_folder_name))) {
        file.rename(paste0(getwd(),"/", output_folder_name),paste0(getwd(),"/","BISCUIT_previous_run","/"));
    }

    if (!dir.exists(paste0(getwd(),"/",output_folder_name))) {
        dir.create(paste0(getwd(),"/",output_folder_name,"/"));
        dir.create(paste0(getwd(),"/",output_folder_name,"/plots/"));
        dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_labels/"));
        dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_labels_per_step_per_batch/"));
        dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_alphas_betas/"));
        dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_Sigmas/"));
        dir.create(paste0(getwd(),"/",output_folder_name,"/plots/Inferred_means/"));
        dir.create(paste0(getwd(),"/",output_folder_name,"/plots/extras/"));
    }

    print("View your analysis arguments:");
    str(pip);

    ############## Run BISCUIT ##############
    start_time_overall <- Sys.time();

    # 1) [process_data] Prepare the input data. Explain what is input and what has to be the output.
    # 2) [IMM_Gibbs_MCMC_parallel] Main MCMC engine. Do not change anything. This runs in parallel 
    #    where each parallel run takes in a matrix X of all cells and a 
    #    gene batch i.e. dim(X) is numcells x gene_batch.
    # 3) [post_MCMC_genesplit_merge] Postprocess MCMC chains from multiple parallel runs
    # 4) [post_process] Compute imputed data based on inferred variables and generate 
    #    plots
    process_data(pip) %>%        
        IMM_Gibbs_MCMC_parallel() %>%    
        post_MCMC_genesplit_merge() %>%    
        post_process();
    ########################################

    curr_time <- Sys.time();

    print(curr_time - start_time_overall);
    write(paste('Overall run time: ', curr_time - start_time_overall), file = f1, append = TRUE);

    invisible(NULL);
}

#' Compute imputed data based on inferred variables 
#' 
#' @description Compute imputed data based on inferred variables 
#'   and generate plots.
#' 
post_process = function(pip) {
    if (pip$num_gene_batches == 1) {
        parallel_impute_onegenebatch(pip) %>% extras_onegenebatch();
    } else {
        parallel_impute(pip) %>% extras();
    }
}



