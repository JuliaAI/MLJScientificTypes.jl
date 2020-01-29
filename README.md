# MLJScientificTypes.jl

Implementation of the MLJ convention for [Scientific Types](https://github.com/alan-turing-institute/ScientificTypes.jl).

BELOW IS STALE README


## Very quick start

For more information and examples please refer to [the
manual](https://alan-turing-institute.github.io/ScientificTypes.jl/dev).

ScientificTypes.jl is primary built around an *interface* for articulating a
convention about the scientific interpretation of data.
This consists of
- a definition of a scientific type hierarchy
- a function `scitype` with scientific types as values

Someone implementing a convention must add methods to this function, while the general user just applies it to data, as in `scitype(4.5)` (returning `Continuous` in the *MLJ* convention).
- Convenience methods for working with scientific types, the most commonly
  used being
  	- `schema(X)`, which returns a `NamedTuple` gathering informations about
	  the types and scitypes of `X`,
	- `elscitype(A)`, which returns the `scitype` of the elements of `A` if `A`
	  is an `AbstractArray`.

For example,

```julia
using ScientificTypes, DataFrames
X = DataFrame(
    a = randn(5),
    b = [-2.0, 1.0, 2.0, missing, 3.0],
    c = [1, 2, 3, 4, 5],
    d = [0, 1, 0, 1, 0],
    e = ['M', 'F', missing, 'M', 'F'],
    )
sch = schema(X) # schema is overloaded in ScientificTypes
```

will print

```
_.table =
┌─────────┬─────────────────────────┬────────────────────────────┐
│ _.names │ _.types                 │ _.scitypes                 │
├─────────┼─────────────────────────┼────────────────────────────┤
│ a       │ Float64                 │ Continuous                 │
│ b       │ Union{Missing, Float64} │ Union{Missing, Continuous} │
│ c       │ Int64                   │ Count                      │
│ d       │ Int64                   │ Count                      │
│ e       │ Union{Missing, Char}    │ Union{Missing, Unknown}    │
└─────────┴─────────────────────────┴────────────────────────────┘
_.nrows = 5
```

Here the default *MLJ* convention is being applied ((cf. [docs](https://alan-turing-institute.github.io/ScientificTypes.jl/dev/#The-MLJ-convention-1)). Detail is obtained in the obvious way; for example:

```julia
julia> sch.names
(:a, :b, :c, :d, :e)
```

Now you could want to specify that `b` is actually a `Count`, and that `d` and `e` are `Multiclass`; this is done with the `coerce` function:

```julia
Xc = coerce(X, :b=>Count, :d=>Multiclass, :e=>Multiclass)
schema(Xc)
```

which prints

```
_.table =
┌─────────┬──────────────────────────────────────────────┬───────────────────────────────┐
│ _.names │ _.types                                      │ _.scitypes                    │
├─────────┼──────────────────────────────────────────────┼───────────────────────────────┤
│ a       │ Float64                                      │ Continuous                    │
│ b       │ Union{Missing, Int64}                        │ Union{Missing, Count}         │
│ c       │ Int64                                        │ Count                         │
│ d       │ CategoricalValue{Int64,UInt8}                │ Multiclass{2}                 │
│ e       │ Union{Missing, CategoricalValue{Char,UInt8}} │ Union{Missing, Multiclass{2}} │
└─────────┴──────────────────────────────────────────────┴───────────────────────────────┘
_.nrows = 5

```
