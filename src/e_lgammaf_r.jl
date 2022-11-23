#=
/* e_lgammaf_r.c -- float version of e_lgamma_r.c.
* Conversion to float by Ian Lance Taylor, Cygnus Support, ian@cygnus.com.
*/

/*
* ====================================================
* Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
*
* Developed at SunPro, a Sun Microsystems, Inc. business.
* Permission to use, copy, modify, and distribute this
* software is freely granted, provided that this notice
* is preserved.
* ====================================================
*/
=#

# const a0f  =  7.7215664089f-02 #= 0x3d9e233f =#
# const a1f  =  3.2246702909f-01 #= 0x3ea51a66 =#
# const a2f  =  6.7352302372f-02 #= 0x3d89f001 =#
# const a3f  =  2.0580807701f-02 #= 0x3ca89915 =#
# const a4f  =  7.3855509982f-03 #= 0x3bf2027e =#
# const a5f  =  2.8905137442f-03 #= 0x3b3d6ec6 =#
# const a6f  =  1.1927076848f-03 #= 0x3a9c54a1 =#
# const a7f  =  5.1006977446f-04 #= 0x3a05b634 =#
# const a8f  =  2.2086278477f-04 #= 0x39679767 =#
# const a9f  =  1.0801156895f-04 #= 0x38e28445 =#
# const a10f =  2.5214456400f-05 #= 0x37d383a2 =#
# const a11f =  4.4864096708f-05 #= 0x383c2c75 =#
# const tcf  =  1.4616321325f+00 #= 0x3fbb16c3 =#
# const tff  = -1.2148628384f-01 #= 0xbdf8cdcd =#
# # #= tt = -(tail of tf) =#
# const ttf  =  6.6971006518f-09 #= 0x31e61c52 =#
# const t0f  =  4.8383611441f-01 #= 0x3ef7b95e =#
# const t1f  = -1.4758771658f-01 #= 0xbe17213c =#
# const t2f  =  6.4624942839f-02 #= 0x3d845a15 =#
# const t3f  = -3.2788541168f-02 #= 0xbd064d47 =#
# const t4f  =  1.7970675603f-02 #= 0x3c93373d =#
# const t5f  = -1.0314224288f-02 #= 0xbc28fcfe =#
# const t6f  =  6.1005386524f-03 #= 0x3bc7e707 =#
# const t7f  = -3.6845202558f-03 #= 0xbb7177fe =#
# const t8f  =  2.2596477065f-03 #= 0x3b141699 =#
# const t9f  = -1.4034647029f-03 #= 0xbab7f476 =#
# const t10f =  8.8108185446f-04 #= 0x3a66f867 =#
# const t11f = -5.3859531181f-04 #= 0xba0d3085 =#
# const t12f =  3.1563205994f-04 #= 0x39a57b6b =#
# const t13f = -3.1275415677f-04 #= 0xb9a3f927 =#
# const t14f =  3.3552918467f-04 #= 0x39afe9f7 =#
# const u0f  = -7.7215664089f-02 #= 0xbd9e233f =#
# const u1f  =  6.3282704353f-01 #= 0x3f2200f4 =#
# const u2f  =  1.4549225569f+00 #= 0x3fba3ae7 =#
# const u3f  =  9.7771751881f-01 #= 0x3f7a4bb2 =#
# const u4f  =  2.2896373272f-01 #= 0x3e6a7578 =#
# const u5f  =  1.3381091878f-02 #= 0x3c5b3c5e =#
# const v1f  =  2.4559779167f+00 #= 0x401d2ebe =#
# const v2f  =  2.1284897327f+00 #= 0x4008392d =#
# const v3f  =  7.6928514242f-01 #= 0x3f44efdf =#
# const v4f  =  1.0422264785f-01 #= 0x3dd572af =#
# const v5f  =  3.2170924824f-03 #= 0x3b52d5db =#
# const s0f  = -7.7215664089f-02 #= 0xbd9e233f =#
# const s1f  =  2.1498242021f-01 #= 0x3e5c245a =#
# const s2f  =  3.2577878237f-01 #= 0x3ea6cc7a =#
# const s3f  =  1.4635047317f-01 #= 0x3e15dce6 =#
# const s4f  =  2.6642270386f-02 #= 0x3cda40e4 =#
# const s5f  =  1.8402845599f-03 #= 0x3af135b4 =#
# const s6f  =  3.1947532989f-05 #= 0x3805ff67 =#
# const r1f  =  1.3920053244f+00 #= 0x3fb22d3b =#
# const r2f  =  7.2193557024f-01 #= 0x3f38d0c5 =#
# const r3f  =  1.7193385959f-01 #= 0x3e300f6e =#
# const r4f  =  1.8645919859f-02 #= 0x3c98bf54 =#
# const r5f  =  7.7794247773f-04 #= 0x3a4beed6 =#
# const r6f  =  7.3266842264f-06 #= 0x36f5d7bd =#
# const w0f  =  4.1893854737f-01 #= 0x3ed67f1d =#
# const w1f  =  8.3333335817f-02 #= 0x3daaaaab =#
# const w2f  = -2.7777778450f-03 #= 0xbb360b61 =#
# const w3f  =  7.9365057172f-04 #= 0x3a500cfd =#
# const w4f  = -5.9518753551f-04 #= 0xba1c065c =#
# const w5f  =  8.3633989561f-04 #= 0x3a5b3dd2 =#
# const w6f  = -1.6309292987f-03 #= 0xbad5c4e8 =#

