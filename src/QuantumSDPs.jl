module QuantumSDPs

import Convex

using LinearAlgebra
import LinearAlgebra.I

if VERSION < v"1.2pre"
    (I::UniformScaling)(n::Integer) = Diagonal(fill(I.λ, n))
end


include("types/QuantumVariable.jl")
include("choi2so.jl")

end # module
