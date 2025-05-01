# Import library
library(R.matlab)

# Import .mat file for AN6 bearing at 0–800 Hz range using AKSVD
base_path_AKSVD <- "_results/_NREL_NEW_CODE/AKSVD/" 
file_names_AKSVD <-"AKSVD_AN6_800_2m3m_345.mat"
file_path_AKSVD <- paste0(base_path, file_names_AKSVD)

# Import .mat file for AN6 bearing at 0–800 Hz range using AKSVD1
base_path_AKSVD1 <- "_results/_NREL_NEW_CODE/AKSVD1/" 
file_names_AKSVD1 <-"AKSVD1_AN6_800_2m3m_345.mat"
file_path_AKSVD1 <- paste0(base_path, file_names_AKSVD1)


# Read the MATLAB .mat file
AN6_AKSVD <- readMat(file_path_AKSVD)
AN6_AKSVD1 <- readMat(file_path_AKSVD1)

# Extract the necessary matrices from the imported data for AKSVD
AKSVD_dists <- AN6_AKSVD$vdist
AKSVD_spars <- AN6_AKSVD$vbests
indices <- 202:1200
AKSVD_vEBIC <- AN6_AKSVD$vEBIC

# Extract the necessary matrices from the imported data for AKSVD1
AKSVD1_dists <- AN6_AKSVD1$vdist
AKSVD1_spars <- AN6_AKSVD1$vbests
indices <- 202:1200
AKSVD1_vEBIC <- AN6_AKSVD1$vEBIC


# Create data frame for AKSVD and AKSVD1
AKSVD_AN6_total <- data.frame(time = indices,
                            dist = AKSVD_dists[,1], 
                            method = "AKSVD")
AKSVD1_AN6_total <- data.frame(time = indices,
                            dist = AKSVD1_dists[,1],
                            method = "AKSVD[1]")

# Bind AKSVD and AKSVD1 to create big data matrix
AN6_total <- rbind(AKSVD_AN6_total, AKSVD1_AN6_total)

# Run PLA algorithm with CPOP when minimum allowable segment length is set at default value
AKSVD_AN6_fit <- cpop(y = AKSVD_AN6_total$dist, x = AKSVD_AN6_total$time, minseglen = 0)
AKSVD1_AN6_fit <- cpop(y = AKSVD_AN6_total$dist, x = AKSVD_AN6_total$time, minseglen = 0)

# Extract fitted valuse from the algorithms
fitted_AKSVD <- fitted(AKSVD_AN6_fit)
fitted_AKSVD$method = "AKSVD"
fitted_AKSVD1 <- fitted(AKSVD1_AN6_fit)
fitted_AKSVD1$method = "AKSVD[1]"


# Set the marker to present on the plot  
marker_data <- data.frame(
  x = 601,
  y = 0.44,
  method = c("AKSVD", "AKSVD[1]")
)


# Define a custom label parser for facets
custom_labeller <- labeller(
  method = label_parsed          
)

# Create a faceted line plot for Distance and Fitted distance
AN6_dist_fit <- ggplot() +
  # Scatter plot for each method
  geom_point(data = rbind(AKSVD_AN6_total, AKSVD1_AN6_total), 
             aes(x = time, y = dist), 
             color = "#00BFC4", size = 2, alpha = 0.4) +
  # Segment plot for fitted values
  geom_segment(data = rbind(fitted_AKSVD, fitted_AKSVD1), 
               aes(x = x0, y = y0, xend = x1, yend = y1), 
               color = "black", linewidth = 0.8, alpha = 1) +
  # Add the magenta marker for each facet
  geom_point(data = marker_data, 
             aes(x = x, y = y), 
             shape = 25, size = 2, color = "deeppink2", fill = "deeppink2") +
  labs(y = "Distance/PLA", x = "Index") +
  facet_grid(. ~ method,
             labeller = custom_labeller) +
  coord_cartesian(xlim = c(200, 1200)) +  # Set x-axis range
  scale_x_continuous(breaks = seq(200, 1200, by = 200))  # Adjust x-axis ticks


# Save the object
folder_path <- ""
file_path <- "NREL_AN6_dist_pla.pdf"

direct <- paste0(folder_path, file_path)

ggsave(filename = direct, 
       plot = AN6_dist_fit, 
       width = 8.5, height = 4, 
       units = "in")

