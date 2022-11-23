# Matches OpenLibm behavior exactly, including return of sign
function _lgamma_r(x::Float64)
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
    # if x < 8.470329472543003e-22
    #     if x < 0
    #         return -log(-x), Int32(-1)
    #     else
    #         return -log(x), Int32(-1)
    #     end
    # end
    if hx < 0
        # ix ≥ 0x43300000 && return 1.0 / 0.0, signgamp #= |x|>=2**52, must be -integer =#
        t = sinpi(x)
        t == 0.0 && return 1.0 / 0.0, signgamp #= -integer =#
        nadj = log(π / abs(t * x))
        if t < 0.0; signgamp = Int32(-1); end
        x = -x
    end

    #= purge off 1 and 2 =#
    if ((ix - 0x3ff00000) | lx) == 0 || ((ix - 0x40000000) | lx) == 0
        r = 0.0
        #= for x < 2.0 =#
    elseif ix < 0x40000000
        #= lgamma(x) = lgamma(x+1)-log(x) =#
        if ix ≤ 0x3feccccc #= 0.8999996185302734 =#
            r = -log(x)
            if ix ≥ 0x3FE76944 #= 0.7315998077392578 =#
                y = 1.0 - x
                i = Int8(0)
            elseif ix ≥ 0x3FCDA661 #= 0.2316399812698364 =#
                y = x - (tc - 1.0)
                i = Int8(1)
            else
                y = x
                i = Int8(2)
            end
        else
            r = 0.0
            if ix ≥ 0x3FFBB4C3 #= 1.7316312789916992 =# #= [1.7316,2] =#
                y = 2.0 - x
                i = Int8(0)
            elseif ix ≥ 0x3FF3B4C4 #= 1.2316322326660156 =# #= [1.23,1.73] =#
                y = x - tc
                i = Int8(1)
            else
                y = x - 1.0
                i = Int8(2)
            end
        end
        if i == Int8(0)
            z = y*y;
		    p1 = a0+z*(a2+z*(a4+z*(a6+z*(a8+z*a10))));
		    p2 = z*(a1+z*(a3+z*(a5+z*(a7+z*(a9+z*a11)))));
		    p  = y*p1+p2;
		    r  += (p-0.5*y);
        elseif i == Int8(1)
            z = y*y;
		    w = z*y;
		    p1 = t0+w*(t3+w*(t6+w*(t9 +w*t12)));	#= parallel comp =#
		    p2 = t1+w*(t4+w*(t7+w*(t10+w*t13)));
		    p3 = t2+w*(t5+w*(t8+w*(t11+w*t14)));
		    p  = z*p1-(tt-w*(p2+y*p3));
		    r += (tf + p)
        elseif i == Int8(2)
            p1 = y*(u0+y*(u1+y*(u2+y*(u3+y*(u4+y*u5)))));
		    p2 = 1.0+y*(v1+y*(v2+y*(v3+y*(v4+y*v5))));
		    r += (-0.5*y + p1/p2);
        end
    elseif ix < 0x40200000                #= x < 8.0 =#
        i = Base.unsafe_trunc(Int8, x)
        y = x - float(i)
        # If performed here, performance is 2x worse; hence, move it below.
        # p = y*(s0+y*(s1+y*(s2+y*(s3+y*(s4+y*(s5+y*s6))))));
	    # q = 1.0+y*(r1+y*(r2+y*(r3+y*(r4+y*(r5+y*r6)))));
	    # r = 0.5*y+p/q;
	    z = 1.0;	#= lgamma(1+s) = log(s) + lgamma(s) =#
        if i == Int8(7)
            z *= (y + 6.0)
            @goto case6
        elseif i == Int8(6)
            @label case6
            z *= (y + 5.0)
            @goto case5
        elseif i == Int8(5)
            @label case5
            z *= (y + 4.0)
            @goto case4
        elseif i == Int8(4)
            @label case4
            z *= (y + 3.0)
            @goto case3
        elseif i == Int8(3)
            @label case3
            z *= (y + 2.0)
        end
        # r += log(z)
        p = y*(s0+y*(s1+y*(s2+y*(s3+y*(s4+y*(s5+y*s6))))));
        q = 1.0+y*(r1+y*(r2+y*(r3+y*(r4+y*(r5+y*r6)))));
        r = log(z) + 0.5*y+p/q;
        #= 8.0 ≤ x < 2^58 =#
    elseif ix < 0x43900000
        z = 1.0 / x
        y = z * z
        w = muladd(z, evalpoly(y, (8.33333333333329678849e-2, -2.77777777728775536470e-3, 7.93650558643019558500e-4, -5.95187557450339963135e-4, 8.36339918996282139126e-4, -1.63092934096575273989e-3)), 4.18938533204672725052e-1)
	    r = muladd(x - 0.5, log(x) - 1.0, w)
    else
        #= 2^58 ≤ x ≤ Inf =#
        r = x * (log(x) - 1.0)
    end
    if hx < 0
        r = nadj - r
    end
    return r, signgamp
end
