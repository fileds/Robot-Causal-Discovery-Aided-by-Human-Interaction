source("R/R/metrics.R")
reverse_edge <- function(edge)
{
  colnames(edge) <- rev(colnames(edge))
  return(edge)
}


get_data_frame <- function(results, expert_model, learner_name)
{
  df <- data.frame()
  for (i in 1:length(results))
  {
    for (j in 1:length(results[[i]]$discovered))
    {
      discovered <- results[[i]]$discovered[[j]]
      if (is.null(discovered)) break
      n_questions <- results[[i]]$n_questions[[j]]
      
      evaluation <- evaluate(expert_model, discovered)
      evaluation <- cbind(data.frame(
        run = i,
        iteration = j,
        n_questions = n_questions,
        learner = learner_name,
        evaluation))
      df <- rbind(df, evaluation)
    }
  }
  
  return(df)
}

# Wrapper for parallelization
question_discovery_wrapper <- function(run, data_dir, batch_size, expert_model, 
                                       learner, n_questions_max, 
                                       verbose = FALSE)
{
  cat(paste0("Run ", run, "\n"))
  
  # Load df object into environment
  df <- readRDS(file = paste0(data_dir, run, ".rds"))
  
  df <- df[1:batch_size, ]
  
  results <- question_discovery(
    df,
    expert_model,
    learner,
    n_questions_max = n_questions_max,
    verbose = verbose)
  
  return(results)
}

# Create RDS file from multiple simulations
create_rds <- function(dir_path)
{
  t_start <- Sys.time()
  files <- list.files(path = dir_path, pattern = "*.RData")
  df_load <- data.frame()
  for (f in files)
  {
    load(paste0(dir_path, f))
    df_load <- rbind(df_load, results_df)
  }
  
  df_load <- df_load %>% 
    mutate(learner = case_when(
      learner == "PC Random" ~ "PC Rndm",
      learner == "MMHC Random" ~ "MMHC Rndm",
      TRUE ~ learner)) %>%
    mutate(shdem = shd_edge_marks / (2 * nrow(expert_model$arcs)))
  
  saveRDS(df_load, file = paste0(dir_path, "df_load.rds"))
}
