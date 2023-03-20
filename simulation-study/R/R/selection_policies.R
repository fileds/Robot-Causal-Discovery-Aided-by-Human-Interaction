# Selects the maximum score
max_policy <- function(scored_question_set)
{
  idx <- base::which.max(scored_question_set$score)
  selection <- scored_question_set[idx, 1:2]
  return(selection)
} 
