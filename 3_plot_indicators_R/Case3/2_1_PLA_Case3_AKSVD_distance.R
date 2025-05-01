# import library
library(tidyr)
library(ggplot2)
library(cpop)

# AKSVD method: This R script computes the PLA values for dictionary distance for each turbine

# Load the dataset
load("data/_SWD_NEW_2M_AKSVD.RData")

# PLA: distance
cpop_sweden <- function(dataset,seg_num){
  master_list <- list()
  
  for(i in 1:length(dataset)){
    results <- vector("list", length(dataset))
    slice_df <- dataset[[i]]$AKSVD_df
    
    min_sen = seg_num #minimum segment length
    
    # piecewise linear approximation
    cpop_output <- cpop(y = slice_df$Distance, x = slice_df$inds, 
                        minseglen = min_sen,
                        prune.approx = TRUE)
    
    fit_results <- fitted(cpop_output)
    vec_changepoint <- changepoints(cpop_output)
    
    pair_list <- list(slice_df, fit_results, vec_changepoint)
    
    master_list[[i]] <- pair_list
  }
  return(master_list)
}

# save object for distance
AKSVD_results_distance <-cpop_sweden(AKSVD_sweden, 0.1)


list_fitted_dist_AKSVD <- list()
list_total_dist_AKSVD <- list()

# extract list for fitted data 
for(tb in 1:length(AKSVD_results_distance)){
  list_fitted_dist_AKSVD[[tb]] <- as.data.frame(AKSVD_results_distance[[tb]][2])
  list_total_dist_AKSVD[[tb]] <- as.data.frame(AKSVD_results_distance[[tb]][1])
}

###################### AKSVD FITTED VALUES: DISTANCE ###########################


# Create a new list with the selected columns and a new index: AKSVD
AKSVD_fitted_dist <- lapply(seq_along(list_fitted_dist_AKSVD), function(i) {
  fit_df <- list_fitted_dist_AKSVD[[i]]
  fit_df$index <- paste("Turbine",i)  # Add index
  fit_df$method <- "AKSVD"
  fit_df$type <- "PLA of distance"
  return(fit_df)
})



##################### Piecewise Approximation #######################

# Combine all the selected data frames into one data frame
fitted_dist_AKSVD <- do.call(rbind, AKSVD_fitted_dist)

# Convert 'index' to a factor (if it's not already)
fitted_dist_AKSVD$index <- factor(fitted_dist_AKSVD$index)

# Create custom labels for the legend
fitted_tb_label <- levels(fitted_dist_AKSVD$index)







