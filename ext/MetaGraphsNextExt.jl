module MetaGraphsNextExt

using SBMLGraphs, SBML, MetaGraphsNext, Gumbo

function testing()
	println("Lets go!")
end


function sbml_to_metagraph(m::SBML.Model, G::T, directed::Bool)::Tuple{T,AbstractVector{String}} where T
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

function Base.convert(_::Type{MetaGraphsNext.MetaGraph}, m::SBML.Model)
	println("Lets go!")
end

end
