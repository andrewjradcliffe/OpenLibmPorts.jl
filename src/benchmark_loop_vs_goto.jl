# while loop vs. goto
using Distributed, Plots
addprocs(24)
@everywhere using BenchmarkTools
fname = joinpath(@__DIR__, "macrointerpolationworkaround.jl")
s = """
function bench_lpgt(x)
    b1 = @benchmark looped(\$x)
    b2 = @benchmark goto(\$x)
    b1, b2
end
mintimes_lpgt(x) = map(x -> minimum(x).time, bench_lpgt(x))
"""
open(fname, "w") do io
    write(io, s)
end
@everywhere function looped(x)
    i = round(x, RoundToZero)
    y = x - i
	z = 1.0
    p = 0.0
    u = x
    while u >= 3.0
        p -= 1.0
        u = x + p
        z *= u
    end
    z
end;
@everywhere function goto(x)
    i = round(x, RoundToZero)
    y = x - i
	z = 1.0
    if i == 7.0
        z *= y + 6.0
        @goto case6
    elseif i == 6.0
        @label case6
        z *= y + 5.0
        @goto case5
    elseif i == 5.0
        @label case5
        z *= y + 4.0
        @goto case4
    elseif i == 4.0
        @label case4
        z *= y + 3.0
        @goto case3
    elseif i == 3.0
        @label case3
        z *= y + 2.0
    end
    z
end;
@everywhere include($fname)
timescat(ts) = mapreduce(x -> [x...], hcat, ts)
pl_f(x, y; opts...) = plot(x, y, label=["looped, avg=$(mean(y[:, 1]))" "goto, avg=$(mean(y[:, 2]))"], legend=:topleft, ylabel="time (ns)", xlabel="x (function arg)"; opts...)

Δ = 1e-3
x = nextfloat(2.0):Δ:prevfloat(8.0)
ts = pmap(mintimes_lpgt, x);
y = timescat(ts);
p = pl_f(x, y', title="Float64, Δx=$(Δ)");
savefig(p, joinpath(@__DIR__, "benchplot_lpgt64.pdf"))
savefig(p, joinpath(@__DIR__, "benchplot_lpgt64.png"))
mean(y, dims=2)
