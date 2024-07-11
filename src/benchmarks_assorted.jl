####
# core, part 1
using BenchmarkTools, Test
function core_p1_1(x)
    u = reinterpret(UInt64, x)
    hx = (u >>> 32) % Int32
    lx = u % Int32

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    signgamp = Int32(1)
    ix = signed(hx & 0x7fffffff)
    ix ≥ 0x7ff00000 && return x * x, signgamp
    ix | lx == 0 && return 1.0 / 0.0, signgamp
    if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
        if hx < 0
            signgamp = Int32(-1)
            return -log(-x), signgamp
        else
            return -log(x), signgamp
        end
    end
    if hx < 0
        ix ≥ 0x43300000 && return 1.0 / 0.0, signgamp #= |x|>=2**52, must be -integer =#
        t = sinpi(x)
        t == 0.0 && return 1.0 / 0.0, signgamp #= -integer =#
        nadj = log(π / abs(t * x))
        if t < 0.0; signgamp = Int32(-1); end
        x = -x
    end
    x, signgamp
end

function core_p1_2(x)
    u = reinterpret(UInt64, x)
    hx = (u >>> 32) % Int32
    lx = u % Int32

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    signgamp = Int32(1)
    ix = signed(hx & 0x7fffffff)
    ix ≥ 0x7ff00000 && return x * x, signgamp
    ix | lx == 0 && return 1.0 / 0.0, signgamp
    if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
        if hx < 0
            signgamp = Int32(-1)
            return -log(-x), signgamp
        else
            return -log(x), signgamp
        end
    end
    if hx < 0
        t = sinpi(x)
        t == 0.0 && return 1.0 / 0.0, signgamp #= -integer =#
        nadj = log(π / abs(t * x))
        if t < 0.0; signgamp = Int32(-1); end
        x = -x
    end
    x, signgamp
end

function bench_core_p1(x)
    b1 = @benchmark core_p1_1($x)
end
mintimes_core_p1(x) = map(x -> minimum(x).time, bench_core_p1(x))
Δ = 2e-2
x = 0.0:Δ:prevfloat(2.0)
ts = map(mintimes_core_p1, x)
ts = map(x -> minimum(bench_core_p1(x)).time, x)

x = -2.0^52
x = nextfloat(-2.0^52)
x = prevfloat(-2.0^52)
core_p1_1(x)
core_p1_2(x)
core_p1_1(nextfloat(x))
core_p1_2(nextfloat(x))

using Test
x = (-2.0^52):(-2.0^30):(-2.0^60)
@test count(iszero ∘ sinpi, x) == length(x)
@test count(isinf ∘ loggamma, x) == length(x)
@test count(isinf ∘ first ∘ _lgamma_r, x) == length(x)

x = nextfloat(-2.0^52)
x = -2.0^52
x = prevfloat(-2.0^52)
@btime core_p1_1($x)
@btime core_p1_2($x)

x = -3rand()
@benchmark core_p1_1($x)
@benchmark core_p1_2($x)

####
function option1(x)
    t = log(x)
    z = 1.0 / x
    y = z * z
    w = muladd(z, evalpoly(y, (8.33333333333329678849e-2, -2.77777777728775536470e-3, 7.93650558643019558500e-4, -5.95187557450339963135e-4, 8.36339918996282139126e-4, -1.63092934096575273989e-3)), 4.18938533204672725052e-1)
    r = (x - 0.5) * (t-1.0)+w
end

function option2(x)
    z = 1.0 / x
    y = z * z
    w = muladd(z, evalpoly(y, (8.33333333333329678849e-2, -2.77777777728775536470e-3, 7.93650558643019558500e-4, -5.95187557450339963135e-4, 8.36339918996282139126e-4, -1.63092934096575273989e-3)), 4.18938533204672725052e-1)
	r = muladd((x - 0.5), (log(x) - 1.0), w)
end

x = 100*rand()
@benchmark option1($x)
@benchmark option2($x)

function unsafe_modf(x)
    ix = Float64(Base.unsafe_trunc(Int8, x))
    x - ix, ix
end

xs = nextfloat(1.0):1e-6:prevfloat(2.0)
for x ∈ xs
    @test _lgamma_r(x)[1] ≈ _loggamma(x)[1] atol=1e-15
end

f1(x, tc, c) = x - (tc - (1.0 - c))
f2(x, tc, c) = x - tc + 1 - c
f3(x, c) = x - 0.46163214496836225 - c
x = 0.975; c = 0.0;
@benchmark f1($(Ref(x))[], $(Ref(tc))[], $(Ref(c))[])
@benchmark f2($(Ref(x))[], $(Ref(tc))[], $(Ref(c))[])
@benchmark f3($(Ref(x))[], $(Ref(c))[])

g1(x, c) = (1.0 + c) - x
g2(x, c) = 1.0 + c - x


h1(x) = x * (log(x) - 1.0)
h2(x) = muladd(x, log(x), -x)

@benchmark h1($(Ref(x))[])
@benchmark h2($(Ref(x))[])

function bench_h(x)
    b1 = @benchmark($x)
    b2 = @benchmark($x)
    b1, b2
end


function ma1(r, y, p1, p2)
    p  = muladd(p1, y, p2)
    r  += muladd(y, -0.5, p)
end

function ma2(r, y, p1, p2)
    r  += muladd(y, -0.5, muladd(p1, y, p2))
end

function ma3(r, y, p1, p2)
    muladd(y, -0.5, muladd(p1, y, p2) + r)
