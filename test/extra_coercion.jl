@testset "issue #7" begin
    df = DataFrame(x=[1,2,3,4], y=["a","b","c","a"])
    coerce!(df, Textual=>Finite)
    @test scitype(df) == Table{Union{ AbstractArray{Count,1},
                                      AbstractArray{Multiclass{3},1} }}
end
