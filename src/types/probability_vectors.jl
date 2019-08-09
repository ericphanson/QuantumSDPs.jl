mutable struct ProbabilityVector{d} <: QuantumVariable
    head::Symbol
    id_hash::UInt64
    size::Tuple{Int, Int}
    value::Convex.ValueOrNothing
    vexity::Convex.Vexity
    function ProbabilityVector(d::Int)
        this = new{d}(:ProbabilityVector, 0, (d,1), nothing, Convex.AffineVexity())
        this.id_hash = objectid(this)
        Convex.id_to_variables[this.id_hash] = this
        this
    end
end
Convex.constraints(p::ProbabilityVector) = [ p >= 0, sum(p) == 1 ]
Convex.sign(::ProbabilityVector) = Convex.Positive()
Convex.vartype(::ProbabilityVector) = Convex.ContVar
Convex.eltype(::ProbabilityVector) = Float64