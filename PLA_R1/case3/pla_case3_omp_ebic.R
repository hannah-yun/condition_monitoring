# import library
library(tidyr)
library(ggplot2)
library(cpop)

# Load the dataset
load("data/_SWD_NEW_2M_OMP.RData")

#EBIC normalisation
omp_ebic_df <- list()
m <- 79
N <- 200
for (i in 1:length(omp_sweden)){
  df <- omp_sweden[[i]]$omp_df
  ebic <- df$EBIC
  ebic1 <- ebic/(m*N)
  df_ebic <- data.frame(Distance = df$Distance,
                        EBIC = ebic1,
                        Sparsity = df$Sparsity,
                        inds = df$inds, 
                        size = df$size)
  omp_ebic_df[[i]] <- df_ebic
}

# PLA process
cpop_swd_ebic <- function(dataset,seg_num){
  master_list <- list()
  
  for(i in 1:length(dataset)){
    results <- vector("list", length(dataset)) 
    min_sen = seg_num #minimum segment length
    
    slice_df <- dataset[[i]] # collect the data
    
    # piecewise linear approximation
    cpop_output <- cpop(y = slice_df$EBIC, x = slice_df$inds, 
                        minseglen = min_sen,
                        prune.approx = TRUE)
    # fitted results
    fit_results <- fitted(cpop_output)
    vec_changepoint <- changepoints(cpop_output)
    # save all results
    pair_list <- list(slice_df, fit_results, vec_changepoint)
    
    master_list[[i]] <- pair_list
  }
  return(master_list)
}

# save object for ebic
omp_swd_cpop_ebic <-cpop_swd_ebic(omp_ebic_df, 0.1)

# objects for fitted values and ebic values
list_fitted_omp <- list()
list_total_omp <- list()

# extract list for fitted data 
for(tb in 1:length(omp_swd_cpop_ebic)){
  list_fitted_omp[[tb]] <- as.data.frame(omp_swd_cpop_ebic[[tb]][2])
  list_total_omp[[tb]] <- as.data.frame(omp_swd_cpop_ebic[[tb]][1])
}

########################## OMP FITTED VALUES: EBIC #############################


# Create a new list with the selected columns and a new index: OMP
omp_fitted <- lapply(seq_along(list_fitted_omp), function(i) {
  fit_df <- list_fitted_omp[[i]]
  fit_df$index <- paste("Turbine",i)  # Add index
  fit_df$method <- "OMP"
  fit_df$type <- "PLA for EBIC"
  return(fit_df)
})



##################### Piecewise Approximation #######################

# Combine all the selected data frames into one data frame
fitted_ebic_omp <- do.call(rbind, omp_fitted)

# Convert 'index' to a factor (if it's not already)
fitted_ebic_omp$index <- factor(fitted_ebic_omp$index)

# Create custom labels for the legend
fitted_tb_label <- levels(fitted_ebic_omp$index)






