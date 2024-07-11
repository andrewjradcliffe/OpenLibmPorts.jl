import SpecialFunctions
using SpecialFunctions: loggamma, logabsgamma
using OpenLibmPorts: loggamma_r, loggammaf_r, lgamma_r, lgammaf_r

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
    for x = 1000:1e-3:10000
        @test isapprox(loggamma_r(x), loggamma(x), atol=1e-11)
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

# @testset "Float32 exhaustive" begin end
u0 = UInt32(0)
x0 = reinterpret(Float32, u0)
reinterpret(Float32, u0 + 0x1)

reinterpret(Float32, reinterpret(UInt32, 1.0f0) - 0x1)
loggammaf(x) = lgammaf_r(x)[1]
logabsgamma_first(x) = logabsgamma(x)[1]

u0 = 0x00000000
uf = u0
for _ = 1:10
    global uf += 0x00000001
    local x = reinterpret(Float32, uf)
    @test loggammaf(x) ≈ loggamma(x)
end

for u = 0x00000000:0x00000001:0x7f800000
    local x = reinterpret(Float32, u)
    @test loggammaf(x) ≈ loggamma(x)
end

# negative values
negative(u::UInt32) = reinterpret(Float32, u | 0x80000000)
meetstol(x) = loggammaf(x) ≈ logabsgamma_first(x)
meetstol(u::UInt32) = meetstol(negative(u))

for u = 0x00000000:0x00000001:0x7f800000
    local x = negative(u)
    @test loggammaf(x) ≈ logabsgamma_first(x)
end
findfirst(!meetstol, 0x00000000:0x00000001:0x7f800000)

i_bad = 1075657106
u_range = 0x00000000:0x00000001:0x7f800000
u_bad = u_range[i_bad]
f_bad = negative(u_bad)

negative(u_bad)

u_range_rest = u_bad+0x00000001:0x00000001:0x7f800000

is_bad = findall(!meetstol, u_range_rest);

us_bad = [u_bad u_range_rest[is_bad]];
fs_bad = negative.(us_bad)

both = [loggammaf.(fs_bad) logabsgamma_first.(fs_bad)];
δ = diff(both, dims=2);
extrema(δ)

findall(x -> modf(x)[1] == 0.0f0, fs_bad)

all(==(-1), last.(logabsgamma.(fs_bad)))
count(==(1), last.(logabsgamma.(fs_bad)))

(length(u_range) - length(us_bad)) / length(u_range)
