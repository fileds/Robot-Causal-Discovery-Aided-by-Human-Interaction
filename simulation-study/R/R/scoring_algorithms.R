library(bnlearn)
library(dplyr)
library(pcalg, include.only = c("opt.target"))

# Edge scoring funciton using OptSingle. Gives score 1 to the edges incident on
# the node with most undirected edges incident on it. See opt.target from
# pcalg for more information.
optsingle_scoring <- function(question_set,
                              pdag,
                              observations = NULL)
{
  target <- opt.target(as.graphNEL(pdag), max.size = 1)


  if (length(target) > 0)
  {
    # Score the undirected edges according to OptSingle.
    question_set <- question_set %>%
      mutate(score = case_when(
      from == target ~ 1,
      TRUE ~ 0))
  }
  else
  {
    question_set <- question_set %>%
      mutate(score = 0)
  }

  return(question_set)
}

# Assign scores to edges based on how well the DAG with that edge fits the data.
hc_scoring <- function(question_set,
                       pdag,
                       observations)
{
  # Compare with directed part of discovered PDAG.
  dag <- pdag
  arcs(dag) <- directed.arcs(pdag)
  initial_score <- score(dag, observations)

  # Score all edges.
  question_set$score <- NA
  for (i in 1:nrow(question_set))
  {
    edge <- question_set[i, 1:2]

    # Set or remove edge
    if (any(duplicated(rbind(arcs(dag), as.matrix(edge)))))
      dag <- drop.edge(dag, edge$from, edge$to)
    else
      dag <- set.arc(dag, edge$from, edge$to, check.cycles = FALSE)

    # Perform check if edge causes a cycle, if that's the case, flip the edge.
    if (acyclic(dag, directed = TRUE))
    {
      question_set[i, ]$score <- score(dag, observations)
    }
    else
    {
      question_set[i, ]$score <- -Inf
    }

    # Reset edges
    arcs(dag) <- directed.arcs(pdag)
  }

  return(question_set)
}

# From ss19-3
assoc_scoring <- function (question_set, pdag, observations, alpha = 0.05)
{
  dag <- pdag
  arcs(dag) <- directed.arcs(pdag)
  question_set$score <- NA
  for (i in 1:nrow(question_set)) {
    n <- question_set[i, 1]
    m <- question_set[i, 2]
    if (!acyclic(set.arc(dag, n, m, check.cycles = FALSE),
                 directed = TRUE)) {
      question_set[i, ]$score <- -Inf
      next
    }
    parents_children <- unique(c(children(pdag, n), parents(pdag, n)))
    association <- 1 - ci.test(x = n, y = m, data = observations)$p.value
    if (m %in% parents_children) {
      score <- 1 - association
    }
    else {
      score <- association
    }
    question_set[i, ]$score <- score
  }
  return(question_set)
}

# Scores edges randomly
random_scoring <- function(question_set, pdag, observations)
{
  question_set$score <- sample(1:nrow(question_set), nrow(question_set))
  return(question_set)
}
