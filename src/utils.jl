"""
    is_type(X, spkg, stype)

Check that an object `X` is of a given type that may be defined in a package
that is not loaded in the current environment.
As an example say `DataFrames` is not loaded in the current environment, a
function from some package could still return a DataFrame in which case it
can be checked with

```
is_type(X, :DataFrames, :DataFrame)
```
"""
function is_type(X, spkg::Symbol, stype::Symbol)
    # If the package is loaded, then it will just be `stype`
    # otherwise it will be `spkg.stype`
    rx = Regex("^($spkg\\.)?$stype")
    return ifelse(match(rx, "$(typeof(X))") === nothing, false, true)
end

# Add a nicer show functionality to `ScientificTypes.Schema` using
# Tables and PrettyTables
function Base.show(io::IO, ::MIME"text/plain", s::ScientificTypes.Schema)
    data   = Tables.matrix(s.table)
    header = ["_.names", "_.types", "_.scitypes"]
    println(io, "_.table = ")
    pretty_table(io, data, header;
                 header_crayon=Crayon(bold=false),
                 alignment=:l)
    println(io, "_.nrows = $(s.nrows)")
end
