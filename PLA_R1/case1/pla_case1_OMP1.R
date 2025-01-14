# import library
library(tidyr)
library(ggplot2)
library(cpop)
library(dplyr)


# Load the dataset


# function for omp1
cpop_nrel_omp1 <- function(dataset,seg_num){
  master_list <- list()
  
  for(i in 1:9){
    
    slice_df <- dataset[[i]]$omp1_df

    results <- vector("list", length(dataset))
    
    min_sen = seg_num
    
    cpop_output <- cpop(y = slice_df$dist, x = slice_df$time, 
                        minseglen = min_sen,
                        prune.approx = TRUE)
    
    fit_results <- fitted(cpop_output)
    vec_changepoint <- changepoints(cpop_output)
    
    pair_list <- list(slice_df, fit_results, vec_changepoint)
    
    master_list[[i]] <- pair_list
  }
  return(master_list)
}

# save object
L1_seed_nrel <- cpop_nrel_omp1(omp1_tb, 0.1)

bearings <- rep(c("AN5", "AN6", "AN7"), 3)
cutoff <- rep(c(1000, 2500, 3500), each =3)

for (i in seq_along(L1_seed_nrel)) {
  L1_seed_nrel[[i]][[2]]$bearings <- bearings[i]        # Assign motor value to each data frame
  L1_seed_nrel[[i]][[2]]$cutoff_freq <- cutoff[i] # Assign cutoff_freq value to each data frame
}

fitted_tb_label <- c("AN5", "AN6", "AN7")


list_fitted_L1 <- list()
list_total_L1 <- list()

# extract list for fitted data 
for(tb in 1:length(L1_seed_nrel)){
  list_fitted_L1[[tb]] <- as.data.frame(L1_seed_nrel[[tb]][2])
  list_total_L1[[tb]] <- as.data.frame(L1_seed_nrel[[tb]][1])
}


####################### PLA: L1 ###############################


# Create a new list with the selected columns and a new index: L1
L1_fitted <- lapply(seq_along(list_fitted_L1), function(i) {
  fit_df <- list_fitted_L1[[i]]
  fit_df$index <- i+4  # Add index
  return(fit_df)
})



##################### Piecewise Approximation #######################

# Combine all the selected data frames into one data frame
fitted_df_L1 <- do.call(rbind, L1_fitted)

# Convert 'index' to a factor (if it's not already)
fitted_df_L1$index <- factor(fitted_df_L1$index)

# Create custom labels for the legend
fitted_tb_label <- paste("AN", levels(fitted_df_L1$index))









