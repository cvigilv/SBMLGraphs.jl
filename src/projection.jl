import SBML

"""
    projected_graph(A::AbstractMatrix{T}, Vp::AbstractVector{Int}) where T

Returns the projection of `A` onto one of its node sets.

Returns the adjacency matrix `Ap` that is the projection of the bipartite graph adjacency
matrix `A` onto the specified nodes. They are connected in `Ap` if they have a common neighbor
in `A`.

# Arguments
- `A::AbstractMatrix{T}`: Adjacency matrix of the bipartite graph.
- `Vp::AbstractVector{Int}`: List of nodes to project onto.

# Returns
- `AbstractMatrix{T}`: A graph adjacency matrix that is the projection onto the given nodes.

# Extended help

This algorithm doesn't check if the inputted adjacency matrix is for a bipartite graph,
therefore the algorithm will fail whenever it detects it's not bipartite, resulting in useless
computation time.

# References

- [`projected_graph` function from `networkx`](https://networkx.org/documentation/stable/_modules/networkx/algorithms/bipartite/projection.html#projected_graph)
"""
function projected_graph(A::AbstractMatrix{T}, Vp::AbstractVector{Int}) where T
    # Helper function
    neighbors(M, idx) = findall(!=(0), M[idx,:])

    # Create empty Vp × Vp adjacency matrix
    Ap = zeros(T, length(Vp), length(Vp))

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
            Ap[idx_mapper[u], idx_mapper[v]] = T(1)
        end
    end

    return Ap
end

"""
    get_reactions_graph(model::SBML.Model, A::AbstractMatrix, V::AbstractVector{String})

Contructs the reaction-centered graph based on SBML model, adjacency matrix and node identifiers.

# Arguments
- `m::SBML.Model`: The SBML model to convert.
- `A::AbstractMatrix{T}`: Adjacency matrix of graph.
- `Vp::AbstractVector{Int}`: List of nodes identifiers.

# Returns
- `AbstractMatrix{T}`: Projected graph adjacency matrix.
- `AbstractVector{String}`: Reaction nodes identifiers.
"""
function get_reactions_graph(model::SBML.Model, A::AbstractMatrix, V::AbstractVector{String})
    Vp = [Int(i) for (i, v) in enumerate(V) if v ∈ keys(model.reactions)]
    return projected_graph(A, Vp), V[Vp]
end


"""
    get_species_graph(model::SBML.Model, A::AbstractMatrix, V::AbstractVector{String})

Contructs the species-centered graph based on SBML model, adjacency matrix and node identifiers.

# Arguments
- `m::SBML.Model`: The SBML model to convert.
- `A::AbstractMatrix{T}`: Adjacency matrix of graph.
- `Vp::AbstractVector{Int}`: List of nodes identifiers.

# Returns
- `AbstractMatrix{T}`: Projected graph adjacency matrix.
- `AbstractVector{String}`: Species nodes identifiers.
"""
function get_species_graph(model::SBML.Model, A::AbstractMatrix, V::AbstractVector{String})
    Vp = [Int(i) for (i, v) in enumerate(V) if v ∈ keys(model.species)]
    return projected_graph(A, Vp), V[Vp]
end
