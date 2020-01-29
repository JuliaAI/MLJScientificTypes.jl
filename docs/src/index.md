# MLJScientificTypes.jl

Implementation of the MLJ convention for
[Scientific Types](https://github.com/alan-turing-institute/ScientificTypes.jl).
Scientific Types allow the distinction between **machine type** and
**scientific type**:

* the _machine type_ is a Julia type the data is currently encoded as (for
instance: `Float64`)
* the _scientific type_ is a type defined by this package which
  encapsulates how the data should be _interpreted_ (for instance:
  `Continuous` or `Multiclass`)

Determining what scientific type should be given to what data is determined
by a convention such as the one this package implements which is the one
in use in the [MLJ](https://github.com/alan-turing-institute/MLJ.jl) universe.

## Type hierarchy

The supported scientific types have the following hierarchy:

```
Found
├─ Known
│  ├─ Finite
│  │  ├─ Multiclass
│  │  └─ OrderedFactor
│  ├─ Infinite
│  │  ├─ Continuous
│  │  └─ Count
│  ├─ Image
│  │  ├─ ColorImage
│  │  └─ GrayImage
|  ├─ Textual
│  └─ Table
└─ Unknown
```

## Getting started

The package is registered and can be installed via the package manager with
`add MLJScientificTypes`.

To get the scientific type of a Julia object according to the MLJ convention,
call `scitype`:

```@example 1
using MLJScientificTypes # hide
scitype(3.14)
```

For a vector, you can use `scitype` or `elscitype` (which will give you a
scitype corresponding to the elements):

```@example 1
scitype([1,2,3,missing])
```

```@example 1
elscitype([1,2,3,missing])
```

For an iterable, you can use `scitype_union` which gives you the tightest union
of scitypes corresponding to the elements:

```@example 1
scitype_union((ifelse(isodd(i), i, missing) for i in 1:5))
```

note that `scitype_union` has to go over all elements which is slow whereas
`scitype` and `elscitype` can often be immediately returned upon inspection of  
the machine type.

## Type coercion for tabular data

The standard workflow involves the following two steps:

1. inspect the `schema` of the data and the `scitypes` in particular
1. provide pairs or a dictionary with column names and scitypes for any changes
you may want and coerce the data to those scitypes

```@example 2
using MLJScientificTypes # hide
using DataFrames, Tables
X = DataFrame(
     name=["Siri", "Robo", "Alexa", "Cortana"],
     height=[152, missing, 148, 163],
     rating=[1, 5, 2, 1])
schema(X)
```

inspecting the scitypes:

```@example 2
schema(X).scitypes
```

but in this case you may want to map the names to `Multiclass`, the height to
`Continuous` and the ratings to `OrderedFactor`; to do so use the `coerce`
function:

```@example 2
Xfixed = coerce(X, :name=>Multiclass,
                   :height=>Continuous,
                   :rating=>OrderedFactor)
schema(Xfixed).scitypes
```

Note that, as it encountered missing values in `height` it coerced the type to
`Union{Missing,Continuous}` and a warning is issued (to avoid such warnings,
coerce to `Union{Missing,T}` where appropriate)

One can also make a replacement based on existing scientific type, instead of
feature name:

```@example 2
X  = (x = [1, 2, 3],
      y = rand(3),
      z = [10, 20, 30])
Xfixed = coerce(X, Count=>Continuous)
schema(Xfixed).scitypes
```

Finally there is a `coerce!` method that does in-place coercion provided the
data structure allows it (at the moment only `DataFrames.DataFrame` is
supported).

## Notes

- We regard the built-in Julia type `Missing` as a scientific type. The new scientific types introduced in the current package are rooted in the abstract type `Found` (see tree above).
- `Finite{N}`, `Multiclass{N}` and `OrderedFactor{N}` are all parametrised by the number of levels `N`. We export the alias `Binary = Finite{2}`.
- `Image{W,H}`, `GrayImage{W,H}` and `ColorImage{W,H}` are all parametrised by the image width and height dimensions, `(W, H)`.
- The function `scitype` has the fallback value `Unknown`.

### Special note on binary data

MLJScientificTypes does not define a separate "binary" scientific
type. Rather, when binary data has an intrinsic "true" class (for example
pass/fail in a product test), then it should be assigned an
`OrderedFactor{2}` scitype, while data with no such class (e.g., gender)
should be assigned a `Multiclass{2}` scitype. In the former case
we recommend that the "true" class come after "false" in the ordering
(corresponding to the usual assignment "false=0" and "true=1"). Of
course, `Finite{2}` covers both cases of binary data.


## Detailed usage examples

```@example 3
using MLJScientificTypes # hide
using CategoricalArrays
scitype((2.718, 42))
```

Let's try with categorical valued objects:

```@example 3
v = categorical(['a', 'c', 'a', missing, 'b'], ordered=true)
scitype(v[1])
```

and

```@example 3
elscitype(v)
```

you could coerce this to `Multiclass`:

```@example 3
w = coerce(v, Union{Missing,Multiclass})
elscitype(w)
```

## Working with tables

```@example 4
using MLJScientificTypes # hide
data = (x1=rand(10), x2=rand(10))
scitype(data)
```

you can also use `schema`:

```@example 4
schema(data)
```

and use `<:` for type checks:

```@example 4
scitype(data) <: Table(Continuous)
```

```@example 4
scitype(data) <: Table(Infinite)
```

or specify multiple types directly:

```@example 4
data = (x=rand(10), y=collect(1:10), z = [1,2,3,1,2,3,1,2,3,1])
data = coerce(data, :z=>OrderedFactor)
scitype(data) <: Table(Continuous,Count,OrderedFactor)
```

## Tuples, arrays and tables

**Important Definition 1** Under any convention, the scitype of a tuple is a
`Tuple` type parametrised by scientific types:

```@example 5
using MLJScientificTypes #hide
scitype((1, 4.5))
```

**Important Definition 2** The scitype of an `AbstractArray`, `A`, is
always`AbstractArray{U}` where `U` is the union of the scitypes of the
elements of `A`, with one exception: If `typeof(A) <:
AbstractArray{Union{Missing,T}}` for some `T` different from `Any`,
then the scitype of `A` is `AbstractArray{Union{Missing, U}}`, where
`U` is the union over all non-missing elements, **even if `A` has no
missing elements**.

This exception is made for performance reasons. If one wants to override it,
one uses `scitype(A, tight=true)`.

```@example 5
v = [1.3, 4.5, missing]
scitype(v)
```

```@example 5
scitype(v[1:2])
```

```@example 5
scitype(v[1:2], tight=true)
```

*Performance note:* Computing type unions over large arrays is
expensive and, depending on the convention's implementation and the
array eltype, computing the scitype can be slow.
In the *MLJ* convention this is mitigated with the help of the
`ScientificTypes.Scitype` method, of which other conventions could make use.
Do `?ScientificTypes.Scitype` for details.
An eltype `Any` may lead to poor performances and you may want to consider
replacing an array `A` with `broadcast(identity, A)` to collapse the eltype and
speed up the computation.

Any table implementing the Tables interface has a scitype encoding the scitypes
of its columns:

```@example 5
using CategoricalArrays
X = (x1=rand(10),
     x2=rand(10),
     x3=categorical(rand("abc", 10)),
     x4=categorical(rand("01", 10)))
schema(X)
```

**Important Definition 3** Specifically, if `X` has columns `c1, ...,
cn`, then

```julia
scitype(X) == Table{Union{scitype(c1), ..., scitype(cn)}}
```

With this definition, common type checks can be performed with tables.
For instance, you could check that each column of `X` has an element scitype that is either
`Continuous` or `Finite`:

```@example 5
scitype(X) <: Table{<:Union{AbstractVector{<:Continuous}, AbstractVector{<:Finite}}}
```

A built-in `Table` constructor provides a shorthand for the right-hand side:

```@example 5
scitype(X) <: Table(Continuous, Finite)
```

Note that `Table(Continuous,Finite)` is a *type* union and not a `Table` *instance*.

## The MLJ convention

The table below summarises the *MLJ* convention for representing
scientific types:

Type `T`        | `scitype(x)` for `x::T`           | package required
:-------------- | :-------------------------------- | :------------------------
`Missing`       | `Missing`                         |
`AbstractFloat` | `Continuous`                      |
`Integer`       |  `Count`                          |
`String`        | `Textual`                         |
`CategoricalValue` | `Multiclass{N}` where `N = nlevels(x)`, provided `x.pool.ordered == false`  | CategoricalArrays
`CategoricalString` | `Multiclass{N}` where `N = nlevels(x)`, provided `x.pool.ordered == false`  | CategoricalArrays
`CategoricalValue` | `OrderedFactor{N}` where `N = nlevels(x)`, provided `x.pool.ordered == true`| CategoricalArrays
`CategoricalString` | `OrderedFactor{N}` where `N = nlevels(x)` provided `x.pool.ordered == true` | CategoricalArrays
`AbstractArray{<:Gray,2}` | `GrayImage{W,H}` where `(W, H) = size(x)`                                   | ColorTypes
`AbstractArrray{<:AbstractRGB,2}` | `ColorImage{W,H}` where `(W, H) = size(x)`                                  | ColorTypes
any table type `T` supported by Tables.jl | `Table{K}` where `K=Union{column_scitypes...}`                      | Tables

Here `nlevels(x) = length(levels(x.pool))`.


## Automatic type conversion

The `autotype` function allows to use specific rules in order to guess
appropriate scientific types for *tabular* data. Such rules would typically be
more constraining than the ones implied by the active convention. When
`autotype` is used, a dictionary of suggested types is returned for each column
in the data; if none of the specified rule applies, the ambient convention is
used as "fallback".

The function is called as:

```julia
autotype(X)
```

If the keyword `only_changes` is passed set to `true`, then only the column names for which the suggested type is different from that provided by the convention are returned.

```julia
autotype(X; only_changes=true)
```

To specify which rules are to be applied, use the `rules` keyword  and specify a tuple of symbols referring to specific rules; the default rule is `:few_to_finite` which applies a heuristic for columns which have relatively few values, these columns are then encoded with an appropriate `Finite` type.
It is important to note that the order in which the rules are specified matters; rules will be applied in that order.

```julia
autotype(X; rules=(:few_to_finite,))
```

Finally, you can also use the following shorthands:

```julia
autotype(X, :few_to_finite)
autotype(X, (:few_to_finite, :discrete_to_continuous))
```

### Available rules

Rule symbol               | scitype suggestion
:------------------------ | :---------------------------------
`:few_to_finite`          | an appropriate `Finite` subtype for columns with few distinct values
`:discrete_to_continuous` | if not `Finite`, then `Continuous` for any `Count` or `Integer` scitypes/types
`:string_to_multiclass`        | `Multiclass` for any string-like column

Autotype can be used in conjunction with `coerce`:

```
X_coerced = coerce(X, autotype(X))
```

### Examples

By default it only applies the `:few_to_many` rule

```@example auto
using MLJScientificTypes # hide
n = 50
X = (a = rand("abc", n),         # 3 values, not number        --> Multiclass
     b = rand([1,2,3,4], n),     # 4 values, number            --> OrderedFactor
     c = rand([true,false], n),  # 2 values, number but only 2 --> Multiclass
     d = randn(n),               # many values                 --> unchanged
     e = rand(collect(1:n), n))  # many values                 --> unchanged
autotype(X, only_changes=true)
```

For example, we could first apply the `:discrete_to_continuous` rule,
followed by `:few_to_finite` rule. The first rule will apply to `b` and `e`
but the subsequent application of the second rule will mean we will
get the same result apart for `e` (which will be `Continuous`)

```@example auto
autotype(X, only_changes=true, rules=(:discrete_to_continuous, :few_to_finite))
```

One should check and possibly modify the returned dictionary
before passing to `coerce`.
