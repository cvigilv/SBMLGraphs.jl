using SBMLGraphs
using SBML
using Graphs
using Test

# Helper functions
idx(target, arr) = findfirst(==(target), arr)

@testset "convert" verbose = true begin
    # Hand constructed expected graph elements
    V = ["S1", "S2", "S3", "S4", "S5", "S6", "r1", "r2", "r3"]
    E = [
        ("S1", "r1"),
        ("r1", "S2"),
        ("S2", "r2"),
        ("r2", "S3"),
        ("S3", "r3"),
        ("S4", "r3"),
        ("r3", "S5"),
        ("r3", "S6"),
    ]

    # Construct graphs from SBML string
    model_str = """<?xml version="1.0" encoding="UTF-8"?>
    <sbml xmlns="http://www.sbml.org/sbml/level3/version2/core" level="3" version="2">
      <model id="graph_model">
    	<listOfCompartments>
    	  <compartment id="C_c" name="cytosol" size="1" constant="true"/>
    	</listOfCompartments>
    	<listOfSpecies>
    	  <species id="S1" compartment="C_c"/>
    	  <species id="S2" compartment="C_c"/>
    	  <species id="S3" compartment="C_c"/>
    	  <species id="S4" compartment="C_c"/>
    	  <species id="S5" compartment="C_c"/>
    	  <species id="S6" compartment="C_c"/>
    	</listOfSpecies>
    	<listOfReactions>
    	  <reaction id="r1" reversible="false">
    		<listOfReactants>
    		  <speciesReference species="S1" stoichiometry="2" constant="true"/>
    		</listOfReactants>
    		<listOfProducts>
    		  <speciesReference species="S2" stoichiometry="1" constant="true"/>
    		</listOfProducts>
    	  </reaction>
    	  <reaction id="r2" reversible="false">
    		<listOfReactants>
    		  <speciesReference species="S2" stoichiometry="1" constant="true"/>
    		</listOfReactants>
    		<listOfProducts>
    		  <speciesReference species="S3" stoichiometry="1" constant="true"/>
    		</listOfProducts>
    	  </reaction>
    	  <reaction id="r3" reversible="false">
    		<listOfReactants>
    		  <speciesReference species="S3" stoichiometry="1" constant="true"/>
    		  <speciesReference species="S4" stoichiometry="1" constant="true"/>
    		</listOfReactants>
    		<listOfProducts>
    		  <speciesReference species="S5" stoichiometry="1" constant="true"/>
    		  <speciesReference species="S6" stoichiometry="1" constant="true"/>
    		</listOfProducts>
    	  </reaction>
    	</listOfReactions>
      </model>
    </sbml>"""
    model = readSBMLFromString(model_str; report_severities = false)

    @testset "SBML.Model -> Base.AbstractMatrix" begin
        # Directed graph adjacency matrix
        dG_exp = zeros(length(V), length(V))
        for e in E
            s, t = e
            dG_exp[idx(s, V), idx(t, V)] = 1
        end

        dG_obs, V_dG_obs = convert(AbstractMatrix{Int64}, model)

        # Compare adjacency matrices
        @test all(dG_exp .== dG_obs)
        @test all(V_dG_obs .== V)
    end

    end

    @testset "SBML.Model -> Graphs.AbstractGraph" begin
        # Directed graph
        dG_exp = DiGraph()
        add_vertices!(dG_exp, length(V))
        for e in E
            s, t = e
            add_edge!(dG_exp, idx(s, V), idx(t, V))
        end

        # Undirected graph
        G_exp = Graph(dG_exp)

		# Convert
        G_obs, V_G_obs = convert(Graphs.Graph, model)
        dG_obs, V_dG_obs = convert(Graphs.DiGraph, model)

        # Compare adjacency matrices
        @test all(adjacency_matrix(G_exp) .== adjacency_matrix(G_obs))
        @test all(adjacency_matrix(dG_exp) .== adjacency_matrix(dG_obs))
		@test all(V_G_obs .== V)
		@test all(V_dG_obs .== V)

    end
end
