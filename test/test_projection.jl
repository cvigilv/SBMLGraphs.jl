using SBMLGraphs
using SBML
using Graphs, SparseArrays
using Test

@testset "projection" verbose = true begin
    model_str = """<?xml version="1.0" encoding="UTF-8"?>
    <sbml xmlns="http://www.sbml.org/sbml/level3/version2/core" level="3" version="2">
      <model id="graph_model">
        <listOfCompartments>
          <compartment id="C_c" name="cytosol" size="1" constant="true"/>
        </listOfCompartments>
        <listOfSpecies>
          <species id="S1" name="S1" compartment="C_c"> </species>
          <species id="S2" name="S2" compartment="C_c"> </species>
          <species id="S3" name="S3" compartment="C_c"> </species>
          <species id="S4" name="S4" compartment="C_c"> </species>
          <species id="S5" name="S5" compartment="C_c"> </species>
          <species id="S6" name="S6" compartment="C_c"> </species>
        </listOfSpecies>
        <listOfReactions>
          <reaction id="r1" reversible="true">
            <listOfReactants>
              <speciesReference species="S1" stoichimetry="1" constant="false"/>
            </listOfReactants>
            <listOfProducts>
              <speciesReference species="S2" stoichiometry="1" constant="false"/>
            </listOfProducts>
          </reaction>
          <reaction id="r2" reversible="false">
            <listOfReactants>
              <speciesReference species="S2" stoichimetry="1" constant="false"/>
            </listOfReactants>
            <listOfProducts>
              <speciesReference species="S4" stoichiometry="1" constant="false"/>
            </listOfProducts>
          </reaction>
          <reaction id="r3" reversible="false">
            <listOfReactants>
              <speciesReference species="S2" stoichimetry="1" constant="false"/>
            </listOfReactants>
            <listOfProducts>
              <speciesReference species="S3" stoichiometry="1" constant="false"/>
            </listOfProducts>
          </reaction>
          <reaction id="r4" reversible="false">
            <listOfReactants>
              <speciesReference species="S3" stoichimetry="1" constant="false"/>
            </listOfReactants>
            <listOfProducts>
              <speciesReference species="S5" stoichiometry="1" constant="false"/>
              <speciesReference species="S6" stoichiometry="1" constant="false"/>
            </listOfProducts>
          </reaction>
          <reaction id="r5" reversible="true">
            <listOfReactants>
              <speciesReference species="S4" stoichimetry="1" constant="false"/>
            </listOfReactants>
            <listOfProducts>
              <speciesReference species="S5" stoichiometry="1" constant="false"/>
            </listOfProducts>
          </reaction>
        </listOfReactions>
      </model>
    </sbml>"""
    model = readSBMLFromString(model_str; report_severities = false)

    @testset "projected_graph" verbose = true begin
        @testset "Base.AbstractMatrix" verbose = true begin
            M, V = convert(AbstractMatrix{Bool}, model)

            A_rxn_exp = [
                0 1 1 0 0;
                0 0 0 0 1;
                0 0 0 1 0;
                0 0 0 0 1;
                0 0 0 0 0;
            ]
            A_met_exp = [
                0 1 0 0 0 0;
                1 0 1 1 0 0;
                0 0 0 0 1 1;
                0 0 0 0 1 0;
                0 0 0 1 0 0;
                0 0 0 0 0 0;
            ]

            @test all(SBMLGraphs.projected_graph(M, findall(x -> occursin("r", x), V)) .== A_rxn_exp)
            @test all(SBMLGraphs.projected_graph(M, findall(x -> occursin("S", x), V)) .== A_met_exp)
        end

        @testset "SparseArrays.SparseMatrixCSC" verbose = true begin
            #if
            M, V = convert(SparseArrays.SparseMatrixCSC, model)
            A_rxn_exp = SparseArrays.sparse(
                Bool.(
                    [
                        0 1 1 0 0;
                        0 0 0 0 1;
                        0 0 0 1 0;
                        0 0 0 0 1;
                        0 0 0 0 0;
                    ]
                )
            )
            A_met_exp = SparseArrays.sparse(
                Bool.(
                    [
                        0 1 0 0 0 0;
                        1 0 1 1 0 0;
                        0 0 0 0 1 1;
                        0 0 0 0 1 0;
                        0 0 0 1 0 0;
                        0 0 0 0 0 0;
                    ]
                )
            )

            # it should
            A_rxn_obs = SBMLGraphs.projected_graph(M, findall(x -> occursin("r", x), V))
            A_met_obs = SBMLGraphs.projected_graph(M, findall(x -> occursin("S", x), V))

            @test typeof(A_rxn_obs) .== typeof(A_rxn_exp)
            @test typeof(A_met_obs) .== typeof(A_met_exp)
            @test all(A_rxn_obs .== A_rxn_exp)
            @test all(A_met_obs .== A_met_exp)
        end

        @testset "Graphs.AbstractGraph" verbose = true begin
            # if
            dG, dV = convert(Graphs.DiGraph, model)
            G, V = convert(Graphs.Graph, model)

            dG_rxn_exp = [
                0 1 1 0 0;
                0 0 0 0 1;
                0 0 0 1 0;
                0 0 0 0 1;
                0 0 0 0 0;
            ]
            dG_met_exp = [
                0 1 0 0 0 0;
                1 0 1 1 0 0;
                0 0 0 0 1 1;
                0 0 0 0 1 0;
                0 0 0 1 0 0;
                0 0 0 0 0 0;
            ]
            G_rxn_exp = [
                0 1 1 0 0;
                1 0 1 0 1;
                1 1 0 1 0;
                0 0 1 0 1;
                0 1 0 1 0;
            ]
            G_met_exp = [
                0 1 0 0 0 0;
                1 0 1 1 0 0;
                0 1 0 0 1 1;
                0 1 0 0 1 0;
                0 0 1 1 0 1;
                0 0 1 0 1 0;
            ]

            # then
            dG_rxn_obs = SBMLGraphs.projected_graph(dG, findall(x -> occursin("r", x), dV))
            dG_met_obs = SBMLGraphs.projected_graph(dG, findall(x -> occursin("S", x), dV))
            G_rxn_obs = SBMLGraphs.projected_graph(G, findall(x -> occursin("r", x), V))
            G_met_obs = SBMLGraphs.projected_graph(G, findall(x -> occursin("S", x), V))

            # should
            @test all(Graphs.adjacency_matrix(dG_rxn_obs) .== dG_rxn_exp)
            @test all(Graphs.adjacency_matrix(dG_met_obs) .== dG_met_exp)
            @test all(Graphs.adjacency_matrix(G_rxn_obs) .== G_rxn_exp)
            @test all(Graphs.adjacency_matrix(G_met_obs) .== G_met_exp)
        end

    end

    @testset "get_reactions_graph" verbose = true begin
        @testset "Base.AbstractMatrix" verbose = true begin
            M, V = convert(AbstractMatrix{Bool}, model)

            A_rxn_exp = [
                0 1 1 0 0;
                0 0 0 0 1;
                0 0 0 1 0;
                0 0 0 0 1;
                0 0 0 0 0;
            ]
            V_rxn_exp = V[findall(x -> occursin("r", x), V)]

            A_rxn_obs, V_rxn_obs = SBMLGraphs.get_reactions_graph(model, M, V)
            @test all(A_rxn_obs .== A_rxn_exp)
            @test all(V_rxn_obs .== V_rxn_exp)
        end

        @testset "Graphs.AbstractGraph" verbose = true begin
            dG, dV = convert(Graphs.DiGraph, model)
            G, V = convert(Graphs.Graph, model)

            dA_rxn_exp = [
                0 1 1 0 0;
                0 0 0 0 1;
                0 0 0 1 0;
                0 0 0 0 1;
                0 0 0 0 0;
            ]
            A_rxn_exp = [
                0 1 1 0 0;
                1 0 1 0 1;
                1 1 0 1 0;
                0 0 1 0 1;
                0 1 0 1 0;
            ]
            V_rxn_exp = V[findall(x -> occursin("r", x), V)]

            #
            dG_rxn_obs, dV_rxn_obs = SBMLGraphs.get_reactions_graph(model, dG, V)
            G_rxn_obs, V_rxn_obs = SBMLGraphs.get_reactions_graph(model, G, V)

            @test all(Graphs.adjacency_matrix(dG_rxn_obs) .== dA_rxn_exp)
            @test all(dV_rxn_obs .== V_rxn_exp)
            @test all(Graphs.adjacency_matrix(G_rxn_obs) .== A_rxn_exp)
            @test all(V_rxn_obs .== V_rxn_exp)
        end
    end

    @testset "get_species_graph" verbose = true begin
        @testset "Base.AbstractMatrix" verbose = true begin
            M, V = convert(AbstractMatrix{Bool}, model)

            A_met_exp = [
                0 1 0 0 0 0;
                1 0 1 1 0 0;
                0 0 0 0 1 1;
                0 0 0 0 1 0;
                0 0 0 1 0 0;
                0 0 0 0 0 0;
            ]
            V_met_exp = V[findall(x -> occursin("S", x), V)]

            A_met_obs, V_met_obs = SBMLGraphs.get_species_graph(model, M, V)
            @test all(A_met_obs .== A_met_exp)
            @test all(V_met_obs .== V_met_exp)
        end

        @testset "Graphs.AbstractGraph" verbose = true begin
            dG, dV = convert(Graphs.DiGraph, model)
            G, V = convert(Graphs.Graph, model)

            dA_met_exp = [
                0 1 0 0 0 0;
                1 0 1 1 0 0;
                0 0 0 0 1 1;
                0 0 0 0 1 0;
                0 0 0 1 0 0;
                0 0 0 0 0 0;
            ]
            A_met_exp = [
                0 1 0 0 0 0;
                1 0 1 1 0 0;
                0 1 0 0 1 1;
                0 1 0 0 1 0;
                0 0 1 1 0 1;
                0 0 1 0 1 0;
            ]
            V_met_exp = V[findall(x -> occursin("S", x), V)]

            dG_met_obs, dV_met_obs = SBMLGraphs.get_species_graph(model, dG, V)
            G_met_obs, V_met_obs = SBMLGraphs.get_species_graph(model, G, V)

            @test all(Graphs.adjacency_matrix(dG_met_obs) .== dA_met_exp)
            @test all(dV_met_obs .== V_met_exp)
            @test all(Graphs.adjacency_matrix(G_met_obs) .== A_met_exp)
            @test all(V_met_obs .== V_met_exp)
        end
    end
end