end
r, y, p1, p2 = rand(), rand(), rand(), rand()
@benchmark ma1($(Ref(r))[], $(Ref(y))[], $(Ref(p1))[], $(Ref(p2))[])
@benchmark ma2($(Ref(r))[], $(Ref(y))[], $(Ref(p1))[], $(Ref(p2))[])
@benchmark ma3($(Ref(r))[], $(Ref(y))[], $(Ref(p1))[], $(Ref(p2))[])


function opt11(r, x, c)
    y = x - 0.46163214496836225 - c #x - (tc - (1.0 - _y))
    z = y * y
    w = z * y
    p1 = evalpoly(w, (4.83836122723810047042e-01, -3.27885410759859649565e-02, 6.10053870246291332635e-03, -1.40346469989232843813e-03, 3.15632070903625950361e-04))
    p2 = evalpoly(w, (-1.47587722994593911752e-01, 1.79706750811820387126e-02, -3.68452016781138256760e-03, 8.81081882437654011382e-04, -3.12754168375120860518e-04))
    p3 = evalpoly(w, (6.46249402391333854778e-02, -1.03142241298341437450e-02, 2.25964780900612472250e-03, -5.38595305356740546715e-04, 3.35529192635519073543e-04))
    p = muladd(w, -muladd(p3, y, p2), -3.63867699703950536541e-18)
    p = muladd(z, p1, -p)
    r += p - 1.21486290535849611461e-1
end

function opt12(r, x, c)
    y = x - .46163214496836225 - c #x - (tc - (1.0 - _y))
    z = y * y
    w = z * y
    p1 = evalpoly(w, (4.83836122723810047042e-01, -3.27885410759859649565e-02, 6.10053870246291332635e-03, -1.40346469989232843813e-03, 3.15632070903625950361e-04))
    p2 = evalpoly(w, (-1.47587722994593911752e-01, 1.79706750811820387126e-02, -3.68452016781138256760e-03, 8.81081882437654011382e-04, -3.12754168375120860518e-04))
    p3 = evalpoly(w, (6.46249402391333854778e-02, -1.03142241298341437450e-02, 2.25964780900612472250e-03, -5.38595305356740546715e-04, 3.35529192635519073543e-04))
    p = muladd(z, p1, -muladd(w, -muladd(p3, y, p2), -3.63867699703950536541e-18))
    r += p - 1.21486290535849611461e-1
end
x = rand()
opt11(r, x, c)
@benchmark opt11($(Ref(r))[], $(Ref(x))[], $(Ref(c))[])
@benchmark opt12($(Ref(r))[], $(Ref(x))[], $(Ref(c))[])

################
# purging preamble
using BenchmarkTools, Test


function option1(x)
    ux = reinterpret(UInt64, x)
    hx = ux >>> 32 % Int32
    lx = ux % UInt32

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    signgam = 1
    ix = hx & 0x7fffffff
    ix ≥ 0x7ff00000 && return x * x, signgam
    ix | lx == 0x00000000 && return Inf, signgam
    if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
        if hx < Int32(0)
            signgam = -1
            return -log(-x), signgam
        else
            return -log(x), signgam
        end
    end
    x, signgam
end

function option2(x)
    ux = reinterpret(UInt64, x)
    hx = ux >>> 32 % Int32

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    signgam = 1
    ix = hx & 0x7fffffff
    ix = hx & 0x7fffffff
    ix ≥ 0x7ff00000 && return x * x, signgam
    # # x == 0.0 && return Inf, signgam
    # if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
    #     if hx < Int32(0)
    #         signgam = -1
    #         return -log(-x), signgam
    #     else
    #         return -log(x), signgam
    #     end
    # end
    if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
        if hx < Int32(0)
            signgam = -1
            return -log(-x), signgam
        else
            return -log(x), signgam
        end
    end
    x, signgam
end

function option3(x)
    ux = reinterpret(UInt64, x)
    lx = ux % UInt32

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    signgam = 1
    negsign = ux >>> 63 != 0
    ix = (ux >>> 32 % UInt32) & 0x7fffffff
    ix ≥ 0x7ff00000 && return x * x, signgam
    ix | lx == 0x00000000 && return Inf, signgam
    if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
        if negsign
            signgam = -1
            return -log(-x), signgam
        else
            return -log(x), signgam
        end
    end
    x, signgam
end

function bench(z)
    b1 = @benchmark option1($z)
    b2 = @benchmark option2($z)
    # b2 = @benchmark option3($z)
    b1, b2
end


x1 = 1.5;
x2 = prevfloat(2.0^-70);
x2′ = -x2;
x3 = Inf;
x4 = NaN;
x5 = -Inf;
x6 = 0.0;
xs = [x1, x2, x2′, x3, x5, x4, x6];
@test all(option1.(xs) .=== option2.(xs) .=== option3.(xs))

bench.(xs)

function opt1(x)
    t = sinpi(x)
    iszero(t) && return Inf
    log(π / abs(t * x))
end

function opt2(x)
    t = sinpi(x)
    iszero(t) && return Inf
    log(π) - log(abs(t * x))
end

opt1(nextfloat(-Inf))
opt2(nextfloat(-Inf))
for x = -100000.0:2e-1:-eps()
    @test opt1(x) ≈ opt2(x) atol=1e-14
end
opt1(-prevfloat(2.0^52))

for x = -eps():eps()/30:-eps()/10
    @test opt1(x) ≈ opt2(x) atol=1e-13
end

yy = -2.0^30
opt1(nextfloat(yy))
opt2(nextfloat(yy))
sinpi(yy)
