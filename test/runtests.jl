using QuantumSDPs
using Test
using SCS, Convex
using Random
using LinearAlgebra, SparseArrays

if VERSION < v"1.2pre"
    import LinearAlgebra.I
    (I::UniformScaling)(n::Integer) = Diagonal(fill(I.λ, n))
end
const ⊗ = kron
ket(i, d) = sparsevec([i], [true], d)
bra(i, d) = ket(i, d)'
ketbra(i,j, d) = ket(i,d) ⊗ bra(j, d)

@testset "QuantumSDPs.jl" begin

    @testset "permuteddims_matrix" begin
        for n in (2, 3, 4, 5)
            dims = ntuple( i -> rand(2:5), n)
            d = prod(dims)
            v = rand(d)
            p = randperm(n)
            out1 = vec(permutedims(reshape(v, dims), p))
            out2 = QuantumSDPs.permutedims_matrix(dims, p) * v
            @test out1 ≈ out2
        end
    end

    @testset "choi2so" begin
        for (dA, dB) in ((2,2), (2,3), (3,2), (3,3), (3, 7), (7, 3))
            J = Choi(dA, dB)
            T = ComplexVariable(dB^2, dA^2)
            p = minimize(real(tr( rand(dA^2, dB^2) * T)), [ choi2so(J, dA, dB) == T ])
            solve!( p, SCSSolver(verbose=false))

            # check conic_form agrees with the numeric implementation
            @test evaluate(T) ≈ choi2so(evaluate(J), dA, dB) atol=1e-4

            # check we can map back
            @test so2choi(evaluate(T), dA, dB) ≈ evaluate(J) atol=1e-4

            # check that `T` is unital
            @test evaluate(T)' * vec(I(dB)) ≈ vec(I(dA)) atol=1e-4

            ρ = randn(dA,dA) + im*randn(dA,dA)
            ρ = ρ/tr(ρ)

            
            for R in (evaluate(T), choi2so(evaluate(J), dA, dB))
                # define a function to implement of the action
                # of R on a matrix
                f_R = x ->  reshape(R*vec(x), (dB, dB))

                # check that the map is trace preserving
                @test tr(f_R(ρ)) ≈ tr(ρ) atol=1e-4

                # check that the method for using J as a function
                # agrees with `f_R`
                # @test f_R(ρ) ≈ evaluate(J(ρ)) atol=1e-4


                # check against the naive definition of the Choi matrix
                J_R = sum( f_R(ketbra(i,j, dA)) ⊗ ketbra(i,j, dA) for i = 1:dA, j = 1:dA )
                @test J_R ≈ evaluate(J) atol=1e-4

            end

        end
    end

end
