using SparseArrays
export choi2so, so2choi

"""
    permutedims_matrix(dims, p)

Returns a matrix `M` so that for any vector `v` of length `prod(dims)`,

    M*v == vec(permutedims(reshape(v, dims), p))

"""
function permutedims_matrix(dims, p)
    d = prod(dims)
    n = length(dims)
    sparse(reshape(PermutedDimsArray(reshape(I(d), (dims..., dims...)), (p..., (n + 1:2n)...)), (d, d)))
end

struct Choi2SOAtom <: Convex.AbstractExpr
    head::Symbol
    id_hash::UInt64
    children::Tuple{Convex.AbstractExpr}
    size::Tuple{Int,Int}
    dA::Int
    dB::Int
    function Choi2SOAtom(x::Convex.AbstractExpr, dA::Int, dB::Int)
        if dA^2 * dB^2 != length(x)
            error("Cannot Choi2SOAtom expression of size $(x.size) with dimensions ($(dA), $(dB))")
        end
        return new(:choi2so, objectid(x), (x,), (dB^2, dA^2), dA, dB)
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
    return choi2so(J, x.dA, x.dB)
end


function Convex.conic_form!(x::Choi2SOAtom, unique_conic_forms::Convex.UniqueConicForms = Convex.UniqueConicForms())
    if !Convex.has_conic_form(unique_conic_forms, x)
        objective = Convex.conic_form!(x.children[1], unique_conic_forms)
        dA = x.dA; dB = x.dB;
        M = permutedims_matrix((dA, dB, dA, dB), (2, 4, 1, 3))
        objective = M * objective
        Convex.cache_conic_form!(unique_conic_forms, x, objective)
    end

    return Convex.get_conic_form(unique_conic_forms, x)
end

"""
    choi2so(x::Convex.AbstractExpr, dA::Int, dB::Int)

Convert from an (unnormalized) Choi matrix of a quantum channel `T` to a matrix representation.
It is assumed `T` is a quantum channel from `A` to `B`, where `A` is `dA`-dimensional space and `B` a `dB`-dimensional space.
"""
choi2so(x::Convex.AbstractExpr, dA::Int, dB::Int) = Choi2SOAtom(x, dA, dB)
choi2so(J, dA, dB) = reshape(PermutedDimsArray(reshape(J, (dA, dB, dA, dB)), (2, 4, 1, 3)), (dB^2, dA^2))




struct SO2ChoiAtom <: Convex.AbstractExpr
    head::Symbol
    id_hash::UInt64
    children::Tuple{Convex.AbstractExpr}
    size::Tuple{Int,Int}
    dA::Int
    dB::Int
    function SO2ChoiAtom(x::Convex.AbstractExpr, dA::Int, dB::Int)
        if !(dA^2 * dB^2 == length(x) && size(x) == (dB^2, dA^2))
            error("Cannot Choi2SOAtom expression of size $(x.size) with dimensions ($(dA), $(dB))")
        end
        return new(:so2choi, objectid(x), (x,), (dA*dB, dA*dB), dA, dB)
    end
end

function Convex.sign(x::SO2ChoiAtom)
    return Convex.sign(x.children[1])
end

function Convex.monotonicity(x::SO2ChoiAtom)
    return (Convex.Nondecreasing(),)
end

function Convex.curvature(x::SO2ChoiAtom)
    return Convex.ConstVexity()
end

function Convex.evaluate(x::SO2ChoiAtom)
    T = Convex.evaluate(x.children[1])
    return so2choi(T, x.dA, x.dB)
end


function Convex.conic_form!(x::SO2ChoiAtom, unique_conic_forms::Convex.UniqueConicForms = Convex.UniqueConicForms())
    if !Convex.has_conic_form(unique_conic_forms, x)
        objective = Convex.conic_form!(x.children[1], unique_conic_forms)
        dA = x.dA; dB = x.dB;
        M = permutedims_matrix((dB, dB, dA, dA), (3, 1, 4, 2))
        objective = M * objective
        Convex.cache_conic_form!(unique_conic_forms, x, objective)
    end

    return Convex.get_conic_form(unique_conic_forms, x)
end

"""
    so2choi(x::Convex.AbstractExpr, dA::Int, dB::Int)

Convert from a matrix representation of a quantum channel `T` to the Choi representation.
It is assumed `T` is a quantum channel from `A` to `B`, where `A` is `dA`-dimensional space and `B` a `dB`-dimensional space.
"""
so2choi(x::Convex.AbstractExpr, dA::Int, dB::Int) = SO2Choi(x, dA, dB)
so2choi(T, dA, dB) = reshape(PermutedDimsArray(reshape(T, (dB, dB, dA, dA)), (3, 1, 4, 2)), (dA*dB, dA*dB))
