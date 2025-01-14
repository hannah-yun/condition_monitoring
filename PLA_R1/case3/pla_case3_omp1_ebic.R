#load the data
load("data/_SWD_NEW_2M_OMP1.RData")

#EBIC normalisation
omp1_ebic_df <- list()
m <- 79
N <- 200
for (i in 1:length(omp1_sweden)){
 df <- omp1_sweden[[i]]$omp1_df
 ebic <- df$EBIC
 ebic1 <- ebic/(m*N)
 df_ebic <- data.frame(Distance = df$Distance,
                       EBIC = ebic1,
                       Sparsity = df$Sparsity,
                       inds = df$inds, 
                       size = df$size)
 omp1_ebic_df[[i]] <- df_ebic
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
omp1_swd_cpop_ebic <- cpop_swd_ebic(omp1_ebic_df, 0.1)

####################### OMP1 PLOTTING ################################

list_fitted_L1 <- list()
list_total_L1 <- list()

# extract list for fitted data 
for(tb in 1:length(omp1_swd_cpop_ebic)){
  list_fitted_L1[[tb]] <- as.data.frame(omp1_swd_cpop_ebic[[tb]][2])
  list_total_L1[[tb]] <- as.data.frame(omp1_swd_cpop_ebic[[tb]][1])
}

# Create a new list with the selected columns and a new index: L1
omp1_fitted <- lapply(seq_along(list_fitted_L1), function(i) {
  fit_df <- list_fitted_L1[[i]]
  fit_df$index <- paste("Turbine",i)  # Add index
  fit_df$method <- "OMP[1]"
  fit_df$type <- "PLA for EBIC"
  return(fit_df)
})



##################### Piecewise Approximation #######################

# Combine all the selected data frames into one data frame
fitted_ebic_omp1 <- do.call(rbind, omp1_fitted)

# Convert 'index' to a factor (if it's not already)
fitted_ebic_omp1$index <- factor(fitted_ebic_omp1$index)

# Create custom labels for the legend
fitted_tb_label <- paste("Turbine", levels(fitted_ebic_omp1$index))



