@testset "Tables" begin
    X = (
        x = rand(5),
        y = rand(Int, 5),
        z = categorical(collect("asdfa")),
        w = rand(5)
    )
    s = schema(X)
    @test info(X) == schema(X)
    @test s.scitypes == (Continuous, Count, Multiclass{4}, Continuous)
    @test s.types == (Float64, Int64, CategoricalValue{Char,UInt32}, Float64)
    @test s.nrows == 5

    @test_throws ArgumentError schema([:x, :y])

    t = scitype(X)
    @test t <: Table(Continuous, Finite, Count)
    @test t <: Table(Infinite, Multiclass)
    @test !(t <: Table(Continuous, Union{Missing, Count}))

    @test MLJScientificTypes._nrows(X) == 5
    @test MLJScientificTypes._nrows(()) == 0
    @test MLJScientificTypes._nrows((i for i in 1:7)) == 7
    
    # PR #61 "scitype checks for `Tables.DictColumn`"
    X1 = Dict(:a=>rand(5), :b=>rand(Int, 5))
    s1 = schema(X1)
    @test info(X1) == schema(X1)
    @test s1.scitypes == (Continuous, Count)
    @test s1.types == (Float64, Int64)
    @test s.nrows == 5
end
end

@testset "csvfile" begin
    X = (x = rand(4), )
    CSV.write("test.csv", X)
    file = CSV.File("test.csv")
    @test scitype(file) == scitype(X)
    rm("test.csv")
end
