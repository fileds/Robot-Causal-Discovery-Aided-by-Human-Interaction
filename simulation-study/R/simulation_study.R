# Timing
t1 <- Sys.time()

library(bnlearn)
library(dplyr)
library(parallel)
source("R/R/question_discovery.R")
source("R/R/question_set_selectors.R")
source("R/R/scoring_algorithms.R")
source("R/R/selection_policies.R")
source("R/R/learners.R")
source("R/R/utils.R")


# Random seed
set.seed(42)

# Command line arguments
# Specification
# [Simulation study label] [Bayesian network] [learner] [N runs] [N questions max] [batch size] [N cores (only checks if one)]
cmdl_args <- commandArgs(trailingOnly = TRUE)
if (length(cmdl_args) < 7)
{
  cat("Missing command line arguments. Given arguments:\n\t ") 
  cat(paste(cmdl_args, collapes = " "))
  cat("\nQuitting...\n")
  quit("no", 1, FALSE)
}

# Parsing arguments
sim_study_label <- cmdl_args[1]
learner_label <- cmdl_args[2]
bn_label <- cmdl_args[3]
bn_file <- paste0("bns/", bn_label, ".rds")
data_dir <- paste0("datasets/", bn_label, "/")
n_runs <- as.integer(cmdl_args[4])
n_questions_max <- as.integer(cmdl_args[5])
batch_size <- as.integer(cmdl_args[6])
n_cores <- as.integer(cmdl_args[7])
n_cores <- ifelse(n_cores < 8, n_cores, detectCores())

cat("Given command line arguments:\n\t") 
cat(paste(cmdl_args, collapes = " "))
cat("\n\n")

# Load data
# Loads bn and data frame to environment
bn <- readRDS(bn_file)
expert_model = model2network(modelstring(bn))

# Select learner
learner = learners[[learner_label]]

# Check if directory exists for saving, otherwise create
save_dir <- paste0("results/", sim_study_label, "/", bn_label, "/", batch_size, "/")
if (!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE)
    
# Get starting time of simulation for simulation label
start_time <- format(Sys.time(), "%Hh%Mm%Ss")

# Parallel setup

# Initiate cluster
if (n_cores > 1)
{
  cl <- makeCluster(n_cores)
  
  # Load libraries and source on clusters
  tmp <- clusterCall(cl, function() {
    library(bnlearn)
    library(dplyr)
    library(pcalg)
    source("R/R/question_discovery.R")
    source("R/R/question_set_selectors.R")
    source("R/R/scoring_algorithms.R")
    source("R/R/selection_policies.R")
    source("R/R/utils.R")
    }
  )
  
  # Perform simulation study
  results <- parLapply(
    cl,
    1:n_runs, 
    question_discovery_wrapper, 
    data_dir = data_dir,
    batch_size = batch_size,
    expert_model = expert_model,
    learner = learner,
    n_questions_max = n_questions_max)
  
  stopCluster(cl)
} else
{
  results <- lapply(
    1:n_runs, 
    question_discovery_wrapper, 
    data_dir = data_dir,
    batch_size = batch_size,
    expert_model = expert_model,
    learner = learner,
    n_questions_max = n_questions_max)
}


# Convert results to a data frame.
results_df <- get_data_frame(results, expert_model, learner$name)
results_df <- results_df %>% 
  mutate(learner = case_when(
    learner == "PC Random" ~ "PC Rndm",
    learner == "MMHC Random" ~ "MMHC Rndm",
    TRUE ~ learner)) %>%
  mutate(shdem = shd_edge_marks / (2 * nrow(expert_model$arcs)))

# Saving all results
save_path <- paste0(
  save_dir, 
  paste(
    learner_label,
    bn_label,
    n_runs,
    "runs",
    n_questions_max,
    "maxq",
    batch_size,
    "batch_size",
    start_time,
    sep = "-")
)
save.image(file = paste0(save_path, ".RData"))
saveRDS(results_df, file = paste0(save_path, ".rds"))
cat(paste0("Saved image in ", save_path, "\n"))

sim_time <- Sys.time() - t1
cat("Finished simulation in\n")
print(sim_time)