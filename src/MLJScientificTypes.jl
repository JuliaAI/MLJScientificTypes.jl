module MLJScientificTypes

# Dependencies
using ScientificTypes
using Tables, CategoricalArrays, ColorTypes, PrettyTables

# re-exports from ScientificTypes
export Scientific, Found, Unknown, Known, Finite, Infinite,
       OrderedFactor, Multiclass, Count, Continuous, Textual,
       Binary, ColorImage, GrayImage, Image, Table
export scitype, scitype_union, elscitype, nonmissing, trait

# exports
export coerce, coerce!, autotype, schema, info

# -------------------------------------------------------------
# Abbreviations

const ST   = ScientificTypes
const Arr  = AbstractArray
const CArr = CategoricalArray
const Cat  = CategoricalValue

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
