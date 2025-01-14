library(R.matlab)
library(ggplot2)
library(cpop)
library(patchwork)
library(grid)
library(gridExtra)
library(ggh4x)
library(tidyverse)

# Load custom functions
source("pla_test2_mean.R")

# Load cycle number data
load("data/cycle_number.RData")

# Load MATLAB data
T2_omp <- readMat("data/omp_unsw_t2_350.mat")

# Extract cycle data
T2_time_2m <- cycle_list[[2]]
cycle1 <- c(10717, T2_time_2m[4:length(T2_time_2m)])

###### save the distance separately
T2_omp_dists_2m <- T2_omp$vdist[,1]
T2_omp_dists_3m <- T2_omp$vdist[,2]

T2_omp_spars_2m <- T2_omp$vbests[,1]
T2_omp_spars_3m <- T2_omp$vbests[,2]

# Extract and normalize EBIC data
normalize_ebic <- function(data, n_rows) {
  data / (n_rows * 200)
}

data_size <- nrow(T2_omp$vdist)
T2_omp_vEBIC_2m <- normalize_ebic(T2_omp$vEBIC[, 1], data_size)
T2_omp_vEBIC_3m <- normalize_ebic(T2_omp$vEBIC[, 2], data_size)


# mean value of them 
mean_T2_omp_dists_2m <- compute_mean_unsw_t2(T2_omp_dists_2m)
mean_T2_omp_dists_3m <- compute_mean_unsw_t2(T2_omp_dists_3m)

mean_T2_omp_vEBIC_2m <- compute_mean_unsw_t2(T2_omp_vEBIC_2m)
mean_T2_omp_vEBIC_3m <- compute_mean_unsw_t2(T2_omp_vEBIC_3m)


T2_omp_mean_dist_2m <- data.frame(Distance = mean_T2_omp_dists_2m,
                               inds = cycle1, 
                               size = "2m")
T2_omp_mean_dist_3m <- data.frame(Distance = mean_T2_omp_dists_3m,
                                  inds = cycle1, 
                                  size = "3m")

T2_omp_mean_dist <- rbind(T2_omp_mean_dist_2m, T2_omp_mean_dist_3m)

# Apply pivoting to transform the distance data frame into a long format
omp_all_one_dist <- T2_omp_mean_dist %>%
  pivot_longer(cols = c(Distance), names_to = "variable", values_to = "value")

# ebic data frame
T2_omp_mean_ebic_2m <- data.frame(EBIC = mean_T2_omp_vEBIC_2m,
                                  inds = cycle1, 
                                  size = "2m")
T2_omp_mean_ebic_3m <- data.frame(EBIC = mean_T2_omp_vEBIC_3m,
                                  inds = cycle1, 
                                  size = "3m")

T2_omp_mean_ebic <- rbind(T2_omp_mean_ebic_2m, T2_omp_mean_ebic_3m)

omp_all_one_ebic <- T2_omp_mean_ebic %>%
  pivot_longer(cols = c(EBIC), names_to = "variable", values_to = "value")


#### sparsity level
numbers_cycle1 <- cycle1[2:length(cycle1)]
num_cycles_2 <- list()

# find cycles
cycle_vec_1 <- cycle1[1] + (0:23)
for(i in 1:length(numbers_cycle1)){
  num_cycles_2[[i]] <- numbers_cycle1[i] + (0:74)
}

cycle_vec_2 <- unlist(num_cycles_2)

cycle_all <- c(cycle_vec_1, cycle_vec_2)

# data frame

T2_omp_spars_2m_df <- data.frame(Sparsity = T2_omp_spars_2m,
                                  inds = cycle_all, 
                                  size = "2m")
T2_omp_spars_3m_df <- data.frame(Sparsity = T2_omp_spars_3m,
                                  inds = cycle_all, 
                                  size = "3m")

T2_omp_spars_df <- rbind(T2_omp_spars_2m_df, T2_omp_spars_3m_df)

omp_all_one_spars <- T2_omp_spars_df %>%
  pivot_longer(cols = c(Sparsity), names_to = c("variable"), values_to = "value")

omp_combined <- rbind(
  omp_all_one_dist,
  omp_all_one_ebic,
  omp_all_one_spars
)




# Create the plot using facet_grid

# Create the plot using combined data

T2_omp_plot<- ggplot(omp_combined, aes(x = inds / 1000000, y = value)) +
  geom_line(color = "darkslategray") +
  
  # Facet grid without independent y-axes
  facet_grid2(variable ~ size, scales = "free_y") +
  
  # Custom y-axis ticks for EBIC and Sparsity (only left y-axis shown)
  facetted_pos_scales(
    y = list(
      variable == "EBIC" ~ scale_y_continuous(breaks = c(-0.0014, -0.0011,-0.0008, -0.0005)),
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
    aes(x = 1521397 / 1000000, y = 0.35),
    shape = 25, size = 1.7, color = "maroon2", fill = "maroon2"
  ) + 
  coord_cartesian(xlim = c(0.01, 2.03)) +  # Set x-axis range
  scale_x_continuous(
    limits = c(0.01, 2.03),  # Set the x-axis limits
    breaks = c(0.01, 0.5, 1.0, 1.5, 2.03)  # Automatically determine intermediate ticks
  )


folder_path <- "/Users/hannahyun/Library/Mobile Documents/com~apple~CloudDocs/__class/_Thesis_writing/H_DL_PLA/_plots/"
file_path <- "UNSW_T2_omp.pdf"

direct <- paste0(folder_path, file_path)

ggsave(filename = direct, 
       plot = T2_omp_plot, 
       width = 7, height = 4.5, 
       units = "in")  

