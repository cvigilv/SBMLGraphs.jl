module GraphsExt

import SBMLGraphs, SBML, Graphs

"""
    _sbml_to_simplegraph(m::SBML.Model, G::Graphs.AbstractGraph, directed::Bool)

Convert an SBML model to a SimpleGraph or SimpleDiGraph.

This function takes an SBML model and converts it to a bipartite graph representation,
where nodes represent both reactions and species, and edges represent the connections
between them.

# Arguments
- `m::SBML.Model`: The SBML model to convert.
- `G::Graphs.AbstractGraph`: The graph object to populate (either SimpleGraph or SimpleDiGraph).
- `directed::Bool`: Whether to create a directed graph or not.

# Returns
A tuple containing:
- The populated graph `G` of type `Graph.AbstractGraph`.
- An `AbstractVector{String}` containing the vertex labels (reaction and species names).

# Note
If `directed` is true and a reaction is reversible, edges are added in both directions.
"""
function _sbml_to_simplegraph(m::SBML.Model, G::Graphs.AbstractGraph, directed::Bool)
    # Helper functions
    ref2idx(ref, lookup) = findfirst(==(ref.species), lookup)

    # Initialize structures to return
    V = []
    E = []

    # Get vertices and add them to the graph
    V_reactions = keys(m.reactions) |> collect
    V_species = keys(m.species) |> collect
    V = sort([V_reactions; V_species])

    Graphs.add_vertices!(G, length(V))

    # Traverse reactions and create bipartite graph
    for (rxn_id, rxn_ref) in m.reactions
        rxn_idx = findfirst(==(rxn_id), V)

        # Convert species name to node index
        reactants_idx = map(e -> ref2idx(e, V), rxn_ref.reactants)
        products_idx = map(e -> ref2idx(e, V), rxn_ref.products)

        # Construct reaction edges from reactants and products species
        E_reactants = Base.product(reactants_idx, [rxn_idx]) |> collect |> vec
        E_products = Base.product([rxn_idx], products_idx) |> collect |> vec

        if directed && rxn_ref.reversible
            E_reactants = [E_reactants; map(reverse, E_reactants)]
            E_products = [E_products; map(reverse, E_products)]
        end

        E = [E_products; E_reactants]

        for e in E
            Graphs.add_edge!(G, e)
        end
    end

    return G, V
end

"""
    Base.convert(t::Type{Graphs.Graph}, m::SBML.Model)::Tuple{Graphs.Graph,AbstractVector{String}}

Convert an SBML model instance to a Graph instance and the nodes identifiers.

# Arguments
- `t::Type{Graphs.Graph}`: The type of Graph to convert to.
- `m::SBML.Model`: The SBML model to be converted.

# Returns
- `Graphs.Graph`: SBML model undirected graph instance.
- `AbstractVector{String}`: Node identifiers.
"""
function Base.convert(_::Type{Graphs.Graph}, m::SBML.Model)::Tuple{Graphs.Graph, AbstractVector{String}}
    return _sbml_to_simplegraph(m, Graphs.Graph(), false)
end


"""
    Base.convert(t::Type{Graphs.DiGraph}, m::SBML.Model)::Tuple{Graphs.DiGraph,AbstractVector{String}}

Convert an SBML model instance to a DiGraph instance and the nodes identifiers.

# Arguments
- `t::Type{Graphs.DiGraph}`: The type of Graph to convert to.
- `m::SBML.Model`: The SBML model to be converted.

# Returns
- `Graphs.DiGraph`: SBML model directed graph instance.
- `AbstractVector{String}`: Node identifiers.
"""
function Base.convert(_::Type{Graphs.DiGraph}, m::SBML.Model)::Tuple{Graphs.DiGraph, AbstractVector{String}}
    return _sbml_to_simplegraph(m, Graphs.DiGraph(), true)
end

"""
    SBMLGraphs._projected_graph(A::Graphs.AbstractGraph, Vp::AbstractVector{Int}) where T

Returns the projection of `G` onto one of its node set.

# Arguments
- `G::Graphs.AbstractGraph`: Bipartite graph.
- `Vp::AbstractVector{Int}`: List of nodes to project onto.

# Returns
- `Graphs.AbstractGraph`: A graph that is the projection onto the given nodes.
"""
function SBMLGraphs._projected_graph(G::Graphs.AbstractGraph, Vp::AbstractVector{Int})
    # Create projected graph
    if Graphs.is_directed(G)
        Gp = Graphs.DiGraph()
    else
        Gp = Graphs.Graph()
    end

    Graphs.add_vertices!(Gp, length(Vp))

    # Create a mapping from original vertex IDs to new vertex IDs
    idx_mapper = enumerate(Vp) |> p -> reverse.(p) |> Dict

    # Iterate over each node finding neighbors and adding edges
    for u in Vp
        nbrs = setdiff(
            Set(v for nbr in Graphs.neighbors(G, u) for v in Graphs.neighbors(G, nbr)),
            Set([u])
        )

        for v in nbrs
            @assert v ∈ Vp "Graph is not bipartite"
            Graphs.add_edge!(Gp, idx_mapper[u], idx_mapper[v])
        end
    end

    return Gp
end


"""
    SBMLGraphs.get_reactions_graph(model::SBML.Model, G::Graphs.AbstractGraph, V::AbstractVector{String})

Contructs the reactions-centered graph based on SBML model, graph and node identifiers.

# Arguments
- `m::SBML.Model`: The SBML model to convert.
- `A::AbstractGraph`: Graph.
- `Vp::AbstractVector{Int}`: List of nodes identifiers.

# Returns
- `AbstractGraph`: Projected graph over reaction nodes.
- `AbstractVector{String}`: Reaction nodes identifiers.
"""
function SBMLGraphs.get_reactions_graph(model::SBML.Model, G::Graphs.AbstractGraph, V::AbstractVector{String})
    Vp = [i for (i, v) in enumerate(V) if v in keys(model.reactions)]
    return SBMLGraphs._projected_graph(G, Vp), V[Vp]
end


"""
    SBMLGraphs.get_species_graph(model::SBML.Model, G::Graphs.AbstractGraph, V::AbstractVector{String})

Contructs the species-centered graph based on SBML model, graph and node identifiers.

# Arguments
- `m::SBML.Model`: The SBML model to convert.
- `A::AbstractGraph`: Graph.
- `Vp::AbstractVector{Int}`: List of nodes identifiers.

# Returns
- `AbstractGraph`: Projected graph over species nodes.
- `AbstractVector{String}`: Species nodes identifiers.
"""
function SBMLGraphs.get_species_graph(model::SBML.Model, G::Graphs.AbstractGraph, V::AbstractVector{String})
    Vp = [i for (i, v) in enumerate(V) if v in keys(model.species)]
    return SBMLGraphs._projected_graph(G, Vp), V[Vp]
end

end
