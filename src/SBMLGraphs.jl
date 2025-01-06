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

include("converter.jl")

end
