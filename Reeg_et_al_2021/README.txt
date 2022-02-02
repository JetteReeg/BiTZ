This is the source code for running and analysing the simulations of the manuscript "Agricultural buffer zone thresholds to safeguard functional bee diversity:  Insights from a community modelling approach" by Reeg et al. (2021). 
All necessary files and scripts are included.
Author: Jette Reeg

# Preparations
Before you start the simulations, you need to compile the model code on your system (runs under Windwos + Unix OS) in each of the subdirectories. 
Please use the code in the file Scripts/BuildBiTZ.txt for compiling.

# Running BiTZ
The R script Scripts/(0) RunBiTZHPC.R runs the complete set of simulations. It is set for parallel computing on 10 cores. You might need to change the number of cores according to your technical resources.

# Analysing the simulations
The output of the simulations was analysed running the follow scripts in the given order:
1. (0) Detect_patches.R: Detection of all arable patches and forest/grassland patches neighboring arable patches
2. (1) Aggregating_simulation_results.R: Aggregation of all simulations
3. (2) Final_figures_without_Fig3.R: Generates Figures 2 a-d
4. (3) Calculate_resource_uptake.R: Calculates the resource uptakes in each cell in year 49 for generating Figure 3
5. (4) Final_Fig3_allLandscapes.R: Generates Figure 3 of the main manuscript, incl. all simulated landscapes
6. (5) Additional_graphics_appendix.R: Generates figures shown in the appendix.

# Local sensitivity analysis

As described in the manuscript, we conducted a local sensitivity analysis. The script (6) Generate_local_sensitivity_analysis.R creates all simulation files needed for the sensitivity analysis. 
The results were aggregated using the script (7) Aggregating_local_sensitivity_analysis.R 
and the figures shown in the main manuscript and the appendix were generated using the script (8) Figures_local_sensitivity_analysis.R.



