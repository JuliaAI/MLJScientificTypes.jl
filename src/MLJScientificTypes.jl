module MLJScientificTypes

# Dependencies
using ScientificTypes
using Tables, CategoricalArrays, ColorTypes, PrettyTables

# Exports
export Table
export categorical, coerce, coerce!, autotype

# Re-exports from ScientificTypes
export Scientific, Found, Unknown, Finite, Infinite,
       OrderedFactor, Multiclass, Count, Continuous, Textual,
       Binary, ColorImage, GrayImage, trait
export scitype, scitype_union, elscitype, schema, info, nonmissing

# -------------------------------------------------------------

# Abbreviations
const ST   = ScientificTypes
const Arr  = AbstractArray
const CArr = CategoricalArray
const Cat  = Union{CategoricalValue,CategoricalString}

# Indicate the convention
struct MLJ <: Convention end

include("init.jl")

# -------------------------------------------------------------
# Includes

include("utils.jl")
include("coerce.jl")
include("autotype.jl")

include("convention/utils.jl")
include("convention/table.jl")
include("convention/infinite.jl")
include("convention/finite.jl")
include("convention/images.jl")

end # module
