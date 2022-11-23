####
using Plots, Statistics
import SpecialFunctions, OpenLibmPorts

f1(x) = OpenLibmPorts.logabsgamma(x)[1]
f2(x) = SpecialFunctions.logabsgamma(x)[1]

delta(x) = abs(f1(x) - f2(big(x)))
# delta_ulp(x) = oftype(x, delta(x)) * 2^(precision(x)-1)
ulp(x::Integer) = delta_ulp(float(x))
function ulp(x)
    z′ = OpenLibmPorts.logabsgamma(x)[1]
    z = SpecialFunctions.logabsgamma(big(x))[1]
    isinf(z′) && isinf(z) && return big(0.0)
    iszero(z′) && iszero(z) && return big(0.0)
    # βᵉ = 2.0^exponent(z′)
    # abs((z′ / βᵉ) - (z / βᵉ)) * 2^(precision(x) - 1)
    e = exponent(z′)
    abs(z′ - z) * 2.0^(precision(x) - 1 - e)
end

delta_rel(x) = (z = f2(big(x)); abs(f1(x) - z) / z)

ulp_plot(x, v; opts...) = plot(x, v, label="computed against MPFR", title="stepsize=$(step(x))", xlabel="x", ylabel="ulp"; opts...)
ulp_plot(x; opts...) = ulp_plot(x, ulp.(x); opts...)

x = 0.0:1e-2:1000
v = delta_ulp.(x);
extrema(v)

p = ulp_plot(x);
savefig(p, joinpath(pwd(), "ulp.pdf"))
savefig(p, joinpath(pwd(), "ulp.png"))

x = 0.0:1e-5:8.0
v = delta_ulp.(x);
p = ulp_plot(x);
savefig(p, joinpath(pwd(), "ulp08.pdf"))
savefig(p, joinpath(pwd(), "ulp08.png"))

p1 = ulp_plot(0.0:1e-4:8.0);
p2 = ulp_plot(8.0:0.1:2.0^10);
p3 = ulp_plot(2.0^10:100.0:2.0^20, xscale=:log10);
p4 = ulp_plot(2.0^20:2.0^20:2.0^40, xscale=:log10);

p = plot(p1, p2, p3, p4, size=(1200,800));
savefig(p, joinpath(pwd(), "ulp_square.pdf"))
savefig(p, joinpath(pwd(), "ulp_square.png"))


f32(u::UInt32) = reinterpret(Float32, u)
negf32(u::UInt32) = reinterpret(Float32, u | 0x80000000)

us = 0x00000000:0x00000001:0x7f800000
ulp_pos = delta_ulp.(f32.(us));

maximum(delta_ulp, x)
####
# Interval 1: 0.0 < x ≤ 2.0
# Maximum: 1.913137008198857371012209807134758696731923380914437929991701337609110630316687
x = nextfloat(0.0):1e-8:2.0
# Interval 2: 2.0 < x < 8.0
x = nextfloat(2.0):1e-8:prevfloat(8.0)
# Interval 3: 8.0 ≤ x < 2^58
x = 8.0:1e-4:2.0^7
x = 2.0^7:1.0:2.0^20
x = 2.0^20:2.0^20:2.0^40
x = 2.0^40:2.0^40:prevfloat(2.0^58)
# Interval 4: 2^58 ≤ x ≤ Inf
x = (2.0^58):(2.0^1000):prevfloat(Inf)


