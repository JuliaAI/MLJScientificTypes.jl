"""
    coerce(A, ...; tight=false, verbosity=1)

Given a table `A`, return a copy of `A` ensuring that the scitype of the
columns match new specifications.
The specifications can be given as a a bunch of `colname=>Scitype` pairs or
as a dictionary whose keys are names and values are scientific types:

```
coerce(X, col1=>scitype1, col2=>scitype2, ... ; verbosity=1)
coerce(X, d::AbstractDict; verbosity=1)
```

One can also specify pairs of type `T1=>T2` in which case all columns with
scientific element type subtyping `Union{T1,Missing}` will be coerced to the
new specified scitype `T2`.

## Examples

Specifiying (name, scitype) pairs:

```
using CategoricalArrays, DataFrames, Tables
X = DataFrame(name=["Siri", "Robo", "Alexa", "Cortana"],
              height=[152, missing, 148, 163],
              rating=[1, 5, 2, 1])
Xc = coerce(X, :name=>Multiclass, :height=>Continuous, :rating=>OrderedFactor)
schema(Xc).scitypes # (Multiclass, Continuous, OrderedFactor)
```

Specifying (T1, T2) pairs:

```
X  = (x = [1, 2, 3],
      y = rand(3),
      z = [10, 20, 30])
Xc = coerce(X, Count=>Continuous)
schema(Xfixed).scitypes # (Continuous, Continuous, Continuous)
```
"""
function coerce end

function coerce(X, types_dict::AbstractDict; kw...)
    isempty(types_dict) && return X
    ScientificTypes.trait(X) == :table || error("Non-tabular data encountered.")
    names  = schema(X).names
    X_ct   = Tables.columntable(X)
    ct_new = (_coerce_col(X_ct, col, types_dict; kw...) for col in names)
    return Tables.materializer(X)(NamedTuple{names}(ct_new))
end

# allow passing pairs like :feature1=>Continuous
coerce(X, types_pairs::Pair{Symbol,<:Type}...; kw...) =
    coerce(X, Dict(types_pairs); kw...)

# allow passing rules like Count=>Continuous
function coerce(X, types_pairs::Pair{<:Type,<:Type}...; kw...)
    from_types = [tp.first  for tp in types_pairs]
    to_types   = [tp.second for tp in types_pairs]
    types_dict = Dict{Symbol,Type}()
    # retrieve the names that match the from_types
    sch = schema(X)
    for (name, st) in zip(sch.names, sch.scitypes)
        j   = findfirst(ft -> Union{Missing,ft} >: st, from_types)
        j === nothing && continue
        # if here then `name` is concerned by the change
        tt = to_types[j]
        types_dict[name] = ifelse(st >: Missing, Union{Missing,tt}, tt)
    end
    coerce(X, types_dict; kw...)
end

# -------------------------------------------------------------
# utilities for coerce

function _coerce_col(X, name, types_dict::AbstractDict; kw...)
    y = getproperty(X, name)
    haskey(types_dict, name) && return coerce(y, types_dict[name]; kw...)
    return y
end

# -------------------------------------------------------------
# In place coercion for dataframe

"""
coerce!(X, ...)

Same as [`ScientificTypes.coerce`](@ref) except it does the modification in
place provided `X` supports in-place modification (at the moment, only the
DataFrame! does). An error is thrown otherwise. The arguments are the same as
`coerce`.
"""
function coerce!(X, args...; kw...)
    # DataFrame --> coerce_dataframe! (see convention)
    is_type(X, :DataFrames, :DataFrame) && return coerce_df!(X, args...; kw...)
    # Everything else
    throw(ArgumentError("In place coercion not supported for $(typeof(X))." *
                        "Try `coerce` instead."))
end

coerce!(X, types::Dict; kw...) = coerce!(X, (p for p in types)..., kw...)

function coerce_df!(df, pairs::Pair{Symbol}...; kw...)
    names = schema(df).names
    types = Dict(pairs)
    for name in names
        name in keys(types) || continue
        # for DataFrames >= 0.19 df[!, name] = coerce(df[!, name], types(name))
        # but we want something that works more robustly... even for older
        # DataFrames; the only way to do this is to use the
        # `df.name = something` but we cannot use setindex! without throwing
        # a deprecation warning... metaprogramming to the rescue!
        name_str = "$name"
        ex = quote
            $df.$name = coerce($df.$name, $types[Symbol($name_str)], $kw...)
        end
        eval(ex)
    end
    return df
end

# -------------------------------------------------------------
# utilities for coerce!

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
