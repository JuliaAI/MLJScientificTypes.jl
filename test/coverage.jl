@testset "misc" begin
    # finite.jl
    a = ["aa", "bb", "aa", "bb"] |> categorical
    @test scitype(a[1]) == Multiclass{2}

    s = scitype(a[1])
    @test MLJScientificTypes._compact_scitype(s) == Symbol("Multiclass{2}")
    a = [missing,1,2,3]
    s = elscitype(a)
    @test MLJScientificTypes._compact_scitype(s) == Symbol("Union{Missing, Count}")
    s = "Union{Missing,ScientificTypes.Continuous}"

    # schema show
    df = DataFrame(x=[1.0,2.0,3.0],y=["a","b","c"])
    s = schema(df)
    io = IOBuffer()
    show(io, MIME("text/plain"), MLJScientificTypes.schema(df))
    @test String(take!(io)) == "_.table = \n┌─────────┬─────────┬────────────┐\n│ _.names │ _.types │ _.scitypes │\n├─────────┼─────────┼────────────┤\n│ x       │ Float64 │ Continuous │\n│ y       │ String  │ Textual    │\n└─────────┴─────────┴────────────┘\n_.nrows = 3\n"
end
