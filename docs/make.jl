using Documenter, QuantumSDPs

makedocs(;
    modules=[QuantumSDPs],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/ericphanson/QuantumSDPs.jl/blob/{commit}{path}#L{line}",
    sitename="QuantumSDPs.jl",
    authors="Eric P. Hanson",
    assets=String[],
)

deploydocs(;
    repo="github.com/ericphanson/QuantumSDPs.jl",
)
