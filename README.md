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

In order to run dictionary learning, we use a function called DL, which can be downloaded from https://github.com/dl-book. Please download the DL folder in the repository.

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
