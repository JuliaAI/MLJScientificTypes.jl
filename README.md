# MLJScientificTypes.jl

| Linux | Coverage | Documentation |
| :-----------: | :------: | :-----------: |
| [![Build Status](https://github.com/JuliaAI/MLJScientificTypes.jl/workflows/CI/badge.svg)](https://github.com/JuliaAI/MLJScientificTypes.jl/actions) | [![codecov.io](http://codecov.io/github/JuliaAI/MLJScientificTypes.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaAI/MLJScientificTypes.jl?branch=master) | [![](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaAI.github.io/MLJScientificTypes.jl/dev)

**This repository is now deprecated.** The last supported release is
MLJScientificTypes
0.4.8. [ScientificTypes](https://github.com/JuliaAI/ScientificTypes.jl)
2.0 and higher now serves the original purpose of MLJScientificTypes,
implementing a scientific type convention called `DefaultConvention`
(but previously known as the `MLJ` convention). 

The scientific types themselves (on which all scientific type
conventions are based) are now defined in
[ScientificTypesBase](https://github.com/JuliaAI/ScientificTypesBase.jl). Previously
ScientificTypes (versions 1.1.1 and lower) defined the basic types and
API.

---

Implementation of a convention for [scientific
types](https://github.com/JuliaAI/ScientificTypes.jl),
as used in the [MLJ
universe](https://github.com/JuliaAI/MLJ.jl).

**Important note.** While this document refers to the *MLJ convention*,
this convention could (and, hopefully, will) be adopted in
statistical/scientific software outside of the MLJ project. Of its
dependencies, only the tiny package
[ScientificTypes.jl](https://github.com/JuliaAI/ScientificTypes.jl)
has any direct connection to MLJ.

This package makes a distinction between **machine type** and
**scientific type** of a Julia object:

* The _machine type_ refers to the Julia type being used to represent
  the object (for instance, `Float64`).

* The _scientific type_ is one of the types defined in
  [ScientificTypes.jl](https://github.com/JuliaAI/ScientificTypes.jl)
  reflecting how the object should be _interpreted_ (for instance,
  `Continuous` or `Multiclass`).


#### Contents

 - [Installation](#installation)
 - [Who is this repository for?](#who-is-this-repository-for)
 - [What's provided here?](#what-is-provided-here)
 - [Very quick start](#very-quick-start)

## Installation

```julia
using Pkg
Pkg.add(MLJScientificTypes)
```

## Who is this repository for?

This repository has two kinds of users in mind:
 
- users of software in the [MLJ
  universe](https://github.com/JuliaAI/MLJ.jl) seeking a
  deeper understanding of the use of scientific types and associated
  tools; *these users do not need to directly install this package*
  but may find its documentation helpful

- developers of statistical and scientific software who want to
  articulate their data type requirements in a generic,
  purpose-oriented way, and who are furthermore happy to adopt an
  existing convention about what data types should be used for
  what purpose (a convention that has been successfully adopted in an
  existing large scale Julia project)

Developers interested in implementing a different convention will
instead import [Scientific
Types.jl](https://github.com/JuliaAI/ScientificTypes.jl),
following the documentation there, possibly using this repo as a
template.

## What's provided here?

The module `MLJScientificTypes` defined in this repo rexports the
scientific types and associated methods defined in [Scientific
Types.jl](https://github.com/JuliaAI/ScientificTypes.jl)
and provides:

- a collection of `ScientificTypes.scitype` definitions that
  articulate the MLJ convention, importing the module automatically
  activating the convention

- a `coerce` function, for changing machine types to reflect a specified
  scientific interpretation (scientific type)

- an `autotype` fuction for "guessing" the intended scientific type of data 


## Very quick start

For more information and examples please refer to [the
manual](https://JuliaAI.github.io/MLJScientificTypes.jl/dev).

```julia
using MLJScientificTypes, DataFrames
X = DataFrame(
    a = randn(5),
    b = [-2.0, 1.0, 2.0, missing, 3.0],
    c = [1, 2, 3, 4, 5],
    d = [0, 1, 0, 1, 0],
    e = ['M', 'F', missing, 'M', 'F'],
    )
sch = schema(X)
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

To specify that instead `b` should be regared as `Count`, and that both `d` and `e` are `Multiclass`, we use the `coerce` function:

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
│ d       │ CategoricalValue{Int64,UInt32}               │ Multiclass{2}                 │
│ e       │ Union{Missing, CategoricalValue{Char,UInt32}}│ Union{Missing, Multiclass{2}} │
└─────────┴──────────────────────────────────────────────┴───────────────────────────────┘
_.nrows = 5

```

