# Some benchmark comparisons of loggamma
# Most likely, one would like to save the plots somewhere other than PWD,
# but, as a default, it should work.
# Also, wrt the `include` -- I assume that the PWD is OpenLibmPorts/src
# Again, hardly portable, but this is not really part of the package.

using Distributed
addprocs(24)
@everywhere using BenchmarkTools, SpecialFunctions, OpenLibmPorts
@everywhere include("benchfuns.jl")

const lbls = ["loggamma, SpecialFunctions" "logabsgamma" "loggamma"]

using Plots
frange(::Type{T}, a, Δ, b) where {T} = T(a):T(Δ):T(b)
timescat(ts) = mapreduce(x -> [x...], hcat, ts)
pl_f(x, y) = plot(x, y, label=lbls, legend=:outertop, ylabel="time (ns)", xlabel="x (function arg)")
function benchplot(tf::F, x::AbstractVector) where {F}
    ts = pmap(tf, x)
    y = timescat(ts)
    p = pl_f(x, y')
end
function benchplots(::Type{T}, tf::F) where {T<:Union{Float32, Float64}, F}
    p1 = benchplot(tf, T(0.0):T(2e-2):T(10.0))
    p2 = benchplot(tf, T(10.0):T(0.2):T(100.0))
    p3 = benchplot(tf, T(100.0):T(20.0):T(10000.0))
    p4 = benchplot(tf, T(10000.0):T(2000.0):T(1000000.0))
    p = plot(p1, p2, p3, p4, layout=grid(2,2), size=(1200,800), plot_title="$(nameof(T))");
end
benchplots_mean(::Type{T}) where {T} = benchplots(T, meantimes)
benchplots_min(::Type{T}) where {T} = benchplots(T, mintimes)

p = benchplots_min(Float64);

savefig(p0, joinpath(pwd(), "benchplot_64.pdf"))
savefig(p0, joinpath(pwd(), "benchplot_64.png"))
savefig(p, joinpath(pwd(), "benchplot_64.svg"))

p2 = benchplots_min(Float32);
savefig(p2, joinpath(pwd(), "benchplot_32.pdf"))
savefig(p2, joinpath(pwd(), "benchplot_32.png"))
savefig(p2, joinpath(pwd(), "benchplot_32.svg"))
