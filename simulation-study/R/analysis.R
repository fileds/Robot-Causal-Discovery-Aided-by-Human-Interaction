library(tidyverse)
library(xtable)
rm(list = ls())
source("R/R/tableau.R")
source("R/R/utils.R")

# Paths to directories
dir_paths <- c("./results/example/asia/500/")

# Quick plots using ggplot
create_plot <- function(dir_path, metric, y_label, ss, n_runs = 500, ribbon = FALSE, save = FALSE, verbose = TRUE)
{
  if (verbose)
    print(paste0(metric, "-", dir_path))
  files <- list.files(path = dir_path, pattern ="*.rds")
  df_load <- data.frame()
  for (f in files)
  {
    if (verbose)
      print(f)
    df <- readRDS(paste0(dir_path, f))
    df_load <- rbind(df_load, df)
  }
  dir_info <- unlist(strsplit(dir_path, split = "/"))
  bn_label <- dir_info[4]
  batch_size <- dir_info[5]
  if (verbose)
    print(paste(bn_label, batch_size))

  # Averaging over runs
  df <- df_load %>%
    group_by(learner, n_questions) %>%
    summarize(
      n_obs = n(),
      y = mean(get(metric)),
      se = sd(get(metric)) / sqrt(n_obs),
      lower = y - 1.96 * se,
      upper = y + 1.96 * se) %>%
    filter(n_obs > n_runs / 10) %>%
    ungroup()

  df_points <- df %>%
    group_by(learner) %>%
    filter(n_questions %in% c(0, 5, 10, 15, 20, 25, tail(n_questions, 1)))


  plt <- df %>%
    ggplot(aes(x = n_questions, y = y, color = learner, fill = learner)) +
    geom_line(linewidth = 0.8) +
    {if(ribbon) geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, linewidth = 0)} +
    geom_errorbar(data = df_points, aes(ymin = lower, ymax = upper),
               alpha = 1,
               linewidth = 0.5,
               width = 0.5) +
    scale_color_manual(name = "Learner", values = unlist(tableau10)) +
    scale_fill_manual(name = "Learner", values = unlist(tableau10)) +
    scale_shape_discrete(name = "Learner") +
    labs(x = "Cumulative Questions",
         y = y_label) +
    ggtitle(paste(bn_label, batch_size)) +
    theme_bw() +
    theme(text = element_text(size = 12))

  ggsave(filename = "example.pdf", width = 16, height = 8, units = "cm")
}
create_plot(dir_paths[1], n_runs = 10, metric = "shdem", y_label = "Relative SHD-EM", ss = "example", ribbon = FALSE, save = TRUE)

# Creating table with top implementations from each starting point.
create_table <- function(dir_path, metric = "shdem", n_runs = 500)
{
  print(paste0(dir_path))
  #files <- list.files(path = dir_path, pattern = paste0("*-", sample_size, "obs*"))
  files <- list.files(path = dir_path, pattern ="*.rds")
  df_load <- data.frame()
  for (f in files)
  {
    #print(f)
    df <- readRDS(paste0(dir_path, f))
    df_load <- rbind(df_load, df)
  }
  info <- unlist(strsplit(dir_path, split = "/"))
  bn_label <- info[4]
  batch_size <- info[5]
  print(length(unique(df_load$learner)))

  # Averaging over runs
  df <- df_load %>%
    group_by(learner, n_questions) %>%
    summarize(
      n_obs = n(),
      y = mean(get(metric)),
      se = sd(get(metric)) / sqrt(n_obs)) %>%
    summarize(
      start = first(y),
      start_ci = 1.96 * first(se),
      #five = nth(y, 6),
      #five_ci = 1.96 * nth(se, 6),
      #diff_five = nth(y, 6) - first(y),
      #fifteen = nth(y, 16),
      #fifteen_ci = 1.96 * nth(se, 16),
      #diff_fifteen = nth(y, 16) - first(y),
      finish = last(y),
      finish_ci = 1.96 * last(se),
      diff_finish = last(y) - first(y),
      diff_finish_ci = 1.96 * sd(last(se) - first(se))) %>%
    mutate(
      bn_label = bn_label,
      batch_size = batch_size) %>%
    mutate(
      discovery_algorithm = case_when(
        grepl("MMHC", learner) ~ "MMHC",
        TRUE ~ "PC")) %>%
    group_by(discovery_algorithm) %>%
    filter(finish == min(finish, na.rm = TRUE)) %>%
    #filter(start == min(start, na.rm = TRUE)) %>%
    #group_by(bn_label, batch_size) %>%
    #filter(finish == min(finish, na.rm = TRUE)) %>%
    #filter(five + fifteen + finish == min(five + fifteen + finish, na.rm = TRUE)) %>%
    ungroup() %>%
    select(c(bn_label, batch_size, learner, start, start_ci, finish, finish_ci, diff_finish))

  return(df)
}

tibl <- create_table(dir_paths[1], n_runs = 10)
write_csv(tibl, "example")
