"""
    mutable struct Choi{dA, dB} <: QuantumVariable

An `AbstractVariable` which represents the Choi matrix of a quantum channel.

If `T` is a quantum channel from system A to system B, then its Choi matrix
is a `dA*dB` by `dA*dB` matrix given by `J` where

    J = T ⊗ id (Ω)

and `Ω =|Ω⟩⟨Ω|` where `|Ω⟩ = ∑ᵢ |i⟩|i⟩` is the unnormalized maximally
entangled state.
"""
mutable struct Choi{T, dA, dB} <: QuantumVariable{T}
    head::Symbol
    id_hash::UInt64
    size::Tuple{Int, Int}
    value::Convex.ValueOrNothing
    vexity::Convex.Vexity
    function Choi{T}(dA::Int, dB::Int) where {T <: Number}
        this = new{T, dA, dB}(:Choi, 0, (dA*dB,dA*dB), nothing, Convex.AffineVexity())
        this.id_hash = objectid(this)
        Convex.id_to_variables[this.id_hash] = this
        this
    end

    Choi{T}(d::Int) where {T <: Number} = Choi{T}(d, d)

    Choi(args...) = Choi{ComplexF64}(args...)
end

Convex.constraints(J::Choi{T, dA, dB}) where {T, dA, dB} = [ J ⪰ 0, Convex.partialtrace(J, 1, [dB, dA]) == I(dA) ]
Convex.sign(::Choi) = Convex.ComplexSign()
Convex.vartype(::Choi) = Convex.ContVar
