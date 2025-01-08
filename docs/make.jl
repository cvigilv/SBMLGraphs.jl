# Load dependencies
## 1. Base packages for documentation generation
using Documenter, SBMLGraphs

## 2. Helper packages for generating documentation
using Pkg, Literate, Glob

## 3. Packages required from documentation build
using SBML, CairoMakie, GraphMakie

## 4. Packages with extensions
using Graphs, SparseArrays

ALL_DEPENDENCIES = Base.loaded_modules_array() |> m -> Symbol.(m) |> m -> String.(m)


# Convert examples .jl to markdown files
TUTORIALS = joinpath(@__DIR__, "src", "tutorial")
SOURCE_FILES = Glob.glob("*.jl", TUTORIALS)
foreach(fn -> Literate.markdown(fn, TUTORIALS), SOURCE_FILES)

# Add dependencies to Documenter
DocMeta.setdocmeta!(
    SBMLGraphs,
    :DocTestSetup,
    Symbol("using " * join(ALL_DEPENDENCIES, ", "))
    ; recursive = true
)

# Generate documentations
makedocs(;
    sitename = "SBMLGraphs.jl",
    authors = "Carlos Vigil Vásquez <carlos.vigil.v@gmail.com> and contributors",
    repo = "https://github.com/cvigilv/SBMLGraphs.jl/blob/{commit}{path}#{line}",

    modules = [
        SBMLGraphs,
        isdefined(Base, :get_extension) ? Base.get_extension(SBMLGraphs, :GraphsExt) : SBMLGraphs.GraphsExt,
        isdefined(Base, :get_extension) ? Base.get_extension(SBMLGraphs, :SparseArraysExt) : SBMLGraphs.SparseArraysExt,
    ],
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://cvigilv.github.io/SBMLGraphs.jl",
        edit_link = "main",
        assets = [],
    ),
    pages = [
        "Welcome to SBMLGraphs.jl" => "index.md",
        "Getting started" => "tutorial/getting-started.md",
        "API" => "api/core.md",
        "Extensions" => "api/extensions.md",
    ],

    doctest = false,
    checkdocs = :none,
    warnonly = true,
)

deploydocs(; repo = "github.com/cvigilv/SBMLGraphs.jl.git", devbranch = "main")
