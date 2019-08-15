mutable struct ProbabilityVector{T, d} <: QuantumVariable{T}
    head::Symbol
    id_hash::UInt64
    size::Tuple{Int, Int}
    value::Convex.ValueOrNothing
    vexity::Convex.Vexity
    function ProbabilityVector{T}(d::Int) where {T <: Real}
        this = new{T, d}(:ProbabilityVector, 0, (d,1), nothing, Convex.AffineVexity())
        this.id_hash = objectid(this)
        Convex.id_to_variables[this.id_hash] = this
        this
    end
    ProbabilityVector(d::Int) = ProbabilityVector{Float64}(d)
end

Convex.constraints(p::ProbabilityVector) = [ p >= 0, sum(p) == 1 ]
Convex.sign(::ProbabilityVector) = Convex.Positive()
Convex.vartype(::ProbabilityVector) = Convex.ContVar
