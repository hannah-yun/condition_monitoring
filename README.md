**Novel indicators for monitoring bearing condition using frequency-domain dictionary learning**

**Overview**

This repository contains R and Matlab code for condition monitoring of bearings in gearboxes using vibration signal analysis. 

**Datasets**

We run experiments on three datasets that are publicly available:
- Case I (abrupt change): Wind turbine gearbox condition monitoring vibration analysis benchmarking dataset 
- Case II (gradual change): Bearing run-to-failure datasets of UNSW
- Case III (combination of abrupt and gradual change): Dataset concerning the vibration signals from wind turbines in Northern Sweden

When downloading each dataset, please use the links in dataset_download file. 

**Requirements**

Ensure you have the following installed:

- MATLAB and R 
- Required Libraries:
- MATLAB: Signal Processing Toolbox
- R: ggplot2, cpop, and tidyverse (if required)

**How to use**

_Step 1: Data preparation_
Prepare the vibration signal data. This step includes importing and reshaping the data into MATLAB. 

_Step 2: Data pre-processing_
Pre-process the dataset from step 1, including filtering for Case III and applying the Welch's method for all 3 cases.

_Step 3: Implementing the DL process to compute three indicators_:
- the dictionary distance between the current estimated dictionary and the dictionary estimated from the initial segments of the signal
- the sparsity levels selected during the DL process
- Extended Bayesian Information Criteria (EBIC) 

_Step 4: Visualise results_
Generate plots for the three indicators by using R.
