using Test

@testset "SBMLGraphs" verbose = true begin
    include("test_convert.jl")
    include("test_projection.jl")
end
