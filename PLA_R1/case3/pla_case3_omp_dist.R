# import library
library(tidyr)
library(ggplot2)
library(cpop)

# Load the dataset
load("data/_SWD_NEW_2M_OMP.RData")

# PLA: distance
cpop_sweden <- function(dataset,seg_num){
  master_list <- list()
  
  for(i in 1:length(dataset)){
    results <- vector("list", length(dataset))
    slice_df <- dataset[[i]]$omp_df
    
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
omp_seed_swd_cpop <-cpop_sweden(omp_sweden, 0.1)


list_fitted_omp <- list()
list_total_omp <- list()

# extract list for fitted data 
for(tb in 1:length(omp_seed_swd_cpop)){
  list_fitted_omp[[tb]] <- as.data.frame(omp_seed_swd_cpop[[tb]][2])
  list_total_omp[[tb]] <- as.data.frame(omp_seed_swd_cpop[[tb]][1])
}

###################### OMP FITTED VALUES: DISTANCE ###########################


# Create a new list with the selected columns and a new index: OMP
omp_fitted <- lapply(seq_along(list_fitted_omp), function(i) {
  fit_df <- list_fitted_omp[[i]]
  fit_df$index <- paste("Turbine",i)  # Add index
  fit_df$method <- "OMP"
  fit_df$type <- "PLA for distance"
  return(fit_df)
})



##################### Piecewise Approximation #######################

# Combine all the selected data frames into one data frame
fitted_dist_omp <- do.call(rbind, omp_fitted)

# Convert 'index' to a factor (if it's not already)
fitted_dist_omp$index <- factor(fitted_dist_omp$index)

# Create custom labels for the legend
fitted_tb_label <- levels(fitted_dist_omp$index)







