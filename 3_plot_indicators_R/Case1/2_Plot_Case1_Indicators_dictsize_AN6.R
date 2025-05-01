# load library
library(R.matlab)
library(ggplot2)
library(cpop)
library(patchwork)
library(grid)
library(gridExtra)
library(ggh4x)
library(tidyverse)

# Import .mat file for AN6 bearing at 0–800 Hz range using AKSVD
base_path <- "_results/_NREL_NEW_CODE/AKSVD/" 
file_names <-"AKSVD_AN6_800_2m3m_345.mat"
file_path <- paste0(base_path, file_names)

# Read the MATLAB .mat file
AN6_AKSVD <- readMat(file_path)

# Extract the necessary matrices from the imported data
data_size <- AN6_AKSVD$vibdata
AKSVD_dists <- AN6_AKSVD$vdist
AKSVD_spars <- AN6_AKSVD$vbests
indices <- 202:1200

# EBIC values for two methods (2m and 3m), normalized by time and number of signals
AKSVD_vEBIC_2m <- AN6_AKSVD$vEBIC[,1]
AKSVD_vEBIC_2m <- AKSVD_vEBIC_2m/(nrow(data_size) * 200)
AKSVD_vEBIC_3m <- AN6_AKSVD$vEBIC[,2]
AKSVD_vEBIC_3m <- AKSVD_vEBIC_3m/(nrow(data_size) * 300)


# Construct a data frame combining all metrics for plotting
AKSVD_test = data.frame(Distance = AKSVD_dists,
                  inds = indices,
                  EBIC.1 = AKSVD_vEBIC_2m,
                  EBIC.2 = AKSVD_vEBIC_3m,
                  Sparsity = AKSVD_spars[2:1000,],
                  method = "AKSVD")


# Convert the data to long format for ggplot2 (grouped by variable and method type)
long_data <- AKSVD_test %>%
  pivot_longer(
    cols = c(Distance.1, Distance.2, Sparsity.1, Sparsity.2, EBIC.1, EBIC.2),
    names_to = c("variable", "type"),
    names_sep = "\\."
  ) %>%
  mutate(
    variable = factor(variable, levels = c("Distance", "EBIC","Sparsity")),
    type = factor(type, levels = c("1", "2"), labels = c("2m", "3m"))
  )

# Define a custom label parser for facets
custom_labeller <- labeller(
  method = label_parsed          
)

# Create a faceted line plot for Distance, EBIC, and Sparsity across index
AN6_plot <-ggplot(long_data, aes(x = inds, y = value, color = variable)) +
  geom_line(data = subset(long_data, variable == "Distance"), aes(x = inds, y = value), color = "darkslategrey") +
  geom_line(data = subset(long_data, variable == "EBIC"), aes(x = inds, y = value), color = "darkslategrey") + 
  geom_line(
    data = subset(long_data, variable == "Sparsity"), 
    aes(x = inds, y = value), 
    alpha = 1,               # Set transparency
    linewidth = 0.3,
    color = "darkslategrey"
  ) +
  facet_grid2(variable ~ type, 
             scales = "free_y",
             labeller = custom_labeller
  ) +
  facetted_pos_scales(
    y = list(
      variable == "EBIC" ~ scale_y_continuous(breaks = seq(from = -2, to = -0.5, by = 0.5)),
      variable == "Sparsity" ~ scale_y_continuous(breaks = c(3, 4, 5)),
      variable == "Distance" ~ scale_y_continuous(breaks = seq(from = 0.2, to = 0.45, by = 0.05)) # Auto-scale for Distance
    )
  ) + 
  labs(x = "Index", y = "") +
  theme(
    strip.placement = "outside",                 # Places strip labels outside the plot
    strip.text.y.left = element_text(size = 10, angle = 0), # Keeps y-axis strip text horizontal
    strip.text.x = element_text(size = 10),      # Adjusts x-axis strip text size
    panel.spacing = unit(0.5, "lines"),          # Adds spacing between panels
    legend.position = "none"                     # Removes the legend
  ) + 
  coord_cartesian(xlim = c(202, 1200)) +  # Set x-axis range
  scale_x_continuous(
    limits = c(202, 1200),  # Set the x-axis limits
    breaks = c(202, 600, 900, 1200)  # Automatically determine intermediate ticks
  ) + 
  geom_point(
    data = subset(long_data, variable == "Distance" & inds == 601), 
    aes(x = inds, y = 0.45), 
    color = "deeppink2",  # Outline color
    fill = "deeppink2",   # Fill color
    size = 2, 
    shape = 25            # Shape that supports fill (triangle)
  ) 


folder_path <- ""
file_path <- "NREL_AN6_AKSVD.pdf"

direct <- paste0(folder_path, file_path)

ggsave(filename = direct, 
       plot = AN6_plot, 
       width = 7, height = 4.5, 
       units = "in")  

