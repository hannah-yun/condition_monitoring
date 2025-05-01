**Novel indicators for monitoring bearing condition using frequency-domain dictionary learning**

**Overview**

This repository contains R and Matlab code for condition monitoring of bearings in gearboxes using vibration signal analysis. 

**Datasets**

We run experiments on three datasets that are publicly available, which can be downloaded from each link:
- Case I (abrupt change): Wind turbine gearbox condition monitoring vibration analysis benchmarking dataset (link: https://data.openei.org/submissions/738)
- Case II (gradual change): Bearing run-to-failure datasets of UNSW (link: https://data.mendeley.com/datasets/h4df4mgrfb/3)
- Case III (combination of abrupt and gradual change): Dataset concerning the vibration signals from wind turbines in Northern Sweden (link: https://ltu.diva-portal.org/smash/record.jsf?pid=diva2%3A1244889&dswid=-9007)


**Requirements**

Ensure you have the following installed:
- MATLAB and R 
- Required Libraries:
- MATLAB: Signal Processing Toolbox, The DL Toolbox
- R: ggplot2, cpop, and tidyverse (if required)

In order to run dictionary learning, we use a function called DL in the DL Toolbox, which can be downloaded from https://github.com/dl-book. Please download the DL folder in the repository.

**How to run the Code**

_Step 1: Download datasets_
Download the dataset from the websites listed in the above for Cases I, Case II, or Case III.

_Step 2: Data pre-processing_
- Open the `1_data_pre-processing` folder corresponding to the appropriate case (Case I, Case II, or Case III).
- First reshape the data, then proceed with the Welch method. For Case III, the filtering processes are included in the reshaping MATLAB file.

_Step 3: Implementing the DL process to compute three indicators_
- Select either `2_1_run_AKSVD_matlab` or `2_2_run_AKSVD1_matlab` depending on sparse coding method. To run the AKSVD method, please download the MATLAB package from [https://github.com/dl-book].
- When running the DL algorithm, the main script begins with `main_DL_`. Please run this matlab file. All necessary functions are provided separately in each folder and shared file folder.

_Step 4: Visualise results_
To plot the indicators—dictionary distance, sparsity, and EBIC--open the `3_indicators_R` folder. You can choose a folder based on the specific case. Case I and Case III compute their values using Piecewise Linear Approximation (PLA), while Case II uses averaging. Each folder contains several R scripts:
- Scripts for creating data frames from MATLAB objects
- Various plotting scripts. Each case has different plots used in the paper, so you can select the ones you'd like to simulate. These scripts are prefixed with `1_`, `2_`, `3_`, etc. Each R script includes a description of its purpose.
