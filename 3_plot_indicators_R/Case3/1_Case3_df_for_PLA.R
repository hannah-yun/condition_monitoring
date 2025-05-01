# load packages
library(R.matlab)
library(purrr)
library(dplyr)

# This R script creates a list of length 6 from the results of each turbine’s DL algorithm.
# Here, the dictionary size 2m is always better than 3m, so we have saved 2m values. 
# Please run this R code for AKSVD and AKSVD1 separately

# Time data df from original files (the first column of the original data)
time_path <- "_raw_data"
time_names <- paste0("raw_T0",1:6,".csv")
time_paths <- file.path(time_path, time_names) # paths

# save time vectors as a list 
time_sweden <- map2(time_paths,1:6, function(path, idx){
  time_data <- read.csv(path)
  time_year <- time_data[,1]
  list(time_year)
})

### Save the dictionary learning data ###
# File paths for new .mat data
base_path <- "_SWD_NEW_CODE" # please set the path if the mat files are saved in the different folder
file_names <- paste0("AKSVD_T", 1:6, ".mat") 
full_paths <- file.path(base_path, file_names) # paths

# Extract data and match with time vectors
AKSVD_sweden <- map2(full_paths, 1:6, function(path, idx) {
  mat_data <- readMat(path)
  
  dist  <- mat_data$vdist[[1]][[1]] # dictionary distance
  spars <- mat_data$vbests[[1]][[1]] # sparsity
  ebic  <- mat_data$vEBIC[[1]][[1]] # ebic 
  
  # Time from previously loaded AKSVD_tb
  time_vec <- time_sweden[[idx]][[1]][201:length(time_sweden[[idx]][[1]])]
  
  # create data frame
  df <- data.frame(
    Distance = dist,
    Sparsity = spars,
    inds = time_vec,
    EBIC = ebic,
    size = "2m"
  )
  
  df <- df[2:nrow(df), ]
  list(AKSVD_df = df)
})

# Save
save(AKSVD_sweden, file = "_SWD_NEW_2M_AKSVD.RData")