# Matches OpenLibm behavior exactly, including return of sign
function lgammaf_r(x::Float32)
    hx = reinterpret(Int32, x)

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    signgamp = 1
    isneg = hx < Int32(0)
    ix = hx & 0x7fffffff
    ix ≥ 0x7f800000 && return x * x, signgamp
    ix == 0x00000000 && return Inf32, signgamp
    if ix < 0x35000000 #= |x|<2**-21, return -log(|x|) =#
        if isneg
            signgamp = -1
            return -log(-x), signgamp
        else
            return -log(x), signgamp
        end
    end
    if isneg
        # ix ≥ 0x4b000000 && return Inf32, signgamp #= |x|>=2**23, must be -integer =#
        t = sinpi(x)
        t == 0.0f0 && return Inf32, signgamp #= -integer =#
        nadj = logπ - log(abs(t * x)) # log(π / abs(t * x))
        if t < 0.0f0; signgamp = -1; end
        x = -x
    end

    if ix < 0x40000000 #= x < 2.0 =#
        i = round(x, RoundToZero)
        f = x - i
        if f == 0.0f0 #= purge off 1; 2 handled by x < 8.0 branch =#
            return 0.0f0, signgamp
        elseif i == 1.0f0
            r = 0.0f0
            c = 1.0f0
        else
            r = -log(x)
            c = 0.0f0
        end
        if f ≥ 0.7315998f0
            y = 1.0f0 + c - x
            z = y * y
            p1 = @evalpoly(z, 7.7215664089f-2, 6.7352302372f-2, 7.3855509982f-3, 1.1927076848f-3, 2.2086278477f-4, 2.5214456400f-5)
            p2 = z * @evalpoly(z, 3.2246702909f-1, 2.0580807701f-2, 2.8905137442f-3, 5.1006977446f-4, 1.0801156895f-4, 4.4864096708f-5)
            p = muladd(p1, y, p2)
            r += muladd(y, -0.5f0, p)
        elseif f ≥ 0.23163998f0 # or, the lb? 0.2316322f0
            y = x - 0.46163213f0 - c
            z = y * y
            w = z * y
            p1 = @evalpoly(w, 4.8383611441f-1, -3.2788541168f-2, 6.1005386524f-3, -1.4034647029f-3, 3.1563205994f-4)
            p2 = @evalpoly(w, -1.4758771658f-1, 1.7970675603f-2, -3.6845202558f-3, 8.8108185446f-4, -3.1275415677f-4)
            p3 = @evalpoly(w, 6.4624942839f-2, -1.0314224288f-2, 2.2596477065f-3, -5.3859531181f-4, 3.3552918467f-4)
            p = muladd(z, p1, -muladd(w, -muladd(p3, y, p2), 6.6971006518f-9))
            r += p - 1.2148628384f-1
        else
            y = x - c
            p1 = y * @evalpoly(y, -7.7215664089f-2, 6.3282704353f-1, 1.4549225569f0, 9.7771751881f-1, 2.2896373272f-1, 1.3381091878f-2)
            p2 = @evalpoly(y, 1.0f0, 2.4559779167f0, 2.1284897327f0, 7.6928514242f-1, 1.0422264785f-1, 3.2170924824f-3)
            r += muladd(y, -0.5f0, p1 / p2)
        end
    elseif ix < 0x41000000 #= x < 8.0 =#
        i = round(x, RoundToZero)
        y = x - i
        z = 1.0f0
        p = 0.0f0
        u = x
        while u ≥ 3.0f0
            p -= 1.0f0
            u = x + p
            z *= u
        end
        p = y * @evalpoly(y, -7.7215664089f-2, 2.1498242021f-1, 3.2577878237f-1, 1.4635047317f-1, 2.6642270386f-2, 1.8402845599f-3, 3.1947532989f-5)
        q = @evalpoly(y, 1.0f0, 1.3920053244f0, 7.2193557024f-1, 1.7193385959f-1, 1.8645919859f-2, 7.7794247773f-4, 7.3266842264f-6)
	    r = log(z) + muladd(0.5f0, y, p / q)
    elseif ix < 0x5c800000 #= 8.0 ≤ x < 2^58 =#
        z = 1.0f0 / x
        y = z * z
        w = muladd(z, @evalpoly(y, 8.3333335817f-2, -2.7777778450f-3, 7.9365057172f-4, -5.9518753551f-4, 8.3633989561f-4, -1.6309292987f-3), 4.1893854737f-1)
        r = muladd(x - 0.5f0, log(x) - 1.0f0, w)
    else
        #= 2^58 ≤ x ≤ Inf =#
        r = muladd(x, log(x), -x)
    end
    if isneg
        r = nadj - r # potential source of roundoff error?
        # r = Float32(Float64(nadj) - Float64(r))
    end
    return r, signgamp
