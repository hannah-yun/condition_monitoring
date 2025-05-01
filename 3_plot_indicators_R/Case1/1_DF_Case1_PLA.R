library(R.matlab)
library(purrr)
library(dplyr)

# Base directory - it's applied to both AKSVD and AKSVD_1
base_path <- "_results/_NREL_NEW_CODE/AKSVD1/" # set the path AKSVD or AKSVD1

# File paths (just the relative names)
file_names <- c(
  "AKSVD_an5_800_2m3m_345.mat",
  "AKSVD_an5_2500_2m3m_345.mat",
  "AKSVD_an5_3500_2m3m_345.mat",
  "AKSVD_an6_800_2m3m_345.mat",
  "AKSVD_an6_2500_2m3m_345.mat",
  "AKSVD_an6_3500_2m3m_345.mat",
  "AKSVD_an7_1000_2m3m_345.mat",
  "AKSVD_an7_2500_2m3m_345.mat",
  "AKSVD_an7_3500_2m3m_345.mat"
)

# full paths
full_paths <- file.path(base_path, file_names) 


# Extract data and match with time vectors
AKSVD_nrel <- map2(full_paths, 1:9, function(path, idx) {
  mat_data <- readMat(path)
  
  # Index-based vEBIC extraction
  if (idx %in% c(1, 4, 7)) {
    ebic <- mat_data$vEBIC[,1]
    spars <- mat_data$vbests[2:1000,1]
    dist  <- mat_data$vdist[,1]
    
  } else {
    ebic <- mat_data$vEBIC[[1]][[1]]
    spars <- mat_data$vbests[[1]][[1]]
    dist <- mat_data$vdist[[1]][[1]]
  }
  
  # Time from previously loaded AKSVD_tb
  time_vec <- 202:1200 # time moment
  
  # create data frame
  df <- data.frame(
    Distance = dist,
    Sparsity = spars,
    inds = time_vec,
    EBIC = ebic,
    size = "2m"
  )
  
  list(AKSVD_df = df)
})


# Save <- depending on AKSVD and AKSVD1, please change the name
save(AKSVD_nrel, file = "_NEW_NREL_AKSVD_1000_2500_3500.RData")

