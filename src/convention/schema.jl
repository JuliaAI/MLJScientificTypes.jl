#=
Functionalities supporting the schema of `X` when `X` is a `Tables.jl`
compatible table.
=#

function ST.schema(X, ::Val{:table}; kw...)
    sch    = Tables.schema(X)
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

ST.info(X, ::Val{:table}) = schema(X)

# Add a nicer show functionality to `ST.Schema` using
# Tables and PrettyTables
function Base.show(io::IO, ::MIME"text/plain", s::ST.Schema)
    data = Tables.matrix((
                names=collect(s.names),
                types=collect(s.types),
                scitypes=collect(s.scitypes) .|> _compact_scitype
                ))
    header = ["_.names", "_.types", "_.scitypes"]
    println(io, "_.table = ")
    pretty_table(io, data, header;
                 header_crayon=Crayon(bold=false),
                 alignment=:l)
    println(io, "_.nrows = $(s.nrows)")
end

# These functions help avoid showing scientific types as
# `ScientificTypes.Continuous`
function _compact_scitype(st::Type{T}) where T <: ST.Found
    t = match(r"(?:ScientificTypes\.)?(.*)", string(T)).captures[1]
    return Symbol(t)
end

function _compact_scitype(st::Type{Union{Missing, T}}) where T <: ST.Found
    U = _compact_scitype(nonmissing(T))
    return Symbol("Union{Missing, $U}")
end
