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

... being reworked