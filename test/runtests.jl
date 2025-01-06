using SBMLGraphs
using SBML
using Graphs, SparseArrays # Extensions
using Test

# Helper functions
idx(target, arr) = findfirst(==(target), arr)

@testset "convert" verbose = true begin
    @testset "SBML.Species" verbose = true begin
        model_str = """<?xml version="1.0" encoding="UTF-8"?>
        <sbml xmlns="http://www.sbml.org/sbml/level3/version2/core" level="3" version="2">
          <model id="graph_model">
            <listOfCompartments>
              <compartment id="C_c" name="cytosol" size="1" constant="true"/>
            </listOfCompartments>
            <listOfSpecies>
              <species id="S1" name="Specie 1" compartment="C_c" hasOnlySubstanceUnits="true" boundaryCondition="false" constant="false" fbc:chemicalFormula="C1">
                <notes>
                  <p>Notes S1</p>
                </notes>
              </species>
              <species id="S2" name="Specie 2" compartment="C_c" hasOnlySubstanceUnits="true" boundaryCondition="false" constant="false" fbc:chemicalFormula="C2">
                <notes>
                     <p>Notes S2</p>
                </notes>
              </species>
            </listOfSpecies>
            <listOfReactions>
              <reaction id="r1" reversible="false">
                <listOfReactants>
                  <speciesReference species="S1" stoichiometry="2" constant="true"/>
                </listOfReactants>
                <listOfProducts>
                  <speciesReference species="S2" stoichiometry="1" constant="false"/>
                </listOfProducts>
                <notes>
                  <p>Notes S1-S2</p>
                </notes>
              </reaction>
            </listOfReactions>
          </model>
        </sbml>"""
        model = readSBMLFromString(model_str; report_severities = false)

        @testset "Base.Dict" verbose = true begin
            # Expected
            exp_rxn_dict = Dict(
                "name" => "Specie 1",
                "compartment" => "C_c",
                "boundary_condition" => false,
                "formula" => nothing,
                "charge" => nothing,
                "initial_amount" => nothing,
                "initial_concentration" => nothing,
                "substance_units" => nothing,
                "conversion_factor" => nothing,
                "only_substance_units" => true,
                "constant" => false,
                "metaid" => nothing,
                "notes" => "<notes>\n  <p>Notes S1</p>\n</notes>",
                "annotation" => nothing,
                "sbo" => nothing,
                "cv_terms" => SBML.CVTerm[],
            )

            # Observed
            obs_rxn_dict = convert(Dict, model.species["S1"])

            for key in keys(exp_rxn_dict)
                @test obs_rxn_dict[key] == exp_rxn_dict[key]
            end
        end
    end

    @testset "SBML.Reaction" verbose = true begin
        model_str = """<?xml version="1.0" encoding="UTF-8"?>
        <sbml xmlns="http://www.sbml.org/sbml/level3/version2/core" level="3" version="2">
          <model id="graph_model">
            <listOfCompartments>
              <compartment id="C_c" name="cytosol" size="1" constant="true"/>
            </listOfCompartments>
            <listOfSpecies>
              <species id="S1" name="Specie 1" compartment="C_c" hasOnlySubstanceUnits="true" boundaryCondition="false" constant="false" fbc:chemicalFormula="C1">
                <notes>
                    <p>Notes S1</p>
                </notes>
              </species>
              <species id="S2" name="Specie 2" compartment="C_c" hasOnlySubstanceUnits="true" boundaryCondition="false" constant="false" fbc:chemicalFormula="C2">
                <notes>
                    <p>Notes S2</p>
                </notes>
              </species>
            </listOfSpecies>
            <listOfReactions>
              <reaction id="r1" reversible="false">
                <listOfReactants>
                  <speciesReference species="S1" stoichiometry="2" constant="true"/>
                </listOfReactants>
                <listOfProducts>
                  <speciesReference species="S2" stoichiometry="1" constant="false"/>
                </listOfProducts>
                <notes>
                  <p>Notes S1-S2</p>
                </notes>
              </reaction>
            </listOfReactions>
          </model>
        </sbml>"""
        model = readSBMLFromString(model_str; report_severities = false)

        @testset "Base.Dict" verbose = true begin
            # Expected
            exp_rxn_dict = Dict(
                "name" => nothing,
                "reactants" => [SBML.SpeciesReference(nothing, "S1", 2.0, true)],
                "products" => [SBML.SpeciesReference(nothing, "S2", 1.0, false)],
                "kinetic_parameters" => Dict{String, SBML.Parameter}(),
                "lower_bound" => nothing,
                "upper_bound" => nothing,
                "gene_product_association" => nothing,
                "kinetic_math" => nothing,
                "reversible" => false,
                "metaid" => nothing,
                "notes" => "<notes>\n  <p>Notes S1-S2</p>\n</notes>",
                "annotation" => nothing,
                "sbo" => nothing,
                "cv_terms" => SBML.CVTerm[],
            )

            # Observed
            obs_rxn_dict = convert(Dict, model.reactions["r1"])

            for key in keys(exp_rxn_dict)
                @test obs_rxn_dict[key] == exp_rxn_dict[key]
            end
        end
    end


    @testset "SBML.Model" verbose = true begin
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

        @testset "Base.AbstractMatrix" begin
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

        @testset "Graphs.AbstractGraph" begin
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

        @testset "SparseArrays.SparseMatrixCSC" begin
            # Directed graph adjacency matrix
            dG_exp = spzeros(length(V), length(V))
            for e in E
                s, t = e
                dG_exp[idx(s, V), idx(t, V)] = 1
            end

            dG_obs, V_dG_obs = convert(SparseArrays.SparseMatrixCSC, model)

            # Compare adjacency matrices
            @test all(dG_exp .== dG_obs)
            @test all(V_dG_obs .== V)
        end
    end
end
