
macro define_variable(name::Symbol, fns, N, calc_size, supertype)
    if N == 1
        esc(quote
            mutable struct $(name){d} <: $(supertype)
                head::Symbol
                id_hash::UInt64
                value::Convex.ValueOrNothing
                size::Tuple{Int, Int}
                vexity::Convex.Vexity
                sign::Convex.Sign
                constraints::Vector{Convex.Constraint}
                vartype::Convex.VarType
                function $(name){d}() where {d}
                    sz = $(calc_size)(d)
                    this = new{d}(:variable, 0, nothing, sz, Convex.AffineVexity(), Convex.NoSign(), Convex.Constraint[], Convex.ContVar)
                    for f in $(fns)
                        push!(this.constraints, f(this))
                    end
                    this.id_hash = objectid(this)
                    Convex.id_to_variables[this.id_hash] = this
                end
                $(name)(d) = $(name){d}()
            end
        end)
    elseif N == 2
        esc(quote
            mutable struct $(name){d1, d2} <: $(supertype)
                head::Symbol
                id_hash::UInt64
                value::Convex.ValueOrNothing
                size::Tuple{Int, Int}
                vexity::Convex.Vexity
                sign::Convex.Sign
                constraints::Vector{Convex.Constraint}
                vartype::Convex.VarType
                function $(name){d1, d2}() where {d1, d2}
                    sz = $(calc_size)(d1, d2)
                    this = new{d1, d2}(:variable, 0, nothing, sz, Convex.AffineVexity(), Convex.NoSign(), Convex.Constraint[], Convex.ContVar)
                    for f in $(fns)
                        push!(this.constraints, f(this))
                    end
                    this.id_hash = objectid(this)
                    Convex.id_to_variables[this.id_hash] = this
                end
                $(name)(d1, d2) = $(name){d1, d2}()
                $(name)(d) = $(name){d, d}()
            end
        end)
    else
        throw(ArgumentError())
    end
end