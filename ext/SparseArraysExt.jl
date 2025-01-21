module SparseArraysExt

using SBMLGraphs, SBML, SparseArrays

"""
    Base.convert(_::Type{SparseArrays.SparseMatrixCSC}, m::SBML.Model)

Convert an SBML model into its (i) directed graph adjacency matrix and node identifiers.

# Arguments
- `t::Type{SparseArrays.SparseMatrixCSC}`: The target type for conversion.
- `s::SBML.Model`: The object to be converted.

# Returns
- `M::SparseArrays.SparseMatrixCSC`: Adjacency matrix for the directed bipartite reaction-species graph contructed from the model.
- `V::AbstractVector{String}`: Node identifiers.
"""
function Base.convert(_::Type{SparseArrays.SparseMatrixCSC}, m::SBML.Model)::Tuple{SparseMatrixCSC, AbstractVector{String}}
    M, V = convert(AbstractMatrix{Bool}, m)

    return sparse(M), V
end

"""
    _projected_graph(A::SparseArrays.SparseMatrixCSC{T}, Vp::AbstractVector{Int}) where T

Returns the projection of `A` onto one of its node sets in CSC format.

# Arguments
- `A::SparseArrays.SparseMatrixCSC{T}`: Adjacency matrix of the bipartite graph.
- `Vp::AbstractVector{Int}`: List of nodes to project onto.

# Returns
- `SparseArrays.SparseMatrixCSC{T}`: A graph adjacency matrix that is the projection onto the given nodes.
"""
function SBMLGraphs._projected_graph(A::SparseArrays.SparseMatrixCSC{Tv, Ti}, Vp::AbstractVector{Int}) where {Tv, Ti}
    # Helper function
    neighbors(M, idx) = findall(!=(0), M[idx, :])

    # Create empty Vp × Vp adjacency matrix
    Ap = SparseArrays.spzeros(Tv, length(Vp), length(Vp))

    # Create a mapping from original vertex IDs to new vertex IDs
    idx_mapper = enumerate(Vp) |> p -> reverse.(p) |> Dict

    # Iterate over each node finding neighbors and adding edges
    for u in Vp
        nbrs = setdiff(
            Set(v for nbr in neighbors(A, u) for v in neighbors(A, nbr)),
            Set([u])
        )

        for v in nbrs
            @assert v ∈ Vp "Graph is not bipartite"
            Ap[idx_mapper[u], idx_mapper[v]] = Tv(1)
        end
    end

    return Ap
end

end
