################
"""
    splitrange(start, step, stop, chunksize)

Divide the range `start:stop` into segments, each of size `chunksize`.
The last segment will contain the remainder, `(start - stop + 1) % chunksize`,
if it exists.
"""
function splitrange(start::T, step::T, stop::T, Lc::Integer) where {T}
    L = (stop - start) ÷ step + one(T)
    n, r = divrem(L, Lc)
    ranges = Vector{StepRange{T, T}}(undef, r == 0 ? n : n + 1)
    l = start
    @inbounds for i = 1:n
        l′ = l
        l += Lc
        ranges[i] = l′:step:(l - one(T))
    end
    if r != 0
        @inbounds ranges[n + 1] = (stop - r + 1):step:stop
    end
    return ranges
end

"""
    splitrange(r::StepRange{T}, chunksize)

Divide the range `ur` into segments, each of size `chunksize`.
"""
splitrange(r::StepRange{T}, Lc::Integer) where {T} = splitrange(r.start, r.step, r.stop, Lc)
################
using Distributed
addprocs(95, exeflags=`-O3`)
@everywhere import SpecialFunctions, OpenLibmPorts
@everywhere function ulp(x::Float32)
    # z′ = OpenLibmPorts.logabsgamma(x)[1]
    # z = OpenLibmPorts.logabsgamma(Float64(x))[1]
    z′ = SpecialFunctions.logabsgamma(x)[1]
    z = SpecialFunctions.logabsgamma(Float64(x))[1]
    isinf(z′) && isinf(oftype(x, z)) && return 0.0
    iszero(z′) && iszero(z) && return 0.0
    e = exponent(z′)
    abs(z′ - z) * 2.0^(precision(x) - 1 - e)
end
@everywhere function ulp(x::Float64)
    z′ = OpenLibmPorts.logabsgamma(x)[1]
    z = SpecialFunctions.logabsgamma(big(x))[1]
    isinf(z′) && isinf(oftype(x, z)) && return big(0.0)
    iszero(z′) && iszero(z) && return big(0.0)
    e = exponent(z′)
    abs(z′ - z) * 2.0^(precision(x) - 1 - e)
end

@everywhere f32(u::UInt32) = reinterpret(Float32, u)
@everywhere negf32(u::UInt32) = reinterpret(Float32, u | 0x80000000)
us = 0x00000000:0x00000001:0x7f800000
u_ranges = splitrange(us, length(us) ÷ (nprocs() - 1));

ulps = reduce(vcat, pmap(Broadcast.BroadcastFunction(ulp ∘ f32), u_ranges));
neg_ulps = reduce(vcat, pmap(Broadcast.BroadcastFunction(ulp ∘ negf32), u_ranges));

mx, i = findmax(ulps);
neg_mx, neg_i = findmax(neg_ulps);

xs = negf32.(us[findall(≥(3.5), neg_ulps)]);
vals_f32 = first.(SpecialFunctions.logabsgamma.(xs));
vals_f64 = first.(SpecialFunctions.logabsgamma.(Float64.(xs)));

# Useful summary plot
using Plots
pl1 = plot(ulp, xs, yscale=:log10, ylabel="ulp", xlabel="x", title="Float32",
           label="computed against Float64");
pl2 = plot(xs, vals_f64, labels="Float64", linewidth=3, xlabel="x",
           ylabel="logabsgamma(x)[1]");
plot!(pl2, xs, vals_f32, labels="Float32", xlabel="x");
pl3 = plot(xs, abs.(vals_f32 .- vals_f64), labels="|z′ - z|", xlabel="x", yscale=:log10);
pl4 = plot(pl1, pl2, pl3, size=(1200,800), layout=grid(2,2));

savefig(pl4, joinpath(pwd(), "fval_notapproxeq_openlibm.pdf"))
savefig(pl4, joinpath(pwd(), "fval_notapproxeq_openlibm.png"))

# Misc
isequallybad(x) = SpecialFunctions.logabsgamma(x)[1] ≈ OpenLibmPorts.logabsgamma(x)[1]
delta(::Type{T}, x) where {T} = abs(OpenLibmPorts.logabsgamma(x)[1] - SpecialFunctions.logabsgamma(T(x))[1])
delta(x::T) where {T} = delta(T, x)

frac = count(isequallybad, xs) / length(xs)
xs′ = filter(!isequallybad, xs);
v1 = SpecialFunctions.logabsgamma.(xs′);
v2 = SpecialFunctions.logabsgamma.(big.(xs′));
mx3, i3 = findmax(ulp, xs′)

g_1 = count(≥(1.0), ulps)
g_15 = count(≥(1.5), ulps)
g_175 = count(≥(1.75), ulps)
g_2 = count(≥(2.0), ulps)
g_225 = count(≥(2.25), ulps)


using Plots
# pl = histogram(ulps, label="computed against Float64");

pl = bar([g_15, g_175, g_2, g_225] ./ length(ulps));

savefig(pl, joinpath(pwd(), "ulp_Float32.pdf"))
