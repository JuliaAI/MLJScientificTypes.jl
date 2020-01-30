@testset "misc" begin
    # finite.jl
    a = ["aa", "bb", "aa", "bb"] |> categorical
    @test scitype(a[1]) == Multiclass{2}

    # schema show
    df = DataFrame(x=[1.0,2.0,3.0],y=["a","b","c"])
    s = schema(df)
    io = IOBuffer()
    show(io, MIME("text/plain"), MLJScientificTypes.schema(df))
    @test String(take!(io)) == "_.table = \n┌─────────┬─────────┬────────────┐\n│ _.names │ _.types │ _.scitypes │\n├─────────┼─────────┼────────────┤\n│ x       │ Float64 │ Continuous │\n│ y       │ String  │ Textual    │\n└─────────┴─────────┴────────────┘\n_.nrows = 3\n"

    # coerce
    x = Any['a', 5]
    @test (@test_logs (:warn, "Char value encountered, such value will be coerced according to the corresponding numeric value (e.g. 'A' to 65).") coerce(x, Count)) == [97, 5]
    x = categorical(['a','b','a','b'])
    @test coerce(x, Continuous) == [1.0,2.0,1.0,2.0]
    y = [missing, 1, 2]
    x = y[2:end]
    c = MLJScientificTypes._check_tight(x, eltype(x), true)
    @test c == [1, 2]
    @test eltype(c) == Int
    y = categorical([missing,1,2])
    x = y[2:end]
    @test eltype(x) >: Missing
    c = MLJScientificTypes._check_tight(x, eltype(x), true)
    @test c == [1,2]
    @test eltype(c) == Int
    c = coerce(x, OrderedFactor, tight=true)
    @test c == categorical([1,2])
    @test !(eltype(c) >: Missing)
end

@testset "Schema" begin
    M = MLJScientificTypes
    sch = M.Schema((:a, :b), (Int, Int), (Count, Count), 5)
    @test sch isa M.Schema{(:a, :b),Tuple{Int64,Int64},Tuple{Count,Count},5}
    @test sch.names == (:a, :b)
    @test sch.types == (Int, Int)
    @test sch.scitypes == (Count, Count)
    @test sch.nrows == 5

    @test_throws ArgumentError sch.something
    @test propertynames(sch) == (:names, :types, :scitypes, :nrows)

    X = [1,2,3]
    @test_throws ArgumentError schema(X)
end
