library(dplyr)
library(bnlearn)
# NOTE: Using a discovery algorithm which stores the conditional dependencies or
# scores could potentially remove this all together.
#' Finds one directed independencies in a PDAG
#' 
#' The benefit of this function is that each edge only appears in one 
#' direction, which is useful when evaluating edge scores later. Arguably a more 
#' concise solution would be to take the set difference of all possible 
#' edges and the discovered edges, and then select only the edges in one 
#' direction if a symmetric scoring of the edges is used. 
#' 
#' @param discovered A discovered PDAG from the package bnlearn
#' 
#' @return A list containing the independencies in the PDAG.
independencies <- function(discovered)
{
  # Sort nodes to avoid iterating twice over nodes
  sorted_nodes <- sort(nodes(discovered))
  
  # List holding the potential questions
  from <- c()
  to <- c()
  for (node_1 in sorted_nodes)
  {
    # Get Markov blanket of current node.
    markov_blanket <- mb(discovered, node_1)
    # Find the potentially dependent nodes by removing the Markov blanket and
    # the already processed nodes.
    potential_dependencies <- base::setdiff(sorted_nodes[sorted_nodes > node_1], markov_blanket)
    # Append the potential edges to the potential questions
    from <- append(from, rep(node_1, length(potential_dependencies)))
    # Append the potential edges to the potential questions
    to <- append(to, potential_dependencies)
  }
  
  return(data.frame(from = from, to = to))
}

fully_connected_edges <- function(discovered)
{
  n_nodes <- length(nodes(discovered))
  # List holding the potential questions
  from <- c()
  to <- c()
  for (node in nodes(discovered))
  {
    # Find the potentially dependent nodes by removing the Markov blanket and
    # Append the potential edges to the potential questions
    from <- append(from, rep(node, n_nodes - 1))
    # Append the potential edges to the potential questions
    to <- append(to, dplyr::setdiff(nodes(discovered), node))
  }
  
  return(data.frame(from = from, to = to))
}

undirected_edges_and_independencies <- function(discovered)
{
  fc <- fully_connected_edges(discovered)
  de <- data.frame(directed.arcs(discovered))
  return(dplyr::setdiff(fc, de))
}

undirected_edges <- function(discovered) data.frame(undirected.arcs(discovered))