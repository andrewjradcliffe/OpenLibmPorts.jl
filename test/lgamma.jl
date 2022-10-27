using SpecialFunctions: loggamma

@testset "lgamma_r" begin
    for x = 1e-4:1e-4:50
        @test isapprox(lgamma_r(x), loggamma(x), atol=1e-13)
    end
    for x = 50:1e-4:100
        @test isapprox(lgamma_r(x), loggamma(x), atol=1e-12)
    end
    for x = 100:1e-3:1000
        @test isapprox(lgamma_r(x), loggamma(x), atol=1e-12)
    end
end

@testset "lgammaf_r" begin
    for x = 1f-4:1f-4:25.0f0
        @test isapprox(lgammaf_r(x), loggamma(x), atol=1e-5)
    end
    for x = 25.0f0:1f-4:100.0f0
        @test isapprox(lgammaf_r(x), loggamma(x), atol=1e-4)
    end
    for x = 100.0f0:1f-3:1000.0f0
        @test isapprox(lgammaf_r(x), loggamma(x), atol=1e-3)
    end
end
