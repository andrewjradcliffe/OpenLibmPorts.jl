module OpenLibmPorts

# Write your package code here.

export lgamma

lgamma(x::Number) = lgamma(float(x))
lgamma(x::Float64) = lgamma_r(x)
lgamma(x::Float32) = lgammaf_r(x)
lgamma(x::Float16) = Float16(lgammaf_r(Float32(x)))


end
