# From openlibm/test/libm-test-ulps.h, openlibm/test/libm-test.c

# lgamma_test block
for T ∈ (Float64, Float32)
    @testset "lgamma_test, $T" begin
        @test loggamma(T(Inf)) === T(Inf)
        @test loggamma(T(0)) === T(Inf)
        @test loggamma(T(NaN)) === T(NaN)

        @test loggamma(T(-3)) === T(Inf)
        @test loggamma(T(-Inf)) === T(Inf)

        # lgamma(1) == 0, lgamma (1) sets signgam to 1
        y, signgam = logabsgamma(T(1))
        @test y === T(0.0)
        @test signgam === 1

        # lgamma(3) == log(2), lgamma (3) sets signgam to 1
        y, signgam = logabsgamma(T(3))
        @test y === log(T(2.0))
        @test signgam === 1

        # lgamma(0.5) == log(sqrt(pi)), lgamma(0.5) sets signgam to 1
        y, signgam = logabsgamma(T(0.5))
        @test y === T(0.5log(π))
        @test signgam === 1

        # lgamma(-0.5) == log(2sqrt(pi)), lgamma(-0.5) sets signgam to -1
        y, signgam = logabsgamma(T(-0.5))
        @test y === T(0.5log(4π))
        @test signgam === -1
        @test_throws DomainError loggamma(T(-0.5))

        # In the two "broken" tests, an exact match not possible, even
        # in Float64, thus, we check for as close a tolerance as
        # possible.

        # lgamma(0.7) == 0.26086724653166651439, lgamma(0.7) sets signgam to 1
        y, signgam = logabsgamma(T(0.7))
        # @test_broken y === 0.26086724653166651439
        if T === Float64
            @test y ≈ 0.26086724653166651439 atol=6e-17
        else
            @test y ≈ 0.26086724653166651439 atol=3e-8
        end
        @test signgam === 1

        # lgamma(1.2) == -0.853740900033158497197e-1, lgamma(1.2) sets signgam to 1
        y, signgam = logabsgamma(T(1.2))
        # @test_broken y === -0.853740900033158497197e-1
        if T === Float64
            @test y ≈ -0.853740900033158497197e-1 atol=2e-17
        else
            @test y ≈ -0.853740900033158497197e-1 atol=2e-8
        end
        @test signgam === 1
    end
end

# tgamma_test block
function tgamma(x)
    y, s = logabsgamma(x)
    exp(y) * s
end
@testset "tgamma_test" begin
    @test tgamma(Inf) === Inf
    @test tgamma(0) === Inf
    @test tgamma(-0) === Inf

    # tgamma(x) === NaN
    @test tgamma(0.5) ≈ √π atol=3e-16
    @test tgamma(-0.5) == -2√π

    @test tgamma(1) == 1.0
    @test tgamma(4) == 6.0

    @test tgamma(0.7) ≈ 1.29805533264755778568 atol=3e-16
    @test tgamma(1.2) == 0.91816874239976061064
end
