#=
/* @(#)e_lgamma_r.c 1.3 95/01/18 */
/*
* ====================================================
* Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
*
* Developed at SunSoft, a Sun Microsystems, Inc. business.
* Permission to use, copy, modify, and distribute this
* software is freely granted, provided that this notice
* is preserved.
* ====================================================
*
*/
=#

#=

/* __ieee754_lgamma_r(x, signgamp)
 * Reentrant version of the logarithm of the Gamma function
 * with user provide pointer for the sign of Gamma(x).
 *
 * Method:
 *   1. Argument Reduction for 0 < x <= 8
 * 	Since gamma(1+s)=s*gamma(s), for x in [0,8], we may
 * 	reduce x to a number in [1.5,2.5] by
 * 		lgamma(1+s) = log(s) + lgamma(s)
 *	for example,
 *		lgamma(7.3) = log(6.3) + lgamma(6.3)
 *			    = log(6.3*5.3) + lgamma(5.3)
 *			    = log(6.3*5.3*4.3*3.3*2.3) + lgamma(2.3)
 *   2. Polynomial approximation of lgamma around its
 *	minimun ymin=1.461632144968362245 to maintain monotonicity.
 *	On [ymin-0.23, ymin+0.27] (i.e., [1.23164,1.73163]), use
 *		Let z = x-ymin;
 *		lgamma(x) = -1.214862905358496078218 + z^2*poly(z)
 *	where
 *		poly(z) is a 14 degree polynomial.
 *   2. Rational approximation in the primary interval [2,3]
 *	We use the following approximation:
 *		s = x-2.0;
 *		lgamma(x) = 0.5*s + s*P(s)/Q(s)
 *	with accuracy
 *		|P/Q - (lgamma(x)-0.5s)| < 2**-61.71
 *	Our algorithms are based on the following observation
 *
 *                             zeta(2)-1    2    zeta(3)-1    3
 * lgamma(2+s) = s*(1-Euler) + --------- * s  -  --------- * s  + ...
 *                                 2                 3
 *
 *	where Euler = 0.5771... is the Euler constant, which is very
 *	close to 0.5.
 *
 *   3. For x>=8, we have
 *	lgamma(x)~(x-0.5)log(x)-x+0.5*log(2pi)+1/(12x)-1/(360x**3)+....
 *	(better formula:
 *	   lgamma(x)~(x-0.5)*(log(x)-1)-.5*(log(2pi)-1) + ...)
 *	Let z = 1/x, then we approximation
 *		f(z) = lgamma(x) - (x-0.5)(log(x)-1)
 *	by
 *	  			    3       5             11
 *		w = w0 + w1*z + w2*z  + w3*z  + ... + w6*z
 *	where
 *		|w - f(z)| < 2**-58.74
 *
 *   4. For negative x, since (G is gamma function)
 *		-x*G(-x)*G(x) = pi/sin(pi*x),
 * 	we have
 * 		G(x) = pi/(sin(pi*x)*(-x)*G(-x))
 *	since G(-x) is positive, sign(G(x)) = sign(sin(pi*x)) for x<0
 *	Hence, for x<0, signgam = sign(sin(pi*x)) and
 *		lgamma(x) = log(|Gamma(x)|)
 *			  = log(pi/(|x*sin(pi*x)|)) - lgamma(-x);
 *	Note: one should avoid compute pi*(-x) directly in the
 *	      computation of sin(pi*(-x)).
 *
 *   5. Special Cases
 *		lgamma(2+s) ~ s*(1-Euler) for tiny s
 *		lgamma(1) = lgamma(2) = 0
 *		lgamma(x) ~ -log(|x|) for tiny x
 *		lgamma(0) = lgamma(neg.integer) = inf and raise divide-by-zero
 *		lgamma(inf) = inf
 *		lgamma(-inf) = inf (bug for bug compatible with C99!?)
 *
 */

=#

