# import Base.Iterators: product

# General {{{
"""
    Base.convert(t::Type{Dict}, s::SBML.Reaction)

Convert an SBML.Reaction object to a Dictionary.


# Arguments
- `t::Type{Dict}`: The target type for conversion (Dictionary).
- `s::SBML.Reaction`: The SBML.Reaction object to be converted.

# Returns
- `Dict`: A Dictionary containing the fields of the SBML.Reaction object as key-value pairs.
"""
function Base.convert(t::Type{Dict}, s::SBML.Reaction)
    return t(
        "name" => s.name,
        "reactants" => s.reactants,
        "products" => s.products,
        "kinetic_parameters" => s.kinetic_parameters,
        "lower_bound" => s.lower_bound,
        "upper_bound" => s.upper_bound,
        "gene_product_association" => s.gene_product_association,
        "kinetic_math" => s.kinetic_math,
        "reversible" => s.reversible,
        "metaid" => s.metaid,
        "notes" => s.notes,
        "annotation" => s.annotation,
        "sbo" => s.sbo,
        "cv_terms" => s.cv_terms,
    )
end
# }}}
# Graph.jl {{{
"""
    sbml_to_simplegraph(m::SBML.Model, G::T, directed::Bool) where T

Convert an SBML model to a SimpleGraph or SimpleDiGraph.

This function takes an SBML model and converts it to a bipartite graph representation,
where nodes represent both reactions and species, and edges represent the connections
between them.

# Arguments
- `m::SBML.Model`: The SBML model to convert.
- `G::T`: The graph object to populate (either SimpleGraph or SimpleDiGraph).
- `directed::Bool`: Whether to create a directed graph or not.

# Returns
A tuple containing:
- The populated graph `G` of type `T`.
- An `AbstractVector{String}` containing the vertex labels (reaction and species names).

# Note
If `directed` is true and a reaction is reversible, edges are added in both directions.
"""
function sbml_to_simplegraph(m::SBML.Model, G::T, directed::Bool)::Tuple{T,AbstractVector{String}} where T
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

		# Construct reaction edges from reactants and products
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
function Base.convert(_::Type{Graphs.Graph}, m::SBML.Model)::Tuple{Graphs.Graph,AbstractVector{String}}
	return sbml_to_simplegraph(m, Graphs.Graph(), false)
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
function Base.convert(_::Type{Graphs.DiGraph}, m::SBML.Model)::Tuple{Graphs.DiGraph,AbstractVector{String}}
	return sbml_to_simplegraph(m, Graphs.DiGraph(), true)
end
# }}}
