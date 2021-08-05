This is the source code for the running and analysing the simulations of the manuscript "Agricultural buffer zone thresholds to safeguard functional bee diversity:  Insights from a community modelling approach" by Reeg et al. (2021). 
All necessary files and scripts are included.
Author: Jette Reeg

# Preparations
Before you start the simulations, you need to compile the model code on your system (runs under Windwos + Unix OS) in each of the subdirectories. 
Please use the code in the file BuildBiTZ for compiling.

# Running BiTZ
The R script RunBiTZ1.R runs the complete set of simulations. It is set for parallel computing on 10 cores. You might need to change the number of cores according to your technical resources.
The script can be started via the Shell script RunBiTZ1.sh/.bat (change it to .bat if you are running the simulations on a Windows system)

# Analysing the simulations
Raw data are summarized in the scripts DetectPatches.R, First_grouping_simulation_results.R and Calclate_resource_uptake.R. 
Graphics according to the manuscript can be produced by running the scripts Final_Graphics_without_Fig6.R and Final_Fig6_allLandscapes.
The Shell script RunAnalyses.sh/.bat (change the extension according to your system) starts all R analyses in sequence. You might need to change the system path for R

