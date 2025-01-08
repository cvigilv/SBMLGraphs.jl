# API

```@docs
SBMLGraphs.SBMLGraphs
```

## Convertion from SBML to other types

```@docs
Base.convert(::Type{Dict}, ::SBML.Species)
Base.convert(::Type{Dict}, ::SBML.Reaction)
Base.convert(::Type{AbstractMatrix{T}}, ::SBML.Model) where T
```

## Relevant graph projections

```@docs
SBMLGraphs.projected_graph(::AbstractMatrix{T}, ::AbstractVector{Int64}) where T
SBMLGraphs.get_species_graph(::SBML.Model, ::AbstractMatrix, ::AbstractVector{String})
SBMLGraphs.get_reactions_graph(::SBML.Model, ::AbstractMatrix, ::AbstractVector{String})
```
