# load library
library(R.matlab)
library(ggplot2)
library(cpop)
library(patchwork)
library(grid)
library(gridExtra)
library(ggh4x)
library(tidyverse)

# import mat file
an6_omp <- # dataset from Matlab

data_size <- an6_omp$vibdata

omp_dists <- an6_omp$vdist
omp_spars <- an6_omp$vbests
indices <- 202:1200
omp_vEBIC_2m <- an6_omp$vEBIC[,1]
omp_vEBIC_2m <- omp_vEBIC_2m/(nrow(data_size) * 200)
omp_vEBIC_3m <- an6_omp$vEBIC[,2]
omp_vEBIC_3m <- omp_vEBIC_3m/(nrow(data_size) * 300)


# generate df
omp_test = data.frame(Distance = omp_dists,
                  inds = indices,
                  EBIC.1 = omp_vEBIC_2m,
                  EBIC.2 = omp_vEBIC_3m,
                  Sparsity = omp_spars[2:1000,],
                  method = "OMP")


# change it to long data
long_data <- omp_test %>%
  pivot_longer(
    cols = c(Distance.1, Distance.2, Sparsity.1, Sparsity.2, EBIC.1, EBIC.2),
    names_to = c("variable", "type"),
    names_sep = "\\."
  ) %>%
  mutate(
    variable = factor(variable, levels = c("Distance", "EBIC","Sparsity")),
    type = factor(type, levels = c("1", "2"), labels = c("2m", "3m"))
  )

# Create the plot using facet_grid
custom_labeller <- labeller(
  method = label_parsed          
)

# plot all statistics using facet_grid
an6_plot <-ggplot(long_data, aes(x = inds, y = value, color = variable)) +
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
      variable == "EBIC" ~ scale_y_continuous(breaks = c(-2.0, -1.5,-1.0, -0.5)),
      variable == "Sparsity" ~ scale_y_continuous(breaks = c(3, 4, 5)),
      variable == "Distance" ~ scale_y_continuous(breaks = c(0.20, 0.25, 0.30, 0.35,0.35, 0.40,0.45)) # Auto-scale for Distance
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
file_path <- "NREL_an6_omp.pdf"

direct <- paste0(folder_path, file_path)

ggsave(filename = direct, 
       plot = an6_plot, 
       width = 7, height = 4.5, 
       units = "in")  

