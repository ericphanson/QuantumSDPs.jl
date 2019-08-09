mutable struct DensityMatrix{d} <: QuantumVariable
    head::Symbol
    id_hash::UInt64
    size::Tuple{Int, Int}
    value::Convex.ValueOrNothing
    vexity::Convex.Vexity
    function DensityMatrix(d::Int)
        this = new{d}(:DensityMatrix, 0, (d,d), nothing, Convex.AffineVexity())
        this.id_hash = objectid(this)
        Convex.id_to_variables[this.id_hash] = this
        this
    end
end
Convex.constraints(ρ::DensityMatrix) = [ ρ ⪰ 0, tr(ρ) == 1 ]
Convex.sign(::DensityMatrix) = Convex.ComplexSign()
Convex.vartype(::DensityMatrix) = Convex.ContVar
Convex.eltype(::DensityMatrix) = ComplexF64
