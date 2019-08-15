abstract type QuantumVariable{T} <: Convex.AbstractVariable{T} end

export ProbabilityVector, DensityMatrix, Choi

using Convex: ⪰

include("probability_vectors.jl")
include("choi.jl")
include("density_matrices.jl")
