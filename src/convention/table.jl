"""
MLJScientificTypes.Table{K}

The scientific type for tabular data (a container `X` for which
`Tables.is_table(X)=true`).

If `X` has columns `c1, c2, ..., cn`, then, by definition,

```
scitype(X) = Table{Union{scitype(c1), scitype(c2), ..., scitype(cn)}}
```

A special constructor of `Table` types exists:

```
Table(T1, T2, T3, ..., Tn) <: Table
```

with the property that

```
scitype(X) <: Table(T1, T2, T3, ..., Tn)
```

if and only if `X` is a table *and*, for every column `col` of `X`,
`scitype(col) <: AbstractVector{<:Tj}`, for some `j` between `1` and
`n`.

Note that this constructor constructs a *type* not an instance,
as instances of scientific types play no role (except for missing).

## Example

```
X = (x1 = [10.0, 20.0, missing],
            x2 = [1.0, 2.0, 3.0],
            x3 = [4, 5, 6])
scitype(X) <: MLJBase.Table(Continuous, Count) # false
scitype(X) <: MLJBase.Table(Union{Continuous, Missing}, Count) # true
```
"""
struct Table{K} <: Known end

function Table(Ts...)
    if !(Union{Ts...} <: Scientific)
        error("Arguments of Table scitype constructor "*
              "must be scientific types. ")
    end
    return Table{<:Union{[AbstractVector{<:T} for T in Ts]...}}
end
