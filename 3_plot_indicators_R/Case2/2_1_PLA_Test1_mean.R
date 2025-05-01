# Test 1: This R script computes the mean for 75 segments when N = 200 (should be modified when N!=200) 
# The first value is computed from 24 segment values to align with the original vibration data

compute_mean_unsw_t1 <- function(df){
  ave_val_vector <- numeric(78)  # Pre-allocate vector for 78 elements
  
  # First 25 rows for the first element
  ave_val_vector[1] <- mean(df[1:24], na.rm = TRUE)
  
  # select 75 signal segments to compute mean
  for (i in 1:77) {
    start_idx <- (i-1)*75 + 26
    end_idx <- start_idx + 74
    selected_dist <- df[start_idx:end_idx]
    
    # compute the mean
    ave_val <- mean(selected_dist, na.rm = TRUE)  
    ave_val_vector[i + 1] <- ave_val  # Append ave_val to the vector
  }

  return(ave_val_vector)
}

