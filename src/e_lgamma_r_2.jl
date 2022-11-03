tofloat(x::UInt32) = reinterpret(Float64, (x | 0x0000000000000000) << 32)
# In order of appearance
tofloat(0x7ff00000) # Inf
tofloat(0x3b900000) # 8.470329472543003e-22
tofloat(0x43300000) # 4.503599627370496e15
tofloat(0x3ff00000) # 1.0
tofloat(0x40000000) # 2.0
tofloat(0x3feccccc) # 0.8999996185302734
tofloat(0x3FE76944) # 0.7315998077392578
tofloat(0x3FCDA661) # 0.23163998126983643
tofloat(0x3FFBB4C3) # 1.7316312789916992
tofloat(0x3FF3B4C4) # 1.2316322326660156
tofloat(0x40200000) # 8.0
tofloat(0x43900000) # 2.8823037615171174e17

function _loggamma3(x::Float64)
    u = reinterpret(UInt64, x)
    hx = u >>> 32 % Int32
    lx = u % Int32

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    signgamp = Int32(1)
    ix = hx & 0x7fffffff
    ix ≥ 0x7ff00000 && return typemax(x), signgamp  # isinf(x)
    ix | lx == 0x00000000 && return typemax(x), signgamp # iszero(x)
    if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
        if hx < 0 # x < 0
            signgamp = Int32(-1)
            return -log(-x), signgamp
        else
            return -log(x), signgamp
        end
    end
    if hx < 0
        # ix ≥ 0x43300000 && return typemax(x), signgamp #= |x|>=2**52, must be -integer =#
        t = sinpi(x)
        iszero(t) && return typemax(x), signgamp #= -integer =#
        nadj = log(π / abs(t * x))
        if t < 0.0; signgamp = Int32(-1); end
        x = -x
    end
    if ix ≤ 0x40000000     #= for x < 2.0 =#
        # fpart, ipart = modf(x)
        ipart = round(x, RoundToZero)
        fpart = x - ipart
        if iszero(fpart)
            return 0.0, signgamp
        elseif isone(ipart)
            r = 0.0
            c = 1.0
        else
            r = -log(x)
            c = 0.0
        end
        if fpart ≥ 0.7316
            y = 1.0 + c - x#(1.0 + _y) - x
            z = y * y
            p1 = evalpoly(z, (7.72156649015328655494e-02, 6.73523010531292681824e-02, 7.38555086081402883957e-03, 1.19270763183362067845e-03, 2.20862790713908385557e-04, 2.52144565451257326939e-05))
            p2 = z * evalpoly(z, (3.22467033424113591611e-01, 2.05808084325167332806e-02, 2.89051383673415629091e-03, 5.10069792153511336608e-04, 1.08011567247583939954e-04, 4.48640949618915160150e-05))
            p = muladd(p1, y, p2)
            r += muladd(y, -0.5, p)
        elseif fpart ≥ 0.2316399812698364 #0.2316322326660156 # 0.23163999999
            y = x - 0.46163214496836225 - c #x - (tc - (1.0 - _y))
            z = y * y
            w = z * y
            p1 = evalpoly(w, (4.83836122723810047042e-01, -3.27885410759859649565e-02, 6.10053870246291332635e-03, -1.40346469989232843813e-03, 3.15632070903625950361e-04))
            p2 = evalpoly(w, (-1.47587722994593911752e-01, 1.79706750811820387126e-02, -3.68452016781138256760e-03, 8.81081882437654011382e-04, -3.12754168375120860518e-04))
            p3 = evalpoly(w, (6.46249402391333854778e-02, -1.03142241298341437450e-02, 2.25964780900612472250e-03, -5.38595305356740546715e-04, 3.35529192635519073543e-04))
            # p = muladd(w, -muladd(p3, y, p2), -3.63867699703950536541e-18)
            # p = muladd(z, p1, -p)
            p = muladd(z, p1, -muladd(w, -muladd(p3, y, p2), -3.63867699703950536541e-18))
            r += p - 1.21486290535849611461e-1
        else
            y = x - c
            p1 = y * evalpoly(y, (-7.72156649015328655494e-02, 6.32827064025093366517e-01, 1.45492250137234768737, 9.77717527963372745603e-01, 2.28963728064692451092e-01, 1.33810918536787660377e-02))
            p2 = evalpoly(y, (1.0, 2.45597793713041134822, 2.12848976379893395361, 7.69285150456672783825e-01, 1.04222645593369134254e-01, 3.21709242282423911810e-03))
		    r += muladd(y, -0.5, p1 / p2)
        end
    elseif ix < 0x40200000              #= x < 8.0 =#
        i = round(x, RoundToZero) #Base.unsafe_trunc(Int8, x)
        y = x - i
	    z = 1.0
        p = 0.0
        u = x
        while u ≥ 3.0
            p -= 1.0
            u = x + p
            z *= u
        end
        p = y * evalpoly(y, (-7.72156649015328655494e-2, 2.14982415960608852501e-1, 3.25778796408930981787e-1, 1.46350472652464452805e-1, 2.66422703033638609560e-2, 1.84028451407337715652e-3, 3.19475326584100867617e-5))
        q = evalpoly(y, (1.0, 1.39200533467621045958, 7.21935547567138069525e-1, 1.71933865632803078993e-1, 1.86459191715652901344e-2, 7.77942496381893596434e-4, 7.32668430744625636189e-6))
        r = log(z) + muladd(0.5, y, p / q) #r = log(z) + 0.5*y + p / q
    elseif ix < 0x43900000              #= 8.0 ≤ x < 2^58 =#
        z = 1.0 / x
        y = z * z
        w = muladd(z, evalpoly(y, (8.33333333333329678849e-2, -2.77777777728775536470e-3, 7.93650558643019558500e-4, -5.95187557450339963135e-4, 8.36339918996282139126e-4, -1.63092934096575273989e-3)), 4.18938533204672725052e-1)
	    r = muladd(x - 0.5, log(x) - 1.0, w)
    else #= 2^58 ≤ x ≤ Inf =#
        r = muladd(x, log(x), -x)
    end
    if hx < 0
        r = nadj - r
    end
    return r, signgamp
end
