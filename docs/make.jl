using Documenter, MLJScientificTypes

makedocs(
    modules = [MLJScientificTypes],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        ),
    sitename = "MLJScientificTypes.jl",
    authors = "Anthony Blaom, Thibaut Lienart, and contributors.",
    pages = [
        "Home" => "index.md",
    ]
)

deploydocs(
    repo = "github.com/alan-turing-institute/MLJScientificTypes.jl"
)
