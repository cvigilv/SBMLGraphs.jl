module SparseArraysExt

using SBML, SparseArrays

"""
    Base.convert(_::Type{SparseArrays.SparseMatrixCSC}, m::SBML.Model)

# Arguments
- `t::Type{AbstractMatrix}`: The target type for conversion (AbstractMatrix).
- `s::SBML.Model`: The SBML.Reaction object to be converted.

# Returns
- `M::AbstractMatrix{Bool}`: Adjacency matrix for the directed bipartite reaction-species graph contructed from the model.
- `V::AbstractVector{String}`: Node identifiers.
"""
function Base.convert(_::Type{SparseArrays.SparseMatrixCSC}, m::SBML.Model)::Tuple{SparseMatrixCSC, AbstractVector{String}}
    M, V = convert(AbstractMatrix{Bool}, m)

    return sparse(M), V
end

end
