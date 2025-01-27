using SBMLGraphs
using SBML
using Graphs, SparseArrays
using Test

include("test_helpers.jl")

@testset "convert_sbml_to_graph" begin
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

	# TODO: Implement this test
	metadata_exp = Dict(
		"S1" => Dict(),
		"S2" => Dict(),
		"S3" => Dict(),
		"S4" => Dict(),
		"S5" => Dict(),
		"S6" => Dict(),
		"r1" => Dict(),
		"r2" => Dict(),
		"r3" => Dict(),
	)

	# TODO: Implement this test
	@testset "Base.AbstractMatrix" begin
		A_obs, V_obs, metadata_obs = convert(model, AbstractMatrix{Bool}; include_metadata=true)
		Arxn_obs, Vrxn_obs = convert(model, AbstractMatrix{Bool}; projected = :reactions)
		Aspc_obs, Vspc_obs  = convert(model, AbstractMatrix{Bool}; projected = :species)
	end

	# TODO: Implement this test
	@testset "SparseArrays.SparseMatrixCSC" begin
		A_obs, V_obs, metadata_obs = convert(model, SparseArrays.SparseMatrixCSC; include_metadata=true)
		Arxn_obs, Vrxn_obs = convert(model, SparseArrays.SparseMatrixCSC; projected = :reactions)
		Aspc_obs, Vspc_obs  = convert(model, SparseArrays.SparseMatrixCSC; projected = :species)
	end

	# TODO: Implement this test
	@testset "Graphs.Graph" begin
		A_obs, V_obs, metadata_obs = convert(model, Graphs.Graph; include_metadata=true)
		Arxn_obs, Vrxn_obs = convert(model, Graphs.Graph; projected = :reactions)
		Aspc_obs, Vspc_obs  = convert(model, Graphs.Graph; projected = :species)
	end

	# TODO: Implement this test
	@testset "Graphs.DiGraph" begin
		dG_obs, V_obs, metadata_obs = convert(model, Graphs.DiGraph; include_metadata=true)
		dGrxn_obs, Vrxn_obs = convert(model, Graphs.DiGraph; projected = :reactions)
		dGspc_obs, Vspc_obs  = convert(model, Graphs.DiGraph; projected = :species)
	end
end
