
export choi2so

struct Choi2SOAtom <: Convex.AbstractExpr
    head::Symbol
    id_hash::UInt64
    children::Tuple{Convex.AbstractExpr}
    size::Tuple{Int, Int}

    function Choi2SOAtom(x::Convex.AbstractExpr, dA::Int, dB::Int)
        if dA^2 * dB^2 != length(x)
            error("Cannot Choi2SOAtom expression of size $(x.size) with dimensions ($(dA), $(dB))")
        end
        return new(:choi2so, objectid(x), (x,), (dB^2, dA^2))
    end
end

function Convex.sign(x::Choi2SOAtom)
    return Convex.sign(x.children[1])
end

function Convex.monotonicity(x::Choi2SOAtom)
    return (Convex.Nondecreasing(),)
end

function Convex.curvature(x::Choi2SOAtom)
    return Convex.ConstVexity()
end

function Convex.evaluate(x::Choi2SOAtom)
    J = Convex.evaluate(x.children[1])
    dB2, dA2 = size(x)
    dB = isqrt(dB2); dA = isqrt(dA2)
    return choi2so(J, dA, dB)
end

function Convex.conic_form!(x::Choi2SOAtom, unique_conic_forms::Convex.UniqueConicForms=Convex.UniqueConicForms())
    return Convex.conic_form!(x.children[1], unique_conic_forms)
end

"""
    choi2so(x::Convex.AbstractExpr, dA::Int, dB::Int)

Convert from an (unnormalized) Choi matrix of a quantum channel `T` to a matrix representation.
It is assumed `T` is a quantum channel from `A` to `B`, where `A` is `dA`-dimensional space and `B` a `dB`-dimensional space.
"""
choi2so(x::Convex.AbstractExpr, dA::Int, dB::Int) = Choi2SOAtom(x, dA, dB)

choi2so(J, dA, dB) = reshape(PermutedDimsArray(reshape(J, (dB,dA,dB,dA)), (1, 3, 2, 4)), (dB^2, dA^2))