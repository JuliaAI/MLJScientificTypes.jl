# Basic scitype

ST.scitype(::Integer,        ::MLJ) = Count
ST.scitype(::AbstractFloat,  ::MLJ) = Continuous
ST.scitype(::AbstractString, ::MLJ) = Textual
ST.scitype(::TimeType,       ::MLJ) = ScientificTimeType
ST.scitype(::Time    ,       ::MLJ) = ScientificTime
ST.scitype(::Date,           ::MLJ) = ScientificDate
ST.scitype(::DateTime,       ::MLJ) = ScientificDateTime

ST.scitype(img::Arr{<:Gray,2}, ::MLJ) = GrayImage{size(img)...}
ST.scitype(img::Arr{<:AbstractRGB,2}, ::MLJ) =
ColorImage{size(img)...}

# CategoricalArray scitype

function ST.scitype(c::Cat, ::MLJ)
    nc = length(levels(c.pool))
    return ifelse(c.pool.ordered, OrderedFactor{nc}, Multiclass{nc})
end

function ST.scitype(A::CArr{T,N}, ::MLJ) where {T,N}
    nlevels = length(levels(A))
    S = ifelse(isordered(A), OrderedFactor{nlevels}, Multiclass{nlevels})
    T >: Missing && (S = Union{S,Missing})
    return AbstractArray{S,N}
end

# Table scitype

function ST.scitype(X, ::MLJ, ::Val{:table}; kw...)
    Xcol = Tables.columns(X)
    col_names = propertynames(Xcol)
    types = map(col_names) do name
        scitype(getproperty(Xcol, name); kw...)
    end
    return Table{Union{types...}}
end

# Scitype for fast array broadcasting

ST.Scitype(::Type{<:Integer},        ::MLJ) = Count
ST.Scitype(::Type{<:AbstractFloat},  ::MLJ) = Continuous
ST.Scitype(::Type{<:AbstractString}, ::MLJ) = Textual
ST.Scitype(::Type{<:TimeType},         ::MLJ) = ScientificTimeType
ST.Scitype(::Type{<:Date},             ::MLJ) = ScientificDate
ST.Scitype(::Type{<:Time},             ::MLJ) = ScientificTime
ST.Scitype(::Type{<:DateTime},         ::MLJ) = ScientificDateTime
