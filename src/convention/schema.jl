#=
Functionalities supporting the schema of `X` when `X` is a `Tables.jl`
compatible table.
=#

function ScientificTypes.schema(X, ::Val{:table}; kw...)
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

# Add a nicer show functionality to `ScientificTypes.Schema` using
# Tables and PrettyTables
function Base.show(io::IO, ::MIME"text/plain", s::ScientificTypes.Schema)
    data = Tables.matrix((
                names=collect(s.names),
                types=collect(s.types),
                scitypes=collect(s.scitypes)
                ))
    header = ["_.names", "_.types", "_.scitypes"]
    println(io, "_.table = ")
    pretty_table(io, data, header;
                 header_crayon=Crayon(bold=false),
                 alignment=:l)
    println(io, "_.nrows = $(s.nrows)")
end

ScientificTypes.info(X, ::Val{:table}) = schema(X)
