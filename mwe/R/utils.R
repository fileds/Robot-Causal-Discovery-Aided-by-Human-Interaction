# Function to ask if edge is in true model. Only used in MWE.
ask_expert <-function(expert_model, discovered, selected)
{
  # If answer is yes
  if (nrow(merge(data.frame(arcs(expert_model)), selected)) > 0) 
    return(T)
  else 
    return(F)
}

# Function to incorporate expert answer. Only used in MWE.
incorporate_answer <-function(discovered, selected_edge, answer)
{
  # Get DAG from discovered PDAG to check for acyclicity
  dag <- discovered
  arcs(dag) <- directed.arcs(discovered)
  
  # If answer is yes.
  if (answer)
  {
    if (acyclic(set.arc(dag, selected_edge$from, selected_edge$to, check.cycles = FALSE), directed = TRUE))
    {
      discovered <- set.arc(discovered, selected_edge$from, selected_edge$to)
    }
    else
    {
      discovered <- set.edge(discovered, selected_edge$from, selected_edge$to)
    }
  }
  # If answer is false and arc is in PDAG.
  else if (nrow(merge(data.frame(arcs(discovered)), selected_edge)) > 0)
  {
    # Check if arc is undirected, then reverse direction if it doesn't cause a
    # cycle, else just drop arc.
    if (any(duplicated(rbind(undirected.arcs(discovered), c(selected_edge$from, selected_edge$to)))))
    {
      if(acyclic(set.arc(dag, selected_edge$to, selected_edge$from, check.cycles = FALSE), directed = TRUE))
      {
        discovered <- set.arc(discovered, selected_edge$to, selected_edge$from)
      }
      else
      {
        discovered <- drop.arc(discovered, selected_edge$from, selected_edge$to)
      }
    }
    else
    {
      discovered <- drop.arc(discovered, selected_edge$from, selected_edge$to)
    }
  }
  
  return(discovered)
}
