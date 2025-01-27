import SBML

"""
    convert_sbml_to_graph(model::SBML.Model,type::Type{T}=AbstractMatrix{Bool};projected::Union{Bool,Symbol}=false, include_metadata::Bool=false) where T

Convert an SBML model to a graph representation.

# Arguments
- `model::SBML.Model`: The SBML model to convert.
- `type::Type{T}=AbstractMatrix{Bool}`: The type of the output graph representation.
- `projected::Union{Bool,Symbol}=false`: Whether to project the graph and onto which set of nodes.
  - `false`: Return the full bipartite graph (default).
  - `:species`: Project onto species nodes.
  - `:reactions`: Project onto reaction nodes.
- `include_metadata::Bool=false`: Whether to include node metadata info output

# Returns
- `Tuple{T, AbstractVector{String}}`: The graph representation and node labels.
"""
function convert_sbml_to_graph(
        model::SBML.Model,
        type::Type{T} = AbstractMatrix{Bool};
        projected::Union{Bool, Symbol} = false,
        include_metadata::Bool = false
    ) where {T}
    # Get graph representation and node labels
    A, V = convert(type, model)

    result = if projected == false
        A, V
    elseif projected == :species
        get_species_graph(model, A, V)
    elseif projected == :reactions
        get_reactions_graph(model, A, V)
    else
        error("Invalid projection. Choose :species, or :reactions. (default = false, returns bipartite species-metabolite graph")
    end

    # Get metadata
    metadata = Dict{String, Dict}()
    if include_metadata
        for (id, reaction) in model.reactions
            metadata[id] = convert(Dict, reaction)
        end
        for (id, specie) in model.species
            metadata[id] = convert(Dict, specie)
        end
    end

    return include_metadata ? (result..., metadata) : result
end