# const a0  =  7.72156649015328655494e-02 #= 0x3FB3C467, 0xE37DB0C8 =#
# const a1  =  3.22467033424113591611e-01 #= 0x3FD4A34C, 0xC4A60FAD =#
# const a2  =  6.73523010531292681824e-02 #= 0x3FB13E00, 0x1A5562A7 =#
# const a3  =  2.05808084325167332806e-02 #= 0x3F951322, 0xAC92547B =#
# const a4  =  7.38555086081402883957e-03 #= 0x3F7E404F, 0xB68FEFE8 =#
# const a5  =  2.89051383673415629091e-03 #= 0x3F67ADD8, 0xCCB7926B =#
# const a6  =  1.19270763183362067845e-03 #= 0x3F538A94, 0x116F3F5D =#
# const a7  =  5.10069792153511336608e-04 #= 0x3F40B6C6, 0x89B99C00 =#
# const a8  =  2.20862790713908385557e-04 #= 0x3F2CF2EC, 0xED10E54D =#
# const a9  =  1.08011567247583939954e-04 #= 0x3F1C5088, 0x987DFB07 =#
# const a10 =  2.52144565451257326939e-05 #= 0x3EFA7074, 0x428CFA52 =#
# const a11 =  4.48640949618915160150e-05 #= 0x3F07858E, 0x90A45837 =#
# const tc  =  1.46163214496836224576e+00 #= 0x3FF762D8, 0x6356BE3F =#
# const tf  = -1.21486290535849611461e-01 #= 0xBFBF19B9, 0xBCC38A42 =#
# #= tt = -(tail of tf) =#
# const tt  = -3.63867699703950536541e-18 #= 0xBC50C7CA, 0xA48A971F =#
# const t0  =  4.83836122723810047042e-01 #= 0x3FDEF72B, 0xC8EE38A2 =#
# const t1  = -1.47587722994593911752e-01 #= 0xBFC2E427, 0x8DC6C509 =#
# const t2  =  6.46249402391333854778e-02 #= 0x3FB08B42, 0x94D5419B =#
# const t3  = -3.27885410759859649565e-02 #= 0xBFA0C9A8, 0xDF35B713 =#
# const t4  =  1.79706750811820387126e-02 #= 0x3F9266E7, 0x970AF9EC =#
# const t5  = -1.03142241298341437450e-02 #= 0xBF851F9F, 0xBA91EC6A =#
# const t6  =  6.10053870246291332635e-03 #= 0x3F78FCE0, 0xE370E344 =#
# const t7  = -3.68452016781138256760e-03 #= 0xBF6E2EFF, 0xB3E914D7 =#
# const t8  =  2.25964780900612472250e-03 #= 0x3F6282D3, 0x2E15C915 =#
# const t9  = -1.40346469989232843813e-03 #= 0xBF56FE8E, 0xBF2D1AF1 =#
# const t10 =  8.81081882437654011382e-04 #= 0x3F4CDF0C, 0xEF61A8E9 =#
# const t11 = -5.38595305356740546715e-04 #= 0xBF41A610, 0x9C73E0EC =#
# const t12 =  3.15632070903625950361e-04 #= 0x3F34AF6D, 0x6C0EBBF7 =#
# const t13 = -3.12754168375120860518e-04 #= 0xBF347F24, 0xECC38C38 =#
# const t14 =  3.35529192635519073543e-04 #= 0x3F35FD3E, 0xE8C2D3F4 =#
# const u0  = -7.72156649015328655494e-02 #= 0xBFB3C467, 0xE37DB0C8 =#
# const u1  =  6.32827064025093366517e-01 #= 0x3FE4401E, 0x8B005DFF =#
# const u2  =  1.45492250137234768737e+00 #= 0x3FF7475C, 0xD119BD6F =#
# const u3  =  9.77717527963372745603e-01 #= 0x3FEF4976, 0x44EA8450 =#
# const u4  =  2.28963728064692451092e-01 #= 0x3FCD4EAE, 0xF6010924 =#
# const u5  =  1.33810918536787660377e-02 #= 0x3F8B678B, 0xBF2BAB09 =#
# const v1  =  2.45597793713041134822e+00 #= 0x4003A5D7, 0xC2BD619C =#
# const v2  =  2.12848976379893395361e+00 #= 0x40010725, 0xA42B18F5 =#
# const v3  =  7.69285150456672783825e-01 #= 0x3FE89DFB, 0xE45050AF =#
# const v4  =  1.04222645593369134254e-01 #= 0x3FBAAE55, 0xD6537C88 =#
# const v5  =  3.21709242282423911810e-03 #= 0x3F6A5ABB, 0x57D0CF61 =#
# const s0  = -7.72156649015328655494e-02 #= 0xBFB3C467, 0xE37DB0C8 =#
# const s1  =  2.14982415960608852501e-01 #= 0x3FCB848B, 0x36E20878 =#
# const s2  =  3.25778796408930981787e-01 #= 0x3FD4D98F, 0x4F139F59 =#
# const s3  =  1.46350472652464452805e-01 #= 0x3FC2BB9C, 0xBEE5F2F7 =#
# const s4  =  2.66422703033638609560e-02 #= 0x3F9B481C, 0x7E939961 =#
# const s5  =  1.84028451407337715652e-03 #= 0x3F5E26B6, 0x7368F239 =#
# const s6  =  3.19475326584100867617e-05 #= 0x3F00BFEC, 0xDD17E945 =#
# const r1  =  1.39200533467621045958e+00 #= 0x3FF645A7, 0x62C4AB74 =#
# const r2  =  7.21935547567138069525e-01 #= 0x3FE71A18, 0x93D3DCDC =#
# const r3  =  1.71933865632803078993e-01 #= 0x3FC601ED, 0xCCFBDF27 =#
# const r4  =  1.86459191715652901344e-02 #= 0x3F9317EA, 0x742ED475 =#
# const r5  =  7.77942496381893596434e-04 #= 0x3F497DDA, 0xCA41A95B =#
# const r6  =  7.32668430744625636189e-06 #= 0x3EDEBAF7, 0xA5B38140 =#
# const w0  =  4.18938533204672725052e-01 #= 0x3FDACFE3, 0x90C97D69 =#
# const w1  =  8.33333333333329678849e-02 #= 0x3FB55555, 0x5555553B =#
# const w2  = -2.77777777728775536470e-03 #= 0xBF66C16C, 0x16B02E5C =#
# const w3  =  7.93650558643019558500e-04 #= 0x3F4A019F, 0x98CF38B6 =#
# const w4  = -5.95187557450339963135e-04 #= 0xBF4380CB, 0x8C0FE741 =#
# const w5  =  8.36339918996282139126e-04 #= 0x3F4B67BA, 0x4CDAD5D1 =#
# const w6  = -1.63092934096575273989e-03 #= 0xBF5AB89D, 0x0B9E43E4 =#

