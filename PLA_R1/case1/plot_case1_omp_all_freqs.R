# import package
library(ggplot2)
library(tidyverse)
library(ggh4x)

# load RData
# load the datset derived from Matlab

# data cleaning for plotting
extracted_dfs <- lapply(omp_all, function(x) x[[1]])  # Adjust index as needed

# combine all dfs
omp_all_one <- do.call(rbind, extracted_dfs)
# factor for cut-off frequency (1000, 2500, 3500)
omp_all_one$cutoff_freq <- as.factor(omp_all_one$cutoff_freq)
omp_all_one1<-omp_all_one %>% select(-dist)

omp_all_spars <- omp_all_one1 %>% select(-EBIC) %>% 
  filter(cutoff_freq == 1000)
omp_all_ebic <- omp_all_one1 %>% select(-Sparsity)

# split df for each cutoff frequency
omp_all_ebic_1000 <- omp_all_ebic %>% filter(cutoff_freq==1000)
omp_all_ebic_2500 <- omp_all_ebic %>% filter(cutoff_freq==2500)
omp_all_ebic_3500 <- omp_all_ebic %>% filter(cutoff_freq==3500)

# split cutoff frequency 1000 for each sensor
omp_all_ebic_1000_an5 <- omp_all_ebic_1000 %>% filter(bearings=="AN5")
omp_all_ebic_1000_an6 <- omp_all_ebic_1000 %>% filter(bearings=="AN6")
omp_all_ebic_1000_an7 <- omp_all_ebic_1000 %>% filter(bearings=="AN7")

# normalised ebic value
omp_all_ebic_1000_an5$EBIC <- omp_all_ebic_1000_an5$EBIC/(21*200)
omp_all_ebic_1000_an6$EBIC <- omp_all_ebic_1000_an6$EBIC/(21*200)
omp_all_ebic_1000_an7$EBIC <- omp_all_ebic_1000_an7$EBIC/(26*200)
omp_combined_1000 <- rbind(omp_all_ebic_1000_an5,omp_all_ebic_1000_an6,omp_all_ebic_1000_an7)
omp_all_ebic_2500$EBIC <- omp_all_ebic_2500$EBIC/(65*200)
omp_all_ebic_3500$EBIC <- omp_all_ebic_3500$EBIC/(90*200)

# final ebic df
omp_all_ebic_final <- rbind(omp_combined_1000,omp_all_ebic_2500,omp_all_ebic_3500)

# long type df for sparsity and ebic
omp_all_one_spars <- omp_all_spars %>%
  pivot_longer(cols = c(Sparsity), names_to = "variable", values_to = "value")

omp_all_one_ebic <- omp_all_ebic_final %>%
  pivot_longer(cols = c(EBIC), names_to = "variable", values_to = "value")


custom_label <- as_labeller(c("Distance" = "PLA of Distance", 
                                 "EBIC" = "EBIC", 
                                 "Sparsity" = "Sparsity",
                              "AN5" = "AN5", 
                              "AN6" = "AN6",
                              "AN7" = "AN7"))



omp_all_roi <-ggplot() +
  # Geom_segment for the first dataset
  geom_segment(
    data = fitted_df_omp,
    aes(x = x0, y = y0, xend = x1, yend = y1, color = factor(cutoff_freq))
  ) +
  # Geom_point and Geom_line for the second dataset
  geom_line(
    data = omp_all_one_spars,
    aes(x = time, y = value, color = factor(cutoff_freq)),
    alpha = 1
  ) + 
  geom_line(
    data = omp_all_one_ebic,
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
    data = subset(fitted_df_omp), 
    aes(x = 601, y = 0.73), 
    color = "deeppink2",  # Outline color
    fill = "deeppink2",   # Fill color
    size = 1.7, 
    shape = 25            # Shape that supports fill (triangle)
  )

# save the plot
folder_path <- ""
file_path <- "NREL_omp_3_idf_rois.pdf"

direct <- paste0(folder_path, file_path)

ggsave(filename = direct, 
       plot = omp_all_roi, 
       width = 7, height = 4.5, 
       units = "in")


