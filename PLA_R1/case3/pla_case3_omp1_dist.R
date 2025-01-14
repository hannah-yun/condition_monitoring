# import library
library(tidyr)
library(ggplot2)
library(cpop)

# load the file
load("data/_SWD_NEW_2M_OMP1.RData")

# PLA: distance
cpop_sweden <- function(dataset,seg_num){
  master_list <- list()
  
  for(i in 1:length(dataset)){
    
    slice_df <- dataset[[i]]$omp1_df
    results <- vector("list", length(dataset))
    
    min_sen = seg_num #minimum segment length
    
    # piecewise linear approximation using cpop package
    cpop_output <- cpop(y = slice_df$Distance, x = slice_df$inds, 
                        minseglen = min_sen,
                        prune.approx = TRUE)
    
    # save objects
    fit_results <- fitted(cpop_output)
    vec_changepoint <- changepoints(cpop_output)
    pair_list <- list(slice_df, fit_results, vec_changepoint)
    master_list[[i]] <- pair_list
  }
  return(master_list)
}

# saved object
omp1_dist_cpop <-cpop_sweden(omp1_sweden, 0.1)

####################### OMP1 PLOTTING ################################


list_fitted_L1 <- list()
list_total_L1 <- list()

# extract list for fitted data 
for(tb in 1:length(omp1_dist_cpop)){
  list_fitted_L1[[tb]] <- as.data.frame(omp1_dist_cpop[[tb]][2])
  list_total_L1[[tb]] <- as.data.frame(omp1_dist_cpop[[tb]][1])
}

# Create a new list with the selected columns and a new index: L1
omp1_fitted_dist <- lapply(seq_along(list_fitted_L1), function(i) {
  fit_df <- list_fitted_L1[[i]]
  fit_df$index <- paste("Turbine",i)  # Add index
  fit_df$method <- "OMP[1]"
  fit_df$type <- "PLA for distance"
  return(fit_df)
})



##################### Piecewise Approximation #######################

# Combine all the selected data frames into one data frame
fitted_dist_omp1 <- do.call(rbind, omp1_fitted_dist)

# Convert 'index' to a factor (if it's not already)
fitted_dist_omp1$index <- factor(fitted_dist_omp1$index)

# Create custom labels for the legend
fitted_tb_label <- paste("Turbine", levels(fitted_dist_omp1$index))



