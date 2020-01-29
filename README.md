# MLJScientificTypes.jl

| [MacOS/Linux] | Coverage |
| :-----------: | :------: |
| [![Build Status](https://travis-ci.org/alan-turing-institute/MLJScientificTypes.jl.svg?branch=master)](https://travis-ci.org/alan-turing-institute/MLJScientificTypes.jl) | [![codecov.io](http://codecov.io/github/alan-turing-institute/MLJScientificTypes.jl/coverage.svg?branch=master)](http://codecov.io/github/alan-turing-institute/MLJScientificTypes.jl?branch=master) |

Implementation of the MLJ convention for [Scientific Types](https://github.com/alan-turing-institute/ScientificTypes.jl).
Scientific Types makes the distinction between **machine type** and
**scientific type**:

* the _machine type_ is a Julia type the data is currently encoded as (for instance: `Float64`)
* the _scientific type_ is a type defined by this package which
  encapsulates how the data should be _interpreted_ (for instance:
  `Continuous` or `Multiclass`)

Determining what scientific type should be given to what data is determined
by a convention such as the one this package implements which is the one
in use in the [MLJ](https://github.com/alan-turing-institute/MLJ.jl) universe.

## Very quick start

For more information and examples please refer to [the
manual](https://alan-turing-institute.github.io/MLJScientificTypes.jl/dev).

```julia
using MLJScientificTypes, DataFrames
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

Detail is obtained in the obvious way; for example:

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
│ d       │ CategoricalValue{Int64,UInt32}                │ Multiclass{2}                 │
│ e       │ Union{Missing, CategoricalValue{Char,UInt32}} │ Union{Missing, Multiclass{2}} │
└─────────┴──────────────────────────────────────────────┴───────────────────────────────┘
_.nrows = 5

```

Note that a warning is shown as you ask to convert a `Union{Missing,T}` to a
`S` which ultimately results in a `Union{Missing,S}`. See the docs for more
details. Compare with the following call which leads to the same result but
shows no warning:

```
Xc = coerce(X, :b=>Union{Missing,Count}, :d=>Multiclass, :e=>Union{Missing,Multiclass})
