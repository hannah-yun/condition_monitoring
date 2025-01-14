#load files 
library(R.matlab)
library(ggplot2)
library(patchwork)
library(grid)
library(gridExtra)
library(ggh4x)
library(tidyverse)

# Load custom functions
source("pla_test1_mean.R")

# Load cycle number data
load("data/cycle_number.RData")

# Load MATLAB data
T1_omp <- readMat("data/omp_unsw_t1_250.mat")

# Extract cycle data
T1_time_2m <- cycle_list[[1]] 
cycle1 <- c(10715, T1_time_2m[4:length(T1_time_2m)])

###### save the distance separately
T1_omp_dists_2m <- T1_omp$vdist[,1]
T1_omp_dists_3m <- T1_omp$vdist[,2]

T1_omp_spars_2m <- T1_omp$vbests[,1]
T1_omp_spars_3m <- T1_omp$vbests[,2]

# Extract and normalize EBIC data
normalize_ebic <- function(data, n_rows) {
  data / (n_rows * 200)
}

data_size <- nrow(T1_omp$vdist)
T1_omp_vEBIC_2m <- normalize_ebic(T1_omp$vEBIC[, 1], data_size)
T1_omp_vEBIC_3m <- normalize_ebic(T1_omp$vEBIC[, 2], data_size)

# mean value of them 
mean_T1_omp_dists_2m <- compute_mean_unsw_t1(T1_omp_dists_2m)
mean_T1_omp_dists_3m <- compute_mean_unsw_t1(T1_omp_dists_3m)

mean_T1_omp_vEBIC_2m <- compute_mean_unsw_t1(T1_omp_vEBIC_2m)
mean_T1_omp_vEBIC_3m <- compute_mean_unsw_t1(T1_omp_vEBIC_3m)

# distance data frame
T1_omp_mean_dist_2m <- data.frame(Distance = mean_T1_omp_dists_2m,
                               inds = cycle1, 
                               size = "2m")
T1_omp_mean_dist_3m <- data.frame(Distance = mean_T1_omp_dists_3m,
                                  inds = cycle1, 
                                  size = "3m")
# row bind
T1_omp_mean_dist <- rbind(T1_omp_mean_dist_2m, T1_omp_mean_dist_3m)

# Apply pivoting to transform the distance data frame into a long format
omp_all_one_dist <- T1_omp_mean_dist %>%
  pivot_longer(cols = c(Distance), names_to = "variable", values_to = "value")


###### save the ebic separately
T1_omp_mean_ebic_2m <- data.frame(EBIC = mean_T1_omp_vEBIC_2m,
                                  inds = cycle1, 
                                  size = "2m")
T1_omp_mean_ebic_3m <- data.frame(EBIC = mean_T1_omp_vEBIC_3m,
                                  inds = cycle1, 
                                  size = "3m")

T1_omp_mean_ebic <- rbind(T1_omp_mean_ebic_2m, T1_omp_mean_ebic_3m)

# Apply pivoting to transform the ebic data frame into a long format
omp_all_one_ebic <- T1_omp_mean_ebic %>%
  pivot_longer(cols = c(EBIC), names_to = "variable", values_to = "value")


# sparsity level (as it is)
numbers_cycle1 <- cycle1[2:length(cycle1)]
num_cycles_2 <- list()

# find cycles per each segment
cycle_vec_1 <- cycle1[1] + (0:23)
for(i in 1:length(numbers_cycle1)){
  num_cycles_2[[i]] <- numbers_cycle1[i] + (0:74)
}

cycle_vec_2 <- unlist(num_cycles_2)

cycle_all <- c(cycle_vec_1, cycle_vec_2)

# data frame for sparsity
T1_omp_spars_2m_df <- data.frame(Sparsity = T1_omp_spars_2m,
                                  inds = cycle_all, 
                                  size = "2m")
T1_omp_spars_3m_df <- data.frame(Sparsity = T1_omp_spars_3m,
                                  inds = cycle_all, 
                                  size = "3m")

T1_omp_spars_df <- rbind(T1_omp_spars_2m_df, T1_omp_spars_3m_df)

omp_all_one_spars <- T1_omp_spars_df %>%
  pivot_longer(cols = c(Sparsity), names_to = c("variable"), values_to = "value")

# data frame combined
omp_combined <- rbind(
  omp_all_one_dist,
  omp_all_one_ebic,
  omp_all_one_spars
)


# Create the plot using facet_grid
T1_omp_plot <- ggplot(omp_combined, aes(x = inds / 1000000, y = value)) +
  geom_line(color = "darkslategray") +
  
  # Facet grid without independent y-axes
  facet_grid2(variable ~ size, scales = "free_y") +
  
  # Custom y-axis ticks for EBIC and Sparsity (only left y-axis shown)
  facetted_pos_scales(
    y = list(
      variable == "EBIC" ~ scale_y_continuous(breaks = c(-0.0025, -0.0020,-0.0015, -0.0010)),
      variable == "Sparsity" ~ scale_y_continuous(breaks = c(3.00, 4.00)),
      variable == "Distance" ~ scale_y_continuous(breaks = c(0.20, 0.25, 0.30, 0.35)) # Auto-scale for Distance
    )
  ) +
  
  labs(x = "Million cycle", y = "") +
  theme(
    strip.placement = "outside",
    strip.text.y.left = element_text(size = 10, angle = 0),
    strip.text.x = element_text(size = 10),
    panel.spacing = unit(0.2, "lines"),
    legend.position = "none",
    axis.ticks.y.right = element_blank(),   # Remove right-side y-axis ticks
    axis.text.y.right = element_blank(),    # Remove right-side y-axis text
    axis.line.y.right = element_blank()     # Remove right-side y-axis line
  ) +
  geom_point(
    data = omp_combined %>% filter(variable == "Distance"),
    aes(x = 255962 / 1000000, y = 0.35),
    shape = 25, size = 1.7, color = "maroon2", fill = "maroon2"
  ) + 
  coord_cartesian(xlim = c(0.01, 0.36)) +  # Set x-axis range
  scale_x_continuous(
    limits = c(0.01, 0.36),  # Set the x-axis limits
    breaks = c(0.01, 0.1, 0.2, 0.3, 0.36)  # Automatically determine intermediate ticks
  )



file_path <- "UNSW_T1_omp.pdf"


ggsave(filename = file_path, 
       plot = T1_omp_plot, 
       width = 7, height = 4.5, 
       units = "in")  

