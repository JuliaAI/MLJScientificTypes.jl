using Documenter, MLJScientificTypes, ScientificTypes

makedocs(
    modules = [MLJScientificTypes, ScientificTypes],
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
    repo = "github.com/JuliaAI/MLJScientificTypes.jl",
    push_preview = true
)
