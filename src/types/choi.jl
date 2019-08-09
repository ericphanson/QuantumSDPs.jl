"An `AbstractVariable` which represents the Choi matrix of a quantum channel."
mutable struct Choi{dA, dB} <: QuantumVariable
    head::Symbol
    id_hash::UInt64
    size::Tuple{Int, Int}
    value::Convex.ValueOrNothing
    vexity::Convex.Vexity
    function Choi(dA::Int, dB::Int)
        this = new{dA, dB}(:Choi, 0, (dA*dB,dA*dB), nothing, Convex.AffineVexity())
        this.id_hash = objectid(this)
        Convex.id_to_variables[this.id_hash] = this
        this
    end

    Choi(d::Int) = Choi(d, d)
end

function Ipart(d, dfull)
    v = ones(dfull)
    if d < dfull
        v[d+1:dfull] .= 0.0
    end
    Diagonal(v)
end

Convex.constraints(J::Choi{dA, dB}) where {dA, dB} = [ J ⪰ 0, Convex.partialtrace(J, 1, [dB, dA]) == Ipart(min(dA,dB), dA) ]
Convex.sign(::Choi) = Convex.ComplexSign()
Convex.vartype(::Choi) = Convex.ContVar
Convex.eltype(::Choi) = ComplexF64


"""
    (J::Choi{dA, dB})(ρ) where {dA, dB}

`J` can be called as a function to act as its corresponding channel.
"""
function (J::Choi{dA, dB})(ρ) where {dA, dB}
    so = choi2so(J, dA, dB)
    Convex.reshape(so * vec(ρ), dB, dB)
end