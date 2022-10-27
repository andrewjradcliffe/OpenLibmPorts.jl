module OpenLibmPorts

# Write your package code here.

include("e_lgamma_r.jl")
include("e_lgammaf_r.jl")

export lgamma

lgamma(x::Number) = lgamma(float(x))
lgamma(x::Float64) = lgamma_r(x)
lgamma(x::Float32) = lgammaf_r(x)
lgamma(x::Float16) = Float16(lgammaf_r(Float32(x)))

# TODO fix this interface, or handle within lgamma itself.
loggamma(x::Number) = loggamma(float(x))
function loggamma(x::Float64)
    u = reinterpret(UInt64, x)
    hx = signed((u >>> 32) % UInt32)
    ix = signed(hx & 0x7fffffff)
    hx < 0 && (ix < 0x3b900000 || ix ≥ 0x43300000) && throw(DomainError(x, "`gamma(x)` must be non-negative"))
    lgamma(x)
end
function loggamma(x::Float32)
    hx = reinterpret(Int32, x)
    ix = signed(hx & 0x7fffffff)
    hx < 0 && (ix < 0x35000000 || ix ≥ 0x4b000000) && throw(DomainError(x, "`gamma(x)` must be non-negative"))
    lgamma(x)
end
loggamma(x::Float16) = Float16(loggamma(Float32(x)))

end
