abstract type QuantumVariable <: Convex.AbstractVariable end
export ProbabilityVector, DensityMatrix, CPTP
using LinearAlgebra
using Convex: ⪰

function Ipart(d, dfull)
    v = ones(dfull)
    if d < dfull
        v[d+1:dfull] .= 0.0
    end
    Diagonal(v)
end

include("define_types.jl")
@define_variable(ProbabilityVector, [x -> x >= 0, x -> sum(x) == 1], 1, d -> (d,1), QuantumVariable)
@define_variable(DensityMatrix, [x -> x ⪰ 0, x -> tr(x) == 1], 1, d -> (d, d), QuantumVariable)
@define_variable(CPTP, [x -> x ⪰ 0, x -> Convex.partialtrace(x, 1, [d2, d1]) == Ipart(min(d1,d2), d1)], 2, (d1, d2) -> (d1*d2, d1*d2), QuantumVariable)



function (T::CPTP{dA, dB})(ρ) where {dA, dB}
    so = choi2so(T, dA, dB)
    Convex.reshape(so * vec(ρ), dB, dB)
end
