library(dplyr)
library(bnlearn)

#' Calculates the my_score score of two BNs.
#' 
#' my_score is 0 for no edges and adds -1 for each wrongly identified dependence
#' or directed edge. It adds 2 for a correct dependence and 1 for a correct 
#' directed edge. So an undirected edge gets the score 1 while a correct edge
#' gets the score 3 and an either undirected or directed wrong edge gets the 
#' score -1. The score is scaled so it ranges between - \infty and 1.
#' TODO: Update range to get correct lower bound (n true independencies / n true dependencies)
#' 
#' The reference point is knowing nothing, i.e. the edge set is the empty set, 
#' which has a score of 0. Then the score considers only wrong edges as worse
#' than knowing nothing, while knowing something correct is more better than
#' how worse it is to know something wrong.
my_score <- function(true, discovered)
{
  comparison_skeleton <- bnlearn::compare(skeleton(true), skeleton(discovered))
  comparison_directed <- bnlearn::compare(true, discovered)
  
  # Comparison of independence relations
  tp_skeleton <- comparison_skeleton$tp # # correctly identified dependencies
  #fp_skeleton <- comparison_skeleton$fp # # of incorrectly identified dependencies
  #fn_skeleton <- comparison_skeleton$fn # # of not identified dependencies
  # Should there be TN?
  
  # Comparison of directions
  tp_directed <- comparison_directed$tp # # of correctly identified causal relationships
  fp_directed <- comparison_directed$fp # # of incorrectly identified causal relationships
  #fn_directed <- comparison_directed$fn # # of not identified causal relationships
  
  # Arc weight
  n_edges <- nrow(true$arcs)
  w_a <- 1 / n_edges
  # TODO: Recunstruct the score to
  #   1. Count the wrong dependencies and wrong directions separately
  #   2. See if you can make it an intuitive reasoning for when half the edges are found.
  my_score <- (1 / 3) * (2 * w_a * tp_skeleton + w_a * tp_directed - 1 * w_a * fp_directed)
  
  return(my_score)
}

my_shd <- function(true, discovered)
{
  mys <- my_score(true, discovered)
  return(nrow(true$arcs) - mys* nrow(true$arcs))
}

direct_bn <- function(bn)
{
  directed_bn <- bn
  arcs(directed_bn) <- directed.arcs(bn)
  return(directed_bn)
}

shd_edge_marks <- function(true, discovered)
{
  # Compare skeletons
  skeleton_comparison <- bnlearn::compare(skeleton(true), skeleton(discovered))
  
  # Compare directed edges
  directed_comparison <- bnlearn::compare(direct_bn(true), 
                                          direct_bn(discovered))
  
  return(skeleton_comparison$fp + skeleton_comparison$fn 
         + directed_comparison$fp + directed_comparison$fn)
}

#' Calculates number of edge flips between two DAGs.
#' 
#' Note: An undirected edge counts as an edge flip from the truth.
#' 
#' @param current Currently discovered DAG. 
#' @param true True DAG underlying the DGP.
#' 
#' @return Number of edge flips between true and discovered.
calculate_n_edge_flips <- function(discovered, true)
{
  # Take the edges that are in discovered but not in true
  diff <- dplyr::setdiff(as.data.frame(discovered$arcs), 
                         as.data.frame(true$arcs))
  
  # Reorient edges in diff by switching order of column names
  names(diff) <- rev(names(diff))
  
  # Take the union of true and diff
  flipped <- dplyr::intersect(diff, as.data.frame(true$arcs))
  
  return(nrow(flipped))
}


#' Compares two graphs using different metrics.
#' 
#' Source https://arxiv.org/abs/1905.12666v1
#' 
#' @param discovered Currently discovered BN.
#' @param true True DAG underlying the DGP.
#' 
#' @return A data frame of one row corresponding to the current iteration.
evaluate <- function(true, discovered)
{
  # True positives, false positives, false negatives
  comparison <- bnlearn::compare(true, discovered)
  tp <- comparison$tp
  fp <- comparison$fp
  fn <- comparison$fn
  
  # Skeleton comparison
  # Compare skeletons
  skeleton_comparison <- bnlearn::compare(skeleton(true), skeleton(discovered))
  skel_tp <- skeleton_comparison$tp
  skel_fp <- skeleton_comparison$fp
  skel_fn <- skeleton_comparison$fn
  
  # Compare directed edges
  directed_comparison <- bnlearn::compare(direct_bn(true), 
                                          direct_bn(discovered))
  dir_tp <- directed_comparison$tp
  dir_fp <- directed_comparison$fp
  dir_fn <- directed_comparison$fn
  
  # SHD edge marks, Colombo et al. 2014
  shd_em <- shd_edge_marks(true, discovered)
  
  # Precision
  if (tp + fp == 0) precision <- 0 else precision <- tp / (tp + fp)
  
  # Recall
  recall <- tp / (tp + fn)
  
  # Structural Hamming Distance
  shd <- bnlearn::shd(discovered, true)
  
  # DAG Dissimilarity Metric (DDM)
  r <- calculate_n_edge_flips(discovered, true)
  n_arcs <- nrow(true$arcs)
  ddm <- (tp + r/2 - fn -fp) / n_arcs
  
  # F1-score
  if (recall + precision == 0) f1 <- 0 else f1 <- (2 * recall * precision) / (recall + precision)
  
  # Balanced Scoring Function (BSF)
  w_a <- n_arcs
  n_nodes <- length(true$nodes)
  w_i <- 0.5 * (n_nodes * (n_nodes - 1)) - n_arcs
  # All independencies minus the negative false independencies
  t_n <- w_i - fn
  bsf <- 0.5 * (tp / w_a + t_n / w_i - fp / w_i - fn / w_a)
  
  # my_score  
  my_score <- my_score(true, discovered)
  
  # my_shd
  my_shd <- nrow(true$arcs) - my_score * nrow(true$arcs)
  
  
  return(data.frame(
      shd = shd,
      shd_edge_marks = shd_em,
      tp = tp,
      fp = fp,
      fn = fn,
      skel_tp = skel_tp,
      skel_fp = skel_fp,
      skel_fn = skel_fn,
      dir_tp = dir_tp,
      dir_fp = dir_fp,
      dir_fn = dir_fn,
      precision = precision,
      recall = recall,
      f1 = f1,
      ddm = ddm,
      bsf = bsf,
      my_score = my_score,
      my_shd = my_shd
    )
  )

  
}