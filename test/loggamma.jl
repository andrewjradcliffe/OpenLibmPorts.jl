import SpecialFunctions
using SpecialFunctions: loggamma
using OpenLibmPorts: loggamma_r, loggammaf_r

@testset "logamma_r" begin
    for x = 1e-4:1e-4:50
        @test isapprox(loggamma_r(x), loggamma(x), atol=1e-13)
    end
    for x = 50:1e-4:100
        @test isapprox(loggamma_r(x), loggamma(x), atol=1e-12)
    end
    for x = 100:1e-3:1000
        @test isapprox(loggamma_r(x), loggamma(x), atol=1e-12)
    end
end

@testset "logammaf_r" begin
    for x = 1f-4:1f-4:25.0f0
        @test isapprox(loggammaf_r(x), loggamma(x), atol=1e-5)
    end
    for x = 25.0f0:1f-4:100.0f0
        @test isapprox(loggammaf_r(x), loggamma(x), atol=1e-4)
    end
    for x = 100.0f0:1f-3:1000.0f0
        @test isapprox(loggammaf_r(x), loggamma(x), atol=1e-3)
    end
end

# We would have caught value errors above, thus, just check signs
@testset "logabsgamma" begin
    for x = -500.0:1e-1:500.0
        @test OpenLibmPorts.logabsgamma(x)[2] == SpecialFunctions.logabsgamma(x)[2]
    end
    for x = -500.0f0:1f-1:500.0f0
        @test OpenLibmPorts.logabsgamma(x)[2] == SpecialFunctions.logabsgamma(x)[2]
    end
end
