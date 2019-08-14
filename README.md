# QuantumSDPs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ericphanson.github.io/QuantumSDPs.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ericphanson.github.io/QuantumSDPs.jl/dev)
[![Build Status](https://travis-ci.com/ericphanson/QuantumSDPs.jl.svg?branch=master)](https://travis-ci.com/ericphanson/QuantumSDPs.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/ericphanson/QuantumSDPs.jl?svg=true)](https://ci.appveyor.com/project/ericphanson/QuantumSDPs-jl)
[![Codecov](https://codecov.io/gh/ericphanson/QuantumSDPs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ericphanson/QuantumSDPs.jl)

# Install

This package isn't registered yet (and is still a work in progress), and requires a specific branch of (my fork of) Convex.jl:

```julia
] add https://github.com/ericphanson/Convex.jl#customvariable
] add https://github.com/ericphanson/QuantumSDPs.jl
```

# What this does

This package exports custom `AbstractVariable`'s for use in `Convex.jl` which encode various objects used in quantum information theory. There are:

* `ProbabilityVector(d)` represents a probability vector of length `d` (i.e. non-negative entries which sum to 1)
* `DensityMatrix(d)` represents a density matrix on a Hilbert space of dimension `d` (i.e. a complex Hermitian trace-1 matrix which is positive semidefinite)
* `Choi(dA, dB)` represents the Choi matrix of a quantum channel from a Hilbert space of dimension `dA` to one of dimension `dB`.

# Example

Here is a very simple example which illustrates one of the features of the package: `Choi` matrices may be called as functions for the channel action.

```julia
julia> using QuantumSDPs, Convex, LinearAlgebra, SCS

julia> p = Variable()
Variable of
size: (1, 1)
sign: NoSign()
vexity: AffineVexity()

julia> p.value = 1/3
0.3333333333333333

julia> fix!(p)
Variable of
size: (1, 1)
sign: NoSign()
vexity: ConstVexity()
value: 0.3333333333333333

julia> id = Diagonal(ones(2))
2×2 Diagonal{Float64,Array{Float64,1}}:
 1.0   ⋅ 
  ⋅   1.0

julia> N(ρ) = p*id/2*tr(ρ) + (1-p)*ρ # depolarizing channel
N (generic function with 1 method)

julia> ρ = [1.0 0.0; 0.0 0.0]
2×2 Array{Float64,2}:
 1.0  0.0
 0.0  0.0

julia> J = Choi(2)
Variable of
size: (4, 4)
sign: ComplexSign()
vexity: AffineVexity()

julia> prob = minimize(nuclearnorm(J(N(ρ)) - ρ)) # invert the action of N on ρ by minimizing trace distance
Problem:
minimize AbstractExpr with
head: nuclearnorm
size: (1, 1)
sign: Positive()
vexity: ConvexVexity()

subject to

current status: not yet solved

julia> solve!(prob, SCSSolver())
----------------------------------------------------------------------------
        SCS v2.0.2 - Splitting Conic Solver
        (c) Brendan O'Donoghue, Stanford University, 2012-2017
----------------------------------------------------------------------------
Lin-sys: sparse-indirect, nnz in A = 161, CG tol ~ 1/iter^(2.00)
eps = 1.00e-05, alpha = 1.50, max_iters = 5000, normalize = 1, scale = 1.00
acceleration_lookback = 20, rho_x = 1.00e-03
Variables n = 41, constraints m = 137
Cones:  primal zero / dual free vars: 65
        sd vars: 72, sd blks: 2
Setup time: 1.00e-04s
----------------------------------------------------------------------------
 Iter | pri res | dua res | rel gap | pri obj | dua obj | kap/tau | time (s)
----------------------------------------------------------------------------
     0| 1.68e+00  2.96e+00  9.22e-01 -5.34e+00  6.44e+00  2.25e-15  1.03e-04 
    40| 1.51e-08  3.92e-08  1.36e-07 -1.01e-08  1.26e-07  4.25e-17  3.02e-03 
----------------------------------------------------------------------------
Status: Solved
Timing: Solve time: 3.03e-03s
        Lin-sys: avg # CG iterations: 2.73, avg solve time: 5.74e-06s
        Cones: avg projection time: 4.12e-05s
        Acceleration: avg step time: 2.20e-05s
----------------------------------------------------------------------------
Error metrics:
dist(s, K) = 4.4962e-08, dist(y, K*) = 1.8990e-08, s'y/|s||y| = -2.3188e-08
primal res: |Ax + s - b|_2 / (1 + |b|_2) = 1.5140e-08
dual res:   |A'y + c|_2 / (1 + |c|_2) = 3.9185e-08
rel gap:    |c'x + b'y| / (1 + |c'x| + |b'y|) = 1.3598e-07
----------------------------------------------------------------------------
c'x = -0.0000, -b'y = 0.0000
============================================================================

julia> prob.optval
-1.010561371686164e-8
```