# Simulation study
The simulation study was performed on the HPC at [HPC2N](https://www.hpc2n.umu.se/). Therefore the R scripts are meant to be called from a bash terminal. 

This is the code used to generate the simulation study, completely unmodified, with the main purpose of repruducibility. Thus the commenting and structure of the code is not optimized for understanding. The intention is to upload a MWE of the main ideas behind the study in a separate folder.

## Dependencies
The repo contains an `renv.lock`-file. Use `renv` to get the correct dependencies by following the instructions at [https://rstudio.github.io/renv/articles/renv.html#reproducibility](https://rstudio.github.io/renv/articles/renv.html#reproducibility).

## Example
To reproduce an example of the simulation study, in bash, run 

```bash
. example.sh
```

## Full simulation study 
See the script `full_study.sh`. Please note that the file is not intended for running on a personal computer as the simulation study takes a lot of time to complete when not parallelized.
