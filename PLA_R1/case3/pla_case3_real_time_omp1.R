# import library
library(cpop)
library(dplyr)
library(ggplot2)

# load the data
load("data/_SWD_NEW_2M_OMP1.RData")

realtime_PLA <- function(dataset, seg_num, data_input){
  all_fitted <- list()
  
  for(j in 1:length(dataset)){
    print(j)
    slice_df <- dataset[[j]]$omp1_df
    num_points <- seq(400, length(slice_df$Distance), by = data_input)
    num_points <- c(num_points, length(slice_df$Distance))
    cpop_fitted <-list()
    
    for (i in num_points) {
      print(i)
      x = slice_df$inds[1:i]
      y = slice_df$Distance[1:i]
      
      # cpop function
      df_cpop <- cpop(y = y, x = x, 
                      minseglen = seg_num,
                      beta = 2*log(length(x)),
                      sd = rep(sqrt(mean(diff(diff(x))^2)/6), length(x)),
                      prune.approx = TRUE)
      
      # save the output from the cpop function
      k <- which(num_points == i)
      
      # fitted values
      fitted_df <- fitted(df_cpop)
      cpop_fitted[[k]] <- fitted_df
    
    }
    all_fitted[[j]] <- cpop_fitted
  }
  return(fitted_value = all_fitted)
}

PLA_swd_omp1 <- realtime_PLA(omp1_sweden, 0.1, 400)




