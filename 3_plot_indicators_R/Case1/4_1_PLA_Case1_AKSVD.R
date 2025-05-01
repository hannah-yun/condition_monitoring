# Import library
library(ggplot2)
library(cpop)
library(tidyverse)


# Load the dataset (pre-processed and saved .mat file from MATLAB)
load("_results/_NREL_NEW_CODE/AKSVD/_NEW_NREL_AKSVD_1000_2500_3500.RData")

# Define a function to apply piecewise linear approximation using the cpop package
# dataset: a list of data frames containing AKSVD results
# seg_num: minimum segment length (used by cpop)
cpop_nrel_AKSVD <- function(dataset,seg_num){
  master_list <- list()
  
  for(i in 1:9){
    
    slice_df <- dataset[[i]]$AKSVD_df  #Extract the ith dataset

    results <- vector("list", length(dataset)) # Placeholder for results 
    
    min_sen = seg_num # Set minimum segment length
    
    # Apply piecewise linear segmentation
    cpop_output <- cpop(y = slice_df$dist, x = slice_df$time, 
                        minseglen = min_sen,
                        prune.approx = TRUE)
    
    # Extract fitted values and changepoints
    fit_results <- fitted(cpop_output)
    vec_changepoint <- changepoints(cpop_output)
    
    # Store original, fitted values, and changepoints as a list
    pair_list <- list(slice_df, fit_results, vec_changepoint)
    
    master_list[[i]] <- pair_list # Return the complete list of results
  }
  return(master_list)
}

# Apply the function to the dataset with a minimum segment length of 0
AKSVD_seed_nrel <- cpop_nrel_AKSVD(AKSVD_nrel, 0)

# Define metadata for bearings and cutoff frequencies
bearings <- rep(c("AN5", "AN6", "AN7"), 3)
cutoff <- rep(c(1000, 2500, 3500), each =3)

# Assign metadata to each result's fitted dataframe
for (i in seq_along(AKSVD_seed_nrel)) {
  AKSVD_seed_nrel[[i]][[2]]$bearings <- bearings[i]        # Add bearing label
  AKSVD_seed_nrel[[i]][[2]]$cutoff_freq <- cutoff[i]       # Add cutoff frequency
}

# Optional labels for plotting or further processing
fitted_tb_label <- c("AN5", "AN6", "AN7")


# Initialize lists to separate fitted and original data frames
list_fitted_AKSVD <- list()
list_total_AKSVD <- list()

# Extract fitted and original data frames from results
for(tb in 1:length(AKSVD_seed_nrel)){
  list_fitted_AKSVD[[tb]] <- as.data.frame(AKSVD_seed_nrel[[tb]][2])
  list_total_AKSVD[[tb]] <- as.data.frame(AKSVD_seed_nrel[[tb]][1])
}



################ Piecewise Linear Approximation with AKSVD ################ 


# Create a new list with only the fitted data frames for AKSVD algorithm
AKSVD_fitted <- lapply(seq_along(list_fitted_AKSVD), function(i) {
  fit_df <- list_fitted_AKSVD[[i]]
  return(fit_df)
})

# Combine all fitted data frames into a single data frame
fitted_df_AKSVD <- do.call(rbind, AKSVD_fitted)

# Ensure 'index' is treated as a factor for plotting/grouping
fitted_df_AKSVD$index <- factor(fitted_df_AKSVD$index)

# Create custom legend labels based on 'index' factor levels
fitted_tb_label <- paste("AN", levels(fitted_df_AKSVD$index))

save(fitted_df_AKSVD, file = "data/fitted_df_omp_all.RData")
