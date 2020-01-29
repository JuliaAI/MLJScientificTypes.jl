# Basic scitype

ScientificTypes.scitype(::Integer,        ::MLJ) = Count
ScientificTypes.scitype(::AbstractFloat,  ::MLJ) = Continuous
ScientificTypes.scitype(::AbstractString, ::MLJ) = Textual

ScientificTypes.scitype(img::Arr{<:Gray,2}, ::MLJ) = GrayImage{size(img)...}
ScientificTypes.scitype(img::Arr{<:AbstractRGB,2}, ::MLJ) =
ColorImage{size(img)...}


# CategoricalArray scitype

function ScientificTypes.scitype(c::Cat, ::MLJ)
    nc = length(levels(c.pool))
    return ifelse(c.pool.ordered, OrderedFactor{nc}, Multiclass{nc})
end

function ScientificTypes.scitype(A::CArr{T,N}, ::MLJ) where {T,N}
    nlevels = length(levels(A))
    S = ifelse(isordered(A), OrderedFactor{nlevels}, Multiclass{nlevels})
    T >: Missing && (S = Union{S,Missing})
    return AbstractArray{S,N}
end

# Table scitype

function ScientificTypes.scitype(X, ::MLJ, ::Val{:table}; kw...)
    Xcol = Tables.columns(X)
    col_names = propertynames(Xcol)
    types = map(col_names) do name
        scitype(getproperty(Xcol, name); kw...)
    end
    return Table{Union{types...}}
end

# Scitype for fast array broadcasting

ScientificTypes.Scitype(::Type{<:Integer},        ::MLJ) = Count
ScientificTypes.Scitype(::Type{<:AbstractFloat},  ::MLJ) = Continuous
ScientificTypes.Scitype(::Type{<:AbstractString}, ::MLJ) = Textual
