# QuantumSDPs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ericphanson.github.io/QuantumSDPs.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ericphanson.github.io/QuantumSDPs.jl/dev)
[![Build Status](https://travis-ci.com/ericphanson/QuantumSDPs.jl.svg?branch=master)](https://travis-ci.com/ericphanson/QuantumSDPs.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/ericphanson/QuantumSDPs.jl?svg=true)](https://ci.appveyor.com/project/ericphanson/QuantumSDPs-jl)
[![Codecov](https://codecov.io/gh/ericphanson/QuantumSDPs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ericphanson/QuantumSDPs.jl)

# Example

```
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

julia> N(ρ) = p*id*tr(ρ) + (1-p)*ρ # depolarizing channel
N (generic function with 1 method)

julia> ρ = [1.0 0.0; 0.0 0.0]
2×2 Array{Float64,2}:
 1.0  0.0
 0.0  0.0

julia> T = CPTP(2)
Variable of
size: (4, 4)
sign: NoSign()
vexity: AffineVexity()

julia> prob = minimize(opnorm(T(N(ρ)) - ρ, 1)) # invert the action of N on ρ by minimizing trace distance
Problem:
minimize AbstractExpr with
head: maximum
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
Lin-sys: sparse-indirect, nnz in A = 62, CG tol ~ 1/iter^(2.00)
eps = 1.00e-05, alpha = 1.50, max_iters = 5000, normalize = 1, scale = 1.00
acceleration_lookback = 20, rho_x = 1.00e-03
Variables n = 22, constraints m = 31
Cones:  primal zero / dual free vars: 11
        linear vars: 10
        sd vars: 10, sd blks: 1
Setup time: 6.88e-05s
----------------------------------------------------------------------------
 Iter | pri res | dua res | rel gap | pri obj | dua obj | kap/tau | time (s)
----------------------------------------------------------------------------
     0| 3.64e+19  3.02e+19  1.00e+00 -1.31e+20  3.67e+19  4.85e+19  6.37e-05 
   100| 1.72e-06  2.01e-06  1.53e-06 -2.61e-07  1.27e-06  4.87e-17  2.83e-03 
----------------------------------------------------------------------------
Status: Solved
Timing: Solve time: 2.84e-03s
        Lin-sys: avg # CG iterations: 5.45, avg solve time: 2.62e-06s
        Cones: avg projection time: 7.04e-06s
        Acceleration: avg step time: 1.64e-05s
----------------------------------------------------------------------------
Error metrics:
dist(s, K) = 1.0335e-16, dist(y, K*) = 2.5223e-09, s'y/|s||y| = 8.1780e-11
primal res: |Ax + s - b|_2 / (1 + |b|_2) = 1.7229e-06
dual res:   |A'y + c|_2 / (1 + |c|_2) = 2.0060e-06
rel gap:    |c'x + b'y| / (1 + |c'x| + |b'y|) = 1.5267e-06
----------------------------------------------------------------------------
c'x = -0.0000, -b'y = 0.0000
============================================================================

julia> prob.optval
-2.614063741210122e-7
```