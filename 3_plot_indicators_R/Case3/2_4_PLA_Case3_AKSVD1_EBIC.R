# import library
library(tidyr)
library(ggplot2)
library(cpop)

# AKSVD1 method: This R script computes the PLA values for EBIC for each turbine

#load the data
load("data/_SWD_NEW_2M_AKSVD1.RData")

#EBIC normalisation
AKSVD1_ebic_df <- list()
m <- 79
N <- 200
for (i in 1:length(AKSVD1_sweden)){
 df <- AKSVD1_sweden[[i]]$AKSVD1_df
 ebic <- df$EBIC
 ebic1 <- ebic/(m*N)
 df_ebic <- data.frame(Distance = df$Distance,
                       EBIC = ebic1,
                       Sparsity = df$Sparsity,
                       inds = df$inds, 
                       size = df$size)
 AKSVD1_ebic_df[[i]] <- df_ebic
}

# PLA: ebic
cpop_swd_ebic <- function(dataset,seg_num){
  master_list <- list()
  
  for(i in 1:length(dataset)){
    
    slice_df <- dataset[[i]]
    #slice_df <- select_df[2:nrow(select_df),]
    
    results <- vector("list", length(dataset))
    
    min_sen = seg_num
    
    cpop_output <- cpop(y = slice_df$EBIC, x = slice_df$inds, 
                        minseglen = min_sen,
                        prune.approx = TRUE)
    
    fit_results <- fitted(cpop_output)
    vec_changepoint <- changepoints(cpop_output)
    
    pair_list <- list(slice_df, fit_results, vec_changepoint)
    
    master_list[[i]] <- pair_list
  }
  return(master_list)
}

# running the file
AKSVD1_results_ebic <- cpop_swd_ebic(AKSVD1_ebic_df, 0.1)

####################### AKSVD1 PLOTTING ################################

list_fitted_ebic_AKSVD1 <- list()
list_total_ebic_AKSVD1 <- list()

# extract list for fitted data 
for(tb in 1:length(AKSVD1_results_ebic)){
  list_fitted_ebic_AKSVD1[[tb]] <- as.data.frame(AKSVD1_results_ebic[[tb]][2])
  list_total_ebic_AKSVD1[[tb]] <- as.data.frame(AKSVD1_results_ebic[[tb]][1])
}

# Create a new list with the selected columns and a new index: L1
AKSVD1_fitted_ebic <- lapply(seq_along(list_fitted_ebic_AKSVD1), function(i) {
  fit_df <- list_fitted_ebic_AKSVD1[[i]]
  fit_df$index <- paste("Turbine",i)  # Add index
  fit_df$method <- "AKSVD[1]"
  fit_df$type <- "PLA of EBIC"
  return(fit_df)
})



##################### Piecewise Approximation #######################

# Combine all the selected data frames into one data frame
fitted_ebic_AKSVD1 <- do.call(rbind, AKSVD1_fitted_ebic)

# Convert 'index' to a factor (if it's not already)
fitted_ebic_AKSVD1$index <- factor(fitted_ebic_AKSVD1$index)

# Create custom labels for the legend
fitted_tb_label <- paste("Turbine", levels(fitted_ebic_AKSVD1$index))



