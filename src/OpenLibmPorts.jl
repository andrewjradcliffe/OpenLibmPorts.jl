module OpenLibmPorts

# Write your package code here.

include("e_lgamma_r.jl")
include("e_lgammaf_r.jl")

# Matches behavior of SpecialFunctions' loggamma, but is ≈ 25% faster since the
# negative sign is not returned, but rather, a DomainError is thrown.
loggamma(x::Number) = loggamma(float(x))
loggamma(x::Float64) = loggamma_r(x)
loggamma(x::Float32) = loggammaf_r(x)
loggamma(x::Float16) = Float16(loggammaf_r(Float32(x)))


# Matches behavior of SpecialFunctions' logabsgamma
_logabsgamma(x::Float64) = lgamma_r(x)
function _logabsgamma(x::Float32)
    y, s = lgammaf_r(x)
    y, Int(s)
end
function _logabsgamma(x::Float16)
    y, s = lgammaf_r(Float32(x))
    Float16(y), s
end

logabsgamma(x::Number) = logabsgamma(float(x))
logabsgamma(x::Base.IEEEFloat) = _logabsgamma(x)

end
