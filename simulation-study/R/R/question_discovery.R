library(dplyr)
library(bnlearn)
source("R/R/metrics.R")

question_discovery <- function(df,
                               expert_model,
                               learner,
                               n_questions_max = 10,
                               verbose = TRUE)
{
  # Perform causal discovery to get initial PDAG.
  learner$discovered <- learner$discover(df)
  
  # Get question set
  question_set <- learner$qs_selector(learner$discovered)
  
  # Create list to store results
  # TODO: Optimize memory allocation
  results <- list(
    discovered = lapply(1:n_questions_max, function(x) NULL),
    selected = lapply(1:n_questions_max, function(x) NULL),
    comparison = lapply(1:n_questions_max, function(x) NULL),
    n_questions = rep(NA, n_questions_max)
  )
  
  # Set initial values
  results$discovered[[1]] <- learner$discovered
  results$comparison[[1]] <- bnlearn::compare(expert_model, learner$discovered)
  results$n_questions[1] <- 0
  
  if (verbose) cat(sprintf("\ni\ttp\tfp\tfn\n"))
  for(i in 1:n_questions_max)
  {
    # Remove previously asked questions from question set.
    question_set <- dplyr::setdiff(question_set, learner$known)
    
    # Break if there are no more questions.
    if(nrow(question_set) == 0) break
    
    # Select questions
    scored_question_set <- do.call(
      learner$scoring_algorithm,
      c(list(question_set = question_set,
             pdag = learner$discovered,
             observations = df),
        learner$scoring_function_args))
    
    # Break if there are no more questions in the scored question set
    if(nrow(scored_question_set) == 0) break
    
    learner$selected <- learner$selection_policy(scored_question_set)
    learner$known <- rbind(learner$known, learner$selected)
    
    
    # Ask expert
    learner$discovered <- ask_expert(expert_model, 
                                     learner$discovered,
                                     learner$selected)
    
    # Compare with experts model
    comparison <- bnlearn::compare(expert_model, learner$discovered)
    
    # Store results
    results$discovered[[i+1]] <- learner$discovered
    results$selected[[i+1]] <- learner$selected
    results$comparison[[i+1]] <- comparison
    results$n_questions[i+1] <- (results$n_questions[i] 
                               + nrow(learner$selected))
    
    if (verbose)
      cat(sprintf("%d\t%d\t%d\t%d\r", i, comparison$tp, comparison$fp, comparison$fn))
  }
  if (verbose)
    cat("\n")
  
  return(results)
}

ask_expert <-function(expert_model, discovered, selected)
{
  dag <- discovered
  arcs(dag) <- directed.arcs(discovered)
  # If answer is yes
  if (nrow(merge(data.frame(arcs(expert_model)), selected)) > 0)
  {
    if (acyclic(set.arc(dag, selected$from, selected$to, check.cycles = FALSE), directed = TRUE))
    {
      discovered <- set.arc(discovered, selected$from, selected$to)
    }
    else
    {
      discovered <- set.edge(discovered, selected$from, selected$to)
    }
  }
  else if (nrow(merge(data.frame(arcs(discovered)), selected)) > 0)
  {
    # Check if arc is undirected, then reverse direction if it doesn't cause a
    # cycle, else just drop arc.
    if (any(duplicated(rbind(undirected.arcs(discovered), c(selected$from, selected$to)))))
    {
      if(acyclic(set.arc(dag, selected$to, selected$from, check.cycles = FALSE), directed = TRUE))
      {
        discovered <- set.arc(discovered, selected$to, selected$from)
      }
      else
      {
        discovered <- drop.arc(discovered, selected$from, selected$to)
      }
    }
    else
    {
      discovered <- drop.arc(discovered, selected$from, selected$to)
    }
  }
  
  return(discovered)
}