# Matches OpenLibm behavior exactly, including return of sign
function lgamma_r(x::Float64)
    ux = reinterpret(UInt64, x)
    hx = ux >>> 32 % Int32
    lx = ux % UInt32

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    signgamp = 1
    ix = hx & 0x7fffffff
    ix ≥ 0x7ff00000 && return x * x, signgamp
    ix | lx == 0x00000000 && return Inf, signgamp
    if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
        if hx < Int32(0)
            signgamp = -1
            return -log(-x), signgamp
        else
            return -log(x), signgamp
        end
    end
    if hx < Int32(0)
        # ix ≥ 0x43300000 && return Inf, signgamp #= |x|>=2**52, must be -integer =#
        t = sinpi(x)
        iszero(t) && return Inf, signgamp #= -integer =#
        nadj = logπ - log(abs(t * x))
        if t < 0.0; signgamp = -1; end
        x = -x
    end
    if ix ≤ 0x40000000     #= for 1.0 ≤ x ≤ 2.0 =#
        i = round(x, RoundToZero)
        f = x - i
        if f == 0.0 #= purge off 1 and 2 =#
            return 0.0, signgamp
        elseif i == 1.0
            r = 0.0
            c = 1.0
        else
            r = -log(x)
            c = 0.0
        end
        if f ≥ 0.7315998077392578
            y = 1.0 + c - x
            z = y * y
            p1 = @evalpoly(z, 7.72156649015328655494e-02, 6.73523010531292681824e-02, 7.38555086081402883957e-03, 1.19270763183362067845e-03, 2.20862790713908385557e-04, 2.52144565451257326939e-05)
            p2 = z * @evalpoly(z, 3.22467033424113591611e-01, 2.05808084325167332806e-02, 2.89051383673415629091e-03, 5.10069792153511336608e-04, 1.08011567247583939954e-04, 4.48640949618915160150e-05)
            p = muladd(p1, y, p2)
            r += muladd(y, -0.5, p)
        elseif f ≥ 0.2316399812698364 # or, the lb? 0.2316322326660156
            y = x - 0.46163214496836225 - c
            z = y * y
            w = z * y
            p1 = @evalpoly(w, 4.83836122723810047042e-01, -3.27885410759859649565e-02, 6.10053870246291332635e-03, -1.40346469989232843813e-03, 3.15632070903625950361e-04)
            p2 = @evalpoly(w, -1.47587722994593911752e-01, 1.79706750811820387126e-02, -3.68452016781138256760e-03, 8.81081882437654011382e-04, -3.12754168375120860518e-04)
            p3 = @evalpoly(w, 6.46249402391333854778e-02, -1.03142241298341437450e-02, 2.25964780900612472250e-03, -5.38595305356740546715e-04, 3.35529192635519073543e-04)
            p = muladd(z, p1, -muladd(w, -muladd(p3, y, p2), -3.63867699703950536541e-18))
            r += p - 1.21486290535849611461e-1
        else
            y = x - c
            p1 = y * @evalpoly(y, -7.72156649015328655494e-02, 6.32827064025093366517e-01, 1.45492250137234768737, 9.77717527963372745603e-01, 2.28963728064692451092e-01, 1.33810918536787660377e-02)
            p2 = @evalpoly(y, 1.0, 2.45597793713041134822, 2.12848976379893395361, 7.69285150456672783825e-01, 1.04222645593369134254e-01, 3.21709242282423911810e-03)
		    r += muladd(y, -0.5, p1 / p2)
        end
    elseif ix < 0x40200000              #= x < 8.0 =#
        i = round(x, RoundToZero)
        y = x - i
	    z = 1.0
        p = 0.0
        u = x
        while u ≥ 3.0
            p -= 1.0
            u = x + p
            z *= u
        end
        p = y * @evalpoly(y, -7.72156649015328655494e-2, 2.14982415960608852501e-1, 3.25778796408930981787e-1, 1.46350472652464452805e-1, 2.66422703033638609560e-2, 1.84028451407337715652e-3, 3.19475326584100867617e-5)
        q = @evalpoly(y, 1.0, 1.39200533467621045958, 7.21935547567138069525e-1, 1.71933865632803078993e-1, 1.86459191715652901344e-2, 7.77942496381893596434e-4, 7.32668430744625636189e-6)
        r = log(z) + muladd(0.5, y, p / q)
    elseif ix < 0x43900000              #= 8.0 ≤ x < 2^58 =#
        z = 1.0 / x
        y = z * z
        w = muladd(z, @evalpoly(y, 8.33333333333329678849e-2, -2.77777777728775536470e-3, 7.93650558643019558500e-4, -5.95187557450339963135e-4, 8.36339918996282139126e-4, -1.63092934096575273989e-3), 4.18938533204672725052e-1)
	    r = muladd(x - 0.5, log(x) - 1.0, w)
    else #= 2^58 ≤ x ≤ Inf =#
        r = muladd(x, log(x), -x)
    end
    if hx < Int32(0)
        r = nadj - r
    end
    return r, signgamp
