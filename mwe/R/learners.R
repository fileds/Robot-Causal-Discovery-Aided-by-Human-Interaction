library(bnlearn)
source("R/question_set_selectors.R")
source("R/scoring_algorithms.R")
source("R/selection_policies.R")

learners <- list(
  pc_hc = list(
    name = "PC HC",
    discover = pc.stable,
    qs_selector = fully_connected_edges,
    scoring_algorithm = hc_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  pc_assoc = list(
    name = "PC Assoc",
    discover = pc.stable,
    qs_selector = fully_connected_edges,
    scoring_algorithm = assoc_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  hc_hc = list(
    name = "HC HC",
    discover = hc,
    qs_selector = fully_connected_edges,
    scoring_algorithm = hc_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  hc_assoc = list(
    name = "HC Assoc",
    discover = hc,
    qs_selector = fully_connected_edges,
    scoring_algorithm = assoc_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  mmhc_hc = list(
    name = "MMHC HC",
    discover = mmhc,
    qs_selector = fully_connected_edges,
    scoring_algorithm = hc_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  mmhc_assoc = list(
    name = "MMHC Assoc",
    discover = mmhc,
    qs_selector = fully_connected_edges,
    scoring_algorithm = assoc_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  pc_random = list(
    name = "PC Random",
    discover = pc.stable,
    qs_selector = fully_connected_edges,
    scoring_algorithm = random_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  hc_random = list(
    name = "HC Random",
    discover = hc,
    qs_selector = fully_connected_edges,
    scoring_algorithm = random_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  mmhc_random = list(
    name = "MMHC Random",
    discover = mmhc,
    qs_selector = fully_connected_edges,
    scoring_algorithm = random_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0))),
  optsingle_pc = list(
    name = "PC OptSingle",
    discover = pc.stable,
    qs_selector = undirected_edges,
    scoring_algorithm = optsingle_scoring,
    scoring_algorithm_args = list(),
    selection_policy = max_policy,
    known = data.frame(from = character(0), to = character(0)))
)
