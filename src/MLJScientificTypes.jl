module MLJScientificTypes

# Dependencies
using ScientificTypes
using Tables, CategoricalArrays, ColorTypes, PrettyTables

# Exports
export categorical, coerce, coerce!, autotype, schema, info

# Re-exports from ScientificTypes
export Scientific, Found, Unknown, Known, Finite, Infinite,
       OrderedFactor, Multiclass, Count, Continuous, Textual,
       Binary, ColorImage, GrayImage, Table
export scitype, scitype_union, elscitype, nonmissing

# -------------------------------------------------------------
# Abbreviations

const ST   = ScientificTypes
const Arr  = AbstractArray
const CArr = CategoricalArray
const Cat  = Union{CategoricalValue,CategoricalString}

# Indicate the convention, see init.jl where it is set.
struct MLJ <: Convention end

include("init.jl")

# -------------------------------------------------------------
# Includes

include("coerce.jl")
include("schema.jl")
include("autotype.jl")

include("convention/scitype.jl")
include("convention/coerce.jl")

end # module
