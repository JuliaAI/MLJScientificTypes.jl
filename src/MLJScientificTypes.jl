module MLJScientificTypes

# Dependencies
using ScientificTypes
using Tables, CategoricalArrays, ColorTypes, PrettyTables

# Exports
export Table
export categorical, coerce, coerce!, autotype

# Re-exports from ScientificTypes
export scitype, scitype_union, elscitype, schema, info, nonmissing

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
include("autotype.jl")

include("convention/table.jl")
include("convention/schema.jl")
include("convention/scitype.jl")
include("convention/coerce.jl")

end # module
