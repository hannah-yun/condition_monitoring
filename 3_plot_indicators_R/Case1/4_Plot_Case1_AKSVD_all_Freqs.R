# Import package
library(ggplot2)
library(tidyverse)
library(ggh4x)

# load RData
# Please run 4_1 to get all indicators from all the range of the frequency

load("data/_NEW_NREL_AKSVD_1000_2500_3500.RData") # the RAW data from 1
load("data/fitted_df_AKSVD_all.RData") # fitted values from PLA from 4_1 for AKSVD and 4_2 for AKSVD1

# Data cleaning for plotting
extracted_dfs <- lapply(AKSVD_all, function(x) x[[1]])  # Adjust index as needed

# Combine all DFs
AKSVD_all_one <- do.call(rbind, extracted_dfs)

# split the matric

# Factorise the cut-off frequency for distance (1000, 2500, 3500)
AKSVD_all_one$cutoff_freq <- as.factor(AKSVD_all_one$cutoff_freq)
AKSVD_all_one1<-AKSVD_all_one %>% select(-dist)

# Split by indicators
AKSVD_all_spars <- AKSVD_all_one1 %>% select(-EBIC) %>% filter(cutoff_freq == 1000)
AKSVD_all_ebic <- AKSVD_all_one1 %>% select(-Sparsity)

# Split df for each cutoff frequency
AKSVD_all_ebic_1000 <- AKSVD_all_ebic %>% filter(cutoff_freq==1000)
AKSVD_all_ebic_2500 <- AKSVD_all_ebic %>% filter(cutoff_freq==2500)
AKSVD_all_ebic_3500 <- AKSVD_all_ebic %>% filter(cutoff_freq==3500)

# split cutoff frequency 1000 for each sensor
AKSVD_all_ebic_1000_AN5 <- AKSVD_all_ebic_1000 %>% filter(bearings=="AN5")
AKSVD_all_ebic_1000_AN6 <- AKSVD_all_ebic_1000 %>% filter(bearings=="AN6")
AKSVD_all_ebic_1000_AN7 <- AKSVD_all_ebic_1000 %>% filter(bearings=="AN7")

# Normalize EBIC values 
AKSVD_all_ebic_1000_AN5$EBIC <- AKSVD_all_ebic_1000_AN5$EBIC/(21*200)
AKSVD_all_ebic_1000_AN6$EBIC <- AKSVD_all_ebic_1000_AN6$EBIC/(21*200)
AKSVD_all_ebic_1000_AN7$EBIC <- AKSVD_all_ebic_1000_AN7$EBIC/(26*200)
AKSVD_combined_1000 <- rbind(AKSVD_all_ebic_1000_AN5,AKSVD_all_ebic_1000_AN6,AKSVD_all_ebic_1000_AN7)
AKSVD_all_ebic_2500$EBIC <- AKSVD_all_ebic_2500$EBIC/(65*200)
AKSVD_all_ebic_3500$EBIC <- AKSVD_all_ebic_3500$EBIC/(90*200)

# FINAL EBIC df
AKSVD_all_ebic_final <- rbind(AKSVD_combined_1000,AKSVD_all_ebic_2500,AKSVD_all_ebic_3500)

# Pivot to long format
AKSVD_all_one_spars <- AKSVD_all_spars %>%
  pivot_longer(cols = c(Sparsity), names_to = "variable", values_to = "value")

AKSVD_all_one_ebic <- AKSVD_all_ebic_final %>%
  pivot_longer(cols = c(EBIC), names_to = "variable", values_to = "value")

# Custom labels
custom_label <- as_labeller(c("Distance" = "PLA of Distance", 
                              "EBIC" = "EBIC", 
                              "Sparsity" = "Sparsity",
                              "AN5" = "AN5", 
                              "AN6" = "AN6",
                              "AN7" = "AN7"))


# Create a faceted line plot for Distance, EBIC, and Sparsity across index
AKSVD_all_roi <-ggplot() +
  # Geom_segment for the first dataset
  geom_segment(
    data = fitted_df_AKSVD,
    aes(x = x0, y = y0, xend = x1, yend = y1, color = factor(cutoff_freq))
  ) +
  # Geom_point and Geom_line for the second dataset
  geom_line(
    data = AKSVD_all_one_spars,
    aes(x = time, y = value, color = factor(cutoff_freq)),
    alpha = 1
  ) + 
  geom_line(
    data = AKSVD_all_one_ebic,
    aes(x = time, y = value, color = factor(cutoff_freq))
  ) +
  # Facet by rows (Distance, Sparsity, EBIC) and columns (AN5, AN6, AN7)
  facet_grid2(variable ~ bearings, scales = "free", labeller = custom_label) +
  # Custom y-axis ticks for EBIC and Sparsity (only left y-axis shown)
  facetted_pos_scales(
    y = list(
      variable == "EBIC" ~ scale_y_continuous(breaks = c(-2, -1,0, 1,2)),
      variable == "Sparsity" ~ scale_y_continuous(breaks = c(3, 4, 5)),
      variable == "Distance" ~ scale_y_continuous(breaks = c(0.2, 0.4, 0.6)) # Auto-scale for Distance
    )
  ) +
  # Additional customizations
  labs(y = "",
       x = "Index",
       color = "ROI:") +
  scale_color_manual(values = c("1000" = "#1b9e77", "2500" = "#d95f02", "3500" = "#7570b3"),  # Custom colors
                     labels = c("1000" = "0-800 Hz: AN5, AN6 \n0-1,010 Hz: AN7", "2500" = "0-2,500 Hz", "3500" = "0-3,500 Hz")) +
  theme(
    strip.text.x = element_text(size = 9),
    strip.text.y = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    legend.position = "bottom",  # Move legend to bottom
    legend.title = element_text(size = 10),  # Adjust legend title size (optional)
    legend.text = element_text(size = 9)
  )  +
  coord_cartesian(xlim = c(202, 1200)) +  # Set x-axis range
  scale_x_continuous(breaks = c(202,400,600,800,1000,1200)) + # Adjust x-axis ticks
  geom_point(
    data = subset(fitted_df_AKSVD), 
    aes(x = 601, y = 0.73), 
    color = "deeppink2",  # Outline color
    fill = "deeppink2",   # Fill color
    size = 1.7, 
    shape = 25            # Shape that supports fill (triangle)
  )

# save the plot
folder_path <- ""
file_path <- "NREL_AKSVD_3_idf_rois.pdf"

direct <- paste0(folder_path, file_path)

ggsave(filename = direct, 
       plot = AKSVD_all_roi, 
       width = 7, height = 4.5, 
       units = "in")


