# Graphs.jl

```@docs
Base.convert(::Type{Graphs.Graph}, ::SBML.Model)
Base.convert(::Type{Graphs.DiGraph}, ::SBML.Model)
```

```@docs
SBMLGraphs.projected_graph(::Graphs.AbstractGraph, ::AbstractVector{Int64})
SBMLGraphs.get_species_graph(::SBML.Model, ::Graphs.AbstractGraph, ::AbstractVector{String})
SBMLGraphs.get_reactions_graph(::SBML.Model, ::Graphs.AbstractGraph, ::AbstractVector{String})
```


# SparseArrays.jl
