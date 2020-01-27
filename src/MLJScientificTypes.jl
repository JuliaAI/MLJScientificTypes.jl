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
       Binary, ColorImage, GrayImage
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

include("table.jl")
include("utils.jl")
include("coerce.jl")

include("scitype/utils.jl")
include("scitype/infinite.jl")
include("scitype/finite.jl")
include("scitype/images.jl")

end # module
