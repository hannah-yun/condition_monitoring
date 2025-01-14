# load library
library(R.matlab)
library(ggplot2)
library(cpop)
library(patchwork)
library(grid)
library(gridExtra)
library(ggh4x)
library(tidyverse)

# import data
load("data/cpop_omp_dist.RData")
load("data/cpop_omp1_dist.RData")
load("data/cpop_omp_ebic.RData")
load("data/cpop_omp1_ebic.RData")

# labeller for omp1(subscript)
custom_labeller <- labeller(
  method = label_parsed          
)

# Create custom labels for the legend
fitted_dist_omp$index <- factor(fitted_dist_omp$index)
fitted_tb_label <- levels(fitted_dist_omp$index)

# generate combined dataset for ebic and distance
swd_dist_total <- rbind(fitted_dist_omp, fitted_dist_omp1, fitted_ebic_omp, fitted_ebic_omp1)


#### plots using facet_grid function ####
swd_facet_grid <- ggplot() +
  geom_segment(data = swd_dist_total, aes(x = x0, y = y0, xend = x1, yend = y1, color = factor(index))) +
  facet_grid2( type~ method, 
             labeller = custom_labeller, scales = "free_y", independent = "y") +  # Use as_labeller with label_parsed
  labs(y = "",
       x = "Year",
       color = "Turbine:") +
  scale_color_manual(
    values = c("#F8766D", "#4DAF4A", "#00BFC4", "#C77CFF", "blue", "#00BFC4"),
    labels = fitted_tb_label,
    guide = guide_legend(nrow = 1)  # Force legend into one row
  ) +
  geom_vline(
    xintercept = c(1.2, 2), 
    color = "gray35", 
    linetype = "dashed"
  ) +
  theme(
    legend.position = "bottom",         # Move legend to the bottom
    legend.title = element_text(size = 10),  # Adjust legend title size
    legend.text = element_text(size = 9),    # Adjust legend text size
    legend.box = "horizontal"          # Ensure horizontal alignment of legend items
  )

#### SAVE PLOTS 

folder_path <- "_plots/"
file_path <- "SWD_PLA_all_1.pdf"

direct <- paste0(folder_path, file_path)

ggsave(filename = direct, 
       plot = swd_facet_grid, 
       width = 7, height = 4.5, 
       units = "in") 


