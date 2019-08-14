abstract type QuantumVariable <: Convex.AbstractVariable end

export ProbabilityVector, DensityMatrix, Choi

using Convex: ⪰

include("probability_vectors.jl")
include("choi.jl")
include("density_matrices.jl")
