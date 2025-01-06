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

"""
    Base.convert(_::Type{AbstractMatrix}, m::SBML.Model)

# Arguments
- `t::Type{AbstractMatrix}`: The target type for conversion (AbstractMatrix).
- `s::SBML.Model`: The SBML.Reaction object to be converted.

# Returns
- `M::AbstractMatrix{Bool}`: Adjacency matrix for the directed bipartite reaction-species graph contructed from the model.
- `V::AbstractVector{String}`: Node identifiers.
"""
function Base.convert(_::Type{AbstractMatrix{T}}, m::SBML.Model)::Tuple{AbstractMatrix{T}, AbstractVector{String}} where {T}
    # Helper functions
    ref2idx(ref, lookup) = findfirst(==(ref.species), lookup)

    # Get vertices and add them to the graph
    V = []
    V_reactions = keys(m.reactions) |> collect
    V_species = keys(m.species) |> collect
    V = sort([V_reactions; V_species])

    # Traverse reactions and create adjacency matrix
    M = zeros(T, length(V), length(V))
    for (rxn_id, rxn_ref) in m.reactions
        rxn_idx = findfirst(==(rxn_id), V)

        # Convert species name to node index
        reactants_idx = map(e -> ref2idx(e, V), rxn_ref.reactants)
        products_idx = map(e -> ref2idx(e, V), rxn_ref.products)

        # Construct reaction edges from reactants and products
        E_reactants = Base.product(reactants_idx, [rxn_idx]) |> collect |> vec
        E_products = Base.product([rxn_idx], products_idx) |> collect |> vec

        if rxn_ref.reversible
            E_reactants = [E_reactants; map(reverse, E_reactants)]
            E_products = [E_products; map(reverse, E_products)]
        end

        for e in [E_products; E_reactants]
            s, t = e
            M[s, t] = T(1)
        end
    end

    return M, V
end
