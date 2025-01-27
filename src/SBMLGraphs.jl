# SPDX-License-Identifier: MIT

"""
# SBMLGraphs.jl

Package for converting Systems Biology Markup Language (SBML) XML files into common graph
representations.

## Extensions

- SparseArrays.jl
- Graphs.jl
"""
module SBMLGraphs

using SBML

include("convert.jl")
include("projection.jl")
include("core.jl")

export get_species_graph, get_reactions_graph, convert_sbml_to_graph

end
