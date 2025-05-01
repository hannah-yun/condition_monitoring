# load library
library(R.matlab)
library(ggplot2)
library(cpop)
library(patchwork)
library(grid)
library(gridExtra)
library(ggh4x)
library(tidyverse)

# This R script presents the PLA values of dictionary distance and EBIC for AKSVD and AKSVD1 in a single plot.

# Import data: in a situation where you saved results from 2_1 to 2_4 as a Rdata
load("cpop_AKSVD_dist.RData")
load("cpop_AKSVD1_dist.RData")
load("cpop_AKSVD_ebic.RData")
load("cpop_AKSVD1_ebic.RData")

# labeller for AKSVD1(subscript)
custom_labeller <- labeller(
  method = label_parsed          
)

# Create custom labels for the legend
fitted_dist_AKSVD$index <- factor(fitted_dist_AKSVD$index)
fitted_tb_label <- levels(fitted_dist_AKSVD$index)

# generate combined dataset for ebic and distance
swd_dist_total <- rbind(fitted_dist_AKSVD, fitted_dist_AKSVD1, fitted_ebic_AKSVD, fitted_ebic_AKSVD1)


#### plots using facet_grid function ####
plot_case3_dist_ebic <- ggplot() +
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

ggsave(filename = file_path, 
       plot = plot_case3_dist_ebic, 
       width = 7, height = 4.5, 
       units = "in") 


