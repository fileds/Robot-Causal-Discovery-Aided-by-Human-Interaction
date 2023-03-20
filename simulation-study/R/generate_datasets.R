# Script generating datasets to sample from.
library(bnlearn)

cmdl_args <- commandArgs(trailingOnly = TRUE)
if (length(cmdl_args) < 2)
{
  cat("Missing command line arguments. Given arguments:\n") 
  cat(paste(cmdl_args, collapes = " "))
  cat("\nExpected [n_runs] [batch_size]") 
  cat("\n\nQuitting...\n")
  quit("no", 1, FALSE)
}

n_runs <- as.integer(cmdl_args[1])
batch_size <- as.integer(cmdl_args[2])
bn_paths <- "./bns/"
files <- list.files(path = bn_paths, pattern = "*.rds")
for (file in files)
{
  print(file)
  dataset_label <- unlist(strsplit(file, split='.', fixed=TRUE))[1]
  save_dir <- paste0("./datasets/", dataset_label, "/")
  if (!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE)
  bn <- readRDS(paste0(bn_paths, file))
  set.seed(42)
  for (i in 1:n_runs)
  {
    df <- rbn(bn, batch_size)
    saveRDS(df, file = paste0(save_dir, i, ".rds"))
  }
}
