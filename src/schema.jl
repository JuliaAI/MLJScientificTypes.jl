#=
Functionalities supporting the schema of `X` when `X` is a `Tables.jl`
compatible table.
=#
struct Schema{names, types, scitypes, nrows} end

"""
    Schema(names, types, scitypes, nrows)

Constructor for a `Schema` object.
"""
function Schema(names::Tuple{Vararg{Symbol}}, types::Type{T},
                scitypes::Type{S}, nrows::Integer) where {T<:Tuple,S<:Tuple}
    return Schema{names,T,S,nrows}()
end

Schema(names, types, scitypes, nrows) =
    Schema{Tuple(Symbol.(names)), Tuple{types...}, Tuple{scitypes...}, nrows}()

if VERSION < v"1.1"
    fieldtypes(t) = Tuple(fieldtype(t, i) for i = 1:fieldcount(t))
end

function Base.getproperty(sch::Schema{names, types, scitypes, nrows},
                          field::Symbol) where {names, types, scitypes, nrows}
    if field === :names
        return names
    elseif field === :types
        return types === nothing ? nothing : fieldtypes(types)
    elseif field === :scitypes
        return scitypes === nothing ? nothing : fieldtypes(scitypes)
    elseif field === :nrows
        return nrows === nothing ? nothing : nrows
    else
        throw(ArgumentError("unsupported property for ScientificTypes.Schema"))
    end
end

Base.propertynames(sch::Schema) = (:names, :types, :scitypes, :nrows)


"""
    schema(X)

Inspect the column types and scitypes of a tabular object.

## Example

```
X = (ncalls=[1, 2, 4], mean_delay=[2.0, 5.7, 6.0])
schema(X)
```
"""
schema(X; kw...) = schema(X, Val(trait(X)); kw...)

# Fallback
schema(X, ::Val{:other}; kw...) =
    throw(ArgumentError("Cannot inspect the internal scitypes of "*
                        "a non-tabular object. "))

function schema(X, ::Val{:table}; kw...)
    sch    = Tables.schema(X)
    sch === nothing && return nothing
    Xcol   = Tables.columntable(X)
    names  = sch.names
    types  = Tuple{sch.types...}
    stypes = Tuple{(elscitype(getproperty(Xcol, n); kw...) for n in names)...}
    return Schema(names, types, stypes, _nrows(X))
end

function _nrows(X)
    Tables.columnaccess(X) || return length(collect(X))
    # if has columnaccess
    cols = Tables.columntable(X)
    !isempty(cols) || return 0
    return length(cols[1])
end

function Base.show(io::IO, ::MIME"text/plain", s::Schema)
    data = Tables.matrix((
                names=collect(s.names),
                types=collect(s.types),
                scitypes=collect(s.scitypes)
                ))
    header = ["_.names", "_.types", "_.scitypes"]
    pretty_table(io, data, header;
                 header_crayon=Crayon(bold=false),
                 alignment=:l)
    println(io, "_.nrows = $(s.nrows)")
end

# overload StatisticalTraits function:
info(X, ::Val{:table}) = schema(X)
