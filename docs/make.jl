using Documenter, MLJScientificTypes

makedocs(
    modules = [MLJScientificTypes],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        # assets = ["assets/custom.css"]
        ),
    sitename = "MLJScientificTypes.jl",
    authors = "Anthony Blaom, Thibaut Lienart, and contributors.",
    pages = [
        "Home" => "index.md",
        # "Manual" => [
        # ],
        # "Library" => [
        # ],
    ]
)

deploydocs(
    repo = "github.com/alan-turing-institute/MLJScientificTypes.jl"
)
