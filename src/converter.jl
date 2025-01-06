"""
	Base.convert(t::Type{Dict}, s::SBML.Reaction)

Convert an SBML.Reaction object to a Dictionary.

# Arguments
- `t::Type{Dict}`: The target type for conversion (Dictionary).
- `s::SBML.Reaction`: The SBML.Reaction object to be converted.

# Returns
- `Dict`: A Dictionary containing the fields of the SBML.Reaction object as key-value pairs.
"""
function Base.convert(t::Type{Dict}, reaction::SBML.Reaction)
    return t(
        "name" => reaction.name,
        "reactants" => reaction.reactants,
        "products" => reaction.products,
        "kinetic_parameters" => reaction.kinetic_parameters,
        "lower_bound" => reaction.lower_bound,
        "upper_bound" => reaction.upper_bound,
        "gene_product_association" => reaction.gene_product_association,
        "kinetic_math" => reaction.kinetic_math,
        "reversible" => reaction.reversible,
        "metaid" => reaction.metaid,
        "notes" => reaction.notes,
        "annotation" => reaction.annotation,
        "sbo" => reaction.sbo,
        "cv_terms" => reaction.cv_terms,
    )
end

"""
	Base.convert(t::Type{Dict}, species::SBML.Species)

Convert an SBML.Species object to a Dictionary.

# Arguments
- `t::Type{Dict}`: The target type for conversion (Dictionary).
- `reaction::SBML.Species`: The SBML.Reaction object to be converted.

# Returns
- `Dict`: A Dictionary containing the fields of the SBML.Reaction object as key-value pairs.
"""
function Base.convert(t::Type{Dict}, species::SBML.Species)
    return t(
        "name" => species.name,
        "compartment" => species.compartment,
        "boundary_condition" => species.boundary_condition,
        "formula" => species.formula,
        "charge" => species.charge,
        "initial_amount" => species.initial_amount,
        "initial_concentration" => species.initial_concentration,
        "substance_units" => species.substance_units,
        "conversion_factor" => species.conversion_factor,
        "only_substance_units" => species.only_substance_units,
        "constant" => species.constant,
        "metaid" => species.metaid,
        "notes" => species.notes,
        "annotation" => species.annotation,
        "sbo" => species.sbo,
        "cv_terms" => species.cv_terms,
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
