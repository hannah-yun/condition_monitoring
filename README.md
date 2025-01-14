**Condition monitoring for vibration signals in bearings gearboxes**

**Overview**
This repository has R and Matlab code, data, and resources for condition monitoring bearings in gearboxes using vibration signal analysis. It aims to identify faults and assess the conditions in the wind turbines with a Dictionary Learning algorithm and various simplification techniques when plotting the results, such as Piecewise Linear Approximation and averaging the value. Moreover, we would like to utilise this analysis for real-time monitoring. 

**Datasets**
There are three datasets that are publicly available for research purposes:
- Case1(abrupt change): Wind turbine gearbox condition monitoring vibration analysis benchmarking dataset 
- Case2 (gradual change): Bearing run-to-failure datasets of UNSW
- Case3 (combination of abrupt and gradual change): Dataset concerning the vibration signals from wind turbines in northern Sweden

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
Pre-process the dataset from step 1, including filtering for case 3 and applying the Welch method for all 3 cases.

_Step 3: Implementing the DL process to find three indicators_
We use two sparse coding methods: Orthogonal Matching Pursuit and Orthogonal Matching Pursuit in the L_1 norm (Manhattan distance). Here, we use three indicators: 
- the dictionary distance between the present estimated dictionary and the estimated dictionary from random generation.
- the sparsity levels that are selected during the DL process
- Extended Bayesian Information Criteria (EBIC) that evaluates how well the dictionary fits the dictionary. 

_Step 4: Visualise results_
Generate plots for the time domain with three indicators with R.
