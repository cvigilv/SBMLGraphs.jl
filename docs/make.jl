using SBMLGraphs
using Documenter
using Pkg, Literate, Glob, CairoMakie

CairoMakie.activate!(type="svg")

ENV["DATADEPS_ALWAYS_ACCEPT"] = true

# generate examples
TUTORIALS = joinpath(@__DIR__, "src", "tutorial")
SOURCE_FILES = Glob.glob("*.jl", TUTORIALS)
foreach(fn -> Literate.markdown(fn, TUTORIALS), SOURCE_FILES)

DocMeta.setdocmeta!(
	SBMLGraphs,
	:DocTestSetup,
	:(using SBMLGraphs, SparseArrays, Graphs);
	recursive=true
)

makedocs(;
    modules=[SBMLGraphs],
    authors="Carlos Vigil Vásquez <carlos.vigil.v@gmail.com> and contributors",
    repo="https://github.com/cvigilv/SBMLGraphs.jl/blob/{commit}{path}#{line}",
    sitename="SBMLGraphs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cvigilv.github.io/SBMLGraphs.jl",
        edit_link="main",
        assets=[],
    ),
    pages=[
        "Welcome to SBMLGraphs.jl" => "index.md",
        "Tutorials" => [
            "Getting started" => "tutorial/getting-started.md",
        ],
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/cvigilv/SBMLGraphs.jl/",
    branch = "gh-pages",
    devbranch="develop",
    devurl = "develop",
    deps = Pkg.add([
    	"SBML",
    	"CairoMakie",
		"GraphMakie",
		"SparseArrays",
		"Graphs"
    ])
)