end

# Deviates from OpenLibm: throws instead of returning negative sign; approximately 25% faster
# when sign is not needed in subsequent computations.
function loggammaf_r(x::Float32)
    hx = reinterpret(Int32, x)

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    ix = hx & 0x7fffffff
    isneg = hx < Int32(0)
    ix ≥ 0x7f800000 && return x * x
    ix == 0x00000000 && return Inf32
    if ix < 0x35000000 #= |x|<2**-21, return -log(|x|) =#
        isneg && throw(DomainError(x, "`gamma(x)` must be non-negative"))
        return -log(x)
    end
    if isneg
        # ix ≥ 0x4b000000 && return Inf32, signgamp #= |x|>=2**23, must be -integer =#
        t = sinpi(x)
        t == 0.0f0 && return Inf32 #= -integer =#
        nadj = logπ - log(abs(t * x))
        t < 0.0f0 && throw(DomainError(x, "`gamma(x)` must be non-negative"))
        x = -x
    end

    if ix ≤ 0x40000000 #= for 1.0 ≤ x ≤ 2.0 =#
        i = round(x, RoundToZero)
        f = x - i
        if f == 0.0f0 #= purge off 1 and 2 =#
            return 0.0f0
        elseif i == 1.0f0
            r = 0.0f0
            c = 1.0f0
        else
            r = -log(x)
            c = 0.0f0
        end
        if f ≥ 0.7315998f0
            y = 1.0f0 + c - x
            z = y * y
            p1 = @evalpoly(z, 7.7215664089f-2, 6.7352302372f-2, 7.3855509982f-3, 1.1927076848f-3, 2.2086278477f-4, 2.5214456400f-5)
            p2 = z * @evalpoly(z, 3.2246702909f-1, 2.0580807701f-2, 2.8905137442f-3, 5.1006977446f-4, 1.0801156895f-4, 4.4864096708f-5)
            p = muladd(p1, y, p2)
            r += muladd(y, -0.5f0, p)
        elseif f ≥ 0.23163998f0 # or, the lb? 0.2316322f0
            y = x - 0.46163213f0 - c
            z = y * y
            w = z * y
            p1 = @evalpoly(w, 4.8383611441f-1, -3.2788541168f-2, 6.1005386524f-3, -1.4034647029f-3, 3.1563205994f-4)
            p2 = @evalpoly(w, -1.4758771658f-1, 1.7970675603f-2, -3.6845202558f-3, 8.8108185446f-4, -3.1275415677f-4)
            p3 = @evalpoly(w, 6.4624942839f-2, -1.0314224288f-2, 2.2596477065f-3, -5.3859531181f-4, 3.3552918467f-4)
            p = muladd(z, p1, -muladd(w, -muladd(p3, y, p2), 6.6971006518f-9))
            r += p - 1.2148628384f-1
        else
            y = x - c
            p1 = y * @evalpoly(y, -7.7215664089f-2, 6.3282704353f-1, 1.4549225569f0, 9.7771751881f-1, 2.2896373272f-1, 1.3381091878f-2)
            p2 = @evalpoly(y, 1.0f0, 2.4559779167f0, 2.1284897327f0, 7.6928514242f-1, 1.0422264785f-1, 3.2170924824f-3)
            r += muladd(y, -0.5f0, p1 / p2)
        end
    elseif ix < 0x41000000 #= x < 8.0 =#
        i = round(x, RoundToZero)
        y = x - i
        z = 1.0f0
        p = 0.0f0
        u = x
        while u ≥ 3.0f0
            p -= 1.0f0
            u = x + p
            z *= u
        end
        p = y * @evalpoly(y, -7.7215664089f-2, 2.1498242021f-1, 3.2577878237f-1, 1.4635047317f-1, 2.6642270386f-2, 1.8402845599f-3, 3.1947532989f-5)
        q = @evalpoly(y, 1.0f0, 1.3920053244f0, 7.2193557024f-1, 1.7193385959f-1, 1.8645919859f-2, 7.7794247773f-4, 7.3266842264f-6)
	    r = log(z) + muladd(0.5f0, y, p / q)
    elseif ix < 0x5c800000 #= 8.0 ≤ x < 2^58 =#
        z = 1.0f0 / x
        y = z * z
        w = muladd(z, @evalpoly(y, 8.3333335817f-2, -2.7777778450f-3, 7.9365057172f-4, -5.9518753551f-4, 8.3633989561f-4, -1.6309292987f-3), 4.1893854737f-1)
        r = muladd(x - 0.5f0, log(x) - 1.0f0, w)
    else
        #= 2^58 ≤ x ≤ Inf =#
        r = muladd(x, log(x), -x)
    end
    if isneg
        r = nadj - r
    end
    return r
end
