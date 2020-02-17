# ------------------------------------------------------------------------
# FINITE

# Arr{T} -> Finite
function coerce(v::Arr{T}, ::Type{T2};
                verbosity::Int=1, tight::Bool=false
                ) where T where T2 <: Union{Missing,Finite}
    v    = _check_tight(v, T, tight)
    vcat = categorical(v, ordered=nonmissing(T2)<:OrderedFactor)
    return _finalize_finite_coerce(vcat, verbosity, T2, T)
end

# CArr{T} -> Finite
function coerce(v::CArr{T}, ::Type{T2};
                verbosity::Int=1, tight::Bool=false
                ) where T where T2 <: Union{Missing,Finite}
    v = _check_tight(v, T, tight)
    return _finalize_finite_coerce(v, verbosity, T2, T)
end

# ------------------------------------------------------------------------
# INFINITE

# Arr{Int} -> {Count} is no-op
function coerce(y::Arr{T}, T2::Type{<:Union{Missing,Count}};
                verbosity::Int=1, tight::Bool=false
                ) where T <: Union{Missing,Integer}
    y = _check_tight(y, T, tight)
    _check_eltype(y, T2, verbosity)
    return y
end

# Arr{Real \ Int} -> {Count} via `_int`, may throw InexactError
function coerce(y::Arr{T}, T2::Type{<:Union{Missing,Count}};
                verbosity::Int=1, tight::Bool=false
                ) where T <: Union{Missing,Real}
    y = _check_tight(y, T, tight)
    _check_eltype(y, T2, verbosity)
    return _int.(y)
end

# Arr{Float} -> Float is no-op
function coerce(y::Arr{T}, T2::Type{<:Union{Missing,Continuous}};
                verbosity::Int=1, tight::Bool=false
                ) where T <: Union{Missing,AbstractFloat}
    y = _check_tight(y, T, tight)
    _check_eltype(y, T2, verbosity)
    return y
end

# Arr{Real \ {Float}} -> Float via `float`
function coerce(y::Arr{T}, T2::Type{<:Union{Missing,Continuous}};
                verbosity::Int=1, tight::Bool=false
                ) where T <: Union{Missing,Real}
    y = _check_tight(y, T, tight)
    _check_eltype(y, T2, verbosity)
    return float(y)
end

# CArr -> Count/Continuous via `_int` or `float(_int)`
function coerce(y::CArr{T}, T2::Type{<:Union{Missing,C}};
                verbosity::Int=1, tight::Bool=false
                ) where T where C <: Infinite
    # here we broadcast and so we don't need to tighten
    iy = _int.(y)
    _check_eltype(iy, T2, verbosity)
    C == Count && return iy
    return float(iy)
end

const MaybeNumber = Union{Missing,AbstractChar,AbstractString}

# Textual => Count / Continuous via parse
function coerce(y::Arr{T}, T2::Type{<:Union{Missing,C}};
                verbosity::Int=1, tight::Bool=false
                ) where T <: MaybeNumber where C <: Infinite
    # NOTE: we're forced to do this in here (as opposed to despatching over
    # CArr) to avoid confusion between CArr and Arr when we want to convert
    # from 'Textual' to 'Infinite'. This is irrelevant though as the bottleneck
    # is the call to `_int.` and `_float.`.
    if !(nonmissing(elscitype(y)) <: Textual)
        throw(CoercionError("Scitype '$(nonmissing(elscitype(y)))' is not " *
                            "supported for coercion to Continuous."))
    end
    y = _check_tight(y, T, tight)
    _check_eltype(y, T2, verbosity)
    C == Count && return _int.(y)
    return _float.(y)
end

## ARRAY OF ANY
# Note: in the categorical case, we don't care, because we broadcast anyway.
# see CArr --> C above.
#
# this is the case where the data may have been badly encoded and resulted
# in an Any[] array a user should proceed with caution here in particular:
#   - if at one point it encounters a type for which there is no AbstractFloat
#     such as a String, it will error.
#   - if at one point it encounters a Char it will **not** error but return a
#     float corresponding to the Char (e.g. 65.0 for 'A') whence the warning
# Also the performances of this should not be expected to be great as we're
# broadcasting an operation on the full vector.
function coerce(y::Arr{Any}, T::Type{<:Union{Missing,C}};
                verbosity=1, tight::Bool=false
                ) where C <: Union{Count,Continuous}
    # to float or to count?
    op, num   = ifelse(C == Count, (_int, "65"), (float, "65.0"))
    has_chars = findfirst(e -> isa(e, Char), y) !== nothing
    if has_chars && verbosity > 0
        @warn "Char value encountered, such value will be coerced according to the corresponding numeric value (e.g. 'A' to $num)."
    end
    # broadcast the operation
    c = op.(y)
    # if the container type has  missing but not target, warn
    if (eltype(c) >: Missing) && !(T >: Missing) && verbosity > 0
        @warn "Trying to coerce from `Any` to `$T` but encountered missing values.\nCoerced to `Union{Missing,$T}` instead."
    end
    return c
end

# ------------------------------------------------------------------------
# UTILITIES

# If trying to  coerce to a non-union type `T` from a type that >: Missing
# for instance  coerce([missing,1,2], Continuous) will throw a warning
# to avoid that do coerce([missing,1,2], Union{Missing,Continuous})
# Special case with Any which is >: Missing depending on categorical case
function _coerce_missing_warn(::Type{T}, from::Type) where T
    T >: Missing && return
    if from == Any
        @warn "Trying to coerce from `Any` to `$T` with categoricals.\n" *
              "Coerced to `Union{Missing,$T}` instead."
    else
        @warn "Trying to coerce from `$from` to `$T`.\n" *
              "Coerced to `Union{Missing,$T}` instead."
    end
    return
end

# v is already categorical here, but may need `ordering` changed
function _finalize_finite_coerce(v, verbosity, T, fromT)
    elst = elscitype(v)
    if (elst >: Missing) && !(T >: Missing)
        verbosity > 0 && _coerce_missing_warn(T, fromT)
    end
    if elst <: T
        return v
    end
    return categorical(v, ordered=nonmissing(T)<:OrderedFactor)
end

_int(::Missing)  = missing
_int(x::Integer) = x
_int(x::Cat)     = CategoricalArrays.order(x.pool)[x.level]
_int(x)          = Int(x)                # NOTE: may throw InexactError

_int(x::AbstractString)   = Int(Meta.parse(x))    # NOTE: may fail
_float(x::AbstractString) = float(Meta.parse(x))
_float(x::Missing) = missing

function _check_eltype(y, T, verb)
    E = eltype(y)
    E >: Missing && verb > 0 && _coerce_missing_warn(T, E)
end

function _check_tight(v::Arr, T, tight)
    if T >: Missing && tight && findfirst(ismissing, v) === nothing
        v = identity.(v)
    end
    return v
end

function _check_tight(v::CArr, T, tight)
    if T >: Missing && tight && findfirst(ismissing, v) === nothing
        v = get.(v)
    end
    return v
end
