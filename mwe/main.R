# Minimum Working example of the Q-SELECT algorithm. 
library(bnlearn)
library(dplyr)
rm(list = ls())
source("R/learners.R")
source("R/utils.R")

# Loading the ASIA data from bnlearn
data(asia)
# Subset data
df <- asia[1:500, ]
# True graph over variables in ASIA
true = model2network("[A][S][T|A][L|S][B|S][D|B:E][E|T:L][X|E]")
# Visualize the true graph
graphviz.plot(true)

# Using the PC HC learner defined in R/learners.R.
# The learner will try to learn the causal graph from data and from questions.
learner <- learners$pc_hc

# Make initial discovery based on data
discovered <- learner$discover(df)
# Compare discovered graph with true graph.
graphviz.compare(true, discovered, diff.args = list(show.first = F))

# Get question set, in this example all possible edges.
question_set <- learner$qs_selector(discovered)
head(question_set)

# Score question set
scored_question_set <- learner$scoring_algorithm(question_set, discovered, df)
head(arrange(scored_question_set, desc(score)))

# Select edge for questioning, in this example the highest scoring edge (i.e.
# the edge most likely to exist according to data).
selected_edge <- learner$selection_policy(scored_question_set)
selected_edge
     
# Ask oracle about edge using ask_expert defined in R/question_discovery.R
answer <- ask_expert(true, discovered, selected_edge)
answer

# Incorporate answer in discovered DAG
discovered1 <- incorporate_answer(discovered, selected_edge, answer)
# Compare with previous discovered graph and true graph
graphviz.compare(discovered, discovered1, diff.args = list(show.first = F))
graphviz.compare(true, discovered1, diff.args = list(show.first = F))  

# Remove edge from question set.
learner$known <- rbind(learner$known, selected_edge)
question_set <- dplyr::setdiff(question_set, learner$known)

# Score the question set based on the new graph.
scored_question_set <- learner$scoring_algorithm(question_set, discovered1, df)
head(arrange(scored_question_set, desc(score)))

# Select edge for questioning, in this example the highest scoring edge (i.e.
# the edge most likely to exist according to data).
selected_edge <- learner$selection_policy(scored_question_set)
selected_edge
     
# Ask oracle about edge using ask_expert defined in R/question_discovery.R
answer <- ask_expert(true, discovered1, selected_edge)
answer

# Incorporate answer in discovered DAG
discovered2 <- incorporate_answer(discovered1, selected_edge, answer)
# Compare with previous discovered graph and true graph
graphviz.compare(discovered1, discovered2, diff.args = list(show.first = F))
graphviz.compare(true, discovered2, diff.args = list(show.first = F))  

# And continue...