end

# Deviates from OpenLibm: throws instead of returning negative sign; approximately 25% faster
# when sign is not needed in subsequent computations.

function loggamma_r(x::Float64)
    ux = reinterpret(UInt64, x)
    hx = ux >>> 32 % Int32
    lx = ux % UInt32

    #= purge off +-inf, NaN, +-0, tiny and negative arguments =#
    ix = hx & 0x7fffffff
    ix ≥ 0x7ff00000 && return x * x
    ix | lx == 0x00000000 && return Inf
    if ix < 0x3b900000 #= |x|<2**-70, return -log(|x|) =#
        hx < Int32(0) && throw(DomainError(x, "`gamma(x)` must be non-negative"))
        return -log(x)
    end
    if hx < Int32(0)
        # ix ≥ 0x43300000 && return Inf #= |x|>=2**52, must be -integer =#
        t = sinpi(x)
        iszero(t) && return Inf #= -integer =#
        nadj = logπ - log(abs(t * x))
        t < 0.0 && throw(DomainError(x, "`gamma(x)` must be non-negative"))
        x = -x
    end
    if ix ≤ 0x40000000     #= for x < 2.0 =#
        i = round(x, RoundToZero)
        f = x - i
        if f == 0.0
            return 0.0
        elseif i == 1.0
            r = 0.0
            c = 1.0
        else
            r = -log(x)
            c = 0.0
        end
        if f ≥ 0.7315998077392578
            y = 1.0 + c - x
            z = y * y
            p1 = @evalpoly(z, 7.72156649015328655494e-02, 6.73523010531292681824e-02, 7.38555086081402883957e-03, 1.19270763183362067845e-03, 2.20862790713908385557e-04, 2.52144565451257326939e-05)
            p2 = z * @evalpoly(z, 3.22467033424113591611e-01, 2.05808084325167332806e-02, 2.89051383673415629091e-03, 5.10069792153511336608e-04, 1.08011567247583939954e-04, 4.48640949618915160150e-05)
            p = muladd(p1, y, p2)
            r += muladd(y, -0.5, p)
        elseif f ≥ 0.2316399812698364 # or, the lb? 0.2316322326660156
            y = x - 0.46163214496836225 - c
            z = y * y
            w = z * y
            p1 = @evalpoly(w, 4.83836122723810047042e-01, -3.27885410759859649565e-02, 6.10053870246291332635e-03, -1.40346469989232843813e-03, 3.15632070903625950361e-04)
            p2 = @evalpoly(w, -1.47587722994593911752e-01, 1.79706750811820387126e-02, -3.68452016781138256760e-03, 8.81081882437654011382e-04, -3.12754168375120860518e-04)
            p3 = @evalpoly(w, 6.46249402391333854778e-02, -1.03142241298341437450e-02, 2.25964780900612472250e-03, -5.38595305356740546715e-04, 3.35529192635519073543e-04)
            p = muladd(z, p1, -muladd(w, -muladd(p3, y, p2), -3.63867699703950536541e-18))
            r += p - 1.21486290535849611461e-1
        else
            y = x - c
            p1 = y * @evalpoly(y, -7.72156649015328655494e-02, 6.32827064025093366517e-01, 1.45492250137234768737, 9.77717527963372745603e-01, 2.28963728064692451092e-01, 1.33810918536787660377e-02)
            p2 = @evalpoly(y, 1.0, 2.45597793713041134822, 2.12848976379893395361, 7.69285150456672783825e-01, 1.04222645593369134254e-01, 3.21709242282423911810e-03)
		    r += muladd(y, -0.5, p1 / p2)
        end
    elseif ix < 0x40200000              #= x < 8.0 =#
        i = round(x, RoundToZero)
        y = x - i
	    z = 1.0
        p = 0.0
        u = x
        while u ≥ 3.0
            p -= 1.0
            u = x + p
            z *= u
        end
        p = y * @evalpoly(y, -7.72156649015328655494e-2, 2.14982415960608852501e-1, 3.25778796408930981787e-1, 1.46350472652464452805e-1, 2.66422703033638609560e-2, 1.84028451407337715652e-3, 3.19475326584100867617e-5)
        q = @evalpoly(y, 1.0, 1.39200533467621045958, 7.21935547567138069525e-1, 1.71933865632803078993e-1, 1.86459191715652901344e-2, 7.77942496381893596434e-4, 7.32668430744625636189e-6)
        r = log(z) + muladd(0.5, y, p / q)
    elseif ix < 0x43900000              #= 8.0 ≤ x < 2^58 =#
        z = 1.0 / x
        y = z * z
        w = muladd(z, @evalpoly(y, 8.33333333333329678849e-2, -2.77777777728775536470e-3, 7.93650558643019558500e-4, -5.95187557450339963135e-4, 8.36339918996282139126e-4, -1.63092934096575273989e-3), 4.18938533204672725052e-1)
	    r = muladd(x - 0.5, log(x) - 1.0, w)
    else #= 2^58 ≤ x ≤ Inf =#
        r = muladd(x, log(x), -x)
    end
    if hx < Int32(0)
        r = nadj - r
    end
    return r
end
