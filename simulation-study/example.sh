#!/bin/bash
if [ ! -d "datasets" ]; then
  echo "Generating datasets"
  mkdir datasets
  Rscript R/generate_datasets.R 10 500
fi
# Command line arguments
# [Simulation study label] [Network label] [Learner] [N runs] [N questions max] [Batch size] [N cores]
if [ ! -d "results" ]; then
  echo "Running simulations"
  Rscript R/simulation_study.R example pc_hc asia 10 30 500 1
  Rscript R/simulation_study.R example pc_assoc asia 10 30 500 1
  Rscript R/simulation_study.R example mmhc_hc asia 10 30 500 1
  Rscript R/simulation_study.R example mmhc_assoc asia 10 30 500 1
  Rscript R/simulation_study.R example pc_random asia 10 30 500 1
  Rscript R/simulation_study.R example mmhc_random asia 10 30 500 1
  Rscript R/simulation_study.R example optsingle_pc asia 10 30 500 1
echo "Done"
fi

if [ ! -f "example.pdf" ]; then
  echo "Creating plot and csv"
  Rscript R/analysis.R
fi

