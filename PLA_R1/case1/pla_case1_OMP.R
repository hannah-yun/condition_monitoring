# import library
library(tidyr)
library(ggplot2)
library(cpop)
library(dplyr)


# Load the dataset
# load the dataset from matlab

# function
cpop_nrel_omp <- function(dataset,seg_num){
  master_list <- list()
  
  for(i in 1:9){
    
    slice_df <- dataset[[i]]$omp_df

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

# save objects
omp_seed_nrel <- cpop_nrel_omp(omp_tb, 0.1)

# assign bearins and cutoff frequency
bearings <- rep(c("AN5", "AN6", "AN7"), 3)
cutoff <- rep(c(1000, 2500, 3500), each =3)

for (i in seq_along(omp_seed_nrel)) {
  omp_seed_nrel[[i]][[2]]$bearings <- bearings[i]        # Assign motor value to each data frame
  omp_seed_nrel[[i]][[2]]$cutoff_freq <- cutoff[i] # Assign cutoff_freq value to each data frame
}

# fitted labels
fitted_tb_label <- c("AN5", "AN6", "AN7")


# save objects
list_fitted_omp <- list()
list_total_omp <- list()

# extract list for fitted data 
for(tb in 1:length(omp_seed_nrel)){
  list_fitted_omp[[tb]] <- as.data.frame(omp_seed_nrel[[tb]][2])
  list_total_omp[[tb]] <- as.data.frame(omp_seed_nrel[[tb]][1])
}



###################### OMP Piecewise approximation ###################### 


# Create a new list with the selected columns and a new index: OMP
omp_fitted <- lapply(seq_along(list_fitted_omp), function(i) {
  fit_df <- list_fitted_omp[[i]]
  return(fit_df)
})


# Combine all the selected data frames into one data frame
fitted_df_omp <- do.call(rbind, omp_fitted)

# Convert 'index' to a factor (if it's not already)
fitted_df_omp$index <- factor(fitted_df_omp$index)

# Create custom labels for the legend
fitted_tb_label <- paste("AN", levels(fitted_df_omp$index))






