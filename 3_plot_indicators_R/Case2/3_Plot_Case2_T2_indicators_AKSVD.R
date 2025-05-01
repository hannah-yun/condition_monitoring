#load packages 
library(R.matlab)
library(ggplot2)
library(patchwork)
library(grid)
library(gridExtra)
library(ggh4x)
library(tidyverse)

# This R script plots three indicator for Test 2
# Please run "Case2_Cycle_Number.R" first and save object "num_cycles" object first


# Load custom functions to compute mean
source("PLA_Test2_mean.R")

# Load MATLAB data
T2_AKSVD <- readMat("data/AKSVD_Case2_T2_250.mat")

# Extract cycle data
T2_time_2m <- num_cycles <- cycle_list[[2]]

# First three cycles are used for initialisation
Cycle_T2 <- c(10717, T2_time_2m[4:length(T2_time_2m)])

###### save the distance separately

# Helper function
normalize_ebic <- function(data, n_rows) data / (n_rows * 200)

dists <- T2_AKSVD$vdist
spars <- T2_AKSVD$vbests
ebic_raw <- T2_AKSVD$vEBIC
n_rows <- nrow(dists)

# Normalise EBIC
ebic <- list(
  `2m` = normalize_ebic(ebic_raw[, 1], n_rows),
  `3m` = normalize_ebic(ebic_raw[, 2], n_rows)
)

# Compute means
mean_vals <- list(
  dist = list(
    `2m` = compute_mean_unsw_T2(dists[, 1]),
    `3m` = compute_mean_unsw_T2(dists[, 2])
  ),
  ebic = list(
    `2m` = compute_mean_unsw_T2(ebic$`2m`),
    `3m` = compute_mean_unsw_T2(ebic$`3m`)
  )
)


# Create data frames
make_df <- function(values, var, label) {
  do.call(rbind, lapply(names(values[[var]]), function(sz) {
    df <- data.frame(
      inds = Cycle_T2,
      size = sz
    )
    df[[label]] <- values[[var]][[sz]]
    return(df)
  }))
}

# Final long-format data frames
AKSVD_all_one_dist <- make_df(mean_vals, "dist", "Distance") %>%
  pivot_longer(cols = Distance, names_to = "variable", values_to = "value")

AKSVD_all_one_ebic <- make_df(mean_vals, "ebic", "EBIC") %>%
  pivot_longer(cols = EBIC, names_to = "variable", values_to = "value")

#### Sparsity level (as it is) ####
num_cycle_T2 <- Cycle_T2[2:length(Cycle_T2)]
num_cycle_ALL <- list()

# find cycles per each segment to create data frame of sparsity
cycle_vec_1 <- Cycle_T2[1] + (0:23)
cycle_vec_2 <- unlist(lapply(Cycle_T2[-1], function(x) x + 0:74))
cycle_all_T2 <- c(cycle_vec_1, cycle_vec_2)

spars_vals <- list(
  `2m` = T2_AKSVD$vbests[, 1],
  `3m` = T2_AKSVD$vbests[, 2]
)

# data frame for sparsity
# Build sparsity dataframe
make_spars_df <- function(values, label) {
  do.call(rbind, lapply(names(values), function(sz) {
    data.frame(
      Sparsity = values[[sz]],
      inds = cycle_all_T2,
      size = sz
    )
  }))
}

# Long format
AKSVD_all_one_spars <- make_spars_df(spars_vals, "Sparsity") %>%
  pivot_longer(cols = Sparsity, names_to = "variable", values_to = "value")


# data frame combined
AKSVD_combined <- rbind(
  AKSVD_all_one_dist,
  AKSVD_all_one_ebic,
  AKSVD_all_one_spars
)

# set the name
AKSVD_combined$variable[AKSVD_combined$variable == "Distance"] <- "Distance (avg.)"
AKSVD_combined$variable[AKSVD_combined$variable == "EBIC"] <- "EBIC (avg.)"



# Create the plot using facet_grid
T2_AKSVD_plot <- ggplot(AKSVD_combined, aes(x = inds / 1000000, y = value)) +
  geom_line(color = "darkslategray") +
  
  # Facet grid without independent y-axes
  facet_grid2(variable ~ size, scales = "free_y") +
  
  # Custom y-axis ticks for EBIC and Sparsity (only left y-axis shown)
  facetted_pos_scales(
    y = list(
      variable == "EBIC (avg.)" ~ scale_y_continuous(breaks = c(-0.0014, -0.0011,-0.0008, -0.0005)),
      variable == "Sparsity" ~ scale_y_continuous(breaks = c(3.00, 4.00)),
      variable == "Distance (avg.)" ~ scale_y_continuous(breaks = c(0.20, 0.25, 0.30, 0.35)) # Auto-scale for Distance
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
    data = AKSVD_combined %>% filter(variable == "Distance (avg.)"),
    aes(x = 1521397 / 1000000, y = 0.35),
    shape = 25, size = 1.7, color = "maroon2", fill = "maroon2"
  ) + 
  coord_cartesian(xlim = c(0.01, 2.03)) +  # Set x-axis range
  scale_x_continuous(
    limits = c(0.01, 2.03),  # Set the x-axis limits
    breaks = c(0.01, 0.5, 1.0, 1.5, 2.03)  # Automatically determine intermediate ticks
  )


file_path <- "UNSW_T2_AKSVD.eps"


ggsave(filename = file_path, 
       plot = T2_AKSVD_plot, 
       device = "eps",
       width = 7, height = 4.5, 
       units = "in")  

