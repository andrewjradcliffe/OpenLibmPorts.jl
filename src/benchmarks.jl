# Some benchmark comparisons of loggamma

using BenchmarkTools, SpecialFunctions, OpenLibmPorts

x1 = 0.51349871934870
x2 = 1.714993874193487
x3 = 2.713493104987419
x4 = 3.531490918743987
x5 = 4.514093879017
x6 = 5.51490871948374189
x7 = 6.513498314908718943
x8 = 7.5134098134987198
x9 = 8.5198347931847897
x10 = 50.134908731409897
x11 = 101.513490819347

function bench(x)
    b1 = @benchmark SpecialFunctions.loggamma($x)
    b2 = @benchmark OpenLibmPorts.logabsgamma($x)
    b3 = @benchmark OpenLibmPorts.loggamma($x)
    b4 = @benchmark OpenLibmPorts.loggamma_r4($x)
    b1, b2, b3, b4
end
meantimes(x) = map(x -> mean(x).time, bench(x))

b1 = bench(x1)
b2 = bench(x2)
b3 = bench(x3)
b4 = bench(x4)
b5 = bench(x5)
b6 = bench(x6)
b7 = bench(x7)
b8 = bench(x8)
b9 = bench(x9)
b10 = bench(x10)
b11 = bench(x11)
@benchmark OpenLibmPorts.loggamma_r($x7)
@benchmark OpenLibmPorts.loggamma_r2($x7)
@benchmark OpenLibmPorts.loggamma_r3($x7)

# times = map(meantimes, 0.0:1e-1:10.0)

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
savefig(p, joinpath(pwd(), "benchplot_64.pdf"))
savefig(p, joinpath(pwd(), "benchplot_64.png"))

p = benchplots_min(Float32);
savefig(p, joinpath(pwd(), "benchplot_32.pdf"))
savefig(p, joinpath(pwd(), "benchplot_32.png"))

using Test
for 𝑥 ∈ 0.0:1e-2:100.0
    @test OpenLibmPorts.loggamma(𝑥) == OpenLibmPorts.loggamma_r4(𝑥)
end

b = bench(0.02)
