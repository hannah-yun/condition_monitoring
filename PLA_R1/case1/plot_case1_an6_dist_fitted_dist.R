# import library
library(R.matlab)

# import OMP
an6_omp <- # data from Matlab

omp_dists <- an6_omp$vdist
omp_spars <- an6_omp$vbests
indices <- 202:1200
omp_vEBIC <- an6_omp$vEBIC

# import OMP1
an6_omp1 <- readMat("data/omp1_an6_800_2m3m_345.mat")

omp1_dists <- an6_omp1$vdist
omp1_spars <- an6_omp1$vbests
indices <- 202:1200
omp1_vEBIC <- an6_omp1$vEBIC


#distances
omp_an6_total <- data.frame(time = indices,
                            dist = omp_dists[,1], 
                            method = "OMP")
omp1_an6_total <- data.frame(time = indices,
                            dist = omp1_dists[,1],
                            method = "OMP[1]")

an6_total <- rbind(omp_an6_total, omp1_an6_total)


omp_an6_fit <- cpop(y = omp_an6_total$dist, x = omp_an6_total$time, minseglen = 0.1)
omp1_an6_fit <- cpop(y = omp_an6_total$dist, x = omp_an6_total$time, minseglen = 0.1)

fitted_omp <- fitted(omp_an6_fit)
fitted_omp$method = "OMP"
fitted_omp1 <- fitted(omp1_an6_fit)
fitted_omp1$method = "OMP[1]"



# marker 
marker_data <- data.frame(
  x = 601,
  y = 0.44,
  method = c("OMP", "OMP[1]")
)


# OMP1 
custom_labeller <- labeller(
  method = label_parsed          
)

# Plot with facet_grid
an6_dist_fit <- ggplot() +
  # Scatter plot for each method
  geom_point(data = rbind(omp_an6_total, omp1_an6_total), 
             aes(x = time, y = dist), 
             color = "#00BFC4", size = 2, alpha = 0.4) +
  # Segment plot for fitted values
  geom_segment(data = rbind(fitted_omp, fitted_omp1), 
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




# save 
folder_path <- ""
file_path <- "NREL_AN6_dist_pla.pdf"

direct <- paste0(folder_path, file_path)

ggsave(filename = direct, 
       plot = an6_dist_fit, 
       width = 8.5, height = 4, 
       units = "in")

