#!/bin/bash
if [ true ]; then
  echo "OBS! This is a script to show how to run the full study. It is not intended for running."
  return 0
fi
# Command line arguments
# [Simulation study label] [Network label] [Learner] [N runs] [N questions max] [Batch size] [N cores]
declare -a datasets=("asia" "sachs" "survey" "child" "insurance" "mildew" "alarm" "barley" "hailfinder")
declare -a learners=("pc_hc" "pc_assoc" "mmhc_hc" "mmhc_assoc" "pc_random" "mmhc_random" "optsingle_pc")
declare -a batch_sizes=("500" "1000" "1500" "3000")
for i in "${datasets[@]}"
do
    for j in "${learners[@]}"
    do
        for k in "${batch_sizes[@]}"
        do
            Rscript R/simulation_study.R full_study $j $i 500 30 $k 1
        done
    done
done

declare -a datasets=("mildew" "alarm" "barley" "hailfinder")
declare -a batch_sizes=("5000")
for i in "${datasets[@]}"
do
    for j in "${learners[@]}"
    do
        for k in "${batch_sizes[@]}"
        do
            Rscript R/simulation_study.R full_study $j $i 500 30 $k 1
        done
    done
done
